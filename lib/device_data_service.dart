import 'package:firebase_database/firebase_database.dart';

import 'app_firebase.dart';

class DeviceDataService {
  DeviceDataService._();

  static const String devicePath = 'devices/main';

  static DatabaseReference get _deviceRef =>
      FirebaseDatabase.instance.ref(devicePath);

  /// Stream data sensor dari `devices/main/sensors` (acs1, ina1, ina2).
  /// Juga menggabungkan data dari `devices/main/status` untuk weather/location.
  static Stream<DeviceStatus> statusStream() {
    return Stream.fromFuture(AppFirebase.ensureInitialized()).asyncExpand((_) {
      return _deviceRef.onValue;
    }).map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return DeviceStatus.defaults();
      return DeviceStatus.fromDeviceNode(value);
    });
  }

  static Stream<Map<String, bool>> relayStream() {
    return Stream.fromFuture(AppFirebase.ensureInitialized()).asyncExpand((_) {
      return _deviceRef.child('relays').onValue;
    }).map((event) {
      return _parseRelays(event.snapshot.value);
    });
  }

  static Future<void> setRelay(String relayKey, bool value) async {
    await AppFirebase.ensureInitialized();

    return _deviceRef.child('relays').update({
      relayKey: value,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Stream pesan notifikasi terbaru yang belum dibaca dari
  /// `devices/main/notifications` (list push-id sesuai struktur JSON).
  /// Return null jika tidak ada notifikasi belum dibaca.
  static Stream<String?> notificationStream() {
    return Stream.fromFuture(AppFirebase.ensureInitialized()).asyncExpand((_) {
      return _deviceRef.child('notifications').onValue;
    }).map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;

      Map<dynamic, dynamic>? latest;
      int latestAt = -1;
      for (final entry in value.entries) {
        final v = entry.value;
        if (v is! Map) continue;
        if (v['isRead'] == true) continue;
        final createdAt = v['createdAt'];
        final at = createdAt is int
            ? createdAt
            : int.tryParse('${createdAt ?? ''}') ?? -1;
        if (at >= latestAt) {
          latestAt = at;
          latest = v;
        }
      }
      return latest?['message']?.toString();
    });
  }

  /// Tandai semua notifikasi belum dibaca sebagai dibaca
  /// (node `devices/main/notifications` berupa list push-id).
  static Future<void> clearNotification() async {
    await AppFirebase.ensureInitialized();

    final snapshot = await _deviceRef.child('notifications').get();
    final value = snapshot.value;
    if (value is! Map) return;

    final updates = <String, dynamic>{};
    for (final entry in value.entries) {
      final v = entry.value;
      if (v is Map && v['isRead'] != true) {
        updates['${entry.key}/isRead'] = true;
      }
    }
    if (updates.isNotEmpty) {
      await _deviceRef.child('notifications').update(updates);
    }
  }

  /// Mengisi data awal ke Firebase Realtime Database jika node belum ada.
  /// Dipanggil otomatis saat app pertama kali dijalankan.
  static Future<void> seedInitialData() async {
    await AppFirebase.ensureInitialized();

    final snapshot = await _deviceRef.get();

    // Jika data sudah ada, tidak perlu seed
    if (snapshot.exists) return;

    await _deviceRef.set({
      'sensors': {
        'acs1': {'current': 0.0, 'voltage': 0.0},
        'ina1': {'current': 0.0, 'power': 0.0, 'voltage': 0.0},
        'ina2': {'current': 0.0, 'power': 0.0, 'voltage': 0.0},
      },
      'relays': {
        'relay1': false,
        'relay2': false,
        'relay3': false,
        'relay4': false,
        'updatedAt': ServerValue.timestamp,
      },
    });
  }

  /// Update status sensor secara manual dari app (untuk testing / admin).
  static Future<void> updateStatus({
    double? batteryLevel,
    double? current,
    double? voltage,
    double? adcVoltage,
    double? power,
    double? temperature,
    double? humidity,
    double? acVoltage,
    double? lightIntensity,
    double? weatherTemp,
    String? weatherDescription,
    String? location,
  }) async {
    await AppFirebase.ensureInitialized();

    final updates = <String, dynamic>{
      'updatedAt': ServerValue.timestamp,
    };

    if (batteryLevel != null) updates['batteryLevel'] = batteryLevel;
    if (current != null) updates['current'] = current;
    if (voltage != null) updates['voltage'] = voltage;
    if (adcVoltage != null) updates['adcSensorVoltage'] = adcVoltage;
    if (power != null) updates['power'] = power;
    if (temperature != null) updates['temperature'] = temperature;
    if (humidity != null) updates['humidity'] = humidity;
    if (acVoltage != null) updates['acVoltage'] = acVoltage;
    if (lightIntensity != null) updates['lightIntensity'] = lightIntensity;
    if (weatherTemp != null) updates['weatherTemp'] = weatherTemp;
    if (weatherDescription != null) updates['weatherDescription'] = weatherDescription;
    if (location != null) updates['location'] = location;

    return _deviceRef.child('status').update(updates);
  }

  static Map<String, bool> _parseRelays(Object? value) {
    final defaults = {
      'relay1': false,
      'relay2': false,
      'relay3': false,
      'relay4': false,
    };

    if (value is! Map) {
      return defaults;
    }

    return {
      'relay1': _asBool(value['relay1'], defaults['relay1']!),
      'relay2': _asBool(value['relay2'], defaults['relay2']!),
      'relay3': _asBool(value['relay3'], defaults['relay3']!),
      'relay4': _asBool(value['relay4'], defaults['relay4']!),
    };
  }
}

