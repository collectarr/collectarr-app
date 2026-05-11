import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/settings/connection_settings_store.dart';
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
}
