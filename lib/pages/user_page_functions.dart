import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'navigation.dart';
import 'firebase_service.dart';

/// Fungsi-fungsi untuk halaman User/Profile (profile.dart)
class UserPageFunctions {
  UserPageFunctions._();

  /// Dapatkan user saat ini
  static User? get currentUser => AuthService.currentUser;

  /// Stream perubahan status auth (login/logout)
  static Stream<User?> get authStateChanges => AuthService.authStateChanges();

  /// Update nama tampilan (display name)
  /// - [displayName]: nama baru
  static Future<void> updateDisplayName(String displayName) async {
    return AuthService.updateProfile(displayName: displayName);
  }

  /// Ganti password
  /// - [newPassword]: password baru (min 6 karakter)
  static Future<void> changePassword(String newPassword) async {
    return AuthService.updatePassword(newPassword);
  }

  /// Kirim email reset password
  static Future<void> sendPasswordResetEmail(String email) async {
    return AuthService.sendPasswordReset(email);
  }

  /// Logout dari aplikasi
  static Future<void> logout() async {
    return AuthService.signOut();
  }

  /// Navigasi ke login setelah logout
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  /// Hapus akun pengguna (permanent)
  /// Perlu re-authentication terlebih dahulu
  static Future<void> deleteAccount() async {
    final user = AuthService.currentUser;
    if (user != null) {
      await user.delete();
      // Hapus data user dari Firestore jika ada
      await FirebaseService.deleteUserData(user.uid);
    }
  }

  /// Re-authentication untuk operasi sensitif (ganti password, hapus akun)
  /// - [email]: email user
  /// - [password]: password saat ini
  /// Returns: true jika berhasil
  static Future<bool> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await AuthService.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('Re-authentication gagal: $e');
      return false;
    }
  }

  /// Validasi input profil
  static String? validateProfile({
    required String displayName,
  }) {
    if (displayName.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (displayName.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (displayName.trim().length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    return null;
  }

  /// Validasi password baru
  static String? validateNewPassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    if (newPassword.isEmpty) {
      return 'Password baru tidak boleh kosong';
    }
    if (newPassword.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (newPassword != confirmPassword) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  /// Tampilkan dialog konfirmasi
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
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
            child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Tampilkan SnackBar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.redAccent,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  /// Format email untuk tampilan (masking)
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  /// Dapatkan inisial nama untuk avatar
  static String getInitials(String? displayName, String? email) {
    final name = displayName?.trim() ?? email?.split('@').first ?? 'User';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Warna avatar berdasarkan nama (consistent)
  static Color getAvatarColor(String name) {
    final colors = [
      const Color(0xFF12A73B),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
      const Color(0xFFF44336),
      const Color(0xFF00BCD4),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
    ];
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}