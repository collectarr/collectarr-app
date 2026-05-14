import 'package:collectarr_app/core/settings/connection_settings.dart';

class ConnectionPreset {
  const ConnectionPreset({
    required this.id,
    required this.label,
    required this.metadataBaseUrl,
    required this.syncBaseUrl,
  });

  static const localDesktop = ConnectionPreset(
    id: 'local-desktop',
    label: 'Local desktop',
    metadataBaseUrl: 'http://localhost:8010',
    syncBaseUrl: 'http://localhost:8020',
  );

  static const androidEmulator = ConnectionPreset(
    id: 'android-emulator',
    label: 'Android emulator',
    metadataBaseUrl: 'http://10.0.2.2:8010',
    syncBaseUrl: 'http://10.0.2.2:8020',
  );

  static const lanTemplate = ConnectionPreset(
    id: 'lan-template',
    label: 'LAN template',
    metadataBaseUrl: 'http://192.168.1.10:8010',
    syncBaseUrl: 'http://192.168.1.10:8020',
  );

  static const values = [
    localDesktop,
    androidEmulator,
    lanTemplate,
  ];

  final String id;
  final String label;
  final String metadataBaseUrl;
  final String syncBaseUrl;

  ConnectionSettings applyTo(ConnectionSettings settings) {
    return settings.copyWith(
      metadataBaseUrl: metadataBaseUrl,
      syncBaseUrl: syncBaseUrl,
      isLoaded: true,
    );
  }
}
