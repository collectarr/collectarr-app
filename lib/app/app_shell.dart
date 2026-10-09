import 'dart:async';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/generic/page/collection_tabs.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_kind_menu.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/reports/collection_export_csv_txt.dart';
import 'package:collectarr_app/features/library/reports/collection_import_data.dart';
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
import 'package:collectarr_app/features/sync/presentation/sync_action_button.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final toolbarIconStyle = IconButton.styleFrom(
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white54,
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        side: BorderSide.none);

    final shell = LibraryAccentScope(
      kind: activeLibrary,
      accent: accent,
      animationsEnabled: uiPreferences.animationsEnabled,
      child: Scaffold(
        appBar: widget.navigationShell.currentIndex == _branchSettings
            ? null
            : AppBar(
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
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Image(
                        key: Key('app.brand-logo'),
                        image: AssetImage('web/icons/Icon-maskable-192.png'),
                        width: 23,
                        height: 23,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                  LibraryOverdueLoansAction(
                    selectedKind: activeLibrary,
                    selectedLabel: activeType.identity.pluralLabel,
                  ),
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
                  SyncActionButton(style: toolbarIconStyle),
                  IconButton(
                    key: const Key('nav.settings'),
                    tooltip: 'Settings',
                    visualDensity: VisualDensity.compact,
                    style: toolbarIconStyle,
                    onPressed: () => widget.navigationShell.goBranch(
                      _branchSettings,
                      initialLocation: widget.navigationShell.currentIndex ==
                          _branchSettings,
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
        drawer: AppNavigationDrawer(
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
    DrawerAction action, {
    required LibraryKindRegistration type,
    required Color accent,
  }) {
    switch (action) {
      case DrawerAction.addFromCore:
        showLibraryAddDialog(context: context, type: type, accent: accent);
        return;
      case DrawerAction.managePickLists:
        showPickListManagerDialog(
          context: context,
          db: ref.read(localDatabaseProvider),
          registry: defaultPickListRegistry,
        );
        return;
      case DrawerAction.manageCollections:
        unawaited(_showManageCollections(type));
        return;
      case DrawerAction.openShelf:
        _goToBranch(_AppShellState._branchShelf);
        return;
      case DrawerAction.printToPdf:
        _withShelf((shelf) {
          final items = libraryItemsForShelf(shelf, type);
          return printCollectionReport(
            context: context,
            title: type.identity.title,
            items: items,
            type: type,
            allShelfEntries: shelf.entries,
          );
        });
        return;
      case DrawerAction.statistics:
        _withShelf((shelf) {
          return showStatsDashboardDialog(
            context,
            type: type,
            state: _shelfForKind(shelf, type.kind),
          );
        });
        return;
      case DrawerAction.findDuplicates:
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
      case DrawerAction.loanManager:
        _goToBranch(_AppShellState._branchLoans);
        return;
      case DrawerAction.manageCustomFields:
        showCustomFieldsManagementDialog(
          context: context,
          db: ref.read(localDatabaseProvider),
        );
        return;
      case DrawerAction.cloudSharing:
        _goToSettingsSection(SettingsSection.connection);
        return;
      case DrawerAction.prefillSettings:
        showPrefillSettingsDialog(context: context, accent: accent);
        return;
      case DrawerAction.settings:
        _goToSettingsSection(SettingsSection.connection);
        return;
      case DrawerAction.libraries:
        _goToBranch(_AppShellState._branchLibraries);
        return;
      case DrawerAction.calendar:
        _goToBranch(_AppShellState._branchCalendar);
        return;
      case DrawerAction.admin:
        _goToBranch(_AppShellState._branchAdmin);
        return;
      case DrawerAction.reassignIndex:
      case DrawerAction.transferFieldData:
        _openLibraryTool(action);
        return;
      case DrawerAction.backupRestore:
      case DrawerAction.clearDatabase:
        _goToSettingsSection(SettingsSection.data);
        return;
      case DrawerAction.exportCsv:
        _withShelf((shelf) {
          final items = libraryItemsForShelf(shelf, type);
          return exportCollectionCsvTxt(
            context: context,
            title: type.identity.title,
            items: items,
            type: type,
            allShelfEntries: shelf.entries,
          );
        });
        return;
      case DrawerAction.exportXml:
        _openShelfImportExport(initialIndex: 0);
        return;
      case DrawerAction.importData:
        _withShelf((shelf) {
          return importCollectionData(
            context: context,
            type: type,
            allShelfEntries: shelf.entries,
          );
        });
        return;
      case DrawerAction.linkAlbums:
        _showUnavailableAction(
          'Link Albums',
          'Album linking is not available in Collectarr yet.',
        );
        return;
      case DrawerAction.keyboardShortcuts:
        showKeyboardShortcutsDialog(context);
        return;
    }
  }

  Future<void> _showManageCollections(LibraryKindRegistration type) async {
    await showSmartListsDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: type.kind.apiValue,
      currentFilter: LibraryFilterSelection.none,
      currentTarget: SmartListCriteriaTarget.catalog,
      collectionManager: true,
      allowCurrentViewUpdate: false,
    );
    if (mounted) {
      ref.read(libraryCollectionTabsRevisionProvider.notifier).refresh();
    }
  }

  void _goToBranch(int branch) {
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  void _openLibraryTool(DrawerAction action) {
    _goToBranch(_AppShellState._branchLibraries);
    final toolName = action == DrawerAction.reassignIndex
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

enum DrawerAction {
  addFromCore,
  managePickLists,
  manageCollections,
  openShelf,
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

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({
    super.key,
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
  final void Function(BuildContext context, DrawerAction action) onSelected;

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  bool _maintenanceExpanded = true;
  bool _importExportExpanded = true;
  bool _helpExpanded = true;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final drawerBg = palette.isDark ? const Color(0xFF383838) : palette.surface;
    final sectionHeaderColor = palette.isDark
        ? Colors.white.withValues(alpha: 0.4)
        : palette.textMuted;

    return Drawer(
      backgroundColor: drawerBg,
      width: (MediaQuery.sizeOf(context).width * 0.86)
          .clamp(0.0, 320.0)
          .toDouble(),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 38,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: libraryAccentChromeFallbackColor(widget.accent),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/sidebar_icons/bars.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
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
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  _DrawerSectionLabel('Collection', color: sectionHeaderColor),
                  _action(
                    context,
                    widget.addLabel,
                    'assets/sidebar_icons/plus.svg',
                    DrawerAction.addFromCore,
                  ),
                  _action(
                    context,
                    'Manage Pick Lists',
                    'assets/sidebar_icons/rectangle-list.svg',
                    DrawerAction.managePickLists,
                  ),
                  _action(
                    context,
                    'Manage Collections',
                    'assets/sidebar_icons/coins.svg',
                    DrawerAction.manageCollections,
                  ),
                  _action(
                    context,
                    'My Shelf',
                    'assets/sidebar_icons/rectangle-list.svg',
                    DrawerAction.openShelf,
                    branch: _AppShellState._branchShelf,
                    key: const Key('nav.shelf'),
                  ),
                  _action(
                    context,
                    'Libraries',
                    'assets/sidebar_icons/table-cells-large.svg',
                    DrawerAction.libraries,
                    branch: _AppShellState._branchLibraries,
                    key: const Key('nav.library'),
                  ),
                  const _DrawerDivider(),
                  _DrawerSectionLabel('Tools', color: sectionHeaderColor),
                  _action(
                    context,
                    'Print to PDF',
                    'assets/sidebar_icons/print.svg',
                    DrawerAction.printToPdf,
                  ),
                  _action(
                    context,
                    'Statistics',
                    'assets/sidebar_icons/chart-column.svg',
                    DrawerAction.statistics,
                  ),
                  _action(
                    context,
                    'Find Duplicates',
                    'assets/sidebar_icons/clone.svg',
                    DrawerAction.findDuplicates,
                  ),
                  _action(
                    context,
                    'Loan Manager',
                    'assets/sidebar_icons/clock.svg',
                    DrawerAction.loanManager,
                    branch: _AppShellState._branchLoans,
                    key: const Key('nav.more'),
                  ),
                  _action(
                    context,
                    'Calendar',
                    'assets/sidebar_icons/calendar-days.svg',
                    DrawerAction.calendar,
                    branch: _AppShellState._branchCalendar,
                    key: const Key('nav.calendar'),
                  ),
                  if (widget.isAdmin) ...[
                    const _DrawerDivider(),
                    _DrawerSectionLabel(
                      'Administration',
                      color: sectionHeaderColor,
                    ),
                    _action(
                      context,
                      'Admin',
                      'assets/sidebar_icons/shield-halved.svg',
                      DrawerAction.admin,
                      branch: _AppShellState._branchAdmin,
                    ),
                  ],
                  const _DrawerDivider(),
                  _DrawerSectionLabel(
                    'Customization',
                    color: sectionHeaderColor,
                  ),
                  _action(
                    context,
                    'Manage Custom Fields',
                    'assets/sidebar_icons/pen-to-square.svg',
                    DrawerAction.manageCustomFields,
                  ),
                  _action(
                    context,
                    'Cloud Sync & Sharing',
                    'assets/sidebar_icons/share-nodes.svg',
                    DrawerAction.cloudSharing,
                  ),
                  _action(
                    context,
                    'Pre-fill Settings',
                    'assets/sidebar_icons/file-signature.svg',
                    DrawerAction.prefillSettings,
                  ),
                  _action(
                    context,
                    'Settings',
                    'assets/sidebar_icons/gear.svg',
                    DrawerAction.settings,
                    branch: _AppShellState._branchSettings,
                  ),
                  const _DrawerDivider(),
                  _DrawerCollapsibleSectionLabel(
                    'Maintenance',
                    color: sectionHeaderColor,
                    isExpanded: _maintenanceExpanded,
                    onTap: () => setState(
                      () => _maintenanceExpanded = !_maintenanceExpanded,
                    ),
                  ),
                  _DrawerCollapsibleSection(
                    isExpanded: _maintenanceExpanded,
                    children: [
                      _action(
                        context,
                        'Re-Assign Index Values',
                        'assets/sidebar_icons/arrow-down-1-9.svg',
                        DrawerAction.reassignIndex,
                      ),
                      _action(
                        context,
                        'Backup / Restore',
                        'assets/sidebar_icons/hard-drive.svg',
                        DrawerAction.backupRestore,
                      ),
                      _action(
                        context,
                        'Clear Database',
                        'assets/sidebar_icons/trash.svg',
                        DrawerAction.clearDatabase,
                      ),
                      _action(
                        context,
                        'Transfer Field Data',
                        'assets/sidebar_icons/arrows-turn-right.svg',
                        DrawerAction.transferFieldData,
                      ),
                    ],
                  ),
                  const _DrawerDivider(),
                  _DrawerCollapsibleSectionLabel(
                    'Import / Export',
                    color: sectionHeaderColor,
                    isExpanded: _importExportExpanded,
                    onTap: () => setState(
                      () => _importExportExpanded = !_importExportExpanded,
                    ),
                  ),
                  _DrawerCollapsibleSection(
                    isExpanded: _importExportExpanded,
                    children: [
                      _action(
                        context,
                        'Export to CSV / TXT',
                        'assets/sidebar_icons/file-export.svg',
                        DrawerAction.exportCsv,
                      ),
                      _action(
                        context,
                        'Export to XML',
                        'assets/sidebar_icons/file-export.svg',
                        DrawerAction.exportXml,
                      ),
                      _action(
                        context,
                        'Import Data',
                        'assets/sidebar_icons/file-import.svg',
                        DrawerAction.importData,
                      ),
                      _action(
                        context,
                        'Link Albums',
                        'assets/sidebar_icons/link.svg',
                        DrawerAction.linkAlbums,
                      ),
                    ],
                  ),
                  const _DrawerDivider(),
                  _DrawerCollapsibleSectionLabel(
                    'Help',
                    color: sectionHeaderColor,
                    isExpanded: _helpExpanded,
                    onTap: () => setState(
                      () => _helpExpanded = !_helpExpanded,
                    ),
                  ),
                  _DrawerCollapsibleSection(
                    isExpanded: _helpExpanded,
                    children: [
                      _action(
                        context,
                        'Keyboard Shortcuts',
                        'assets/sidebar_icons/keyboard.svg',
                        DrawerAction.keyboardShortcuts,
                      ),
                    ],
                  ),
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
    String svgAsset,
    DrawerAction action, {
    int? branch,
    Key? key,
  }) {
    final palette = appPalette(context);
    final selected = branch == widget.currentBranch;
    final itemColor = selected
        ? widget.accent
        : (palette.isDark ? Colors.white : palette.textPrimary);

    return InkWell(
      key: key,
      onTap: () => widget.onSelected(context, action),
      hoverColor: palette.isDark ? const Color(0x26FFFFFF) : null,
      child: Container(
        color: selected
            ? widget.accent.withValues(alpha: palette.isDark ? 0.2 : 0.1)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 18,
              child: Center(
                child: SvgPicture.asset(
                  svgAsset,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontFamilyFallback: kAppFontFamilyFallback,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: itemColor,
                ),
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kAppFontFamily,
          fontFamilyFallback: kAppFontFamilyFallback,
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DrawerCollapsibleSectionLabel extends StatelessWidget {
  const _DrawerCollapsibleSectionLabel(
    this.label, {
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0x26FFFFFF),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontFamilyFallback: kAppFontFamilyFallback,
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: SvgPicture.asset(
                'assets/sidebar_icons/chevron-down.svg',
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerCollapsibleSection extends StatelessWidget {
  const _DrawerCollapsibleSection({
    required this.isExpanded,
    required this.children,
  });

  final bool isExpanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: isExpanded
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              )
            : const SizedBox(
                width: double.infinity,
                height: 0,
              ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = appPalette(context).isDark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0x33000000) : const Color(0x1F000000),
            width: 1,
          ),
          bottom: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x33FFFFFF),
            width: 1,
          ),
        ),
      ),
    );
  }
}
