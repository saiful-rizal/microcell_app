import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Fungsi utilitas bersama yang digunakan di multiple halaman
class SharedPageFunctions {
  SharedPageFunctions._();

  // ============================================
  // FORMATTING
  // ============================================

  /// Format timestamp ke string readable Indonesia
  /// - [timestamp]: DateTime, Timestamp Firestore, atau int (milliseconds)
  /// Returns: String format "dd MMM yyyy, HH:mm" (contoh: "24 Agu 2026, 14:30")
  static String formatTimestamp(dynamic timestamp) {
    DateTime? dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp);
    }
    if (dateTime == null) return '--';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format durasi (detik) ke string readable
  /// Returns: "X detik" | "X menit" | "X jam" | "X hari"
  static String formatDuration(int seconds) {
    if (seconds < 60) return '$seconds detik';
    if (seconds < 3600) return '${(seconds / 60).floor()} menit';
    if (seconds < 86400) return '${(seconds / 3600).floor()} jam';
    return '${(seconds / 86400).floor()} hari';
  }

  /// Format angka dengan pemisah ribuan
  /// Returns: "1.234" | "1.234.567"
  static String formatNumber(num value, {int decimals = 0}) {
    final str = value.toStringAsFixed(decimals);
    final parts = str.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    if (decimals > 0 && parts.length > 1) {
      return '$integerPart.${parts[1]}';
    }
    return integerPart;
  }

  /// Format ukuran file (bytes -> KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ============================================
  // UI HELPERS
  // ============================================

  /// Tampilkan SnackBar standar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.redAccent,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Tampilkan SnackBar error
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.redAccent);
  }

  /// Tampilkan SnackBar sukses
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  /// Tampilkan SnackBar info
  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.blue);
  }

  /// Tampilkan loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Memproses...',
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Tutup loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Tampilkan dialog konfirmasi
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
    Color? cancelColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: cancelColor ?? Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? const Color(0xFF12A73B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilkan bottom sheet
  static void showBottomSheet({
    required BuildContext context,
    required Widget child,
    double? height,
    bool isScrollControlled = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: child),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Validasi email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi password
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validasi nomor telepon Indonesia
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  // ============================================
  // NAVIGATION
  // ============================================

  /// Navigasi ke route dan hapus history (pushAndRemoveUntil)
  static void navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigasi ke route biasa (pushNamed)
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Kembali ke halaman sebelumnya
  static void goBack(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }

  /// Kembali ke halaman pertama (root)
  static void goToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // ============================================
  // DEBOUNCE / THROTTLE
  // ============================================

  /// Debounce function call
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    // Implementation would need a timer reference
    // This is a placeholder - actual implementation needs a Debouncer class
    Future.delayed(delay, callback);
  }

  // ============================================
  // DEVICE/SPECIFIC HELPERS
  // ============================================

  /// Parsing status string dari device
  static String parseDeviceStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
      case 'connected':
        return 'Online';
      case 'offline':
      case 'disconnected':
        return 'Offline';
      case 'error':
      case 'fault':
        return 'Error';
      default:
        return 'Unknown';
    }
  }

  /// Warna berdasarkan status device
  static Color getDeviceStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
      case 'connected':
        return const Color(0xFF12A73B);
      case 'offline':
      case 'disconnected':
        return Colors.grey;
      case 'error':
      case 'fault':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  /// Icon berdasarkan status device
  static IconData getDeviceStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'online':
      case 'connected':
        return Icons.wifi;
      case 'offline':
      case 'disconnected':
        return Icons.wifi_off;
      case 'error':
      case 'fault':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }
}