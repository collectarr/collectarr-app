import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/engine/provider_sync_coordinator.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final externalAccountsProvider =
    FutureProvider.autoDispose<List<ProviderAccount>>((ref) async {
  final store = ref.watch(providerAccountStoreProvider);
  return store.getAllAccounts();
});

class ExternalServicesPage extends ConsumerStatefulWidget {
  const ExternalServicesPage({super.key});

  @override
  ConsumerState<ExternalServicesPage> createState() =>
      _ExternalServicesPageState();
}

class _ExternalServicesPageState extends ConsumerState<ExternalServicesPage> {
  final Set<String> _syncingAccounts = {};
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final registryAsync = ref.watch(providerRegistryProvider);
    final accountsAsync = ref.watch(externalAccountsProvider);
    final palette = appPalette(context);

    final registry =
        registryAsync.asData?.value ?? defaultProviderConnectorRegistry;
    final connectors = registry.getAll();

    return Scaffold(
      backgroundColor: palette.panel,
      appBar: AppBar(
        title: const Text('External Services & Integrations'),
        backgroundColor: palette.panel,
        elevation: 0,
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading services: $err',
              style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (accounts) {
          final accountMap = {
            for (final a in accounts) a.provider: a,
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_statusMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    border: Border.all(color: palette.accent),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: palette.accent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(color: palette.textPrimary),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _statusMessage = null),
                      ),
                    ],
                  ),
                ),
              Text(
                'Connected Providers & Capabilities',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage external data sources, personal list synchronization, and file imports. Capabilities are dynamically derived directly from active connectors.',
                style: TextStyle(color: palette.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final connector in connectors)
                _buildConnectorCard(
                  context,
                  connector: connector,
                  account: accountMap[connector.id],
                  palette: palette,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectorCard(
    BuildContext context, {
    required ProviderConnector connector,
    required ProviderAccount? account,
    required AppThemePalette palette,
  }) {
    final isConnected = account != null;
    final isSyncing = isConnected && _syncingAccounts.contains(account.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: palette.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isConnected
              ? palette.accent.withValues(alpha: 0.5)
              : palette.divider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            connector.descriptor.displayName,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: palette.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CONNECTED',
                                style: TextStyle(
                                  color: palette.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports: ${connector.descriptor.allSupportedKinds.join(', ')}',
                        style:
                            TextStyle(color: palette.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isConnected && (connector.canPull || connector.canPush))
                  ElevatedButton.icon(
                    onPressed: isSyncing ? null : () => _handleSync(account),
                    icon: isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync, size: 16),
                    label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
                  )
                else if (connector.canPull || connector.canPush)
                  OutlinedButton.icon(
                    onPressed: () => _handleConnect(connector),
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Connect'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (connector.supportsMetadata)
                  _capabilityChip('Metadata', Icons.search, palette),
                if (connector.canImport)
                  _capabilityChip('File Import', Icons.file_upload, palette),
                if (connector.canPull)
                  _capabilityChip('Pull Sync', Icons.download, palette),
                if (connector.canPush)
                  _capabilityChip('Push Sync', Icons.upload, palette),
                if (connector.supportsBidirectionalSync)
                  _capabilityChip('2-Way Sync', Icons.swap_horiz, palette,
                      isHighlight: true),
              ],
            ),
            if (isConnected) ...[
              const SizedBox(height: 12),
              Divider(color: palette.divider),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User: ${account.displayName} (@${account.username ?? account.remoteHandle ?? 'unknown'})',
                    style: TextStyle(color: palette.textPrimary, fontSize: 12),
                  ),
                  Text(
                    account.lastSyncAt != null
                        ? 'Last sync: ${account.lastSyncAt!.toLocal().toString().split('.').first}'
                        : 'Never synced',
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _capabilityChip(
    String label,
    IconData icon,
    AppThemePalette palette, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? palette.accent.withValues(alpha: 0.15)
            : palette.panel,
        border: Border.all(
          color: isHighlight ? palette.accent : palette.divider,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isHighlight ? palette.accent : palette.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isHighlight ? palette.accent : palette.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSync(ProviderAccount account) async {
    setState(() {
      _syncingAccounts.add(account.id);
      _statusMessage = 'Syncing ${account.displayName}...';
    });

    try {
      final registry = (await ref.read(providerRegistryProvider.future));
      final coordinator = ProviderSyncCoordinator(
        engine: const ExternalStateEngine(),
        registry: registry,
        accountStore: ref.read(providerAccountStoreProvider),
        linkStore: ref.read(providerLinkStoreProvider),
      );

      final result = await coordinator.pullAccount(accountId: account.id);
      if (mounted) {
        setState(() {
          _statusMessage =
              'Sync complete for ${account.displayName}: pulled ${result.pulledCount}, applied ${result.appliedCount}, conflicts: ${result.conflictCount}.';
        });
        ref.invalidate(externalAccountsProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Sync error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _syncingAccounts.remove(account.id);
        });
      }
    }
  }

  Future<void> _handleConnect(ProviderConnector connector) async {
    final tokenController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Connect ${connector.descriptor.displayName}'),
          content: TextField(
            controller: tokenController,
            decoration: const InputDecoration(
              labelText: 'Access Token / API Key',
              hintText: 'Paste token here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(tokenController.text.trim()),
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final store = ref.read(providerAccountStoreProvider);
      final account = ProviderAccount(
        id: '${connector.id.value}-connected',
        provider: connector.id,
        displayName: connector.descriptor.displayName,
        authType: ProviderAuthType.accessToken,
        connectedAt: DateTime.now().toUtc(),
      );
      await store.saveAccount(account, accessToken: result);
      ref.invalidate(externalAccountsProvider);
      if (mounted) {
        setState(() {
          _statusMessage = 'Connected ${connector.descriptor.displayName}';
        });
      }
    }
  }
}
