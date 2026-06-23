import 'package:flutter/material.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const control = '/control';
  static const profile = '/profile';
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _routes = [
    AppRoutes.dashboard,
    AppRoutes.control,
    AppRoutes.profile,
  ];

  void _openPage(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: 'Dashboard',
                onPressed: () => _openPage(context, 0),
                icon: Icon(
                  Icons.home,
                  size: 32,
                  color: currentIndex == 0 ? const Color(0xFF00D100) : Colors.grey,
                ),
              ),
              const SizedBox(width: 50), // Space for center button
              IconButton(
                tooltip: 'Profile',
                onPressed: () => _openPage(context, 2),
                icon: Icon(
                  Icons.person,
                  size: 32,
                  color: currentIndex == 2 ? const Color(0xFF00D100) : const Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
          Positioned(
            top: -25,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => _openPage(context, 1),
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFF004D1A), // Dark green
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.present_to_all_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
