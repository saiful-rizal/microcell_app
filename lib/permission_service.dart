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
      