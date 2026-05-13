import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/settings/connection_settings_store.dart';
import 'package:flutter_riverpod/legacy.dart';

final connectionSettingsProvider =
    StateNotifierProvider<ConnectionSettingsController, ConnectionSettings>(
  (ref) => ConnectionSettingsController()..load(),
);

class ConnectionSettingsController extends StateNotifier<ConnectionSettings> {
  ConnectionSettingsController({ConnectionSettingsStore? store})
      : _store = store ?? ConnectionSettingsStore(),
        super(const ConnectionSettings());

  final ConnectionSettingsStore _store;

  Future<void> load() async {
    state = await _store.read();
  }

  Future<void> save({
    required String metadataBaseUrl,
    required String syncBaseUrl,
    required String syncKey,
  }) async {
    final settings = ConnectionSettings(
      metadataBaseUrl: _normalizeUrl(metadataBaseUrl),
      syncBaseUrl: _normalizeUrl(syncBaseUrl),
      syncKey: syncKey.trim(),
      isLoaded: true,
    );
    await _store.write(settings);
    state = settings;
  }

  Future<void> reset() async {
    await _store.reset();
    state = const ConnectionSettings(isLoaded: true);
  }

  String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
