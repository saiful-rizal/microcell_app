import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

class AppFirebase {
  AppFirebase._();

  static Future<FirebaseApp>? _initialization;

  static bool get isInitialized => Firebase.apps.isNotEmpty;

  static Future<FirebaseApp> ensureInitialized() {
    if (Firebase.apps.isNotEmpty) {
      return Future.value(Firebase.app());
    }

    return _initialization ??= Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