class DeviceStatus {
  const DeviceStatus({
    required this.batteryLevel,
    required this.current,
    required this.voltage,
    required this.dcCurrent,
    required this.dcPower,
    required this.batteryPowerDc,
    required this.temperature,
    required this.humidity,
    required this.acVoltage,
    required this.lightIntensity,
    required this.weatherTemp,
    required this.weatherDescription,
    required this.location,
    required this.updatedAt,
  });

  /// Persentase daya baterai (0–100), dihitung dari acs1.voltage
  final double batteryLevel;

  /// Arus listrik dari sensor acs1.current (Ampere)
  final double current;

  /// Voltase baterai dari sensor acs1.voltage (Volt)
  final double voltage;

  /// Arus DC dari sensor ina1.current (Ampere)
  final double dcCurrent;

  /// Daya Batrai DC dari sensor ina1.voltage (Volt DC)
  final double dcPower;

  /// Tegangan Batreai DC dari sensor ina1.power (Watt)
  final double batteryPowerDc;

  final double temperature;
  final double humidity;
  final double acVoltage;
  final double lightIntensity;
  final double weatherTemp;
  final String weatherDescription;
  final String location;
  final DateTime? updatedAt;

  factory DeviceStatus.defaults() {
    return const DeviceStatus(
      batteryLevel: 0,
      current: 0,
      voltage: 0,
      dcCurrent: 0,
      dcPower: 0,
      batteryPowerDc: 0,
      temperature: 15,
      humidity: 75,
      acVoltage: 220,
      lightIntensity: 570,
      weatherTemp: 35,
      weatherDescription: 'Cuaca Berawan',
      location: 'Bangsalsari, Jember',
      updatedAt: null,
    );
  }

  /// Konversi voltage ACS712 (0–3.3V) ke persentase baterai (0–100%).
  /// Range tegangan: 0V = 0%, 3.3V = 100%.
  static double _voltageToBatteryPercent(double voltage) {
    const double minVoltage = 0.0;
    const double maxVoltage = 3.3;
    final clamped = voltage.clamp(minVoltage, maxVoltage);
    return ((clamped - minVoltage) / (maxVoltage - minVoltage)) * 100;
  }

