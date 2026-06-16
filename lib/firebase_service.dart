import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _googleInitialized = false;

  // Web Client ID dari Google Cloud Console / Firebase Console.
  // Anda dapat mengisinya secara eksplisit jika Credential Manager tidak mendeteksi dari google-services.json.
  static const String? webClientId = null;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<void> initializeGoogleSignIn() async {
    if (_googleInitialized || kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: webClientId,
      );
      _googleInitialized = true;
    } catch (e) {
      debugPrint('Google Sign-In initialization failed: $e');
    }
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);
    return credential;
  }

  static Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      return credential;
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      throw FirebaseAuthException(
        code: 'google-sign-in-unsupported',
        message: 'Google Sign-In belum didukung di platform ini.',
      );
    }

    await initializeGoogleSignIn();

    final bool supportsAuth = GoogleSignIn.instance.supportsAuthenticate();
    debugPrint('Google Sign-In supportsAuthenticate: $supportsAuth');

    try {
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
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      debugPrint('=========================================');
      debugPrint('GOOGLE SIGN-IN ERROR DIAGNOSTICS:');
      debugPrint('Detail Error: $e');
      debugPrint('Langkah Penyelesaian:');
      debugPrint('1. Daftarkan SHA-1 key debug (dari gradlew signingReport) ke Firebase Console.');
      debugPrint('2. Aktifkan provider Google di Firebase Console -> Authentication.');
      debugPrint('3. Pastikan mengunduh ulang google-services.json setelah menambahkan SHA-1.');
      debugPrint('4. Jika masih gagal, isi konstanta `webClientId` di `firebase_service.dart` dengan Web Client ID dari Firebase/GCP Console.');
      debugPrint('=========================================');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();

    if (!kIsWeb && _googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }
  }

  static Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
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
        case 'popup-closed-by-user':
        case 'canceled':
          return 'Login Google dibatalkan.';
        default:
          return error.message ?? 'Autentikasi gagal.';
      }
    }

    return 'Terjadi kesalahan. Coba lagi.';
  }
}

class DeviceDataService {
  DeviceDataService._();

  static const String devicePath = 'devices/main';

  static DatabaseReference get _deviceRef =>
      FirebaseDatabase.instance.ref(devicePath);

  static Stream<DeviceStatus> statusStream() {
    return _deviceRef.child('status').onValue.map((event) {
      return DeviceStatus.fromValue(event.snapshot.value);
    });
  }

  static Stream<Map<String, bool>> relayStream() {
    return _deviceRef.child('relays').onValue.map((event) {
      return _parseRelays(event.snapshot.value);
    });
  }

  static Future<void> setRelay(String relayKey, bool value) {
    return _deviceRef.child('relays').update({
      relayKey: value,
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Stream<String?> notificationStream() {
    return _deviceRef.child('notification').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return value['message']?.toString();
      }
      if (value is String) {
        return value;
      }
      return null;
    });
  }

  static Future<void> clearNotification() {
    return _deviceRef.child('notification').remove();
  }

  static Map<String, bool> _parseRelays(Object? value) {
    final defaults = {
      'relay1': false,
      'relay2': false,
      'relay3': true,
    };

    if (value is! Map) {
      return defaults;
    }

    return {
      'relay1': _asBool(value['relay1'], defaults['relay1']!),
      'relay2': _asBool(value['relay2'], defaults['relay2']!),
      'relay3': _asBool(value['relay3'], defaults['relay3']!),
    };
  }
}

class DeviceStatus {
  const DeviceStatus({
    required this.batteryLevel,
    required this.current,
    required this.voltage,
    required this.temperature,
    required this.humidity,
    required this.acVoltage,
    required this.lightIntensity,
    required this.weatherTemp,
    required this.weatherDescription,
    required this.location,
    required this.updatedAt,
  });

  final double batteryLevel;
  final double current;
  final double voltage;
  final double temperature;
  final double humidity;
  final double acVoltage;
  final double lightIntensity;
  final double weatherTemp;
  final String weatherDescription;
  final String location;
  final DateTime? updatedAt;

  factory DeviceStatus.defaults() {
    return const DeviceStatus(
      batteryLevel: 85,
      current: 1.2,
      voltage: 12.5,
      temperature: 15,
      humidity: 75,
      acVoltage: 220,
      lightIntensity: 570,
      weatherTemp: 35,
      weatherDescription: 'Cuaca Berawan',
      location: 'Bangsalsari, Jember',
      updatedAt: null,
    );
  }

  factory DeviceStatus.fromValue(Object? value) {
    final fallback = DeviceStatus.defaults();

    if (value is! Map) {
      return fallback;
    }

    return DeviceStatus(
      batteryLevel: _asDouble(
        _readAny(value, ['batteryLevel', 'battery', 'battery_level']),
        fallback.batteryLevel,
      ),
      current: _asDouble(
        _readAny(value, ['current', 'arus']),
        fallback.current,
      ),
      voltage: _asDouble(
        _readAny(value, ['voltage', 'tegangan']),
        fallback.voltage,
      ),
      temperature: _asDouble(
        _readAny(value, ['temperature', 'suhu']),
        fallback.temperature,
      ),
      humidity: _asDouble(
        _readAny(value, ['humidity', 'kelembapan']),
        fallback.humidity,
      ),
      acVoltage: _asDouble(
        _readAny(value, ['acVoltage', 'ac_voltage']),
        fallback.acVoltage,
      ),
      lightIntensity: _asDouble(
        _readAny(value, ['lightIntensity', 'intensity', 'lux']),
        fallback.lightIntensity,
      ),
      weatherTemp: _asDouble(
        _readAny(value, ['weatherTemp', 'weather_temp']),
        fallback.weatherTemp,
      ),
      weatherDescription:
          _readAny(value, ['weatherDescription', 'weather'])?.toString() ??
              fallback.weatherDescription,
      location: _readAny(value, ['location', 'lokasi'])?.toString() ??
          fallback.location,
      updatedAt: _asDateTime(_readAny(value, ['updatedAt', 'updated_at'])),
    );
  }

  int get batteryPercent => batteryLevel.clamp(0, 100).round();

  double get batteryFraction => batteryLevel.clamp(0, 100) / 100;
}

Object? _readAny(Map<dynamic, dynamic> source, List<String> keys) {
  for (final key in keys) {
    if (source.containsKey(key)) {
      return source[key];
    }
  }

  return null;
}

double _asDouble(Object? value, double fallback) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  }

  return fallback;
}

bool _asBool(Object? value, bool fallback) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }

  return fallback;
}

DateTime? _asDateTime(Object? value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  if (value is double) {
    return DateTime.fromMillisecondsSinceEpoch(value.round());
  }

  return null;
}
