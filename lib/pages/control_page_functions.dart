import 'package:flutter/material.dart';

import 'device_data_service.dart';

/// Fungsi-fungsi untuk halaman Control Relay (control.dart)
class ControlPageFunctions {
  ControlPageFunctions._();

  /// Daftar relay yang tersedia
  static const List<String> relayKeys = ['relay1', 'relay2', 'relay3', 'relay4'];

  /// Label display untuk setiap relay
  static const Map<String, String> relayLabels = {
    'relay1': 'Relay 1',
    'relay2': 'Relay 2',
    'relay3': 'Relay 3',
    'relay4': 'Relay 4',
  };

  /// Deskripsi fungsi setiap relay (customize sesuai hardware)
  static const Map<String, String> relayDescriptions = {
    'relay1': 'Pompa Utama',
    'relay2': 'Pompa Sirkulasi',
    'relay3': 'Lampu UV',
    'relay4': 'Kipas Pendingin',
  };

  /// Icon untuk setiap relay
  static const Map<String, IconData> relayIcons = {
    'relay1': Icons.water_pump,
    'relay2': Icons.sync_alt,
    'relay3': Icons.wb_iridescent,
    'relay4': Icons.air,
  };

  /// Warna untuk setiap relay
  static const Map<String, Color> relayColors = {
    'relay1': Color(0xFF12A73B),
    'relay2': Color(0xFF2196F3),
    'relay3': Color(0xFF9C27B0),
    'relay4': Color(0xFFFF9800),
  };

  /// Stream status relay realtime
  static Stream<Map<String, bool>> getRelayStream() {
    return DeviceDataService.relayStream();
  }

  /// Update status relay (ON/OFF)
  /// - [relayKey]: 'relay1', 'relay2', 'relay3', atau 'relay4'
  /// - [value]: true = ON, false = OFF
  /// Returns: true jika berhasil
  static Future<bool> toggleRelay(String relayKey, bool value) async {
    try {
      await DeviceDataService.setRelay(relayKey, value);
      return true;
    } catch (e) {
      debugPrint('Gagal toggle $relayKey: $e');
      return false;
    }
  }

  /// Toggle relay (ON -> OFF, OFF -> ON)
  static Future<bool> flipRelay(String relayKey, bool currentValue) async {
    return toggleRelay(relayKey, !currentValue);
  }

  /// Matikan semua relay sekaligus (emergency stop)
  static Future<void> turnOffAllRelays() async {
    for (final key in relayKeys) {
      await DeviceDataService.setRelay(key, false);
    }
  }

  /// Nyalakan semua relay sekaligus
  static Future<void> turnOnAllRelays() async {
    for (final key in relayKeys) {
      await DeviceDataService.setRelay(key, true);
    }
  }

  /// Set multiple relay sekaligus
  /// - [states]: Map {'relay1': true, 'relay2': false, ...}
  static Future<void> setMultipleRelays(Map<String, bool> states) async {
    final updates = <String, dynamic>{};
    for (final entry in states.entries) {
      updates[entry.key] = entry.value;
    }
    updates['updatedAt'] = 'ServerValue.timestamp'; // placeholder

    // Note: DeviceDataService.setRelay update satu per satu
    // Untuk batch update, perlu akses langsung ke database ref
    for (final entry in states.entries) {
      await DeviceDataService.setRelay(entry.key, entry.value);
    }
  }

  /// Validasi apakah relay key valid
  static bool isValidRelayKey(String key) {
    return relayKeys.contains(key);
  }

  /// Dapatkan label untuk relay key
  static String getLabel(String relayKey) {
    return relayLabels[relayKey] ?? relayKey.toUpperCase();
  }

  /// Dapatkan deskripsi untuk relay key
  static String getDescription(String relayKey) {
    return relayDescriptions[relayKey] ?? '';
  }

  /// Dapatkan icon untuk relay key
  static IconData getIcon(String relayKey) {
    return relayIcons[relayKey] ?? Icons.toggle_on;
  }

  /// Dapatkan warna untuk relay key
  static Color getColor(String relayKey) {
    return relayColors[relayKey] ?? const Color(0xFF12A73B);
  }

  /// Format state untuk tampilan (ON/OFF)
  static String formatState(bool isOn) {
    return isOn ? 'ON' : 'OFF';
  }

  /// Warna state untuk tampilan
  static Color getStateColor(bool isOn) {
    return isOn ? const Color(0xFF12A73B) : Colors.grey;
  }

  /// Icon state untuk tampilan
  static IconData getStateIcon(bool isOn) {
    return isOn ? Icons.toggle_on : Icons.toggle_off;
  }
}