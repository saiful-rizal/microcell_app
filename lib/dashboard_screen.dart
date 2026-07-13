import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'auth_service.dart';
import 'device_data_service.dart';
import 'navigation.dart';
import 'notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceStatus>(
      stream: DeviceDataService.statusStream(),
      initialData: DeviceStatus.defaults(),
      builder: (context, snapshot) {
        final status = snapshot.data ?? DeviceStatus.defaults();

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: Stack(
            children: [
              // Top Image Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Image.asset(
                  'assets/images/cow.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Dark Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),

              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(context, status),
                      if (snapshot.hasError) _buildErrorNotice(),
                      const SizedBox(height: 35),
                      _buildBatteryPanel(status),
                      const SizedBox(height: 45),
                      _buildStatusGrid(status),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DeviceStatus status) {
    final user = AuthService.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Budianto';

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(user?.photoURL),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Haii',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text('👋', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification Bell dengan badge realtime
              StreamBuilder<List<AppNotification>>(
                stream: NotificationService.stream(),
                builder: (context, snap) {
                  final unread = (snap.data ?? [])
                      .where((n) => !n.isRead)
                      .length;
                  return GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.notifications),
                    child: Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B5E20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Glass Card for Location/Weather
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6DAF32).withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_cleanNumber(status.weatherTemp)} °C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.weatherDescription,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    return const CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        color: Colors.green,
        size: 26,
      ),
    );
  }

  Widget _buildErrorNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB7791F),
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Realtime Database belum terbaca. Menampilkan data contoh.',
              style: TextStyle(
                color: Color(0xFF8A5A12),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryPanel(DeviceStatus status) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        CircularPercentIndicator(
          radius: 110,
          lineWidth: 18,
          percent: status.batteryFraction,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: const Color(0xFF6DAF32),
          backgroundColor: const Color(0xFF333333),
          center: Container(
            width: 182,
            height: 182,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFA5D631), Color(0xFF2E6B0B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Daya Baterai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${status.batteryPercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Arus',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        Text(
                          '${_cleanNumber(status.current)} A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 25),
                    Column(
                      children: [
                        const Text(
                          'Tegangan',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        Text(
                          '${_cleanNumber(status.voltage)} V',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -18,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF0F4A18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid(DeviceStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 2.1,
        children: [
          _MetricCard(
            icon: Icons.thermostat,
            title: 'Suhu',
            value: '${_cleanNumber(status.temperature)} °C',
          ),
          _MetricCard(
            icon: Icons.water_drop_outlined,
            title: 'Kelembapan',
            value: '${_cleanNumber(status.humidity)} %',
          ),
          _MetricCard(
            icon: Icons.bolt_outlined,
            title: 'Tegangan AC',
            value: '${_cleanNumber(status.acVoltage)} V',
          ),
          _MetricCard(
            icon: Icons.light_mode_outlined,
            title: 'Intensitas Cahaya',
            value: '${_cleanNumber(status.lightIntensity)} Lux',
          ),
        ],
      ),
    );
  }

  String _cleanNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFBBEAAB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: Colors.black87,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


