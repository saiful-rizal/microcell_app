import 'package:flutter/material.dart';
import 'control.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'navigation.dart';
import 'profile.dart';
import 'opening.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OpeningScreen(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.control: (context) => const RelayControlScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
      },
    );
  }
}
