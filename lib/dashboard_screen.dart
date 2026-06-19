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
          backgroundColor: const Color(0xFFF4F7F5),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, status),
                  StreamBuilder<String?>(
                    stream: DeviceDataService.notificationStream(),
                    builder: (context, notificationSnapshot) {
                      final message = notificationSnapshot.data;
                      if (message == null || message.trim().isEmpty) {
                        return const SizedBox(height: 34);
                      }
                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.green.shade200, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                DeviceDataService.clearNotification();
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.green,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (snapshot.hasError) _buildErrorNotice(),
                  _buildBatteryPanel(status),
                  const SizedBox(height: 16),
                  _buildSectionHeader(status),
                  const SizedBox(height: 10),
                  _buildStatusGrid(status),
                  const SizedBox(height: 18),
                ],
              ),
            ),
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
        : 'Pengguna';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 130,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            color: Colors.black.withValues(alpha: 0.36),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _buildAvatar(user?.photoURL),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hai',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<String?>(
                stream: DeviceDataService.notificationStream(),
                builder: (context, snapshot) {
                  final hasNotification =
                      snapshot.data?.trim().isNotEmpty == true ||
                          _hasStatusNotification(status);

                  return IconButton(
                    tooltip: 'Notifikasi',
                    onPressed: () => _showNotificationMenu(context, status),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 22,
                        ),
                        if (hasNotification)
                          Positioned(
                            right: -1,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
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
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: -20,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7DCB22),
                  Color(0xFF6F8D73),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status.weatherDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_cleanNumber(status.weatherTemp)} C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationMenu(BuildContext context, DeviceStatus status) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationMenu(status: status),
    );
  }

  bool _hasStatusNotification(DeviceStatus status) {
    return status.batteryPercent <= 40 ||
        status.voltage < 11.5 ||
        status.temperature >= 35 ||
        status.temperature <= 10 ||
        status.humidity >= 85 ||
        status.humidity <= 35 ||
        status.acVoltage < 200 ||
        status.acVoltage > 240 ||
        status.lightIntensity < 200;
  }

  Widget _buildAvatar(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    return const CircleAvatar(
      radius: 16,
      backgroundColor: Color(0xFFD7ECD8),
      child: Icon(
        Icons.person,
        color: Colors.green,
        size: 18,
      ),
    );
  }

  Widget _buildErrorNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB7791F),
            size: 18,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 55,
            lineWidth: 8,
            percent: status.batteryFraction,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: const Color(0xFF7DCB22),
            backgroundColor: const Color(0xFFE5E7EB),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.battery_charging_full,
                  color: Color(0xFF7DCB22),
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  '${status.batteryPercent}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7DCB22),
                  ),
                ),
                const Text(
                  'Battery',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInfoPill(
                  Icons.electric_bolt,
                  'Arus',
                  '${_cleanNumber(status.current)} A',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoPill(
                  Icons.battery_5_bar,
                  'Tegangan',
                  '${_cleanNumber(status.voltage)} V',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(DeviceStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Device Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          if (status.updatedAt != null)
            Text(
              'Update ${_timeText(status.updatedAt!)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid(DeviceStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _MetricCard(
            icon: Icons.thermostat,
            title: 'Suhu',
            value: '${_cleanNumber(status.temperature)} C',
          ),
          _MetricCard(
            icon: Icons.water_drop,
            title: 'Kelembapan',
            value: '${_cleanNumber(status.humidity)}%',
          ),
          _MetricCard(
            icon: Icons.bolt,
            title: 'AC Voltage',
            value: '${_cleanNumber(status.acVoltage)} V',
          ),
          _MetricCard(
            icon: Icons.wb_sunny,
            title: 'Intensitas',
            value: '${_cleanNumber(status.lightIntensity)} Lux',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  String _timeText(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _cleanNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF7DCB22),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
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
