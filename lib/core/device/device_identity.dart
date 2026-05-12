import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentity {
  static const _key = 'collectarr.device_id';
  static Future<String>? _initFuture;

  Future<String> getOrCreate() {
    final existingFuture = _initFuture;
    if (existingFuture != null) {
      return existingFuture;
    }

    final future = _loadOrCreate();
    _initFuture = future;
    return future.catchError((Object error) {
      if (identical(_initFuture, future)) {
        _initFuture = null;
      }
      throw error;
    });
  }

  static void resetForTesting() {
    _initFuture = null;
  }

  Future<String> _loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final deviceId = const Uuid().v4();
    await prefs.setString(_key, deviceId);
    return deviceId;
  }

  Future<String> regenerate() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = const Uuid().v4();
    await prefs.setString(_key, deviceId);
    _initFuture = Future.value(deviceId);
    return deviceId;
  }
}
