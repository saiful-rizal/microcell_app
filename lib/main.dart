import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'control.dart';
import 'dashboard_screen.dart';
import 'firebase_options.dart';
import 'firebase_service.dart';
import 'login_screen.dart';
import 'navigation.dart';
import 'profile.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.initializeGoogleSignIn();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.control: (context) => const RelayControlScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
      },
    );
  }
}
