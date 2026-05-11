import 'package:shared_preferences/shared_preferences.dart';

class SyncCursorStore {
  static const _key = 'collectarr.sync.last_server_time';

  Future<DateTime?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value).toUtc();
  }

  Future<void> write(DateTime serverTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, serverTime.toUtc().toIso8601String());
  }
}
