part of 'settings_page.dart';

extension _SettingsConnectionActions on _SettingsPageState {
  void _syncTextControllers(ConnectionSettings settings) {
    final last = _lastSyncedSettings;
    if (last?.metadataBaseUrl == settings.metadataBaseUrl &&
        last?.syncBaseUrl == settings.syncBaseUrl &&
        last?.syncKey == settings.syncKey) {
      return;
    }
    _metadataController.text = settings.metadataBaseUrl;
    _syncController.text = settings.syncBaseUrl;
    _syncKeyController.text = settings.syncKey;
    _lastSyncedSettings = settings;
  }

  void _scheduleConnectionAutoSave() {
    _connectionSaveDebounce?.cancel();
    _connectionSaveDebounce = Timer(
      const Duration(milliseconds: 650),
      () => unawaited(_autoSaveConnectionSettings()),
    );
  }

  Future<void> _autoSaveConnectionSettings({String? notify}) async {
    _connectionSaveDebounce?.cancel();
    await ref.read(connectionSettingsProvider.notifier).save(
          metadataBaseUrl: _metadataController.text,
          syncBaseUrl: _syncController.text,
          syncKey: _syncKeyController.text,
        );
    unawaited(ref.read(syncControllerProvider.notifier).refreshPendingCount());
    if (mounted && notify != null) {
      _showToast(notify, tone: AppToastTone.success);
    }
  }

