import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_kind_menu.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/stats/stats_dashboard.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/settings/custom_fields_settings.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/features/sync/presentation/sync_status_overlay.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _didRequestInitialOnlineFirstSync = false;
  int _drawerRequestSequence = 0;

  /// Branch indices in the GoRouter StatefulShellRoute:
  /// 0 = libraries, 1 = shelf, 2 = loans, 3 = calendar, 4 = admin, 5 = settings
  static const _branchLibraries = 0;
  static const _branchShelf = 1;
  static const _branchLoans = 2;
  static const _branchCalendar = 3;
  static const _branchAdmin = 4;
  static const _branchSettings = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRequestInitialOnlineFirstSync) {
        return;
      }
      _didRequestInitialOnlineFirstSync = true;
      ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final libraryTypes = selectableLibraryHomeTypes(catalog, navPreferences);
    final selectedKind = ref.watch(selectedLibraryKindProvider);
    final activeLibrary = selectedLibraryHomeType(
      libraryTypes,
      canonicalLibraryNavKind(selectedKind) ?? selectedKind,
    ).kind;
    final activeKind = catalogMediaKindFromValue(activeLibrary);
    final activeType = defaultLibraryKindRegistry.require(activeKind);
    final accent = libraryAccentForKind(activeKind);
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final mediaQuery = MediaQuery.maybeOf(context);
    final accentTheme = buildLibraryAccentTheme(Theme.of(context), accent);
    final toolbarIconStyle = Theme.of(context).iconButtonTheme.style?.copyWith(
              backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
            ) ??
        IconButton.styleFrom(backgroundColor: Colors.transparent);

    final shell = LibraryAccentScope(
      kind: activeLibrary,
      accent: accent,
      animationsEnabled: uiPreferences.animationsEnabled,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          automaticallyImplyLeading: false,
          leadingWidth: 44,
          leading: Builder(
            builder: (context) => IconButton(
              key: const Key('app.open-navigation'),
              tooltip: 'Open navigation',
              visualDensity: VisualDensity.compact,
              style: toolbarIconStyle,
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
          titleSpacing: 2,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.library_music_outlined, size: 19),
              SizedBox(width: 7),
              Text('Collectarr'),
            ],
          ),
          backgroundColor: libraryAccentChromeFallbackColor(accent),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 19),
          flexibleSpace: LibraryAccentChrome(
            accent: accent,
            animationDuration: uiPreferences.animationsEnabled
                ? kAppAnimNormal
                : Duration.zero,
          ),
          actions: [
            MediaLibraryKindMenu(
              types: libraryTypes,
              registry: defaultLibraryKindRegistry,
              onSelected: (type) {
                ref
                    .read(selectedLibraryKindProvider.notifier)
                    .select(type.kind);
                final libraryUri = Uri(
                  path: '/libraries',
                  queryParameters: {'kind': type.kind},
                );
                context.go(libraryUri.toString());
              },
            ),
            IconButton(
              key: const Key('nav.settings'),
              tooltip: 'Settings',
              visualDensity: VisualDensity.compact,
              style: toolbarIconStyle,
              onPressed: () => widget.navigationShell.goBranch(
                _branchSettings,
                initialLocation:
                    widget.navigationShell.currentIndex == _branchSettings,
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 4),
          ],
        ),
        drawer: _AppNavigationDrawer(
          currentBranch: widget.navigationShell.currentIndex,
          isAdmin: auth.isAdmin,
          accent: accent,
          addLabel: 'Add ${activeType.identity.pluralLabel} from Core',
          onSelected: (drawerContext, action) {
            Navigator.of(drawerContext).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _handleDrawerAction(
                action,
                type: activeType,
                accent: accent,
              );
            });
          },
        ),
        body: Stack(
          children: [
            AnimatedTheme(
              data: accentTheme,
              duration: uiPreferences.animationsEnabled
                  ? kAppAnimNormal
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              child: widget.navigationShell,
            ),
            const SyncStatusOverlay(),
          ],
        ),
      ),
    );
    if (mediaQuery == null) {
      return shell;
    }
    return MediaQuery(
      data: mediaQuery.copyWith(
        disableAnimations:
            mediaQuery.disableAnimations || !uiPreferences.animationsEnabled,
      ),
      child: shell,
    );
  }

  void _handleDrawerAction(
    _DrawerAction action, {
    required LibraryKindRegistration type,
    required Color accent,
  }) {
    switch (action) {
      case _DrawerAction.addFromCore:
        showLibraryAddDialog(context: context, type: type, accent: accent);
        return;
      case _DrawerAction.managePickLists:
        showPickListManagerDialog(
          context: context,
          db: ref.read(localDatabaseProvider),
          registry: defaultPickListRegistry,
        );
        return;
      case _DrawerAction.manageCollections:
        _goToBranch(_AppShellState._branchShelf);
        return;
      case _DrawerAction.printToPdf:
        _withShelf((shelf) {
          final items = libraryItemsForShelf(shelf, type);
          return printCollectionReport(
            context: context,
            title: type.identity.title,
            items: items,
          );
        });
        return;
      case _DrawerAction.statistics:
        _withShelf((shelf) {
          return showStatsDashboardDialog(
            context,
            type: type,
            state: _shelfForKind(shelf, type.kind),
          );
        });
        return;
      case _DrawerAction.findDuplicates:
        _withShelf((shelf) {
          final entries = shelf.entries
              .where((entry) => entry.mediaKind == type.kind)
              .toList(growable: false);
          return showDuplicateItemsDialog(
            context,
            duplicateGroups: findDuplicateShelfGroups(entries),
          );
        });
        return;
      case _DrawerAction.loanManager:
        _goToBranch(_AppShellState._branchLoans);
        return;
      case _DrawerAction.manageCustomFields:
        showCustomFieldsManagementDialog(
          context: context,
          db: ref.read(localDatabaseProvider),
        );
        return;
      case _DrawerAction.cloudSharing:
        _goToSettingsSection(SettingsSection.connection);
        return;
      case _DrawerAction.prefillSettings:
        showPrefillSettingsDialog(context: context, accent: accent);
        return;
      case _DrawerAction.settings:
        _goToSettingsSection(SettingsSection.connection);
        return;
      case _DrawerAction.libraries:
        _goToBranch(_AppShellState._branchLibraries);
        return;
      case _DrawerAction.calendar:
        _goToBranch(_AppShellState._branchCalendar);
        return;
      case _DrawerAction.admin:
        _goToBranch(_AppShellState._branchAdmin);
        return;
      case _DrawerAction.reassignIndex:
      case _DrawerAction.transferFieldData:
        _openLibraryTool(action);
        return;
      case _DrawerAction.backupRestore:
      case _DrawerAction.clearDatabase:
        _goToSettingsSection(SettingsSection.data);
        return;
      case _DrawerAction.exportCsv:
        _openShelfImportExport(initialIndex: 0);
        return;
      case _DrawerAction.exportXml:
        _openShelfImportExport(initialIndex: 0);
        return;
      case _DrawerAction.importData:
        _openShelfImportExport(initialIndex: 1);
        return;
      case _DrawerAction.linkAlbums:
        _showUnavailableAction(
          'Link Albums',
          'Album linking is not available in Collectarr yet.',
        );
        return;
      case _DrawerAction.keyboardShortcuts:
        showKeyboardShortcutsDialog(context);
        return;
    }
  }

  void _goToBranch(int branch) {
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  void _openLibraryTool(_DrawerAction action) {
    _goToBranch(_AppShellState._branchLibraries);
    final toolName = action == _DrawerAction.reassignIndex
        ? 'Re-Assign Index Values'
        : 'Transfer Field Data';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open the library Tools menu to use $toolName.'),
      ),
    );
  }

  void _showUnavailableAction(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _goToSettingsSection(SettingsSection section) {
    context.go('${AppRoutes.settings}?section=${section.name}');
  }

  void _openShelfImportExport({required int initialIndex}) {
    final request = ++_drawerRequestSequence;
    context.go(
      '${AppRoutes.shelf}?wizard=$initialIndex&request=$request',
    );
  }

  Future<void> _withShelf(
    Future<void> Function(ShelfState shelf) action,
  ) async {
    try {
      final shelf = await ref.read(shelfProvider.future);
      if (!mounted) return;
      await action(shelf);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load the collection: $error')),
      );
    }
  }

  ShelfState _shelfForKind(ShelfState shelf, CatalogMediaKind kind) {
    final entries = shelf.entries
        .where((entry) => entry.mediaKind == kind)
        .toList(growable: false);
    final owned = entries
        .where((entry) => entry.isEntry && entry.libraryEntrySummary != null)
        .map((entry) => entry.libraryEntrySummary!)
        .toList(growable: false);
    final paid = owned
        .where(
            (entry) => entry.pricePaidCents != null && entry.currency != null)
        .toList(growable: false);
    final currencies = paid.map((entry) => entry.currency!).toSet();
    final mixedCurrencies = currencies.length > 1;
    final active = owned.where((entry) => !entry.isDeleted).toList();
    final kindKey = kind.apiValue;
    final locationCounts = <String, int>{};
    for (final entry in entries.where((entry) => entry.isEntry)) {
      final label = entry.locationPath ?? 'No location';
      locationCounts.update(label, (count) => count + 1, ifAbsent: () => 1);
    }
    return ShelfState(
      entries: entries,
      entryCount: active.length,
      wishlistCount: entries.where((entry) => entry.isWishlisted).length,
      pricedCount: paid.length,
      totalPaidCents: mixedCurrencies
          ? null
          : paid.fold<int>(0, (total, entry) => total + entry.pricePaidCents!),
      primaryCurrency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: mixedCurrencies,
      wishlistItemCountByKind: {
        kindKey: entries.where((entry) => entry.isWishlisted).length,
      },
      missingMetadataCount:
          entries.where((entry) => entry.catalogSummary == null).length,
      locationCounts: locationCounts,
      soldCount: active.where((entry) => entry.soldAt != null).length,
      totalSellCents: mixedCurrencies
          ? null
          : active
              .where((entry) => entry.sellPriceCents != null)
              .fold<int>(0, (total, entry) => total + entry.sellPriceCents!),
      marketValuedCount:
          active.where((entry) => entry.marketValueCents != null).length,
      totalMarketValueCents: mixedCurrencies
          ? null
          : active
              .where((entry) => entry.marketValueCents != null)
              .fold<int>(0, (total, entry) => total + entry.marketValueCents!),
      libraryEntryCountByKind: {kindKey: active.length},
    );
  }
}

