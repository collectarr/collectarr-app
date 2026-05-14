import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_presets.dart';
import 'package:collectarr_app/core/settings/connection_settings_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('connection settings persist local endpoint overrides', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ConnectionSettingsStore();

    await store.write(
      const ConnectionSettings(
        metadataBaseUrl: 'http://metadata.local:8010/',
        syncBaseUrl: 'http://sync.local:8020/',
        syncKey: ' local-key ',
      ),
    );

    final settings = await store.read();

    expect(settings.metadataBaseUrl, 'http://metadata.local:8010');
    expect(settings.syncBaseUrl, 'http://sync.local:8020');
    expect(settings.syncKey, 'local-key');
    expect(settings.isLoaded, isTrue);
  });

  test('connection settings reset to compile-time defaults', () async {
    SharedPreferences.setMockInitialValues({
      'collectarr.settings.metadata_base_url': 'http://metadata.local',
      'collectarr.settings.sync_base_url': 'http://sync.local',
      'collectarr.settings.sync_key': 'secret',
    });
    final store = ConnectionSettingsStore();

    await store.reset();
    final settings = await store.read();

    expect(settings.metadataBaseUrl, ConnectionSettings.defaultMetadataBaseUrl);
    expect(settings.syncBaseUrl, ConnectionSettings.defaultSyncBaseUrl);
    expect(settings.syncKey, ConnectionSettings.defaultSyncKey);
  });

  test('connection pairing code round trips endpoint settings', () {
    const pairing = ConnectionPairing();
    final code = pairing.encode(
      const ConnectionSettings(
        metadataBaseUrl: 'http://metadata.local:8010/',
        syncBaseUrl: 'http://sync.local:8020/',
        syncKey: ' local-key ',
      ),
    );

    final settings = pairing.decode(code);

    expect(code, startsWith(ConnectionPairing.prefix));
    expect(settings.metadataBaseUrl, 'http://metadata.local:8010');
    expect(settings.syncBaseUrl, 'http://sync.local:8020');
    expect(settings.syncKey, 'local-key');
  });

  test('connection pairing code can decode raw json for manual recovery', () {
    final settings = const ConnectionPairing().decode(
      '{"version":1,"metadata_base_url":"http://core","sync_base_url":"http://sync","sync_key":"key"}',
    );

    expect(settings.metadataBaseUrl, 'http://core');
    expect(settings.syncBaseUrl, 'http://sync');
    expect(settings.syncKey, 'key');
  });

  test('connection presets apply endpoint URLs without changing sync key', () {
    const settings = ConnectionSettings(syncKey: 'secret');

    final next = ConnectionPreset.androidEmulator.applyTo(settings);

    expect(next.metadataBaseUrl, 'http://10.0.2.2:8010');
    expect(next.syncBaseUrl, 'http://10.0.2.2:8020');
    expect(next.syncKey, 'secret');
  });

  test('connection diagnostics explains rejected sync keys', () {
    final requestOptions = RequestOptions(path: '/sync/status');
    final error = DioException(
      requestOptions: requestOptions,
      response: Response<void>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
    );

    final message = ConnectionDiagnostics.syncError(error, 'http://sync');

    expect(message, 'Sync key rejected (401). Check the configured key.');
  });

  test('connection diagnostics explains unreachable services', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/health'),
      type: DioExceptionType.connectionError,
    );

    final message = ConnectionDiagnostics.metadataError(
      error,
      'http://localhost:8010',
    );

    expect(
      message,
      'Could not reach metadata server at http://localhost:8010.',
    );
  });
}
