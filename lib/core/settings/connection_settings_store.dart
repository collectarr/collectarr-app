import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionSettingsStore {
  ConnectionSettingsStore({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _metadataBaseUrlKey = 'collectarr.settings.metadata_base_url';
  static const _syncBaseUrlKey = 'collectarr.settings.sync_base_url';
  static const _syncKeyKey = 'collectarr.settings.sync_key';
  static const _secureSyncKeyKey = 'collectarr.settings.sync_key';
  static const _legacyPublicSyncKey = 'collectarr-sync-dev-key';
  static const _preferOnlineFirstSyncKey =
      'collectarr.settings.prefer_online_first_sync';

  final FlutterSecureStorage _secureStorage;

  Future<ConnectionSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    var syncKey = await _secureStorage.read(key: _secureSyncKeyKey);
    if (syncKey == null) {
      final legacySyncKey = prefs.getString(_syncKeyKey)?.trim();
      if (legacySyncKey != null &&
          legacySyncKey.isNotEmpty &&
          legacySyncKey != _legacyPublicSyncKey) {
        await _secureStorage.write(
          key: _secureSyncKeyKey,
          value: legacySyncKey,
        );
        syncKey = legacySyncKey;
      }
    }
    await prefs.remove(_syncKeyKey);
    return ConnectionSettings(
      metadataBaseUrl: (prefs.getString(_metadataBaseUrlKey) ??
              ConnectionSettings.defaultMetadataBaseUrl)
          .trim(),
      syncBaseUrl: (prefs.getString(_syncBaseUrlKey) ??
              ConnectionSettings.defaultSyncBaseUrl)
          .trim(),
      syncKey: (syncKey ?? ConnectionSettings.defaultSyncKey).trim(),
      preferOnlineFirstSync: prefs.getBool(_preferOnlineFirstSyncKey) ?? false,
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
    await _secureStorage.write(
      key: _secureSyncKeyKey,
      value: settings.syncKey.trim(),
    );
    await prefs.remove(_syncKeyKey);
    await prefs.setBool(
      _preferOnlineFirstSyncKey,
      settings.preferOnlineFirstSync,
    );
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metadataBaseUrlKey);
    await prefs.remove(_syncBaseUrlKey);
    await _secureStorage.delete(key: _secureSyncKeyKey);
    await prefs.remove(_syncKeyKey);
    await prefs.remove(_preferOnlineFirstSyncKey);
  }

  String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