enum _DrawerAction {
  addFromCore,
  managePickLists,
  manageCollections,
  printToPdf,
  statistics,
  findDuplicates,
  loanManager,
  libraries,
  calendar,
  admin,
  manageCustomFields,
  cloudSharing,
  prefillSettings,
  settings,
  reassignIndex,
  backupRestore,
  clearDatabase,
  transferFieldData,
  exportCsv,
  exportXml,
  importData,
  linkAlbums,
  keyboardShortcuts,
}

class _AppNavigationDrawer extends StatelessWidget {
  const _AppNavigationDrawer({
    required this.currentBranch,
    required this.isAdmin,
    required this.accent,
    required this.addLabel,
    required this.onSelected,
  });

  final int currentBranch;
  final bool isAdmin;
  final Color accent;
  final String addLabel;
  final void Function(BuildContext context, _DrawerAction action) onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.86)
          .clamp(0.0, 320.0)
          .toDouble(),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 46,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              color: libraryAccentChromeFallbackColor(accent),
              child: const Row(
                children: [
                  Icon(Icons.library_music_outlined,
                      color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Collectarr',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerSectionLabel('Collection', color: palette.textMuted),
                  _action(
                      context, addLabel, Icons.add, _DrawerAction.addFromCore),
                  _action(context, 'Manage Pick Lists',
                      Icons.view_list_outlined, _DrawerAction.managePickLists),
                  _action(context, 'Manage Collections', Icons.storage_outlined,
                      _DrawerAction.manageCollections,
                      branch: _AppShellState._branchShelf),
                  _action(context, 'Libraries', Icons.apps_outlined,
                      _DrawerAction.libraries,
                      branch: _AppShellState._branchLibraries),
                  const Divider(height: 12),
                  _DrawerSectionLabel('Tools', color: palette.textMuted),
                  _action(context, 'Print to PDF', Icons.print_outlined,
                      _DrawerAction.printToPdf),
                  _action(context, 'Statistics', Icons.bar_chart_outlined,
                      _DrawerAction.statistics),
                  _action(context, 'Find Duplicates', Icons.copy_outlined,
                      _DrawerAction.findDuplicates),
                  _action(context, 'Loan Manager', Icons.schedule_outlined,
                      _DrawerAction.loanManager,
                      branch: _AppShellState._branchLoans),
                  _action(context, 'Calendar', Icons.calendar_month_outlined,
                      _DrawerAction.calendar,
                      branch: _AppShellState._branchCalendar),
                  if (isAdmin) ...[
                    const Divider(height: 18),
                    _DrawerSectionLabel('Administration',
                        color: palette.textMuted),
                    _action(
                        context,
                        'Admin',
                        Icons.admin_panel_settings_outlined,
                        _DrawerAction.admin,
                        branch: _AppShellState._branchAdmin),
                  ],
                  const Divider(height: 12),
                  _DrawerSectionLabel('Customization',
                      color: palette.textMuted),
                  _action(context, 'Manage Custom Fields', Icons.edit_note,
                      _DrawerAction.manageCustomFields),
                  _action(context, 'Cloud Sync & Sharing', Icons.cloud_outlined,
                      _DrawerAction.cloudSharing),
                  _action(context, 'Pre-fill Settings', Icons.note_add_outlined,
                      _DrawerAction.prefillSettings),
                  _action(context, 'Settings', Icons.settings_outlined,
                      _DrawerAction.settings,
                      branch: _AppShellState._branchSettings),
                  const Divider(height: 12),
                  _DrawerSectionLabel('Maintenance', color: palette.textMuted),
                  _action(context, 'Re-Assign Index Values',
                      Icons.format_list_numbered, _DrawerAction.reassignIndex),
                  _action(context, 'Backup / Restore', Icons.backup_outlined,
                      _DrawerAction.backupRestore),
                  _action(context, 'Clear Database', Icons.delete_outline,
                      _DrawerAction.clearDatabase),
                  _action(context, 'Transfer Field Data', Icons.swap_horiz,
                      _DrawerAction.transferFieldData),
                  const Divider(height: 12),
                  _DrawerSectionLabel('Import / Export',
                      color: palette.textMuted),
                  _action(context, 'Export to CSV / TXT',
                      Icons.file_download_outlined, _DrawerAction.exportCsv),
                  _action(context, 'Export to XML', Icons.description_outlined,
                      _DrawerAction.exportXml),
                  _action(context, 'Import Data', Icons.file_upload_outlined,
                      _DrawerAction.importData),
                  _action(context, 'Link Albums', Icons.link_outlined,
                      _DrawerAction.linkAlbums),
                  const Divider(height: 12),
                  _DrawerSectionLabel('Help', color: palette.textMuted),
                  _action(context, 'Keyboard Shortcuts',
                      Icons.keyboard_outlined, _DrawerAction.keyboardShortcuts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context,
    String label,
    IconData icon,
    _DrawerAction action, {
    int? branch,
  }) {
    final palette = appPalette(context);
    final selected = branch == currentBranch;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      selected: selected,
      selectedTileColor: accent.withValues(alpha: palette.isDark ? 0.2 : 0.1),
      leading: Icon(
        icon,
        size: 19,
        color: selected ? accent : palette.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? palette.textPrimary : null,
        ),
      ),
      onTap: () => onSelected(context, action),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 7, 12, 5),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
