import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionSettingsStore {
  ConnectionSettingsStore({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _metadataBaseUrlKey = 'collectarr.settings.metadata_base_url';
  static const _syncBaseUrlKey = 'collectarr.settings.sync_base_url';
  static const _secureSyncKeyKey = 'collectarr.settings.sync_key';
  static const _preferOnlineFirstSyncKey =
      'collectarr.settings.prefer_online_first_sync';

  final FlutterSecureStorage _secureStorage;

  Future<ConnectionSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    final syncKey = await _secureStorage.read(key: _secureSyncKeyKey);
    return ConnectionSettings(
      metadataBaseUrl: resolveBaseUrl(
        stored: prefs.getString(_metadataBaseUrlKey),
        buildDefault: ConnectionSettings.defaultMetadataBaseUrl,
      ),
      syncBaseUrl: resolveBaseUrl(
        stored: prefs.getString(_syncBaseUrlKey),
        buildDefault: ConnectionSettings.defaultSyncBaseUrl,
      ),
      syncKey: (syncKey ?? ConnectionSettings.defaultSyncKey).trim(),
      preferOnlineFirstSync: prefs.getBool(_preferOnlineFirstSyncKey) ?? false,
      isLoaded: true,
    );
  }

  Future<void> write(ConnectionSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await _writeUrl(
      prefs,
      _metadataBaseUrlKey,
      settings.metadataBaseUrl,
      ConnectionSettings.defaultMetadataBaseUrl,
    );
    await _writeUrl(
      prefs,
      _syncBaseUrlKey,
      settings.syncBaseUrl,
      ConnectionSettings.defaultSyncBaseUrl,
    );
    await _secureStorage.write(
      key: _secureSyncKeyKey,
      value: settings.syncKey.trim(),
    );
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
    await prefs.remove(_preferOnlineFirstSyncKey);
  }

  /// The saved URL, or the build's. A release with a real server ignores a
  /// saved local address, which a development build leaves behind.
  @visibleForTesting
  static String resolveBaseUrl({
    required String? stored,
    required String buildDefault,
    bool releaseBuild = kReleaseMode,
  }) {
    final url = (stored ?? buildDefault).trim();
    if (releaseBuild && _isLocalUrl(url) && !_isLocalUrl(buildDefault)) {
      return buildDefault.trim();
    }
    return url;
  }

  static bool _isLocalUrl(String url) => const {
        '127.0.0.1',
        'localhost',
        '::1',
        '10.0.2.2',
      }.contains(Uri.tryParse(url.trim())?.host);

  /// Saves only a URL that differs from the build's, so a later release can
  /// move its server without leaving installs on the old address.
  Future<void> _writeUrl(
    SharedPreferences prefs,
    String key,
    String url,
    String buildDefault,
  ) async {
    final normalized = _normalizeUrl(url);
    if (normalized == _normalizeUrl(buildDefault)) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, normalized);
    }
  }

  String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
