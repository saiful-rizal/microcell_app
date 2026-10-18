import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'device_data_service.dart';

/// Fungsi-fungsi untuk halaman Dashboard (dashboard_screen.dart)
class DashboardPageFunctions {
  DashboardPageFunctions._();

  /// Stream status device realtime dari Firebase Realtime Database
  /// Returns: Stream<DeviceStatus> dengan data sensor (suhu, kelembaban, tegangan, dll)
  static Stream<DeviceStatus> getDeviceStatusStream() {
    return DeviceDataService.statusStream();
  }

  /// Stream status relay realtime
  /// Returns: Stream<Map<String, bool>> dengan key relay1, relay2, relay3, relay4
  static Stream<Map<String, bool>> getRelayStream() {
    return DeviceDataService.relayStream();
  }

  /// Stream notifikasi device
  static Stream<String?> getNotificationStream() {
    return DeviceDataService.notificationStream();
  }

  /// Update status relay (ON/OFF)
  /// - [relayKey]: 'relay1', 'relay2', 'relay3', atau 'relay4'
  /// - [value]: true = ON, false = OFF
  static Future<void> updateRelay(String relayKey, bool value) async {
    return DeviceDataService.setRelay(relayKey, value);
  }

  /// Hapus notifikasi device
  static Future<void> clearNotification() async {
    return DeviceDataService.clearNotification();
  }

  /// Format nilai sensor untuk tampilan dashboard
  /// Returns: String formatted (contoh: "25.5 °C")
  static String formatSensorValue(String sensorType, double value) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
      case 'suhu':
        return '${value.toStringAsFixed(1)} °C';
      case 'humidity':
      case 'kelembaban':
      case 'kelembapan':
        return '${value.toStringAsFixed(1)} %';
      case 'ph':
        return value.toStringAsFixed(2);
      case 'tds':
        return '${value.toStringAsFixed(0)} ppm';
      case 'voltage':
      case 'tegangan':
        return '${value.toStringAsFixed(1)} V';
      case 'current':
      case 'arus':
        return '${value.toStringAsFixed(2)} A';
      case 'power':
      case 'daya':
        return '${value.toStringAsFixed(1)} W';
      case 'batterylevel':
      case 'battery':
        return '${value.toStringAsFixed(0)} %';
      case 'lightintensity':
      case 'lux':
        return '${value.toStringAsFixed(0)} lux';
      case 'acvoltage':
        return '${value.toStringAsFixed(0)} V';
      default:
        return value.toStringAsFixed(1);
    }
  }

  /// Cek apakah nilai sensor dalam batas normal (untuk indikator warna)
  /// Returns: 'normal' | 'warning' | 'danger'
  static String getSensorStatus(String sensorType, double value) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
      case 'suhu':
        if (value < 15 || value > 40) return 'danger';
        if (value < 20 || value > 35) return 'warning';
        return 'normal';
      case 'humidity':
      case 'kelembaban':
      case 'kelembapan':
        if (value < 30 || value > 90) return 'danger';
        if (value < 40 || value > 80) return 'warning';
        return 'normal';
      case 'ph':
        if (value < 5.5 || value > 8.5) return 'danger';
        if (value < 6.0 || value > 8.0) return 'warning';
        return 'normal';
      case 'tds':
        if (value < 200 || value > 1500) return 'danger';
        if (value < 300 || value > 1200) return 'warning';
        return 'normal';
      case 'batterylevel':
      case 'battery':
        if (value < 20) return 'danger';
        if (value < 40) return 'warning';
        return 'normal';
      default:
        return 'normal';
    }
  }

  /// Warna berdasarkan status sensor
  static Color getStatusColor(String status) {
    switch (status) {
      case 'danger':
        return Colors.redAccent;
      case 'warning':
        return Colors.orange;
      case 'normal':
      default:
        return const Color(0xFF12A73B); // primary green
    }
  }

  /// Icon berdasarkan tipe sensor
  static IconData getSensorIcon(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
      case 'suhu':
        return Icons.thermostat;
      case 'humidity':
      case 'kelembaban':
      case 'kelembapan':
        return Icons.water_drop;
      case 'ph':
        return Icons.science;
      case 'tds':
        return Icons.opacity;
      case 'voltage':
      case 'tegangan':
        return Icons.flash_on;
      case 'current':
      case 'arus':
        return Icons.electrical_services;
      case 'power':
      case 'daya':
        return Icons.bolt;
      case 'batterylevel':
      case 'battery':
        return Icons.battery_std;
      case 'lightintensity':
      case 'lux':
        return Icons.wb_sunny;
      case 'acvoltage':
        return Icons.power;
      default:
        return Icons.sensors;
    }
  }

  /// Label display untuk tipe sensor
  static String getSensorLabel(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
      case 'suhu':
        return 'Suhu';
      case 'humidity':
      case 'kelembaban':
      case 'kelembapan':
        return 'Kelembaban';
      case 'ph':
        return 'pH';
      case 'tds':
        return 'TDS';
      case 'voltage':
      case 'tegangan':
        return 'Tegangan DC';
      case 'current':
      case 'arus':
        return 'Arus';
      case 'power':
      case 'daya':
        return 'Daya';
      case 'batterylevel':
      case 'battery':
        return 'Baterai';
      case 'lightintensity':
      case 'lux':
        return 'Cahaya';
      case 'acvoltage':
        return 'Tegangan AC';
      case 'weathertemp':
        return 'Cuaca';
      default:
        return sensorType.toUpperCase();
    }
  }

  /// Inisialisasi data awal device (seed) - dipanggil sekali saat setup
  static Future<void> seedInitialData() async {
    return DeviceDataService.seedInitialData();
  }

  /// Update status sensor manual (untuk testing/admin)
  static Future<void> updateStatus({
    double? batteryLevel,
    double? current,
    double? voltage,
    double? temperature,
    double? humidity,
    double? acVoltage,
    double? lightIntensity,
    double? weatherTemp,
    String? weatherDescription,
    String? location,
  }) async {
    return DeviceDataService.updateStatus(
      batteryLevel: batteryLevel,
      current: current,
      voltage: voltage,
      temperature: temperature,
      humidity: humidity,
      acVoltage: acVoltage,
      lightIntensity: lightIntensity,
      weatherTemp: weatherTemp,
      weatherDescription: weatherDescription,
      location: location,
    );
  }
}