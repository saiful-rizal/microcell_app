import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'navigation.dart';

/// Fungsi-fungsi untuk halaman Login (login_screen.dart)
class LoginPageFunctions {
  LoginPageFunctions._();

  /// Login dengan email & password
  /// - [email]: email pengguna
  /// - [password]: password pengguna
  /// Returns: UserCredential jika berhasil
  /// Throws: FirebaseAuthException jika gagal
  static Future<UserCredential> loginEmail({
    required String email,
    required String password,
  }) async {
    return AuthService.signInWithEmail(email: email, password: password);
  }

  /// Registrasi akun baru dengan email & password
  /// - [name]: nama lengkap pengguna
  /// - [email]: email pengguna
  /// - [password]: password (min 6 karakter)
  /// Returns: UserCredential jika berhasil
  static Future<UserCredential> registerEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthService.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }

  /// Login dengan Google Sign-In
  /// Returns: UserCredential jika berhasil
  /// Throws: FirebaseAuthException jika gagal / tidak didukung platform
  static Future<UserCredential> loginGoogle() async {
    return AuthService.signInWithGoogle();
  }

  /// Kirim email reset password
  /// - [email]: email terdaftar pengguna
  static Future<void> sendPasswordReset(String email) async {
    return AuthService.sendPasswordReset(email);
  }

  /// Validasi input form login/register
  /// Returns: error message (null jika valid)
  static String? validateForm({
    required bool isRegister,
    required String name,
    required String email,
    required String password,
  }) {
    if (isRegister && name.trim().isEmpty) {
      return 'Masukkan nama lengkap';
    }
    if (email.trim().isEmpty) {
      return 'Masukkan email';
    }
    if (password.trim().isEmpty) {
      return 'Masukkan password';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Jalankan aksi autentikasi dengan loading & error handling
  /// - [context]: BuildContext untuk navigasi & SnackBar
  /// - [action]: fungsi async yang melakukan auth (login/register/google)
  /// - [onSuccess]: callback saat berhasil (default: navigate to dashboard)
  static Future<void> runAuthAction({
    required BuildContext context,
    required Future<void> Function() action,
    VoidCallback? onSuccess,
  }) async {
    // Loading state dikelola oleh caller (stateful widget)
    try {
      await action();

      if (!context.mounted) return;

      onSuccess?.call() ?? navigateToDashboard(context);
    } catch (error) {
      if (!context.mounted) return;
      showErrorSnackBar(context, AuthService.readableAuthError(error));
    }
  }

  /// Navigasi ke dashboard setelah login berhasil
  static void navigateToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  /// Tampilkan SnackBar error standar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// Tampilkan SnackBar sukses standar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}