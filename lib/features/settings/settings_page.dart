import 'dart:async';
import 'dart:convert';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_presets.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/core/sync/sync_warning_formatter.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/settings/app_log_viewer_panel.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/provider_imports_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/settings/collection_schema_management_panel.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

final _metadataProposalHistoryProvider =
    FutureProvider.autoDispose<List<MetadataProposalRecord>>((ref) async {
  return const MetadataProposalStore().read();
});

final _deviceIdentityProvider = FutureProvider.autoDispose<String>((ref) async {
  return DeviceIdentity().getOrCreate();
});

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
  _DiagnosticState? _metadataDiagnostic;
  _DiagnosticState? _syncDiagnostic;
  Map<String, dynamic>? _syncStatusDetails;
  List<Map<String, dynamic>> _syncDevices = const [];
  ConnectionSettings? _lastSyncedSettings;
  Timer? _connectionSaveDebounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _connectionSaveDebounce?.cancel();
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
    final mediaCatalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (catalog) => catalog,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final tmdbImportSettings = ref.watch(tmdbImportSettingsProvider);
    final metadataProposalHistory = ref.watch(_metadataProposalHistoryProvider);
    final deviceId = ref.watch(_deviceIdentityProvider);
    final selectedLibraryKind = ref.watch(selectedLibraryKindProvider);
    final accentScope = LibraryAccentScope.maybeOf(context);
    final accent =
        accentScope?.accent ?? libraryAccentForKind(selectedLibraryKind);
    final animationDuration = accentScope?.animationDuration ??
        (uiPreferences.animationsEnabled
            ? kAppAnimNormal
            : Duration.zero);
    _syncTextControllers(settings);

    return Theme(
      data: buildLibraryAccentTheme(Theme.of(context), accent),
      child: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: libraryAccentChromeFallbackColor(accent),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: LibraryAccentChrome(
              accent: accent,
              animationDuration: animationDuration,
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.route_outlined), text: 'Connection'),
                Tab(
                  icon: Icon(Icons.view_comfy_alt_outlined),
                  text: 'Libraries',
                ),
                Tab(icon: Icon(Icons.palette_outlined), text: 'Appearance'),
                Tab(icon: Icon(Icons.backup_outlined), text: 'Data'),
                Tab(icon: Icon(Icons.account_circle_outlined), text: 'Account'),
                Tab(icon: Icon(Icons.bug_report_outlined), text: 'Logs'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _SettingsTabBody(
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
                  _SettingsPanel(
                    icon: Icons.dns_outlined,
                    title: 'Metadata server',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _metadataController,
                          maxLines: 1,
                          onChanged: (_) => _scheduleConnectionAutoSave(),
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
                          maxLines: 1,
                          onChanged: (_) => _scheduleConnectionAutoSave(),
                          decoration: const InputDecoration(
                            labelText: 'Sync service URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _syncKeyController,
                          maxLines: 1,
                          onChanged: (_) => _scheduleConnectionAutoSave(),
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Sync key',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: settings.preferOnlineFirstSync,
                          onChanged: (value) async {
                            await ref
                                .read(connectionSettingsProvider.notifier)
                                .save(
                                  metadataBaseUrl: _metadataController.text,
                                  syncBaseUrl: _syncController.text,
                                  syncKey: _syncKeyController.text,
                                  preferOnlineFirstSync: value,
                                );
                            if (!mounted) {
                              return;
                            }
                            ref
                                .read(syncControllerProvider.notifier)
                                .refreshPendingCount();
                            if (value) {
                              unawaited(ref
                                  .read(syncControllerProvider.notifier)
                                  .syncOnlineFirstIfEnabled());
                            }
                          },
                          title: const Text('Prefer online-first personal sync'),
                          subtitle: const Text(
                            'Keep the local cache, but sync automatically on startup and after local personal changes when your sync service is available.',
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
                              icon: sync.isOffline
                                  ? Icons.cloud_off
                                  : Icons.cloud_done,
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
                            onKeepLocal: _keepLocalConflict,
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
                              onPressed: _checkConnections,
                              icon:
                                  const Icon(Icons.health_and_safety_outlined),
                              label: const Text('Check connections'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: sync.isSyncing ? null : _syncNow,
                              icon: sync.isSyncing
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.sync),
                              label: const Text('Sync now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (sync.syncLog.isNotEmpty)
                    _SettingsPanel(
                      icon: Icons.history_outlined,
                      title: 'Sync history',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final entry in sync.syncLog.reversed)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    entry.success
                                        ? Icons.check_circle_outline
                                        : Icons.error_outline,
                                    size: 16,
                                    color: entry.success
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatSyncTime(entry.timestamp),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  if (entry.success)
                                    Text(
                                      '${entry.pushed} pushed'
                                      '${entry.rejected > 0 ? ', ${entry.rejected} rejected' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kAppTextSecondary,
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Text(
                                        entry.errorMessage ?? 'Failed',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
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
                          onPressed: () => _scanPairingQr(context),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan pairing QR'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showPairingCodeDialog(context),
                          icon: const Icon(Icons.input_outlined),
                          label: const Text('Apply pairing code'),
                        ),
                      ],
                    ),
                  ),
                  _TabResetActions(
                    label: 'Reset connection defaults',
                    onReset: _resetConnectionDefaults,
                  ),
                ],
              ),
              _SettingsTabBody(
                children: [
                  _SettingsPanel(
                    icon: Icons.view_comfy_alt_outlined,
                    title: 'Library navigation',
                    child: _LibraryNavSettings(
                      catalog: mediaCatalog,
                      preferences: navPreferences,
                      onPlacementChanged: (placement) => ref
                          .read(libraryNavPreferencesProvider.notifier)
                          .setPlacement(placement),
                      onOrderChanged: (order) => ref
                          .read(libraryNavPreferencesProvider.notifier)
                          .setOrder(order),
                      onVisibilityChanged: (kind, visible) => ref
                          .read(libraryNavPreferencesProvider.notifier)
                          .setKindVisible(kind, visible),
                      onReset: () => ref
                          .read(libraryNavPreferencesProvider.notifier)
                          .reset(),
                    ),
                  ),
                  _SettingsPanel(
                    icon: Icons.account_tree_outlined,
                    title: 'Collection schema',
                    child: CollectionSchemaManagementPanel(
                      db: ref.read(localDatabaseProvider),
                    ),
                  ),
                ],
              ),
              _SettingsTabBody(
                children: [
                  _SettingsPanel(
                    icon: Icons.motion_photos_auto_outlined,
                    title: 'Appearance',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.gradient_outlined),
                          title: const Text('Animations'),
                          subtitle: const Text(
                            'Enable or disable all UI animations, transitions and effects.',
                          ),
                          value: uiPreferences.animationsEnabled,
                          onChanged: (value) => ref
                              .read(uiPreferencesProvider.notifier)
                              .setAnimationsEnabled(value),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _resetAppearanceDefaults,
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Reset appearance defaults'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _SettingsTabBody(
                children: [
                  _SettingsPanel(
                    icon: Icons.backup_outlined,
                    title: 'Local backup',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Import or export your local collection as Collectarr CSV, CLZ-friendly CSV, or ComicInfo.xml. Personal fields stored on this device stay in the exported data.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _showImportExportWizard(initialIndex: 1),
                              icon: const Icon(Icons.upload_file_outlined),
                              label: const Text('Import collection'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _showImportExportWizard(initialIndex: 0),
                              icon: const Icon(Icons.download_outlined),
                              label: const Text('Export collection'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _copyBackup(clzFriendly: false),
                              icon: const Icon(Icons.copy_all),
                              label: const Text('Copy Collectarr export'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _copyBackup(clzFriendly: true),
                              icon: const Icon(Icons.table_view),
                              label: const Text('Copy CLZ-friendly export'),
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
                  _SettingsPanel(
                    icon: Icons.download_outlined,
                    title: 'Import data',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Import your collection and tracking data from external services.',
                        ),
                        const SizedBox(height: 12),
                        _ImportSourcesGrid(
                          tmdbSettings: tmdbImportSettings,
                        ),
                      ],
                    ),
                  ),
                  _SettingsPanel(
                    icon: Icons.outbox_outlined,
                    title: 'Metadata proposals',
                    child: _MetadataProposalHistory(
                      records: metadataProposalHistory.value ?? const [],
                      isLoading: metadataProposalHistory.isLoading,
                      onClear: _clearProposalHistory,
                    ),
                  ),
                ],
              ),
              _SettingsTabBody(
                children: [
                  _SettingsPanel(
                    icon: Icons.devices_outlined,
                    title: 'Device identity',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText(deviceId.value ?? 'Loading device id...'),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: deviceId.isLoading
                                ? null
                                : _regenerateDeviceId,
                            icon: const Icon(Icons.refresh_outlined),
                            label: const Text('Regenerate device id'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SettingsPanel(
                    icon: Icons.account_circle_outlined,
                    title: 'Account',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText(auth.email ?? 'Not signed in'),
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
                            if (auth.isAuthenticated)
                              _StatusChip(
                                icon: auth.isAdmin
                                    ? Icons.admin_panel_settings_outlined
                                    : Icons.person_outline,
                                label: auth.isAdmin
                                    ? 'Core admin'
                                    : 'Standard account',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          auth.isAuthenticated
                              ? auth.isAdmin
                                  ? 'Admin tools are available in navigation and advanced metadata workflows.'
                                  : 'Admin-only tools are hidden for this account. Refresh permissions after a role change.'
                              : 'You can browse the app and send metadata proposals without signing in. Sign in is only needed for admin tools.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (auth.isAuthenticated) ...[
                              OutlinedButton.icon(
                                onPressed: _refreshAccountPermissions,
                                icon: const Icon(Icons.manage_accounts_outlined),
                                label: const Text('Refresh permissions'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(authControllerProvider.notifier)
                                    .logout(),
                                icon: const Icon(Icons.logout),
                                label: const Text('Sign out'),
                              ),
                            ] else
                              FilledButton.icon(
                                onPressed: () => context.go(AppRoutes.auth),
                                icon: const Icon(Icons.login),
                                label: const Text('Sign in'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ── Logs tab ─────────────────────────────────────────────
              _SettingsTabBody(
                children: [
                  _SettingsPanel(
                    icon: Icons.bug_report_outlined,
                    title: 'Application log',
                    child: const AppLogViewerPanel(),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      _syncKeyController.text = settings.syncKey;
      _metadataDiagnostic = null;
      _syncDiagnostic = null;
      _syncStatusDetails = null;
      _syncDevices = const [];
    });
    unawaited(
      _autoSaveConnectionSettings(
        notify: '${preset.label} endpoints saved',
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
    ref.read(syncControllerProvider.notifier).refreshPendingCount();
    if (mounted && notify != null) {
      _showToast(notify, tone: AppToastTone.success);
    }
  }

  Future<void> _resetAppearanceDefaults() async {
    await ref.read(uiPreferencesProvider.notifier).setAnimationsEnabled(true);
    if (mounted) {
      _showToast('Appearance defaults restored', tone: AppToastTone.success);
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
    final scanned = await showModalBottomSheet<String>(
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
    if (scanned == null || scanned.isEmpty || !mounted) {
      return;
    }
    await _applyPairingCode(scanned);
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
    setState(() {
      _metadataDiagnostic = null;
      _syncDiagnostic = null;
      _syncStatusDetails = null;
      _syncDevices = const [];
    });
    ref.read(syncControllerProvider.notifier).refreshPendingCount();
    if (mounted) {
      _showToast('Connection defaults restored', tone: AppToastTone.success);
    }
  }

  Future<void> _checkConnections() async {
    await _autoSaveConnectionSettings();
    if (!mounted) {
      return;
    }
    await Future.wait([
      _checkMetadata(),
      _checkSync(),
    ]);
  }

  Future<void> _checkMetadata() async {
    final url = _metadataController.text.trim();
    setState(() {
      _metadataDiagnostic = const _DiagnosticState.checking();
    });
    try {
      final data = await ApiClient(baseUrl: url).health();
      if (!mounted) return;
      final status = data['status']?.toString() ?? 'unknown';
      setState(() {
        _metadataDiagnostic = _DiagnosticState.ok('Metadata server: $status');
      });
    } catch (error) {
      if (!mounted) return;
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
      if (!mounted) return;
      final protocol = data['protocol_version']?.toString() ?? 'unknown';
      final version = data['schema_version']?.toString() ?? 'unknown';
      final entities = data['entity_count']?.toString() ?? 'unknown';
      final changes = data['change_count']?.toString() ?? 'unknown';
      setState(() {
        _syncDiagnostic = _DiagnosticState.ok(
          'Sync connected: protocol $protocol, schema $version, $entities entities, $changes events',
        );
        _syncStatusDetails = data;
        _syncDevices = devices;
      });
    } catch (error) {
      if (!mounted) return;
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
    _showToast(_syncResultMessage(sync), tone: _syncResultTone(sync));
  }

  Future<void> _refreshAccountPermissions() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshCurrentUser();
      if (!mounted) {
        return;
      }
      final auth = ref.read(authControllerProvider);
      _showToast(
        auth.isAdmin
            ? 'Account permissions refreshed: admin'
            : 'Account permissions refreshed: standard account',
        tone: AppToastTone.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showToast(
        'Could not refresh permissions: ${_describeError(error)}',
        tone: AppToastTone.error,
      );
    }
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

  Future<void> _copyBackup({required bool clzFriendly}) async {
    final state = await ref.read(shelfProvider.future);
    final db = ref.read(localDatabaseProvider);
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final cfValues = await cfRepo.listAllValues();
    final csv = CollectionCsv();
    final data = clzFriendly
        ? csv.exportClzFriendlyShelf(
            state.entries,
            customFieldDefinitions: cfDefs,
            customFieldValuesByItem: cfValues,
          )
        : csv.exportShelf(
            state.entries,
            customFieldDefinitions: cfDefs,
            customFieldValuesByItem: cfValues,
          );
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) {
      return;
    }
    _showToast(
      clzFriendly
          ? 'CLZ-friendly CSV backup copied'
          : 'Collectarr CSV backup copied',
      tone: AppToastTone.success,
    );
  }

  Future<void> _showImportExportWizard({required int initialIndex}) async {
    final state = await ref.read(shelfProvider.future);
    final db = ref.read(localDatabaseProvider);
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final cfValues = await cfRepo.listAllValues();
    if (!mounted) {
      return;
    }
    final imported = await showDialog<int>(
      context: context,
      builder: (context) => ImportExportWizardDialog(
        entries: state.entries,
        initialIndex: initialIndex,
        customFieldDefinitions: cfDefs,
        customFieldValuesByItem: cfValues,
      ),
    );
    if (imported != null && mounted) {
      _showToast(
        'Imported $imported rows into your collection',
        tone: AppToastTone.success,
      );
    }
  }

  Future<void> _copySyncBackupGuide() async {
    final guide = [
      'Sync backup',
      '1. Stop collectarr-sync.',
      '2. Copy collectarr-sync.db plus -wal/-shm sidecars if present.',
      '3. Store the backup with the SYNC_API_KEY used by your devices.',
      '4. Restore while collectarr-sync is stopped, then run Check sync service.',
      '5. If conflicts appear after restore, choose Keep service or Keep local in Settings.',
      '',
      'Docker:',
      'docker compose --profile sync stop sync',
      'docker compose --profile sync cp sync:/data ./collectarr-sync-data',
      'Compress-Archive -Path .\\collectarr-sync-data\\* -DestinationPath .\\collectarr-sync-data.zip -Force',
      '',
      'Restore:',
      'docker compose --profile sync stop sync',
      'docker compose --profile sync cp ./collectarr-sync-data/. sync:/data',
      'docker compose --profile sync start sync',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: guide));
    if (!mounted) {
      return;
    }
    _showToast('Sync backup guide copied', tone: AppToastTone.success);
  }

  Future<void> _clearProposalHistory() async {
    await const MetadataProposalStore().clear();
    if (mounted) {
      ref.invalidate(_metadataProposalHistoryProvider);
      setState(() {});
      _showToast('Local proposal history cleared', tone: AppToastTone.success);
    }
  }

  Future<void> _regenerateDeviceId() async {
    await DeviceIdentity().regenerate();
    ref.invalidate(_deviceIdentityProvider);
    if (mounted) {
      _showToast('Device id regenerated', tone: AppToastTone.success);
    }
  }

  void _showToast(String message, {AppToastTone tone = AppToastTone.info}) {
    if (!mounted) {
      return;
    }
    showAppToast(context, message, tone: tone);
  }

  String _describeError(Object error) {
    final text = error.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    if (text.startsWith('StateError: ')) {
      return text.substring('StateError: '.length);
    }
    return text;
  }

  AppToastTone _syncResultTone(SyncState sync) {
    if (sync.errorMessage != null) {
      return AppToastTone.error;
    }
    if (sync.warningMessage != null) {
      return AppToastTone.info;
    }
    return AppToastTone.success;
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

class _LibraryNavSettings extends StatelessWidget {
  const _LibraryNavSettings({
    required this.catalog,
    required this.preferences,
    required this.onPlacementChanged,
    required this.onOrderChanged,
    required this.onVisibilityChanged,
    required this.onReset,
  });

  final List<CatalogMediaType> catalog;
  final LibraryNavPreferences preferences;
  final ValueChanged<LibraryNavPlacement> onPlacementChanged;
  final ValueChanged<List<String>> onOrderChanged;
  final void Function(String kind, bool visible) onVisibilityChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final types = _orderedSettingsMediaTypes(catalog, preferences);
    final visibleTypes = [
      for (final type in types)
        if (preferences.isVisible(type.kind)) type,
    ];
    final hiddenCount = types.length - visibleTypes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LibraryNavSummary(
          visibleCount: visibleTypes.length,
          hiddenCount: hiddenCount,
          placement: preferences.placement,
        ),
        const SizedBox(height: 12),
        Text(
          'Position',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            SegmentedButton<LibraryNavPlacement>(
              segments: const [
                ButtonSegment(
                  value: LibraryNavPlacement.top,
                  icon: Icon(Icons.view_week_outlined),
                  label: Text('Top bar'),
                ),
                ButtonSegment(
                  value: LibraryNavPlacement.left,
                  icon: Icon(Icons.vertical_split_outlined),
                  label: Text('Left rail'),
                ),
              ],
              selected: {preferences.placement},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  onPlacementChanged(selection.first),
            ),
            Text(
              preferences.placement == LibraryNavPlacement.top
                  ? 'Extra libraries collapse into More when the window is narrow.'
                  : 'The vertical rail keeps libraries visible on dense desktop layouts.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LibraryNavPreview(
          types: visibleTypes.isEmpty ? types.take(1).toList() : visibleTypes,
          placement: preferences.placement,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Libraries',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset library navigation'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Drag rows or use the arrow buttons to reorder. Hidden libraries are removed from the top bar/rail, but can be restored here.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: types.length,
          onReorderItem: (oldIndex, newIndex) {
            final reordered = types.map((type) => type.kind).toList();
            final moved = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, moved);
            onOrderChanged(reordered);
          },
          itemBuilder: (context, index) {
            final type = types[index];
            final visible = preferences.isVisible(type.kind);
            final reordered = types.map((type) => type.kind).toList();
            return ListTile(
              key: ValueKey('library-nav-${type.kind}'),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: SizedBox(
                width: 74,
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    const SizedBox(width: 6),
                    _LibraryNavTypeIcon(type: type),
                  ],
                ),
              ),
              title: Text(type.pluralLabel),
              subtitle: Text(
                [
                  visible ? 'Visible' : 'Hidden',
                  type.providers.isEmpty
                      ? 'No provider'
                      : 'Providers: ${type.providers.join(', ')}',
                ].join(' | '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                children: [
                  IconButton(
                    tooltip: 'Move up',
                    onPressed: index == 0
                        ? null
                        : () {
                            final moved = reordered.removeAt(index);
                            reordered.insert(index - 1, moved);
                            onOrderChanged(reordered);
                          },
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: 'Move down',
                    onPressed: index == types.length - 1
                        ? null
                        : () {
                            final moved = reordered.removeAt(index);
                            reordered.insert(index + 1, moved);
                            onOrderChanged(reordered);
                          },
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  Switch(
                    value: visible,
                    onChanged: (value) => onVisibilityChanged(
                      type.kind,
                      value,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LibraryNavSummary extends StatelessWidget {
  const _LibraryNavSummary({
    required this.visibleCount,
    required this.hiddenCount,
    required this.placement,
  });

  final int visibleCount;
  final int hiddenCount;
  final LibraryNavPlacement placement;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SettingsMiniStat(
          icon: Icons.visibility_outlined,
          label: '$visibleCount visible',
        ),
        _SettingsMiniStat(
          icon: Icons.visibility_off_outlined,
          label: '$hiddenCount hidden',
        ),
        _SettingsMiniStat(
          icon: placement == LibraryNavPlacement.top
              ? Icons.view_week_outlined
              : Icons.vertical_split_outlined,
          label: placement == LibraryNavPlacement.top ? 'Top bar' : 'Left rail',
        ),
        const _SettingsMiniStat(
          icon: Icons.more_horiz,
          label: 'Overflow uses More',
        ),
      ],
    );
  }
}

class _LibraryNavPreview extends StatelessWidget {
  const _LibraryNavPreview({
    required this.types,
    required this.placement,
  });

  final List<CatalogMediaType> types;
  final LibraryNavPlacement placement;

  @override
  Widget build(BuildContext context) {
    final visible = types.take(5).toList();
    final overflow = types.length - visible.length;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: placement == LibraryNavPlacement.left
            ? Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final type in visible.take(4))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _LibraryNavPreviewTile(type: type),
                          ),
                        if (overflow > 0)
                          _LibraryNavPreviewBadge(label: '+$overflow'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Left rail keeps library switching pinned beside the workspace.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final type in visible)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _LibraryNavPreviewButton(type: type),
                            ),
                          if (overflow > 0)
                            _LibraryNavPreviewBadge(label: 'More +$overflow'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LibraryNavTypeIcon extends StatelessWidget {
  const _LibraryNavTypeIcon({required this.type});

  final CatalogMediaType type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: libraryAccentForKind(type.kind).withValues(alpha: 0.18),
        border: Border.all(color: libraryAccentForKind(type.kind)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox.square(
        dimension: 30,
        child: Icon(
          libraryIconForKind(type.kind),
          size: 17,
          color: libraryAccentForKind(type.kind),
        ),
      ),
    );
  }
}

class _LibraryNavPreviewButton extends StatelessWidget {
  const _LibraryNavPreviewButton({required this.type});

  final CatalogMediaType type;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.22),
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(libraryIconForKind(type.kind), size: 15, color: accent),
            const SizedBox(width: 5),
            Text(
              type.pluralLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryNavPreviewTile extends StatelessWidget {
  const _LibraryNavPreviewTile({required this.type});

  final CatalogMediaType type;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.20),
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox.square(
        dimension: 36,
        child: Icon(libraryIconForKind(type.kind), size: 18, color: accent),
      ),
    );
  }
}

class _LibraryNavPreviewBadge extends StatelessWidget {
  const _LibraryNavPreviewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _SettingsMiniStat extends StatelessWidget {
  const _SettingsMiniStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTabBody extends StatelessWidget {
  const _SettingsTabBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _TabResetActions extends StatelessWidget {
  const _TabResetActions({
    required this.label,
    required this.onReset,
  });

  final String label;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.restart_alt),
        label: Text(label),
      ),
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

List<CatalogMediaType> _orderedSettingsMediaTypes(
  List<CatalogMediaType> catalog,
  LibraryNavPreferences preferences,
) {
  final topLevelByKind = {
    for (final type in catalog)
      if (type.isTopLevel) type.kind: type,
  };
  final defaultKinds = [
    for (final config in collectarrLibraryTypes.types)
      config.workspace.kind.apiValue,
  ];
  final orderedKinds = preferences.orderedKinds([
    ...defaultKinds,
    ...topLevelByKind.keys,
  ]);
  final ordered = <CatalogMediaType>[];
  for (final kind in orderedKinds) {
    final type = topLevelByKind.remove(kind);
    if (type != null) {
      ordered.add(type);
    }
  }
  ordered.addAll(topLevelByKind.values.toList()
    ..sort((a, b) => a.pluralLabel.compareTo(b.pluralLabel)));
  return ordered.isEmpty
      ? fallbackMediaCatalog.where((type) => type.isTopLevel).toList()
      : ordered;
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
                  icon: Icons.account_tree_outlined,
                  label: 'protocol ${status['protocol_version'] ?? '-'}',
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
    required this.onKeepLocal,
    required this.onDismiss,
    required this.onDismissAll,
  });

  final List<SyncRejectedChange> changes;
  final Future<void> Function(SyncRejectedChange change) onKeepLocal;
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
            const Text(
              'Use Keep local when this device should overwrite the service on the next sync. Use Keep service when the service version is correct.',
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
                      tooltip: 'View payload diff',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) =>
                            _SyncConflictDiffDialog(change: change),
                      ),
                      icon: const Icon(Icons.difference_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Copy conflict id',
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: change.key),
                      ),
                      icon: const Icon(Icons.copy_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Keep local version',
                      onPressed: () => onKeepLocal(change),
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
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

class _SyncConflictDiffDialog extends StatelessWidget {
  const _SyncConflictDiffDialog({required this.change});

  final SyncRejectedChange change;

  @override
  Widget build(BuildContext context) {
    final localPayload = change.localPayload ?? const <String, dynamic>{};
    final servicePayload = change.servicePayload ?? const <String, dynamic>{};
    return AlertDialog(
      title: const Text('Sync conflict diff'),
      content: SizedBox(
        width: 860,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ConflictDiffChip(label: change.entityType),
                  _ConflictDiffChip(label: _shortSyncId(change.entityId)),
                  _ConflictDiffChip(label: change.reason),
                  if (change.localAction != null)
                    _ConflictDiffChip(label: 'local ${change.localAction}'),
                  if (change.serviceAction != null)
                    _ConflictDiffChip(
                      label: 'service ${change.serviceAction}',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final panels = [
                    _PayloadPanel(
                      title: 'Local rejected payload',
                      timestamp: change.localClientChangedAt,
                      payload: localPayload,
                    ),
                    _PayloadPanel(
                      title: 'Service kept payload',
                      timestamp: change.currentClientChangedAt,
                      payload: servicePayload,
                    ),
                  ];
                  if (constraints.maxWidth < 720) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        panels[0],
                        const SizedBox(height: 12),
                        panels[1],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: panels[0]),
                      const SizedBox(width: 12),
                      Expanded(child: panels[1]),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _PayloadPanel extends StatelessWidget {
  const _PayloadPanel({
    required this.title,
    required this.payload,
    this.timestamp,
  });

  final String title;
  final DateTime? timestamp;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatProposalTime(timestamp!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            SelectableText(
              encoded,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictDiffChip extends StatelessWidget {
  const _ConflictDiffChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
  final label = SyncWarningFormatter.reasonLabel(change.reason);
  final current = change.currentClientChangedAt;
  if (current == null) {
    return label;
  }
  return '$label, service kept ${_formatProposalTime(current)}';
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

class _ImportSourcesGrid extends ConsumerWidget {
  const _ImportSourcesGrid({required this.tmdbSettings});

  final TmdbImportSettings tmdbSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 150,
          ),
          itemCount: providerImportDescriptors.length,
          itemBuilder: (context, index) {
            final descriptor = providerImportDescriptors[index];
            final isAvailable = descriptor.availability ==
                ProviderImportAvailability.available;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAvailable
                      ? theme.colorScheme.outline.withValues(alpha: 0.4)
                      : theme.dividerColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          providerImportIcon(descriptor.id),
                          size: 22,
                          color: isAvailable
                              ? theme.colorScheme.primary
                              : theme.hintColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            descriptor.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Coming soon',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descriptor.summary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isAvailable)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () => _openProvider(
                            context,
                            ref,
                            descriptor.id,
                          ),
                          icon: const Icon(Icons.import_export_outlined,
                              size: 18),
                          label: const Text('Import'),
                        ),
                      )
                    else if (descriptor.supportsFileImport)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.upload_file_outlined,
                              size: 18),
                          label: const Text('Select CSV File'),
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.sync_outlined, size: 18),
                          label: const Text('Import'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openProvider(
    BuildContext context,
    WidgetRef ref,
    ProviderImportId id,
  ) {
    switch (id) {
      case ProviderImportId.tmdb:
        showDialog<void>(
          context: context,
          builder: (_) => ProviderImportsDialog(
            initialTmdbSettings: tmdbSettings,
          ),
        );
      default:
        break;
    }
  }
}
