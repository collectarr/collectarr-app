import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/engine/provider_sync_coordinator.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsProviderAccountsPanel extends ConsumerStatefulWidget {
  const SettingsProviderAccountsPanel({super.key});

  @override
  ConsumerState<SettingsProviderAccountsPanel> createState() =>
      _SettingsProviderAccountsPanelState();
}

class _SettingsProviderAccountsPanelState
    extends ConsumerState<SettingsProviderAccountsPanel> {
  final Set<String> _syncingAccounts = {};
  final Set<String> _connectingProviders = {};

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(providerRegistryProvider);
    final accounts = ref.watch(externalAccountsProvider);

    return registry.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Could not load integrations: $error'),
      data: (providerRegistry) => accounts.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text('Could not load connected accounts: $error'),
        data: (connectedAccounts) {
          final connectors = providerRegistry
              .getAll()
              .where(
                (connector) =>
                    connector.supportsPersonalRead ||
                    connector.supportsPersonalWrite,
              )
              .where(
                (connector) =>
                    connector.supportsAccountAuthorization ||
                    connectedAccounts.any(
                      (account) => account.provider == connector.id,
                    ),
              )
              .toList(growable: false)
            ..sort((a, b) =>
                a.descriptor.displayName.compareTo(b.descriptor.displayName));

          if (connectors.isEmpty) {
            return const Text('No account based integrations are available.');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < connectors.length; index++) ...[
                if (index > 0) const Divider(height: 20),
                _buildConnector(
                  connector: connectors[index],
                  accounts: connectedAccounts
                      .where(
                          (account) => account.provider == connectors[index].id)
                      .toList(growable: false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnector({
    required ProviderConnector connector,
    required List<ProviderAccount> accounts,
  }) {
    final theme = Theme.of(context);
    final supportedKinds = connector.descriptor.allSupportedKinds
        .where((kind) => kind != CatalogMediaKind.unknown)
        .map(_kindLabel)
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(connector.id.icon, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connector.descriptor.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (supportedKinds.isNotEmpty)
                    Text(
                      'Personal lists · $supportedKinds',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (connector.accountAuthorization != null)
              OutlinedButton.icon(
                onPressed: _connectingProviders.contains(connector.id.value)
                    ? null
                    : () => _connect(connector),
                icon: _connectingProviders.contains(connector.id.value)
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_link_outlined),
                label: const Text('Connect'),
              ),
          ],
        ),
        if (accounts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 8),
            child: Text(
              'No account connected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          for (final account in accounts)
            _buildAccountCard(connector: connector, account: account),
        ],
      ],
    );
  }

  Widget _buildAccountCard({
    required ProviderConnector connector,
    required ProviderAccount account,
  }) {
    final theme = Theme.of(context);
    final isSyncing = _syncingAccounts.contains(account.id);
    final handle = account.username?.trim();
    final accountName = handle == null || handle.isEmpty
        ? account.displayName
        : '${account.displayName} · @$handle';
    final lastSync = account.lastSyncAt == null
        ? 'Never synced'
        : 'Last sync ${account.lastSyncAt!.toLocal().toString().split('.').first}';

    return Card(
      margin: const EdgeInsets.only(top: 6),
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    accountName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 26, top: 2),
              child: Text(
                lastSync,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 6,
              children: [
                if (connector.supportsPersonalRead)
                  OutlinedButton.icon(
                    onPressed: isSyncing ? null : () => _syncAccount(account),
                    icon: isSyncing
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync, size: 16),
                    label: Text(isSyncing ? 'Syncing…' : 'Sync now'),
                  ),
                TextButton.icon(
                  onPressed: isSyncing ? null : () => _disconnect(account),
                  icon: const Icon(Icons.link_off_outlined, size: 16),
                  label: const Text('Disconnect'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(ProviderConnector connector) async {
    final credentialController = TextEditingController();
    final credential = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: Text('Connect ${connector.descriptor.displayName}'),
        content: TextField(
          controller: credentialController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Access token',
            helperText:
                'The token is verified before the account is saved securely.',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(credentialController.text),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    credentialController.dispose();
    if (!mounted || credential == null || credential.trim().isEmpty) return;

    setState(() => _connectingProviders.add(connector.id.value));
    try {
      final account = await connector.accountAuthorization!.authorize(
        credential.trim(),
      );
      if (account == null) {
        throw const FormatException(
            'The provider did not recognize this token.');
      }
      await ref.read(providerAccountStoreProvider).saveAccount(
            account,
            accessToken: credential.trim(),
          );
      ref.invalidate(externalAccountsProvider);
      if (mounted) {
        showAppToast(
          context,
          'Connected ${account.displayName}.',
          tone: AppToastTone.success,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppToast(
          context,
          'Could not connect ${connector.descriptor.displayName}: $error',
          tone: AppToastTone.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _connectingProviders.remove(connector.id.value));
      }
    }
  }

  Future<void> _syncAccount(ProviderAccount account) async {
    setState(() => _syncingAccounts.add(account.id));
    try {
      final registry = await ref.read(providerRegistryProvider.future);
      final coordinator = ProviderSyncCoordinator(
        engine: const ExternalStateEngine(),
        registry: registry,
        accountStore: ref.read(providerAccountStoreProvider),
        linkStore: ref.read(providerLinkStoreProvider),
      );
      final result = await coordinator.pullAccount(accountId: account.id);
      ref.invalidate(externalAccountsProvider);
      if (mounted) {
        showAppToast(
          context,
          'Sync complete: ${result.pulledCount} received, '
          '${result.appliedCount} applied, '
          '${result.conflictCount} conflicts.',
          tone: AppToastTone.success,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppToast(
          context,
          'Sync failed: $error',
          tone: AppToastTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _syncingAccounts.remove(account.id));
    }
  }

  Future<void> _disconnect(ProviderAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: Text('Disconnect ${account.displayName}?'),
        content: const Text(
          'The saved provider token will be removed from this device. '
          'Your local collection will remain unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      await ref.read(providerAccountStoreProvider).deleteAccount(account.id);
      ref.invalidate(externalAccountsProvider);
      if (mounted) {
        showAppToast(
          context,
          'Disconnected ${account.displayName}.',
          tone: AppToastTone.success,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppToast(
          context,
          'Could not disconnect ${account.displayName}: $error',
          tone: AppToastTone.error,
        );
      }
    }
  }
}

class SettingsCatalogSourcesPanel extends ConsumerWidget {
  const SettingsCatalogSourcesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(providerRegistryProvider);
    return registry.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Could not load catalog sources: $error'),
      data: (providerRegistry) {
        final connectors = providerRegistry
            .getAll()
            .where((connector) => connector.supportsMetadata)
            .toList(growable: false)
          ..sort((a, b) =>
              a.descriptor.displayName.compareTo(b.descriptor.displayName));
        final kinds = CatalogMediaKind.values
            .where(
              (kind) =>
                  kind != CatalogMediaKind.unknown &&
                  connectors.any(
                    (connector) => connector.descriptor.supportsKind(kind),
                  ),
            )
            .toList(growable: false);

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: const Text('Metadata sources'),
          subtitle: Text(
            '${connectors.length} providers across ${kinds.length} collection types',
          ),
          children: [
            for (final connector in connectors)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(connector.id.icon, size: 18),
                title: Text(connector.descriptor.displayName),
                subtitle: Text(
                  '${connector.descriptor.allSupportedKinds.where((kind) => kind != CatalogMediaKind.unknown).map(_kindLabel).join(', ')} · '
                  '${_connectorCapabilities(connector).join(' · ')}',
                ),
              ),
          ],
        );
      },
    );
  }
}

String _kindLabel(CatalogMediaKind kind) => switch (kind) {
      CatalogMediaKind.comic => 'Comics',
      CatalogMediaKind.manga => 'Manga',
      CatalogMediaKind.anime => 'Anime',
      CatalogMediaKind.book => 'Books',
      CatalogMediaKind.game => 'Video games',
      CatalogMediaKind.boardgame => 'Board games',
      CatalogMediaKind.movie => 'Movies',
      CatalogMediaKind.tv => 'TV',
      CatalogMediaKind.music => 'Music',
      CatalogMediaKind.unknown => 'Other',
    };

List<String> _connectorCapabilities(ProviderConnector connector) => [
      if (connector.supportsMetadata && connector.descriptor.supportsSearch)
        'Search',
      if (connector.supportsImages) 'Images',
      if (connector.supportsIdentity) 'External IDs',
      if (connector.supportsBarcode) 'Barcode lookup',
      if (connector.supportsPersonalListFileImport) 'File import',
      if (connector.supportsPersonalRead || connector.supportsPersonalWrite)
        'Personal sync',
    ];
