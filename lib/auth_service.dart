import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_firebase.dart';

class AuthService {
  AuthService._();

  static bool _googleInitialized = false;
  static Future<void>? _googleInitialization;

  // Isi dengan Web Client ID dari Firebase/GCP jika google-services.json
  // belum berisi oauth_client client_type 3.
  static const String? webClientId = null;

  static User? get currentUser {
    if (!AppFirebase.isInitialized) {
      return null;
    }

    return FirebaseAuth.instance.currentUser;
  }

  static Stream<User?> authStateChanges() {
    return Stream.fromFuture(AppFirebase.ensureInitialized()).asyncExpand((_) {
      return FirebaseAuth.instance.authStateChanges();
    });
  }

  static Future<void> initializeGoogleSignIn() async {
    if (_googleInitialized || kIsWeb) {
      return;
    }

    if (_isDesktop) {
      return;
    }

    _googleInitialization ??= _initializeGoogleSignInInstance();

    await _googleInitialization;
  }

  static Future<void> _initializeGoogleSignInInstance() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
    );
    _googleInitialized = true;
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await AppFirebase.ensureInitialized();

    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await AppFirebase.ensureInitialized();

    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);
    return credential;
  }

  static Future<UserCredential> signInWithGoogle() async {
    if (!kIsWeb && _isDesktop) {
      throw FirebaseAuthException(
        code: 'google-sign-in-unsupported',
        message: 'Google Sign-In belum didukung di platform ini.',
      );
    }

    await AppFirebase.ensureInitialized();

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return FirebaseAuth.instance.signInWithPopup(provider);
    }

    try {
      await initializeGoogleSignIn();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw FirebaseAuthException(
          code: 'google-sign-in-unsupported',
          message: 'Google Sign-In belum tersedia di perangkat ini.',
        );
      }

      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;

      if (auth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-token',
          message: 'Token Google tidak ditemukan.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      return FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      debugPrint('Google Sign-In failed: $error');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await AppFirebase.ensureInitialized();
    await FirebaseAuth.instance.signOut();

    if (!kIsWeb && _googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }
  }

  static Future<void> sendPasswordReset(String email) async {
    await AppFirebase.ensureInitialized();

    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> updatePassword(String newPassword) async {
    await AppFirebase.ensureInitialized();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Pengguna belum masuk.',
      );
    }
    await user.updatePassword(newPassword);
  }

  static Future<void> updateProfile({required String displayName}) async {
    await AppFirebase.ensureInitialized();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Pengguna belum masuk.',
      );
    }
    await user.updateDisplayName(displayName);
  }

  static String readableAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Format email belum benar.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau password belum sesuai.';
        case 'email-already-in-use':
          return 'Email ini sudah terdaftar.';
        case 'weak-password':
          return 'Password minimal 6 karakter.';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah.';
        case 'google-sign-in-unsupported':
          return error.message ?? 'Google Sign-In belum didukung.';
        case 'missing-google-token':
          return 'Token Google tidak ditemukan. Coba login ulang.';
        case 'popup-closed-by-user':
        case 'canceled':
          return 'Login Google dibatalkan.';
        default:
          return error.message ?? 'Autentikasi gagal.';
      }
    }

    if (error is FirebaseException) {
      return error.message ?? 'Firebase belum siap. Coba lagi.';
    }

    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          return 'Login Google dibatalkan.';
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          return 'Google Sign-In belum terkonfigurasi. Tambahkan SHA-1/SHA-256 di Firebase Console, aktifkan provider Google, lalu unduh ulang google-services.json.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google Sign-In belum bisa dibuka di perangkat ini.';
        default:
          return error.description ?? 'Login Google gagal.';
      }
    }

    return 'Terjadi kesalahan. Coba lagi.';
  }

  static bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;
}
