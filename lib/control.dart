import 'package:flutter/material.dart';

import 'device_data_service.dart';
import 'navigation.dart';

class RelayControlScreen extends StatelessWidget {
  const RelayControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, bool>>(
      stream: DeviceDataService.relayStream(),
      initialData: const {
        'relay1': false,
        'relay2': false,
        'relay3': true,
      },
      builder: (context, snapshot) {
        final relays = snapshot.data ??
            const {
              'relay1': false,
              'relay2': false,
              'relay3': true,
            };
        final isAnyRelayActive = relays.values.any((value) => value);

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(isAnyRelayActive),
                  const SizedBox(height: 52),
                  if (snapshot.hasError) _buildErrorNotice(),
                  _buildRelayCard(
                    context,
                    title: 'Stop Kontak 1',
                    relayKey: 'relay1',
                    value: relays['relay1'] ?? false,
                  ),
                  _buildRelayCard(
                    context,
                    title: 'Stop Kontak 2',
                    relayKey: 'relay2',
                    value: relays['relay2'] ?? false,
                  ),
                  _buildRelayCard(
                    context,
                    title: 'Stop Kontak 3',
                    relayKey: 'relay3',
                    value: relays['relay3'] ?? false,
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildHeader(bool isActive) {
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
            color: Colors.black.withValues(alpha: .40),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Controlling Relay',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: -28,
          child: Container(
            padding: const EdgeInsets.all(12),
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
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.power : Icons.power_off,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Indicator Relay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor:
                                isActive ? Colors.greenAccent : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? 'Aktif' : 'Nonaktif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
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
              'Relay belum terbaca dari Realtime Database.',
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

  Widget _buildRelayCard(
    BuildContext context, {
    required String title,
    required String relayKey,
    required bool value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
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
              color: value ? const Color(0xFFE9F8DF) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb,
              color: value ? Colors.amber : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF0B7A2A),
            inactiveTrackColor: const Color(0xFFD1D5DB),
            onChanged: (newValue) {
              _setRelay(context, relayKey, newValue);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setRelay(
    BuildContext context,
    String relayKey,
    bool value,
  ) async {
    try {
      await DeviceDataService.setRelay(relayKey, value);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah relay. Periksa koneksi database.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
