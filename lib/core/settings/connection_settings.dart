class ConnectionSettings {
  const ConnectionSettings({
    this.metadataBaseUrl = defaultMetadataBaseUrl,
    this.syncBaseUrl = defaultSyncBaseUrl,
    this.syncKey = defaultSyncKey,
    this.isLoaded = false,
  });

  static const defaultMetadataBaseUrl = String.fromEnvironment(
    'COLLECTARR_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8010',
  );
  static const defaultSyncBaseUrl = String.fromEnvironment(
    'COLLECTARR_SYNC_BASE_URL',
    defaultValue: 'http://127.0.0.1:8020',
  );
  static const defaultSyncKey = String.fromEnvironment(
    'COLLECTARR_SYNC_KEY',
    defaultValue: 'collectarr-sync-dev-key',
  );

  final String metadataBaseUrl;
  final String syncBaseUrl;
  final String syncKey;
  final bool isLoaded;

  ConnectionSettings copyWith({
    String? metadataBaseUrl,
    String? syncBaseUrl,
    String? syncKey,
    bool? isLoaded,
  }) {
    return ConnectionSettings(
      metadataBaseUrl: metadataBaseUrl ?? this.metadataBaseUrl,
      syncBaseUrl: syncBaseUrl ?? this.syncBaseUrl,
      syncKey: syncKey ?? this.syncKey,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