  /// Buat DeviceStatus dari seluruh node `devices/main`.
  /// Membaca data sensor dari `sensors/acs1` dan `sensors/ina1`,
  /// serta data weather/location dari `status`.
  factory DeviceStatus.fromDeviceNode(Map<dynamic, dynamic> deviceNode) {
    final fallback = DeviceStatus.defaults();

    // --- Ambil data sensor ---
    final sensors = deviceNode['sensors'];
    final acs1 = (sensors is Map) ? sensors['acs1'] : null;
    final ina1 = (sensors is Map) ? sensors['ina1'] : null;

    // acs1 values
    final acs1Voltage = _asDouble(
      (acs1 is Map) ? acs1['voltage'] : null,
      0.0,
    );
    final acs1Current = _asDouble(
      (acs1 is Map) ? acs1['current'] : null,
      0.0,
    );

    // ina1 values
    final ina1Voltage = _asDouble(
      (ina1 is Map) ? ina1['voltage'] : null,
      0.0,
    );
    final ina1Current = _asDouble(
      (ina1 is Map) ? ina1['current'] : null,
      0.0,
    );
    final ina1Power = _asDouble(
      (ina1 is Map) ? ina1['power'] : null,
      0.0,
    );

    // --- Ambil data status (weather, location) ---
    final status = deviceNode['status'];
    final statusMap = (status is Map) ? status : <dynamic, dynamic>{};

    return DeviceStatus(
      // 1. Daya Baterai: acs1.voltage → persen
      batteryLevel: _voltageToBatteryPercent(acs1Voltage),
      // 2. Tegangan Batreai DC: ina1.power
      voltage: acs1Voltage,
      batteryPowerDc: ina1Power,
      // 3. Daya Batrai DC: ina1.voltage
      dcPower: ina1Voltage,
      // 4. Arus DC: ina1.current
      dcCurrent: ina1Current,
      // 5. Arus Listrik: acs1.current
      current: acs1Current,
      temperature: _asDouble(
        _readAny(statusMap, ['temperature', 'suhu']),
        fallback.temperature,
      ),
      humidity: _asDouble(
        _readAny(statusMap, ['humidity', 'kelembapan']),
        fallback.humidity,
      ),
      acVoltage: _asDouble(
        _readAny(statusMap, ['acVoltage', 'ac_voltage']),
        fallback.acVoltage,
      ),
      lightIntensity: _asDouble(
        _readAny(statusMap, ['lightIntensity', 'intensity', 'lux']),
        fallback.lightIntensity,
      ),
      weatherTemp: _asDouble(
        _readAny(statusMap, ['weatherTemp', 'weather_temp']),
        fallback.weatherTemp,
      ),
      weatherDescription:
          _readAny(statusMap, ['weatherDescription', 'weather'])?.toString() ??
              fallback.weatherDescription,
      location: _readAny(statusMap, ['location', 'lokasi'])?.toString() ??
          fallback.location,
      updatedAt: _asDateTime(_readAny(statusMap, ['updatedAt', 'updated_at'])),
    );
  }

  int get batteryPercent => batteryLevel.clamp(0, 100).round();

  double get batteryFraction => batteryLevel.clamp(0, 100) / 100;

  /// Arus dalam miliAmpere untuk tampilan kartu.
  double get currentMa => current * 1000;
}

Object? _readAny(Map<dynamic, dynamic> source, List<String> keys) {
  for (final key in keys) {
    if (source.containsKey(key)) {
      return source[key];
    }
  }

  return null;
}

double _asDouble(Object? value, double fallback) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  }

  return fallback;
}

bool _asBool(Object? value, bool fallback) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }

  return fallback;
}

DateTime? _asDateTime(Object? value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  if (value is double) {
    return DateTime.fromMillisecondsSinceEpoch(value.round());
  }

  return null;
}
