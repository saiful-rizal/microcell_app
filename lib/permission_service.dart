import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// PermissionService — mengelola semua permission runtime yang dibutuhkan
/// sistem Microcell App saat dijalankan di perangkat Android.
class PermissionService {
  PermissionService._();

  // ─── Local Notifications ─────────────────────────────────────────────
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static bool _notifInitialized = false;

  /// Inisialisasi plugin notifikasi lokal.
  /// Panggil sekali di main() sebelum runApp().
  static Future<void> initLocalNotifications() async {
    if (_notifInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Buat notification channel Android
    if (!kIsWeb && Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'microcell_alerts',
        'Microcell Alerts',
        description: 'Notifikasi peringatan sensor dan status perangkat Microcell.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _notifInitialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Bisa ditambahkan navigasi ke halaman notifikasi di sini
    debugPrint('[PermissionService] Notification tapped: ${response.payload}');
  }

  // ─── Request Semua Permission Sistem ────────────────────────────────
  /// Minta semua permission yang dibutuhkan sistem saat app pertama kali dibuka.
  /// Mengembalikan true jika notifikasi diizinkan (permission kritis).
  static Future<bool> requestAllPermissions() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return true;

    final results = <Permission, PermissionStatus>{};

    if (!kIsWeb && Platform.isAndroid) {
      // Permission notifikasi (wajib Android 13+)
      results[Permission.notification] =
          await Permission.notification.request();

      // Exact alarm untuk alert sensor terjadwal
      // (hanya minta jika belum granted, tidak crash di API < 31)
      try {
        final exactAlarm = await Permission.scheduleExactAlarm.status;
        if (!exactAlarm.isGranted) {
          results[Permission.scheduleExactAlarm] =
              await Permission.scheduleExactAlarm.request();
        }
      } catch (_) {
        // scheduleExactAlarm tidak tersedia di API < 31, abaikan
      }
    }

    if (!kIsWeb && Platform.isIOS) {
      results[Permission.notification] =
          await Permission.notification.request();
    }

    // Log hasil
    for (final entry in results.entries) {
      debugPrint(
        '[PermissionService] ${entry.key.toString()} → ${entry.value}',
      );
    }

    // Return true jika notifikasi diizinkan
    final notifStatus = results[Permission.notification];
    return notifStatus == null || notifStatus.isGranted;
  }

  /// Cek apakah permission notifikasi sudah diberikan.
  static Future<bool> isNotificationGranted() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return true;
    return (await Permission.notification.status).isGranted;
  }

  // ─── Kirim Notifikasi Lokal ──────────────────────────────────────────
  static int _notifId = 0;

  /// Tampilkan notifikasi lokal (untuk alert sensor kritis).
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotifType type = NotifType.info,
  }) async {
    if (!_notifInitialized) await initLocalNotifications();

    final androidDetails = AndroidNotificationDetails(
      'microcell_alerts',
      'Microcell Alerts',
      channelDescription:
          'Notifikasi peringatan sensor dan status perangkat Microcell.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: _typeColor(type),
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotif.show(
      _notifId++,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Color _typeColor(NotifType type) {
    switch (type) {
      case NotifType.danger:
        return const Color(0xFFDC2626);
      case NotifType.warning:
        return const Color(0xFFF59E0B);
      case NotifType.success:
        return const Color(0xFF16A34A);
      case NotifType.info:
        return const Color(0xFF0284C7);
    }
  }
}

/// Jenis notifikasi — sesuai dengan tipe yang ada di sistem Microcell.
enum NotifType { info, warning, danger, success }
