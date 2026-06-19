import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notification = false;
  bool isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      initialData: AuthService.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!.trim()
            : 'Pengguna Microcell';
        final email = user?.email ?? 'Belum ada email';

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.dashboard,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildAvatar(user?.photoURL),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Akun pengguna aktif',
                    onTap: () {},
                  ),
                  _buildSwitchMenu(),
                  _buildMenuItem(
                    icon: Icons.key_outlined,
                    title: 'Reset Password',
                    subtitle: 'Kirim tautan reset ke email',
                    onTap: () => _sendPasswordReset(email),
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: isSigningOut ? 'Keluar...' : 'Keluar',
                    subtitle: 'Akhiri sesi login',
                    onTap: isSigningOut ? () {} : _signOut,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
        );
      },
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    return Stack(
      children: [
        if (photoUrl != null && photoUrl.isNotEmpty)
          CircleAvatar(
            radius: 38,
            backgroundImage: NetworkImage(photoUrl),
          )
        else
          const CircleAvatar(
            radius: 38,
            backgroundColor: Color(0xFFD7ECD8),
            child: Icon(
              Icons.person,
              color: Colors.green,
              size: 40,
            ),
          ),
        Positioned(
          right: 0,
          bottom: 2,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFBFE8C1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _menuDecoration(),
      child: ListTile(
        dense: true,
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: _buildMenuIcon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchMenu() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _menuDecoration(),
      child: SwitchListTile(
        dense: true,
        contentPadding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
        secondary: _buildMenuIcon(Icons.notifications_none),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Text(
          'Peringatan status alat',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        value: notification,
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.black,
        onChanged: (value) {
          setState(() => notification = value);
        },
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFD7ECD8),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.green,
        size: 16,
      ),
    );
  }

  BoxDecoration _menuDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Future<void> _sendPasswordReset(String email) async {
    if (!email.contains('@')) {
      _showSnackBar('Email akun belum tersedia.');
      return;
    }

    try {
      await AuthService.sendPasswordReset(email);
      _showSnackBar('Link reset password dikirim ke $email.', isError: false);
    } catch (error) {
      _showSnackBar(AuthService.readableAuthError(error));
    }
  }

  Future<void> _signOut() async {
    setState(() => isSigningOut = true);

    try {
      await AuthService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        _showSnackBar('Gagal keluar. Coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => isSigningOut = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }
}
