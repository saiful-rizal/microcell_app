import 'dart:ui';
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
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Image.asset(
                  'assets/images/cow.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(isAnyRelayActive),
                      const SizedBox(height: 30),
                      if (snapshot.hasError) _buildErrorNotice(),
                      _buildRelayCard(
                        context,
                        title: 'Stop Kontak 1',
                        relayKey: 'relay1',
                        value: relays['relay1'] ?? false,
                      ),
                      const SizedBox(height: 12),
                      _buildRelayCard(
                        context,
                        title: 'Stop Kontak 2',
                        relayKey: 'relay2',
                        value: relays['relay2'] ?? false,
                      ),
                      const SizedBox(height: 12),
                      _buildRelayCard(
                        context,
                        title: 'Stop Kontak 3',
                        relayKey: 'relay3',
                        value: relays['relay3'] ?? false,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildHeader(bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/icon_app.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Controlling Relay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance the row
            ],
          ),
          const SizedBox(height: 60),
          // Glass Card Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6DAF32).withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.light,
                          color: isActive ? Colors.cyanAccent : Colors.grey,
                          size: 60,
                        ),
                        if (isActive)
                          Positioned(
                            bottom: 0,
                            child: Icon(
                              Icons.wifi_tethering,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Indicator Relay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: isActive ? Colors.greenAccent : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isActive ? 'Aktif' : 'Nonaktif',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildErrorNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                fontSize: 12,
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBBEAAB), // Light green background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: value ? Colors.amber[700] : Colors.blueGrey,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _setRelay(context, relayKey, !value),
            child: Container(
              width: 60,
              height: 32,
              decoration: BoxDecoration(
                color: value ? Colors.black : Colors.grey[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
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
