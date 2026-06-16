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
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: 'Dashboard',
            onPressed: () => _openPage(context, 0),
            icon: Icon(
              Icons.home,
              color: currentIndex == 0 ? const Color(0xFF8BCF00) : Colors.grey,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => _openPage(context, 1),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: currentIndex == 1
                    ? const Color(0xFF006400)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.power_settings_new,
                color: currentIndex == 1 ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => _openPage(context, 2),
            icon: Icon(
              Icons.person,
              color: currentIndex == 2 ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
