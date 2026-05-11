import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

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
    _syncTextControllers(settings);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _checkSync,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Check sync service'),
                  ),
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

  Future<void> _reset() async {
    await ref.read(connectionSettingsProvider.notifier).reset();
    setState(() {
      _metadataDiagnostic = null;
      _syncDiagnostic = null;
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
        _metadataDiagnostic = _DiagnosticState.error(error.toString());
      });
    }
  }

  Future<void> _checkSync() async {
    setState(() {
      _syncDiagnostic = const _DiagnosticState.checking();
    });
    try {
      final data = await CollectarrSyncClient(
        baseUrl: _syncController.text,
        syncKey: _syncKeyController.text,
      ).health();
      final version = data['schema_version']?.toString() ?? 'unknown';
      setState(() {
        _syncDiagnostic = _DiagnosticState.ok('Sync schema: $version');
      });
    } catch (error) {
      setState(() {
        _syncDiagnostic = _DiagnosticState.error(error.toString());
      });
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
