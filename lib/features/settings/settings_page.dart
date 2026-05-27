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
import 'package:collectarr_app/features/settings/database_backup.dart';
import 'package:collectarr_app/features/settings/import_job_provider.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
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
import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

part 'settings_connection_widgets.dart';
part 'settings_library_nav_widgets.dart';
part 'settings_data_import_widgets.dart';

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
              key: ValueKey(accent),
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
                          readOnly: true,
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
                                        color: appPalette(context).textSecondary,
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
                          secondary: Icon(
                            ref.watch(appThemeModeProvider) == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          title: const Text('Dark mode'),
                          subtitle: const Text(
                            'Switch between dark and light theme.',
                          ),
                          value:
                              ref.watch(appThemeModeProvider) == ThemeMode.dark,
                          onChanged: (value) => ref
                              .read(appThemeModeProvider.notifier)
                              .setMode(
                                  value ? ThemeMode.dark : ThemeMode.light),
                        ),
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
                        const Divider(height: 24),
                        Text('Cover grid',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.grid_view_sharp),
                          title: const Text('Flat covers'),
                          subtitle: const Text(
                            'Remove shadows and borders from cover tiles.',
                          ),
                          value: uiPreferences.flatCovers,
                          onChanged: (value) => ref
                              .read(uiPreferencesProvider.notifier)
                              .setFlatCovers(value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.title),
                          title: const Text('Show titles in grid'),
                          subtitle: const Text(
                            'Show title text below covers in grid view.',
                          ),
                          value: uiPreferences.showCoverTitles,
                          onChanged: (value) => ref
                              .read(uiPreferencesProvider.notifier)
                              .setShowCoverTitles(value),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.space_bar),
                          title: const Text('Grid spacing'),
                          subtitle: Slider(
                            value: uiPreferences.gridSpacing,
                            min: 4,
                            max: 14,
                            divisions: 10,
                            label:
                                '${uiPreferences.gridSpacing.round()} px',
                            onChanged: (value) => ref
                                .read(uiPreferencesProvider.notifier)
                                .setGridSpacing(value.roundToDouble()),
                          ),
                        ),
                        const Divider(height: 24),
                        Text('Card view',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.photo_size_select_large),
                          title: const Text('Card cover width'),
                          subtitle: Slider(
                            value: uiPreferences.cardCoverWidth,
                            min: 60,
                            max: 120,
                            divisions: 12,
                            label:
                                '${uiPreferences.cardCoverWidth.round()} px',
                            onChanged: (value) => ref
                                .read(uiPreferencesProvider.notifier)
                                .setCardCoverWidth(value.roundToDouble()),
                          ),
                        ),
                        const Divider(height: 24),
                        Text('Layout',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.add_circle_outline),
                          title: const Text('Floating Add button'),
                          subtitle: const Text(
                            'Use a floating action button instead of inline toolbar button.',
                          ),
                          value: uiPreferences.fabAddButton,
                          onChanged: (value) => ref
                              .read(uiPreferencesProvider.notifier)
                              .setFabAddButton(value),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.density_small),
                          title: const Text('Sidebar row padding'),
                          subtitle: Slider(
                            value: uiPreferences.sidebarRowPadding,
                            min: 0,
                            max: 8,
                            divisions: 8,
                            label:
                                '${uiPreferences.sidebarRowPadding.round()} px',
                            onChanged: (value) => ref
                                .read(uiPreferencesProvider.notifier)
                                .setSidebarRowPadding(value.roundToDouble()),
                          ),
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
                        const _ImportJobsPanel(),
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
                  _SettingsPanel(
                    icon: Icons.save_outlined,
                    title: 'Database backup & restore',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create a full JSON backup of your local database, or restore from a previous backup. '
                          'This includes all collection, wishlist, tracking, custom fields, locations, smart lists, and queue data.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _backupDatabase,
                              icon: const Icon(Icons.save_alt_outlined),
                              label: const Text('Backup to JSON'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _restoreDatabase,
                              icon: const Icon(Icons.restore_outlined),
                              label: const Text('Restore from JSON'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _SettingsPanel(
                    icon: Icons.delete_forever_outlined,
                    title: 'Clear database',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Permanently delete ALL local data including collection, wishlist, tracking, custom fields, and settings. '
                          'This cannot be undone.',
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: _clearDatabase,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Clear entire database'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.errorContainer,
                              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                            ),
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
                                  ? 'Full admin access: dashboard, ingest jobs, logs, system management, and all catalog operations.'
                                  : 'Catalog search, proposals, corrections, and provider workflows are available. Admin-only tools (dashboard, ingest jobs, logs) are hidden.'
                              : 'You can browse the app and send metadata proposals without signing in. Sign in is only needed for server features.',
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
    await ref.read(uiPreferencesProvider.notifier).resetDefaults();
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

  Future<void> _backupDatabase() async {
    try {
      final db = ref.read(localDatabaseProvider);
      final backup = DatabaseBackup(db);
      final json = await backup.exportJson();
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'collectarr_backup_$stamp.json';
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON', extensions: ['json']),
        ],
      );
      if (location == null) return;
      final file = XFile.fromData(
        utf8.encode(json),
        mimeType: 'application/json',
        name: fileName,
      );
      await file.saveTo(location.path);
      if (mounted) {
        _showToast('Backup saved', tone: AppToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Backup failed: ${_describeError(e)}',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON', extensions: ['json']),
        ],
      );
      if (file == null) return;
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore database'),
          content: const Text(
            'This will replace ALL local data with the backup contents. '
            'Any current data will be lost. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final content = await file.readAsString();
      final data = jsonDecode(content);
      if (data is! Map<String, dynamic>) {
        _showToast('Invalid backup file', tone: AppToastTone.error);
        return;
      }
      final db = ref.read(localDatabaseProvider);
      await DatabaseBackup(db).import(data);
      if (mounted) {
        _showToast('Database restored', tone: AppToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Restore failed: ${_describeError(e)}',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _clearDatabase() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear database'),
        content: const Text(
          'This will permanently delete ALL local data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (firstConfirm != true || !mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'All collection data, tracking history, custom fields, '
          'locations, smart lists, and reading queues will be '
          'permanently erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Yes, delete everything'),
          ),
        ],
      ),
    );
    if (secondConfirm != true || !mounted) return;

    try {
      final db = ref.read(localDatabaseProvider);
      await DatabaseBackup(db).clearAll();
      if (mounted) {
        _showToast('Database cleared', tone: AppToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Clear failed: ${_describeError(e)}',
            tone: AppToastTone.error);
      }
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
