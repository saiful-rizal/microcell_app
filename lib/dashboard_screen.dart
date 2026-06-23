import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'auth_service.dart';
import 'device_data_service.dart';
import 'navigation.dart';

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
              // Notification Bell
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B5E20), // Dark green background
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
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

class _NotificationMenu extends StatelessWidget {
  const _NotificationMenu({
    required this.status,
  });

  final DeviceStatus status;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F5),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD7ECD8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF0B7A2A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Status alat terbaru',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: StreamBuilder<String?>(
                stream: DeviceDataService.notificationStream(),
                builder: (context, snapshot) {
                  final message = snapshot.data?.trim();
                  final alerts = _alerts(message);
                  final activeCount =
                      alerts.where((alert) => alert.isActive).length;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      children: [
                        _NotificationSummary(
                          activeCount: activeCount,
                          updatedAt: status.updatedAt,
                        ),
                        const SizedBox(height: 12),
                        for (final alert in alerts) _NotificationTile(alert),
                        if (message != null && message.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _clearNotification(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0B7A2A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.done_all,
                                size: 18,
                              ),
                              label: const Text(
                                'Tandai selesai',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_NotificationAlert> _alerts(String? message) {
    final alerts = <_NotificationAlert>[];

    if (message != null && message.isNotEmpty) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.info_outline_rounded,
          title: 'Pesan perangkat',
          message: message,
          color: const Color(0xFF0B7A2A),
        ),
      );
    }

    alerts.addAll(_statusAlerts());

    if (alerts.isEmpty) {
      alerts.add(
        const _NotificationAlert(
          icon: Icons.check_circle_outline,
          title: 'Semua sistem normal',
          message: 'Tidak ada peringatan baru dari perangkat Microcell.',
          color: Color(0xFF0B7A2A),
          isActive: false,
        ),
      );
    }

    return alerts;
  }

  List<_NotificationAlert> _statusAlerts() {
    final alerts = <_NotificationAlert>[];

    if (status.batteryPercent <= 20) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.battery_alert,
          title: 'Baterai rendah',
          message:
              'Sisa ${status.batteryPercent}%. Segera cek sumber daya panel.',
          color: const Color(0xFFDC2626),
        ),
      );
    } else if (status.batteryPercent <= 40) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.battery_3_bar,
          title: 'Baterai mulai rendah',
          message:
              'Sisa ${status.batteryPercent}%. Pantau pengisian perangkat.',
          color: const Color(0xFFF59E0B),
        ),
      );
    }

    if (status.voltage < 11.5) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.electric_bolt,
          title: 'Tegangan DC turun',
          message:
              'Tegangan baterai ${_formatNumber(status.voltage)} V berada di bawah batas aman.',
          color: const Color(0xFFF59E0B),
        ),
      );
    }

    if (status.temperature >= 35) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.thermostat,
          title: 'Suhu tinggi',
          message:
              'Suhu perangkat mencapai ${_formatNumber(status.temperature)} C.',
          color: const Color(0xFFEA580C),
        ),
      );
    } else if (status.temperature <= 10) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.ac_unit,
          title: 'Suhu rendah',
          message:
              'Suhu perangkat turun ke ${_formatNumber(status.temperature)} C.',
          color: const Color(0xFF0284C7),
        ),
      );
    }

    if (status.humidity >= 85) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.water_drop,
          title: 'Kelembapan tinggi',
          message:
              'Kelembapan ${_formatNumber(status.humidity)}%. Periksa area perangkat.',
          color: const Color(0xFF0284C7),
        ),
      );
    } else if (status.humidity <= 35) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.water_drop_outlined,
          title: 'Kelembapan rendah',
          message:
              'Kelembapan ${_formatNumber(status.humidity)}%. Kondisi udara cenderung kering.',
          color: const Color(0xFFF59E0B),
        ),
      );
    }

    if (status.acVoltage < 200 || status.acVoltage > 240) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.bolt,
          title: 'AC voltage tidak stabil',
          message:
              'Nilai AC voltage terbaca ${_formatNumber(status.acVoltage)} V.',
          color: const Color(0xFFF59E0B),
        ),
      );
    }

    if (status.lightIntensity < 200) {
      alerts.add(
        _NotificationAlert(
          icon: Icons.wb_sunny_outlined,
          title: 'Intensitas cahaya rendah',
          message:
              'Intensitas ${_formatNumber(status.lightIntensity)} Lux. Panel mungkin kurang mendapat cahaya.',
          color: const Color(0xFFF59E0B),
        ),
      );
    }

    return alerts;
  }

  Future<void> _clearNotification(BuildContext context) async {
    try {
      await DeviceDataService.clearNotification();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi ditandai selesai.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF0B7A2A),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membersihkan notifikasi.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

class _NotificationSummary extends StatelessWidget {
  const _NotificationSummary({
    required this.activeCount,
    required this.updatedAt,
  });

  final int activeCount;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final isStable = activeCount == 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isStable
              ? const [
                  Color(0xFF7DCB22),
                  Color(0xFF0B7A2A),
                ]
              : const [
                  Color(0xFFFFC107),
                  Color(0xFF7DCB22),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isStable
                  ? Icons.verified_outlined
                  : Icons.notifications_active_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStable
                      ? 'Semua sistem stabil'
                      : '$activeCount peringatan aktif',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  updatedAt == null
                      ? 'Menunggu data terbaru'
                      : 'Update ${_formatTime(updatedAt!)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.alert);

  final _NotificationAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.color.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              alert.icon,
              color: alert.color,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.28,
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

class _NotificationAlert {
  const _NotificationAlert({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.isActive = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final bool isActive;
}

String _formatNumber(double value) {
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
}

String _formatTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
