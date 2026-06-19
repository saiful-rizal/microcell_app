import 'package:firebase_database/firebase_database.dart';

import 'app_firebase.dart';

class DeviceDataService {
  DeviceDataService._();

  static const String devicePath = 'devices/main';

  static DatabaseReference get _deviceRef =>
      FirebaseDatabase.instance.ref(devicePath);

  static Stream<DeviceStatus> statusStream() {
    return Stream.fromFuture(AppFirebase.ensureInitialized()).asyncExpand((_) {
      return _deviceRef.child('status').onValue;
    }).map((event) {
      return DeviceStatus.fromValue(event.snapshot.value);
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

  static Stream<String?> notificationStream() {
    return Stream.fromFuture(AppFirebase.ensureInitialized()).asyncExpand((_) {
      return _deviceRef.child('notification').onValue;
    }).map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return value['message']?.toString();
      }
      if (value is String) {
        return value;
      }
      return null;
    });
  }

  static Future<void> clearNotification() async {
    await AppFirebase.ensureInitialized();

    return _deviceRef.child('notification').remove();
  }

  static Map<String, bool> _parseRelays(Object? value) {
    final defaults = {
      'relay1': false,
      'relay2': false,
      'relay3': true,
    };

    if (value is! Map) {
      return defaults;
    }

    return {
      'relay1': _asBool(value['relay1'], defaults['relay1']!),
      'relay2': _asBool(value['relay2'], defaults['relay2']!),
      'relay3': _asBool(value['relay3'], defaults['relay3']!),
    };
  }
}

class DeviceStatus {
  const DeviceStatus({
    required this.batteryLevel,
    required this.current,
    required this.voltage,
    required this.temperature,
    required this.humidity,
    required this.acVoltage,
    required this.lightIntensity,
    required this.weatherTemp,
    required this.weatherDescription,
    required this.location,
    required this.updatedAt,
  });

  final double batteryLevel;
  final double current;
  final double voltage;
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
      batteryLevel: 85,
      current: 1.2,
      voltage: 12.5,
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

  factory DeviceStatus.fromValue(Object? value) {
    final fallback = DeviceStatus.defaults();

    if (value is! Map) {
      return fallback;
    }

    return DeviceStatus(
      batteryLevel: _asDouble(
        _readAny(value, ['batteryLevel', 'battery', 'battery_level']),
        fallback.batteryLevel,
      ),
      current: _asDouble(
        _readAny(value, ['current', 'arus']),
        fallback.current,
      ),
      voltage: _asDouble(
        _readAny(value, ['voltage', 'tegangan']),
        fallback.voltage,
      ),
      temperature: _asDouble(
        _readAny(value, ['temperature', 'suhu']),
        fallback.temperature,
      ),
      humidity: _asDouble(
        _readAny(value, ['humidity', 'kelembapan']),
        fallback.humidity,
      ),
      acVoltage: _asDouble(
        _readAny(value, ['acVoltage', 'ac_voltage']),
        fallback.acVoltage,
      ),
      lightIntensity: _asDouble(
        _readAny(value, ['lightIntensity', 'intensity', 'lux']),
        fallback.lightIntensity,
      ),
      weatherTemp: _asDouble(
        _readAny(value, ['weatherTemp', 'weather_temp']),
        fallback.weatherTemp,
      ),
      weatherDescription:
          _readAny(value, ['weatherDescription', 'weather'])?.toString() ??
              fallback.weatherDescription,
      location: _readAny(value, ['location', 'lokasi'])?.toString() ??
          fallback.location,
      updatedAt: _asDateTime(_readAny(value, ['updatedAt', 'updated_at'])),
    );
  }

  int get batteryPercent => batteryLevel.clamp(0, 100).round();

  double get batteryFraction => batteryLevel.clamp(0, 100) / 100;
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