  Future<void> _copyPairingCode() async {
    final settings = ConnectionSettings(
      metadataBaseUrl: _metadataController.text,
      syncBaseUrl: _syncController.text,
      syncKey: _syncKeyController.text,
      isLoaded: true,
    );
    final code = const ConnectionPairing().encode(settings);
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (!mounted) {
        return;
      }
      _showToast('Pairing code copied', tone: AppToastTone.success);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showToast(
        'Could not copy pairing code: ${_describeError(error)}',
        tone: AppToastTone.error,
      );
    }
  }

  Future<void> _showPairingCodeDialog(BuildContext context) async {
    final code = await showDialog<String>(
      context: context,
      builder: (context) => const _PairingCodeDialog(),
    );
    if (code == null || !mounted) {
      return;
    }
    await _applyPairingCode(code);
  }

  Future<void> _showPairingQrDialog(BuildContext context) async {
    final settings = ConnectionSettings(
      metadataBaseUrl: _metadataController.text,
      syncBaseUrl: _syncController.text,
      syncKey: _syncKeyController.text,
      isLoaded: true,
    );
    final code = const ConnectionPairing().encode(settings);
    await showDialog<void>(
      context: context,
      builder: (context) => _PairingQrDialog(code: code),
    );
  }

  Future<void> _scanPairingQr(BuildContext context) async {
    final scanned = await showModalBottomSheet<ScannedCode>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScanSheet(
        title: 'Scan pairing QR',
        description: 'Point the camera at a Collectarr pairing QR code, '
            'or paste the pairing code below.',
        manualLabel: 'Pairing code',
        submitLabel: 'Apply code',
        leadingIcon: Icons.qr_code_scanner,
      ),
    );
    if (scanned == null || scanned.value.isEmpty || !mounted) {
      return;
    }
    await _applyPairingCode(scanned.value);
  }

  Future<void> _applyPairingCode(String code) async {
    try {
      final settings = const ConnectionPairing().decode(code);
      await ref.read(connectionSettingsProvider.notifier).save(
            metadataBaseUrl: settings.metadataBaseUrl,
            syncBaseUrl: settings.syncBaseUrl,
            syncKey: settings.syncKey,
          );
      if (!mounted) {
        return;
      }
      _updateConnectionState(() {
        _metadataDiagnostic = null;
        _syncDiagnostic = null;
        _syncStatusDetails = null;
        _syncDevices = const [];
      });
      unawaited(
          ref.read(syncControllerProvider.notifier).refreshPendingCount());
      _showToast('Pairing settings applied', tone: AppToastTone.success);
    } catch (error) {
      if (mounted) {
        _showToast(
          'Invalid pairing code: ${_describeError(error)}',
          tone: AppToastTone.error,
        );
      }
    }
  }

  Future<void> _resetConnectionDefaults() async {
    await ref.read(connectionSettingsProvider.notifier).reset();
    _updateConnectionState(() {
      _metadataDiagnostic = null;
      _syncDiagnostic = null;
      _syncStatusDetails = null;
      _syncDevices = const [];
    });
    unawaited(ref.read(syncControllerProvider.notifier).refreshPendingCount());
    if (mounted) {
      _showToast('Connection defaults restored', tone: AppToastTone.success);
    }
  }

  Future<void> _checkSyncConnection() async {
    await _autoSaveConnectionSettings();
    if (!mounted) {
      return;
    }
    await _checkSync();
  }

  Future<void> _checkMetadata() async {
    final url = _metadataController.text.trim();
    _updateConnectionState(() {
      _metadataDiagnostic = const _DiagnosticState.checking();
    });
    try {
      final data = await ApiClient(baseUrl: url).health();
      if (!mounted) return;
      final status = data['status']?.toString() ?? 'unknown';
      _updateConnectionState(() {
        _metadataDiagnostic = _DiagnosticState.ok('Metadata server: $status');
      });
    } catch (error) {
      if (!mounted) return;
      _updateConnectionState(() {
        _metadataDiagnostic = _DiagnosticState.error(
          ConnectionDiagnostics.metadataError(
            error,
            _metadataController.text,
          ),
        );
      });
    }
  }

  Future<void> _checkSync() async {
    _updateConnectionState(() {
      _syncDiagnostic = const _DiagnosticState.checking();
    });
    try {
      final client = CollectarrSyncClient(
        baseUrl: _syncController.text,
        syncKey: _syncKeyController.text,
      );
      final data = await client.status();
      final devices = await client.devices();
      if (!mounted) return;
      final protocol = data['protocol_version']?.toString() ?? 'unknown';
      final version = data['schema_version']?.toString() ?? 'unknown';
      final entities = data['entity_count']?.toString() ?? 'unknown';
      final changes = data['change_count']?.toString() ?? 'unknown';
      _updateConnectionState(() {
        _syncDiagnostic = _DiagnosticState.ok(
          'Sync connected: protocol $protocol, schema $version, $entities entities, $changes events',
        );
        _syncStatusDetails = data;
        _syncDevices = devices;
      });
    } catch (error) {
      if (!mounted) return;
      _updateConnectionState(() {
        _syncDiagnostic = _DiagnosticState.error(
          ConnectionDiagnostics.syncError(
            error,
            _syncController.text,
          ),
        );
        _syncStatusDetails = null;
        _syncDevices = const [];
      });
    }
  }

  Future<void> _syncNow() async {
    await ref.read(syncControllerProvider.notifier).syncNow();
    if (!mounted) {
      return;
    }
    final sync = ref.read(syncControllerProvider);
    _showToast(_syncResultMessage(sync), tone: _syncResultTone(sync));
  }

  Future<void> _keepLocalConflict(SyncRejectedChange change) async {
    final queued = await ref
        .read(syncControllerProvider.notifier)
        .keepLocalRejectedChange(change);
    if (!mounted) {
      return;
    }
    final pendingCount = ref.read(syncControllerProvider).pendingCount;
    _showToast(
      queued
          ? 'Local version queued for the next sync. ${_pendingSyncLabel(pendingCount)} ready to upload.'
          : 'Local version is no longer available for that conflict.',
      tone: queued ? AppToastTone.success : AppToastTone.error,
    );
  }

  String _pendingSyncLabel(int count) {
    if (count == 1) {
      return '1 pending change is';
    }
    return '$count pending changes are';
  }

  String _syncResultMessage(SyncState sync) {
    if (sync.errorMessage != null) {
      return 'Personal sync unavailable: ${sync.errorMessage}';
    }
    return sync.warningMessage ?? 'Personal sync complete';
  }
}
