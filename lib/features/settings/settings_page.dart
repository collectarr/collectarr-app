import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'dart:async';

import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/settings/connection_pairing.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/settings/app_log_viewer_panel.dart';
import 'package:collectarr_app/features/settings/settings_connection_widgets.dart';
import 'package:collectarr_app/features/settings/settings_connection_diagnostics.dart';
import 'package:collectarr_app/features/settings/settings_proposal_history.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/settings/settings_account_section.dart';
import 'package:collectarr_app/features/settings/settings_appearance_section.dart';
import 'package:collectarr_app/features/settings/settings_data_section.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:collectarr_app/features/settings/settings_updates_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'settings_connection_actions.dart';

ThemeData _settingsTheme(BuildContext context) {
  final action = appPalette(context).utilityAction;
  final theme = buildLibraryAccentTheme(Theme.of(context), action);
  return theme.copyWith(
    textTheme: theme.textTheme.copyWith(
      bodyLarge: theme.textTheme.bodyLarge
          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodyMedium: theme.textTheme.bodyMedium
          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      titleMedium: theme.textTheme.titleMedium
          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: theme.textTheme.bodySmall
          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
    ),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      labelStyle:
          TextStyle(color: action, fontSize: 14, fontWeight: FontWeight.w700),
      floatingLabelStyle:
          TextStyle(color: action, fontSize: 14, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: theme.filledButtonTheme.style!.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.disabled)
                ? action.withValues(alpha: .38)
                : action),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.disabled)
                ? Colors.white54
                : Colors.white),
      ),
    ),
  );
}

final _metadataProposalHistoryProvider =
    FutureProvider.autoDispose<List<MetadataProposalRecord>>((ref) async {
  return const MetadataProposalStore().read();
});

// Appearance holds the reference Settings page, so it comes first and opens
// by default; connection and data tabs are Collectarr additions.
enum SettingsSection {
  // Font Awesome glyphs, as everywhere else in the app chrome.
  appearance('Appearance', AppIcons.palette),
  connection('Connection', AppIcons.plug),
  libraries('Libraries', AppIcons.layerGroup),
  proposals('Proposals', AppIcons.clipboardCheck),
  data('Data', AppIcons.database),
  account('Account', AppIcons.user),
  updates('Updates', AppIcons.appUpdate),
  logs('Logs', AppIcons.bug);

  const SettingsSection(this.title, this.icon);
  final String title;
  final IconData icon;
}

