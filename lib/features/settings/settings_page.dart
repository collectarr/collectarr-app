import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_presets.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/features/collection/collection_csv.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    this.showWebSyncWarning = kIsWeb,
  });

  final bool showWebSyncWarning;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _metadataController = TextEditingController();
  final _syncController = TextEditingController();
  final _syncKeyController = TextEditingController();
  Future<String>? _deviceIdFuture;
  _DiagnosticState? _metadataDiagnostic;
  _DiagnosticState? _syncDiagnostic;
  Map<String, dynamic>? _syncStatusDetails;
  List<Map<String, dynamic>> _syncDevices = const [];
  ConnectionSettings? _lastSyncedSettings;

  @override
  void initState() {
    super.initState();
    _deviceIdFuture = DeviceIdentity().getOrCreate();
  }

  @override
  void dispose() {
    _metadataController.dispose();
    _syncController.dispose();
    _syncKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(connectionSettingsProvider);
    final auth = ref.watch(authControllerProvider);
    final sync = ref.watch(syncControllerProvider);
    _syncTextControllers(settings);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsPanel(
            icon: Icons.route_outlined,
            title: 'Connection presets',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in ConnectionPreset.values)
                  OutlinedButton.icon(
                    onPressed: () => _applyConnectionPreset(preset),
                    icon: Icon(_presetIcon(preset)),
                    label: Text('Use ${preset.label}'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.dns_outlined,
            title: 'Metadata server',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _metadataController,
                  decoration: const InputDecoration(
                    labelText: 'Metadata API URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _DiagnosticRow(
                  diagnostic: _metadataDiagnostic,
                  idleLabel: 'Not checked',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _checkMetadata,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Check metadata server'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.cloud_sync_outlined,
            title: 'Personal sync service',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showWebSyncWarning) ...[
                  const _SyncWebWarning(),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _syncController,
                  decoration: const InputDecoration(
                    labelText: 'Sync service URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _syncKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Sync key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _DiagnosticRow(
                  diagnostic: _syncDiagnostic,
                  idleLabel: 'Not checked',
                ),
                if (_syncStatusDetails != null) ...[
                  const SizedBox(height: 12),
                  _SyncServiceSummary(
                    status: _syncStatusDetails!,
                    devices: _syncDevices,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      icon: Icons.pending_actions,
                      label: '${sync.pendingCount} pending',
                    ),
                    _StatusChip(
                      icon: sync.isOffline ? Icons.cloud_off : Icons.cloud_done,
                      label: sync.isOffline ? 'Offline' : 'Ready',
                      isError: sync.isOffline,
                    ),
                    if (sync.warningMessage != null)
                      _StatusChip(
                        icon: Icons.sync_problem_outlined,
                        label: sync.warningMessage!,
                      ),
                    _StatusChip(
                      icon: Icons.schedule,
                      label: sync.lastSyncedAt == null
                          ? 'Never synced'
                          : 'Last ${_formatSyncTime(sync.lastSyncedAt!)}',
                    ),
                  ],
                ),
                if (sync.rejectedChanges.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SyncConflictSummary(
                    changes: sync.rejectedChanges,
                    onDismiss: (change) => ref
                        .read(syncControllerProvider.notifier)
                        .dismissRejectedChange(change.key),
                    onDismissAll: () => ref
                        .read(syncControllerProvider.notifier)
                        .dismissAllRejectedChanges(),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _checkSync,
                      icon: const Icon(Icons.health_and_safety_outlined),
                      label: const Text('Check sync service'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: sync.isSyncing ? null : _syncNow,
                      icon: sync.isSyncing
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: const Text('Sync now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.qr_code_2_outlined,
            title: 'Device pairing',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _copyPairingCode,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy pairing code'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showPairingQrDialog(context),
                  icon: const Icon(Icons.qr_code_2_outlined),
                  label: const Text('Show pairing QR'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showPairingCodeDialog(context),
                  icon: const Icon(Icons.input_outlined),
                  label: const Text('Apply pairing code'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.devices_outlined,
            title: 'Device identity',
            child: FutureBuilder<String>(
              future: _deviceIdFuture,
              builder: (context, snapshot) {
                final deviceId = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SelectableText(deviceId ?? 'Loading device id...'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed:
                            snapshot.connectionState == ConnectionState.waiting
                                ? null
                                : _regenerateDeviceId,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Regenerate device id'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.backup_outlined,
            title: 'Local backup',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Copy a CSV snapshot of the local shelf. This includes personal fields stored on this device.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _copyBackup(clzFriendly: false),
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Copy Collectarr CSV'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copyBackup(clzFriendly: true),
                      icon: const Icon(Icons.table_view),
                      label: const Text('Copy CLZ-friendly CSV'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _copySyncBackupGuide,
                      icon: const Icon(Icons.description_outlined),
                      label: const Text('Copy sync backup guide'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.outbox_outlined,
            title: 'Metadata proposals',
            child: FutureBuilder<List<MetadataProposalRecord>>(
              future: const MetadataProposalStore().read(),
              builder: (context, snapshot) {
                return _MetadataProposalHistory(
                  records: snapshot.data ?? const [],
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                  onClear: _clearProposalHistory,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.account_circle_outlined,
            title: 'Account',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(auth.email ?? 'Signed in'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (auth.token != null || auth.isExpired)
                      _StatusChip(
                        icon: auth.isExpired
                            ? Icons.lock_clock_outlined
                            : Icons.verified_user_outlined,
                        label: _sessionStatusLabel(auth),
                        isError: auth.isExpired,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save settings'),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset defaults'),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  void _applyConnectionPreset(ConnectionPreset preset) {
    final settings = preset.applyTo(ref.read(connectionSettingsProvider));
    setState(() {
      _metadataController.text = settings.metadataBaseUrl;
      _syncController.text = settings.syncBaseUrl;
      _metadataDiagnostic = null;
      _syncDiagnostic = null;
      _syncStatusDetails = null;
      _syncDevices = const [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${preset.label} endpoints applied. Save settings next.'),
      ),
    );
  }

  IconData _presetIcon(ConnectionPreset preset) {
    return switch (preset.id) {
      'local-desktop' => Icons.computer_outlined,
      'android-emulator' => Icons.android_outlined,
      _ => Icons.router_outlined,
    };
  }

  Future<void> _save() async {
    await ref.read(connectionSettingsProvider.notifier).save(
          metadataBaseUrl: _metadataController.text,
          syncBaseUrl: _syncController.text,
          syncKey: _syncKeyController.text,
        );
    ref.read(syncControllerProvider.notifier).refreshPendingCount();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection settings saved')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pairing code copied')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not copy pairing code: $error')),
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
      setState(() {
        _metadataDiagnostic = null;
        _syncDiagnostic = null;
        _syncStatusDetails = null;
        _syncDevices = const [];
      });
      ref.read(syncControllerProvider.notifier).refreshPendingCount();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pairing settings applied')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid pairing code: $error')),
        );
      }
    }
  }

  Future<void> _reset() async {
    await ref.read(connectionSettingsProvider.notifier).reset();
    setState(() {
      _metadataDiagnostic = null;
      _syncDiagnostic = null;
      _syncStatusDetails = null;
      _syncDevices = const [];
    });
  }

  Future<void> _checkMetadata() async {
    setState(() {
      _metadataDiagnostic = const _DiagnosticState.checking();
    });
    try {
      final data = await ApiClient(baseUrl: _metadataController.text).health();
      final status = data['status']?.toString() ?? 'unknown';
      setState(() {
        _metadataDiagnostic = _DiagnosticState.ok('Metadata server: $status');
      });
    } catch (error) {
      setState(() {
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
    setState(() {
      _syncDiagnostic = const _DiagnosticState.checking();
    });
    try {
      final client = CollectarrSyncClient(
        baseUrl: _syncController.text,
        syncKey: _syncKeyController.text,
      );
      final data = await client.status();
      final devices = await client.devices();
      final version = data['schema_version']?.toString() ?? 'unknown';
      final entities = data['entity_count']?.toString() ?? 'unknown';
      final changes = data['change_count']?.toString() ?? 'unknown';
      setState(() {
        _syncDiagnostic = _DiagnosticState.ok(
          'Sync connected: schema $version, $entities entities, $changes events',
        );
        _syncStatusDetails = data;
        _syncDevices = devices;
      });
    } catch (error) {
      setState(() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_syncResultMessage(sync)),
      ),
    );
  }

  String _syncResultMessage(SyncState sync) {
    if (sync.errorMessage != null) {
      return 'Personal sync unavailable: ${sync.errorMessage}';
    }
    return sync.warningMessage ?? 'Personal sync complete';
  }

  Future<void> _copyBackup({required bool clzFriendly}) async {
    final state = await ref.read(shelfProvider.future);
    final csv = CollectionCsv();
    final data = clzFriendly
        ? csv.exportClzFriendlyShelf(state.entries)
        : csv.exportShelf(state.entries);
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          clzFriendly
              ? 'CLZ-friendly CSV backup copied'
              : 'Collectarr CSV backup copied',
        ),
      ),
    );
  }

  Future<void> _copySyncBackupGuide() async {
    final guide = [
      'Sync backup',
      '1. Stop collectarr-sync.',
      '2. Copy collectarr-sync.db plus -wal/-shm sidecars if present.',
      '3. Store the backup with the SYNC_API_KEY used by your devices.',
      '4. Restore while collectarr-sync is stopped, then run Check sync service.',
      '',
      'Docker:',
      'docker compose --profile sync stop sync',
      'docker compose --profile sync cp sync:/data ./collectarr-sync-data',
      'Compress-Archive -Path .\\collectarr-sync-data\\* -DestinationPath .\\collectarr-sync-data.zip -Force',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: guide));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync backup guide copied')),
    );
  }

  Future<void> _clearProposalHistory() async {
    await const MetadataProposalStore().clear();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local proposal history cleared')),
      );
    }
  }

  Future<void> _regenerateDeviceId() async {
    final future = DeviceIdentity().regenerate();
    setState(() {
      _deviceIdFuture = future;
    });
    await future;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device id regenerated')),
      );
    }
  }

  String _formatSyncTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
  }

  String _sessionStatusLabel(AuthState auth) {
    if (auth.isExpired) {
      return 'Session expired';
    }
    final expiresAt = auth.expiresAt;
    if (expiresAt == null) {
      return 'Session expiry unavailable';
    }
    return 'Session expires ${_formatSyncTime(expiresAt)}';
  }
}

class _PairingCodeDialog extends StatefulWidget {
  const _PairingCodeDialog();

  @override
  State<_PairingCodeDialog> createState() => _PairingCodeDialogState();
}

class _PairingCodeDialogState extends State<_PairingCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apply pairing code'),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Pairing code',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _PairingQrDialog extends StatelessWidget {
  const _PairingQrDialog({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Pairing QR'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              code,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
          child: const Text('Copy code'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _SyncWebWarning extends StatelessWidget {
  const _SyncWebWarning();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.32),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.public_off_outlined,
              color: colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Web sync uses your personal sync endpoint directly. Browser CORS, HTTPS, and local-network access rules can block it even when desktop or mobile sync works.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataProposalHistory extends StatelessWidget {
  const _MetadataProposalHistory({
    required this.records,
    required this.isLoading,
    required this.onClear,
  });

  final List<MetadataProposalRecord> records;
  final bool isLoading;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator();
    }
    if (records.isEmpty) {
      return const Text('No local proposal submissions yet.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              icon: Icons.outbox_outlined,
              label: '${records.length} submitted locally',
            ),
            _StatusChip(
              icon: Icons.pending_actions,
              label:
                  "${records.where((row) => row.status == 'pending').length} pending",
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final record in records.take(5))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(record.title ?? record.query),
            subtitle: Text(
              [
                record.source,
                record.provider,
                record.status,
                _formatProposalTime(record.createdAt),
              ].join(' | '),
            ),
          ),
        if (records.length > 5)
          Text('+${records.length - 5} older proposal submissions'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear local history'),
          ),
        ),
      ],
    );
  }
}

String _formatProposalTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.diagnostic, required this.idleLabel});

  final _DiagnosticState? diagnostic;
  final String idleLabel;

  @override
  Widget build(BuildContext context) {
    final state = diagnostic;
    if (state == null) {
      return _DiagnosticPill(
        icon: Icons.radio_button_unchecked,
        label: idleLabel,
      );
    }
    if (state.isChecking) {
      return const _DiagnosticPill(
        icon: Icons.sync,
        label: 'Checking...',
      );
    }
    return _DiagnosticPill(
      icon: state.isOk ? Icons.check_circle_outline : Icons.error_outline,
      label: state.message,
      isError: !state.isOk,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: isError ? colorScheme.error : colorScheme.primary,
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SyncServiceSummary extends StatelessWidget {
  const _SyncServiceSummary({
    required this.status,
    required this.devices,
  });

  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> devices;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  icon: Icons.storage_outlined,
                  label: '${status['entity_count'] ?? '-'} entities',
                ),
                _StatusChip(
                  icon: Icons.delete_sweep_outlined,
                  label: '${status['tombstone_count'] ?? '-'} tombstones',
                ),
                _StatusChip(
                  icon: Icons.history,
                  label: '${status['change_count'] ?? '-'} events',
                ),
                _StatusChip(
                  icon: Icons.event_repeat,
                  label: '${status['retention_days'] ?? '-'}d retention',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Devices seen', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            if (devices.isEmpty)
              const Text('No synced devices yet.')
            else
              for (final device in devices.take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.devices_other, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${device['device_id']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${device['change_count'] ?? 0} events'),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SyncConflictSummary extends StatelessWidget {
  const _SyncConflictSummary({
    required this.changes,
    required this.onDismiss,
    required this.onDismissAll,
  });

  final List<SyncRejectedChange> changes;
  final ValueChanged<SyncRejectedChange> onDismiss;
  final VoidCallback onDismissAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.28),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.36)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.sync_problem_outlined, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync conflict review',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: onDismissAll,
                  icon: const Icon(Icons.done_all_outlined),
                  label: const Text('Keep service'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final change in changes.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.rule_folder_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${change.entityType}:${_shortSyncId(change.entityId)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _conflictLabel(change),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy conflict id',
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: change.key),
                      ),
                      icon: const Icon(Icons.copy_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Keep service version',
                      onPressed: () => onDismiss(change),
                      icon: const Icon(Icons.check_outlined, size: 18),
                    ),
                  ],
                ),
              ),
            if (changes.length > 5)
              Text('+${changes.length - 5} older rejected changes'),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticPill extends StatelessWidget {
  const _DiagnosticPill({
    required this.icon,
    required this.label,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isError ? colorScheme.error : colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _shortSyncId(String id) {
  if (id.length <= 8) {
    return id;
  }
  return id.substring(0, 8);
}

String _conflictLabel(SyncRejectedChange change) {
  final current = change.currentClientChangedAt;
  if (current == null) {
    return change.reason;
  }
  return '${change.reason}, server kept ${_formatProposalTime(current)}';
}

class _DiagnosticState {
  const _DiagnosticState.checking()
      : isChecking = true,
        isOk = false,
        message = '';

  const _DiagnosticState.ok(this.message)
      : isChecking = false,
        isOk = true;

  const _DiagnosticState.error(this.message)
      : isChecking = false,
        isOk = false;

  final bool isChecking;
  final bool isOk;
  final String message;
}
