import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionSettingsStore {
  static const _metadataBaseUrlKey = 'collectarr.settings.metadata_base_url';
  static const _syncBaseUrlKey = 'collectarr.settings.sync_base_url';
  static const _syncKeyKey = 'collectarr.settings.sync_key';

  Future<ConnectionSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    return ConnectionSettings(
      metadataBaseUrl: (prefs.getString(_metadataBaseUrlKey) ??
              ConnectionSettings.defaultMetadataBaseUrl)
          .trim(),
      syncBaseUrl: (prefs.getString(_syncBaseUrlKey) ??
              ConnectionSettings.defaultSyncBaseUrl)
          .trim(),
      syncKey: (prefs.getString(_syncKeyKey) ??
              ConnectionSettings.defaultSyncKey)
          .trim(),
      isLoaded: true,
    );
  }

  Future<void> write(ConnectionSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _metadataBaseUrlKey,
      _normalizeUrl(settings.metadataBaseUrl),
    );
    await prefs.setString(_syncBaseUrlKey, _normalizeUrl(settings.syncBaseUrl));
    await prefs.setString(_syncKeyKey, settings.syncKey.trim());
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metadataBaseUrlKey);
    await prefs.remove(_syncBaseUrlKey);
    await prefs.remove(_syncKeyKey);
  }

  String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