SettingsSection? settingsSectionFromRouteValue(String? value) {
  for (final section in SettingsSection.values) {
    if (section.name == value) return section;
  }
  return null;
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    this.showWebSyncWarning = kIsWeb,
    this.initialSection,
  });

  final bool showWebSyncWarning;
  final SettingsSection? initialSection;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _metadataController = TextEditingController();
  final _syncController = TextEditingController();
  final _syncKeyController = TextEditingController();
  SettingsDiagnosticState? _metadataDiagnostic;
  SettingsDiagnosticState? _syncDiagnostic;
  Map<String, dynamic>? _syncStatusDetails;
  List<Map<String, dynamic>> _syncDevices = const [];
  ConnectionSettings? _lastSyncedSettings;
  Timer? _connectionSaveDebounce;
  SettingsSection _selectedSection = SettingsSection.appearance;

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection ?? SettingsSection.appearance;
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection &&
        widget.initialSection != null) {
      _selectedSection = widget.initialSection!;
    }
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
    final sync = ref.watch(syncControllerProvider);
    final mediaCatalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (catalog) => catalog,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final metadataProposalHistory = ref.watch(_metadataProposalHistoryProvider);
    final accent = appPalette(context).utilityAction;
    final isAndroidPlatform =
        Theme.of(context).platform == TargetPlatform.android;
    _syncTextControllers(settings);

    final windowClass = AppWindowClass.of(context);

    Widget buildSection(SettingsSection section) {
      return _buildSectionContent(
        section: section,
        settings: settings,
        sync: sync,
        mediaCatalog: mediaCatalog,
        navPreferences: navPreferences,
        metadataProposalHistory: metadataProposalHistory,
        isAndroidPlatform: isAndroidPlatform,
      );
    }

    if (windowClass.isCompact) {
      return Theme(
        data: _settingsTheme(context),
        child: Scaffold(
          backgroundColor: appManagementCanvasColor(context),
          appBar: AppPageHeader(
              icon: Icons.settings_outlined,
              leading: _buildBackButton(context),
              title: const Text('Settings')),
          body: AppManagementContent(
              child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: SettingsSection.values.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final section = SettingsSection.values[index];
              return ListTile(
                leading: Icon(section.icon, color: accent),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => Theme(
                        data: _settingsTheme(ctx),
                        child: Scaffold(
                          backgroundColor: appManagementCanvasColor(context),
                          appBar: AppPageHeader(
                              icon: Icons.settings_outlined,
                              leading: AppPageBackButton(),
                              title: Text(section.title)),
                          body: AppManagementContent(
                              child: buildSection(section)),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )),
        ),
      );
    }

    return Theme(
      data: _settingsTheme(context),
      child: DefaultTabController(
        key: ValueKey(_selectedSection),
        initialIndex: SettingsSection.values.indexOf(_selectedSection),
        length: SettingsSection.values.length,
        child: Scaffold(
          backgroundColor: appManagementCanvasColor(context),
          appBar: AppPageHeader(
              icon: Icons.settings_outlined,
              leading: _buildBackButton(context),
              title: const Text('Settings'),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                labelColor: appPalette(context).textPrimary,
                unselectedLabelColor: appPalette(context).textSecondary,
                indicatorColor: accent,
                tabs: SettingsSection.values
                    .map((s) => Tab(
                        height: 36,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(s.icon, size: 16),
                          const SizedBox(width: 6),
                          Text(s.title)
                        ])))
                    .toList(),
              )),
          // Room for the reference 958 px page plus its 16 px margins.
          body: AppManagementContent(
              maxWidth: 990,
              child: TabBarView(
                children: SettingsSection.values.map(buildSection).toList(),
              )),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return AppPageBackButton(
        key: const Key('settings.back'),
        onPressed: () => context.go(AppRoutes.forKind(
            AppRoutes.libraries,
            LibraryAccentScope.maybeOf(context)?.kind ??
                ref.read(selectedLibraryKindProvider))));
  }

  Widget _buildSectionContent({
    required SettingsSection section,
    required ConnectionSettings settings,
    required SyncState sync,
    required List<CatalogMediaType> mediaCatalog,
    required LibraryNavPreferences navPreferences,
    required AsyncValue<List<MetadataProposalRecord>> metadataProposalHistory,
    required bool isAndroidPlatform,
  }) {
    switch (section) {
      case SettingsSection.connection:
        return _buildConnectionSection(settings, sync);
      case SettingsSection.libraries:
        return _buildLibrariesSection(
            mediaCatalog, navPreferences, isAndroidPlatform);
      case SettingsSection.appearance:
        return const SettingsAppearanceSection();
      case SettingsSection.proposals:
        return _buildProposalsSection(metadataProposalHistory);
      case SettingsSection.data:
        return const SettingsDataSection();
      case SettingsSection.account:
        return const SettingsAccountSection();
      case SettingsSection.updates:
        return const SettingsUpdatesSection();
      case SettingsSection.logs:
        return _buildLogsSection();
    }
  }

  Widget _buildConnectionSection(
    ConnectionSettings settings,
    SyncState sync,
  ) {
    return SettingsTabBody(
      children: [
        SettingsPanel(
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
              SettingsDiagnosticRow(
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
        SettingsPanel(
          icon: Icons.cloud_sync_outlined,
          title: 'Personal sync service',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showWebSyncWarning) ...[
                const SettingsSyncWebWarning(),
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
                  await ref.read(connectionSettingsProvider.notifier).save(
                        metadataBaseUrl: _metadataController.text,
                        syncBaseUrl: _syncController.text,
                        syncKey: _syncKeyController.text,
                        preferOnlineFirstSync: value,
                      );
                  if (!mounted) {
                    return;
                  }
                  unawaited(ref
                      .read(syncControllerProvider.notifier)
                      .refreshPendingCount());
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
              const SizedBox(height: 8),
              SettingsDiagnosticRow(
                diagnostic: _syncDiagnostic,
                idleLabel: 'Not checked',
              ),
              if (_syncStatusDetails != null) ...[
                const SizedBox(height: 12),
                SettingsSyncServiceSummary(
                  status: _syncStatusDetails!,
                  devices: _syncDevices,
                ),
              ],
              const SizedBox(height: 12),
              if (sync.rejectedChanges.isNotEmpty) ...[
                const SizedBox(height: 12),
                SettingsSyncConflictSummary(
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
                    onPressed: _checkSyncConnection,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Check sync server connection'),
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
          SettingsPanel(
            icon: Icons.history_outlined,
            title: 'Sync history',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in sync.syncLog.reversed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          entry.success
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          size: 16,
                          color: entry.success ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatSettingsTime(entry.timestamp),
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
        SettingsPanel(
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
        SettingsResetAction(
          label: 'Reset connection defaults',
          onReset: _resetConnectionDefaults,
        ),
      ],
    );
  }

  Widget _buildLibrariesSection(
    List<CatalogMediaType> mediaCatalog,
    LibraryNavPreferences navPreferences,
    bool isAndroidPlatform,
  ) {
    return SettingsTabBody(
      children: [
        SettingsPanel(
          icon: Icons.view_list_outlined,
          title: 'Library customization',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Manage reusable pick lists for edit dialogs, custom fields, filters, and cleanup flows.',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => showPickListManagerDialog(
                    context: context,
                    db: ref.read(localDatabaseProvider),
                    registry: defaultPickListRegistry,
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('Manage pick lists'),
                ),
              ),
            ],
          ),
        ),
        if (!isAndroidPlatform)
          SettingsPanel(
            icon: Icons.keyboard_command_key,
            title: 'Keyboard shortcuts',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Review current shortcuts and manage key bindings. Shortcut remapping will be configurable here.',
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => showKeyboardShortcutsDialog(context),
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('View shortcuts'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProposalsSection(
    AsyncValue<List<MetadataProposalRecord>> metadataProposalHistory,
  ) {
    return SettingsTabBody(
      children: [
        SettingsPanel(
          icon: Icons.outbox_outlined,
          title: 'Metadata proposals',
          child: SettingsMetadataProposalHistory(
            records: metadataProposalHistory.value ?? const [],
            isLoading: metadataProposalHistory.isLoading,
            onClear: _clearProposalHistory,
          ),
        ),
      ],
    );
  }

  Widget _buildLogsSection() {
    return const SettingsTabBody(
      children: [
        SettingsPanel(
          icon: Icons.bug_report_outlined,
          title: 'Application log',
          child: AppLogViewerPanel(),
        ),
      ],
    );
  }

  void _updateConnectionState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  Future<void> _clearProposalHistory() async {
    await const MetadataProposalStore().clear();
    if (mounted) {
      ref.invalidate(_metadataProposalHistoryProvider);
      setState(() {});
      showSettingsToast('Local proposal history cleared',
          tone: AppToastTone.success);
    }
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
}
