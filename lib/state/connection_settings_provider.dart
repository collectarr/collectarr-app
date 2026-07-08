import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/settings/connection_settings_store.dart';
import 'package:flutter_riverpod/legacy.dart';

final connectionSettingsProvider =
    StateNotifierProvider<ConnectionSettingsController, ConnectionSettings>(
  (ref) => ConnectionSettingsController()..load(),
);

class ConnectionSettingsController extends StateNotifier<ConnectionSettings> {
  ConnectionSettingsController({ConnectionSettingsStore? store, Uri? launchUri})
      : _store = store ?? ConnectionSettingsStore(),
        _launchUri = launchUri ?? Uri.base,
        super(const ConnectionSettings());

  final ConnectionSettingsStore _store;
  final Uri _launchUri;

  Future<void> load() async {
    if (_shouldResetFromLaunchUri()) {
      await _store.reset();
    }
    state = await _store.read();
  }

  Future<void> save({
    required String metadataBaseUrl,
    required String syncBaseUrl,
    required String syncKey,
    bool? preferOnlineFirstSync,
  }) async {
    final settings = ConnectionSettings(
      metadataBaseUrl: _normalizeUrl(metadataBaseUrl),
      syncBaseUrl: _normalizeUrl(syncBaseUrl),
      syncKey: syncKey.trim(),
      preferOnlineFirstSync:
          preferOnlineFirstSync ?? state.preferOnlineFirstSync,
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

  bool _shouldResetFromLaunchUri() {
    final fragmentQueryParameters = _fragmentQueryParameters();
    final value = _launchUri.queryParameters['resetConnection'] ??
        fragmentQueryParameters['resetConnection'];
    return switch (value?.toLowerCase()) {
      '1' || 'true' || 'yes' => true,
      _ => false,
    };
  }

  Map<String, String> _fragmentQueryParameters() {
    final fragment = _launchUri.fragment;
    final queryIndex = fragment.indexOf('?');
    if (queryIndex == -1 || queryIndex == fragment.length - 1) {
      return const <String, String>{};
    }
    return Uri.splitQueryString(fragment.substring(queryIndex + 1));
  }
}
