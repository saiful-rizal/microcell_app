import 'package:flutter/material.dart';
import 'app_firebase.dart';
import 'auth_service.dart';
import 'control.dart';
import 'dashboard_screen.dart';
import 'device_data_service.dart';
import 'login_screen.dart';
import 'navigation.dart';
import 'notification_screen.dart';
import 'permission_service.dart';
import 'profile.dart';
import 'opening.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase sebelum runApp
  await AppFirebase.ensureInitialized();

  // Inisialisasi local notifications (channel Android, dll.)
  await PermissionService.initLocalNotifications();

  // Request semua permission yang dibutuhkan sistem
  await PermissionService.requestAllPermissions();

  // Pre-warm Google Sign-In di background agar tidak lambat saat user tap
  AuthService.initializeGoogleSignIn().ignore();

  // Seed data awal ke Realtime Database jika belum ada (hanya sekali)
  DeviceDataService.seedInitialData().ignore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.control: (context) => const RelayControlScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.notifications: (context) => const NotificationScreen(),
      },
    );
  }
}

/// AuthGate: menentukan apakah user sudah login atau belum.
/// - Jika sudah login → langsung ke DashboardScreen
/// - Jika belum → tampilkan OpeningScreen (splash + onboarding + login)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        // Masih loading state Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        // User sudah login → seed data jika belum ada lalu ke Dashboard
        if (snapshot.hasData && snapshot.data != null) {
          DeviceDataService.seedInitialData().ignore();
          return const DashboardScreen();
        }

        // User belum login → tampilkan opening/onboarding
        return const OpeningScreen();
      },
    );
  }
}

/// Widget loading minimalis saat menunggu status auth Firebase
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF12A73B),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
