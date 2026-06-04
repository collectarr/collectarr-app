import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LibraryDesktopSecondaryToolbar extends StatelessWidget {
  const LibraryDesktopSecondaryToolbar({
    super.key,
    required this.type,
    required this.viewState,
    required this.adapter,
    required this.counts,
    required this.onEditColumns,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    this.browserMode = LibraryWorkspaceBrowserMode.media,
    this.supportsMediaReleaseSplit = false,
    this.onBrowserModeChanged,
    this.showReleaseFolderBack = false,
    this.releaseFolderLabel,
    this.onReleaseFolderBack,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    required this.selectedBucket,
    required this.onClearBucket,
    required this.quickView,
    required this.hasActiveFilters,
    required this.onQuickViewSelected,
    required this.onClearFilters,
    this.onEditFilters,
    this.activeFilterCount = 0,
    this.onEditSort,
    this.activeSortFavoriteId,
    this.sortFavorites = const [],
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.onManageSortFavorites,
    this.onRandomPick,
    this.onDownloadAllCovers,
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onTransferFieldData,
    this.onReassignIndex,
    this.onPrintReport,
    this.onShareCollection,
    this.groupMode,
    this.folderPreset,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.onGroupModeChanged,
    this.showBottomBorder = true,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceViewState viewState;
  final LibraryMediaAdapter adapter;
  final LibraryToolbarCounts counts;
  final VoidCallback onEditColumns;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final LibraryWorkspaceBrowserMode browserMode;
  final bool supportsMediaReleaseSplit;
  final ValueChanged<LibraryWorkspaceBrowserMode>? onBrowserModeChanged;
  final bool showReleaseFolderBack;
  final String? releaseFolderLabel;
  final VoidCallback? onReleaseFolderBack;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback? onEditSort;
  final String? selectedBucket;
  final VoidCallback onClearBucket;
  final LibraryQuickView? quickView;
  final bool hasActiveFilters;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final VoidCallback onClearFilters;
  final VoidCallback? onEditFilters;
  final int activeFilterCount;
  final String? activeSortFavoriteId;
  final List<LibrarySortFavorite> sortFavorites;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final VoidCallback? onManageSortFavorites;
  final VoidCallback? onRandomPick;
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onPrintReport;
  final VoidCallback? onShareCollection;
  final LibraryFolderPreset? folderPreset;
  final LibraryGroupMode? groupMode;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final ValueChanged<LibraryFolderPreset>? onGroupModeChanged;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final mediaScopeLabel = type.mediaReleaseScopeLabel;
    final pinnedColumnPresets = [
      for (final preset in columnFavoritePresets)
        if (pinnedColumnFavoriteKeys.contains(libraryColumnFavoriteKey(preset)))
          preset,
    ];
    final overflowColumnPresets = [
      for (final preset in columnFavoritePresets)
        if (!pinnedColumnFavoriteKeys
            .contains(libraryColumnFavoriteKey(preset)))
          preset,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: palette.divider))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (!viewState.isSidebarVisible &&
                        onGroupModeChanged != null) ...[
                      LibraryGroupModeMenuButton(
                        type: type,
                        folderPreset: folderPreset,
                        accent: libraryAccentForKind(type.workspace.kind),
                        icon: folderPreset == null
                            ? Icons.account_tree_outlined
                            : genericFolderPresetIcon(folderPreset!, type),
                        onChanged: onGroupModeChanged!,
                        sidebarVisible: false,
                        onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                        pinnedFolderPresets: pinnedFolderPresets,
                        onPinnedPresetsChanged: onPinnedFolderPresetsChanged,
                        iconOnly: true,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (onEditSort != null)
                      const _LibraryDesktopToolbarSeparator(),
                    if (onEditSort != null)
                      LibraryToolbarSortButton(
                        onPressed: onEditSort!,
                        sortFavorites: sortFavorites,
                        activeSortFavoriteId: activeSortFavoriteId,
                        pinnedSortFavoriteIds: pinnedSortFavoriteIds,
                        onSortFavoriteSelected: onSortFavoriteSelected,
                        onManageFavoritesPressed: onManageSortFavorites,
                      ),
                    const _LibraryDesktopToolbarSeparator(),
                    LibraryViewModeDropdown(
                      viewMode: viewState.viewMode,
                      onChanged: onViewModeChanged,
                    ),
                    if (supportsMediaReleaseSplit) ...[
                      const _LibraryDesktopToolbarSeparator(),
                      _LibraryDesktopToolbarSection(
                        label: 'Scope',
                        child: PopupMenuButton<LibraryWorkspaceBrowserMode>(
                          tooltip: 'Browser scope',
                          initialValue: browserMode,
                          onSelected: onBrowserModeChanged,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: LibraryWorkspaceBrowserMode.media,
                              child: Text(mediaScopeLabel),
                            ),
                            const PopupMenuItem(
                              value: LibraryWorkspaceBrowserMode.releases,
                              child: Text('Releases'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: appPalette(context).divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  browserMode ==
                                          LibraryWorkspaceBrowserMode.media
                                      ? mediaScopeLabel
                                      : 'Releases',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_drop_down, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const _LibraryDesktopToolbarSeparator(),
                    LibraryDetailsLayoutDropdown(
                      detailsLayout: viewState.detailsLayout,
                      onChanged: onDetailsLayoutChanged,
                    ),
                    if (viewState.viewMode == LibraryViewMode.list) ...[
                      const _LibraryDesktopToolbarSeparator(),
                      _LibraryDesktopToolbarSection(
                        label: 'Columns',
                        child: _LibraryColumnLauncher(
                          activeLabel: activeColumnFavoriteLabel,
                          onManageColumns: onEditColumns,
                          pinnedPresets: pinnedColumnPresets,
                          overflowPresets: overflowColumnPresets,
                          onPresetSelected: onColumnFavoriteSelected,
                        ),
                      ),
                    ] else if (viewState.viewMode.supportsCoverSize) ...[
                      const _LibraryDesktopToolbarSeparator(),
                      _LibraryDesktopToolbarSection(
                        label: 'Covers',
                        child: LibraryCoverSizeSlider(
                          viewMode: viewState.viewMode,
                          coverSize: viewState.coverSize,
                          minCoverSize: adapter.viewProfile.minCoverSize,
                          maxCoverSize: adapter.viewProfile.maxCoverSize,
                          onChanged: onCoverSizeChanged,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            LibraryWorkspaceControlStrip(
              children: [
                LibraryItemCountLabel(
                  shown: counts.shown,
                  total: counts.total,
                  pluralLabel: type.pluralLabel,
                ),
                if (showReleaseFolderBack && onReleaseFolderBack != null)
                  TextButton.icon(
                    onPressed: onReleaseFolderBack,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text(
                      releaseFolderLabel == null
                          ? 'Back'
                          : 'Back: ${releaseFolderLabel!}',
                    ),
                  ),
                if (selectedBucket != null)
                  LibraryToolbarScopeChip(
                    label: selectedBucket!,
                    onClear: onClearBucket,
                  ),
                if (onEditFilters != null)
                  LibraryFilterButton(
                    activeCount: activeFilterCount,
                    onPressed: onEditFilters!,
                  ),
                LibraryToolsButton(
                  type: type,
                  counts: counts,
                  selectedBucket: selectedBucket,
                  quickView: quickView,
                  hasActiveFilters: hasActiveFilters,
                  onQuickViewSelected: onQuickViewSelected,
                  onClearFilters: onClearFilters,
                  onRandomPick: onRandomPick,
                  onDownloadAllCovers: onDownloadAllCovers,
                  shelfState: shelfState,
                  onSmartLists: onSmartLists,
                  onFolders: onFolders,
                  onReadingQueue: onReadingQueue,
                  onEditConditionPickList: onEditConditionPickList,
                  onEditGradePickList: onEditGradePickList,
                  onEditTagPickList: onEditTagPickList,
                  onTransferFieldData: onTransferFieldData,
                  onReassignIndex: onReassignIndex,
                  onPrintReport: onPrintReport,
                  onShareCollection: onShareCollection,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryDesktopToolbarSection extends StatelessWidget {
  const _LibraryDesktopToolbarSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.22,
                fontSize: 10,
              ),
        ),
        const SizedBox(width: 3),
        child,
      ],
    );
  }
}

class _LibraryDesktopToolbarSeparator extends StatelessWidget {
  const _LibraryDesktopToolbarSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 18,
        child: VerticalDivider(
          width: 1,
          thickness: 1,
          color: appPalette(context).divider,
        ),
      ),
    );
  }
}

enum _LibraryColumnLauncherAction { manage }

class _LibraryColumnLauncher extends StatelessWidget {
  const _LibraryColumnLauncher({
    required this.activeLabel,
    required this.onManageColumns,
    required this.pinnedPresets,
    required this.overflowPresets,
    required this.onPresetSelected,
  });

  final String? activeLabel;
  final VoidCallback onManageColumns;
  final List<LibraryTableColumnPreset> pinnedPresets;
  final List<LibraryTableColumnPreset> overflowPresets;
  final ValueChanged<LibraryTableColumnPreset>? onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final entries = <LibraryDenseMenuEntry<Object>>[];
    for (final preset in [...pinnedPresets, ...overflowPresets]) {
      entries.add(
        LibraryDenseMenuEntry<Object>(
          value: preset,
          label: preset.label,
          icon: Icons.bookmark_outline,
          active: preset.label == activeLabel,
          trailingLabel: '${preset.columns.length}',
        ),
      );
    }
    entries.add(
      const LibraryDenseMenuEntry<Object>(
        value: _LibraryColumnLauncherAction.manage,
        label: 'Manage columns',
        icon: Icons.tune,
      ),
    );

    return LibraryDenseSplitButton<Object>(
      key: const ValueKey('library-column-split-button'),
      label: activeLabel ?? 'Custom columns',
      icon: Icons.view_column_outlined,
      onPressed: onManageColumns,
      entries: entries,
      onSelected: (value) {
        if (value is LibraryTableColumnPreset) {
          onPresetSelected?.call(value);
          return;
        }
        onManageColumns();
      },
      tone: LibraryDenseButtonTone.surface,
      tooltip: 'Columns',
    );
  }
}

class LibraryDesktopFilteringToolbar extends StatelessWidget {
  const LibraryDesktopFilteringToolbar({
    super.key,
    required this.type,
    required this.accent,
    required this.searchController,
    required this.collectionStatusScope,
    required this.availableLetters,
    required this.selectedBucket,
    required this.onAdd,
    required this.onScan,
    required this.onRefreshMetadata,
    required this.onSearchChanged,
    required this.onClearBucket,
    this.onCollectionStatusScopeChanged,
    this.selectedLetter,
    this.onLetterSelected,
    this.onRandomPick,
    this.onScanCover,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final TextEditingController searchController;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final String? selectedBucket;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearBucket;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;

  @override
  Widget build(BuildContext context) {
    final showChromeRow = onCollectionStatusScopeChanged != null;
    final showAlphabetRow = onLetterSelected != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            LibraryToolbarPrimaryActions(
              addLabel: 'Add ${type.pluralLabel}',
              onAdd: onAdd,
              onScanBarcode: onScan,
              onRefreshMetadata: onRefreshMetadata,
              onRandomPick: onRandomPick,
              onScanCover: onScanCover,
              addBackgroundColor: accent,
              addForegroundColor: Colors.white,
            ),
            if (showChromeRow) ...[
              const SizedBox(width: 6),
              LibraryCollectionStatusScopeDropdown(
                collectionStatusScope: collectionStatusScope,
                onCollectionStatusScopeChanged: onCollectionStatusScopeChanged!,
              ),
            ],
            const SizedBox(width: 8),
            SizedBox(
              width: 380,
              child: LibraryToolbarSearch(
                controller: searchController,
                hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
                onScanBarcode: onScan,
                onScanCover: onScanCover,
                selectedFilterLabel: selectedBucket,
                onSearch: onSearchChanged,
                onClearFilter: onClearBucket,
                onChanged: onSearchChanged,
                selectionColor: appPalette(context).selection,
              ),
            ),
            if (showAlphabetRow) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 420,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: LibraryToolbarAlphabetRow(
                      letters: availableLetters,
                      selectedLetter: selectedLetter,
                      onLetterSelected: onLetterSelected!,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            const _LibraryDesktopUtilityCluster(),
          ],
        ),
      ),
    );
  }
}

enum _LibraryWorkspaceDestination {
  shelf,
  calendar,
  admin,
  settings,
  shortcuts,
}

extension on _LibraryWorkspaceDestination {
  String get label {
    switch (this) {
      case _LibraryWorkspaceDestination.shelf:
        return 'Shelf';
      case _LibraryWorkspaceDestination.calendar:
        return 'Calendar';
      case _LibraryWorkspaceDestination.admin:
        return 'Admin';
      case _LibraryWorkspaceDestination.settings:
        return 'Settings';
      case _LibraryWorkspaceDestination.shortcuts:
        return 'Keyboard shortcuts';
    }
  }

  IconData get icon {
    switch (this) {
      case _LibraryWorkspaceDestination.shelf:
        return Icons.inventory_2_outlined;
      case _LibraryWorkspaceDestination.calendar:
        return Icons.calendar_month_outlined;
      case _LibraryWorkspaceDestination.admin:
        return Icons.admin_panel_settings_outlined;
      case _LibraryWorkspaceDestination.settings:
        return Icons.settings_outlined;
      case _LibraryWorkspaceDestination.shortcuts:
        return Icons.keyboard_command_key;
    }
  }

  String? get route {
    switch (this) {
      case _LibraryWorkspaceDestination.shelf:
        return AppRoutes.shelf;
      case _LibraryWorkspaceDestination.calendar:
        return AppRoutes.calendar;
      case _LibraryWorkspaceDestination.admin:
        return AppRoutes.admin;
      case _LibraryWorkspaceDestination.settings:
        return AppRoutes.settings;
      case _LibraryWorkspaceDestination.shortcuts:
        return null;
    }
  }

  String get section {
    switch (this) {
      case _LibraryWorkspaceDestination.shelf:
      case _LibraryWorkspaceDestination.calendar:
        return 'Workspace';
      case _LibraryWorkspaceDestination.admin:
        return 'Administration';
      case _LibraryWorkspaceDestination.settings:
      case _LibraryWorkspaceDestination.shortcuts:
        return 'Help';
    }
  }
}

class _LibraryDesktopUtilityCluster extends ConsumerWidget {
  const _LibraryDesktopUtilityCluster();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _LibraryDesktopSyncButton(),
        const SizedBox(width: 4),
        _LibraryWorkspaceMenuButton(isAdmin: auth.isAdmin),
      ],
    );
  }
}

class _LibraryWorkspaceMenuButton extends StatelessWidget {
  const _LibraryWorkspaceMenuButton({required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final background = Color.alphaBlend(
      palette.surface.withValues(alpha: 0.88),
      palette.toolbar,
    );
    final border = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.12 : 0.08),
      palette.divider,
    );
    final destinations = [
      _LibraryWorkspaceDestination.shelf,
      _LibraryWorkspaceDestination.calendar,
      if (isAdmin) _LibraryWorkspaceDestination.admin,
      _LibraryWorkspaceDestination.settings,
      _LibraryWorkspaceDestination.shortcuts,
    ];
    return PopupMenuButton<_LibraryWorkspaceDestination>(
      tooltip: 'Workspace menu',
      onSelected: (destination) {
        final route = destination.route;
        if (route != null) {
          context.go(route);
          return;
        }
        showKeyboardShortcutsDialog(context);
      },
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_LibraryWorkspaceDestination>>[];
        String? currentSection;
        for (final destination in destinations) {
          if (destination.section != currentSection) {
            if (items.isNotEmpty) {
              items.add(const PopupMenuDivider(height: 8));
            }
            items.add(
              PopupMenuItem<_LibraryWorkspaceDestination>(
                enabled: false,
                height: 24,
                child: Text(
                  destination.section.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.24,
                  ),
                ),
              ),
            );
            currentSection = destination.section;
          }
          items.add(
            PopupMenuItem<_LibraryWorkspaceDestination>(
              value: destination,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(destination.icon, size: 16, color: palette.textPrimary),
                  const SizedBox(width: 8),
                  Text(destination.label),
                ],
              ),
            ),
          );
        }
        return items;
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu, size: 15, color: palette.textPrimary),
              const SizedBox(width: 5),
              Text(
                'Menu',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 1),
              Icon(Icons.expand_more, size: 15, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryDesktopSyncButton extends ConsumerWidget {
  const _LibraryDesktopSyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    final palette = appPalette(context);
    final background = Color.alphaBlend(
      palette.surface.withValues(alpha: 0.88),
      palette.toolbar,
    );
    final border = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.12 : 0.08),
      palette.divider,
    );
    final foreground = sync.isOffline
        ? (palette.isDark ? Colors.orange.shade200 : Colors.orange.shade700)
        : palette.textPrimary;
    final mutedForeground = foreground.withValues(alpha: 0.72);
    final badgeBackground = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.18 : 0.12),
      palette.selection,
    );
    return Tooltip(
      message: sync.isSyncing
          ? 'Personal sync is running'
          : sync.pendingCount > 0
              ? 'Run personal sync now (${sync.pendingCount} pending)'
              : 'Run personal sync now',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: sync.isSyncing
              ? null
              : () => ref.read(syncControllerProvider.notifier).syncNow(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sync.isOffline
                          ? Icons.cloud_off_outlined
                          : Icons.sync_outlined,
                      size: 15,
                      color: sync.isSyncing ? mutedForeground : foreground,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Sync',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:
                                sync.isSyncing ? mutedForeground : foreground,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                if (!sync.isSyncing && sync.pendingCount > 0)
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBackground,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        sync.pendingCount > 99
                            ? '99+'
                            : sync.pendingCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryToolbarDividerLine extends StatelessWidget {
  const LibraryToolbarDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: appPalette(context).divider,
    );
  }
}

class LibrarySelectionToolbarBand extends StatelessWidget {
  const LibrarySelectionToolbarBand({
    super.key,
    required this.selectedCount,
    required this.totalSelectableCount,
    required this.callbacks,
  });

  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySelectionCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          bottom: BorderSide(color: palette.divider),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: callbacks.onClearSelection,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: palette.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: callbacks.onSelectAll,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: palette.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('All'),
          ),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: palette.divider,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: LibrarySelectionControls(
                callbacks: callbacks,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$selectedCount of $totalSelectableCount selected',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class LibraryCompactToolbarContent extends StatelessWidget {
  const LibraryCompactToolbarContent({
    super.key,
    required this.type,
    required this.searchController,
    required this.accent,
    required this.counts,
    required this.viewMode,
    required this.selectedBucket,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onRefreshMetadata,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.pinnedViewPresets = const {},
    this.onTogglePinnedViewPreset,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    this.onTogglePinnedColumnFavorite,
    required this.onManageColumns,
    this.canJumpToIssue = false,
    this.onJumpToIssueSubmitted,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onClearBucket,
    this.onEditFilters,
    this.activeFilterCount = 0,
    this.onRandomPick,
    this.onDownloadAllCovers,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onEditSort,
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
    this.selectionCallbacks,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final Color accent;
  final LibraryToolbarCounts counts;
  final LibraryViewMode viewMode;
  final String? selectedBucket;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final VoidCallback onManageColumns;
  final bool canJumpToIssue;
  final ValueChanged<String>? onJumpToIssueSubmitted;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onClearBucket;
  final VoidCallback? onEditFilters;
  final int activeFilterCount;
  final VoidCallback? onRandomPick;
  final VoidCallback? onDownloadAllCovers;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onEditSort;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final int selectedCount;
  final int totalSelectableCount;

  @override
  Widget build(BuildContext context) {
    final showChromeRow = onCollectionStatusScopeChanged != null;
    final showAlphabetRow =
        availableLetters.isNotEmpty && onLetterSelected != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: searchController,
                  constraints: const BoxConstraints.tightFor(height: 36),
                  hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
                  leading: const Icon(Icons.search),
                  trailing: selectedBucket == null
                      ? null
                      : [
                          IconButton(
                            tooltip: 'Clear scope chip',
                            onPressed: onClearBucket,
                            icon: const Icon(Icons.clear, size: 18),
                          ),
                        ],
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Add ${type.pluralLabel}',
              ),
              const SizedBox(width: 4),
              LibraryToolsButton(
                type: type,
                counts: counts,
                selectedBucket: selectedBucket,
                quickView: quickView,
                hasActiveFilters: hasActiveFilters,
                onQuickViewSelected: onQuickViewSelected,
                onClearFilters: onClearFilters,
                onRandomPick: onRandomPick,
                onDownloadAllCovers: onDownloadAllCovers,
                onSmartLists: onSmartLists,
                onFolders: onFolders,
                onReadingQueue: onReadingQueue,
                onEditConditionPickList: onEditConditionPickList,
                onEditGradePickList: onEditGradePickList,
                onEditTagPickList: onEditTagPickList,
                onEditSort: onEditSort,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.start,
                  children: [
                    Tooltip(
                      message: viewMode.supportsCoverSize
                          ? 'Views and cover size'
                          : 'Views (cover size unavailable in this view)',
                      child: IconButton.filledTonal(
                        onPressed: () => showLibraryCompactCoverSizeSheet(
                          context,
                          viewMode,
                          onViewModeChanged,
                          onDetailsLayoutChanged,
                          onCoverSizeChanged,
                        ),
                        icon: const Icon(
                          Icons.photo_size_select_large_outlined,
                        ),
                      ),
                    ),
                    if (onEditFilters != null)
                      LibraryFilterButton(
                        activeCount: activeFilterCount,
                        onPressed: onEditFilters!,
                      ),
                    LibraryItemCountLabel(
                      shown: counts.shown,
                      total: counts.total,
                      pluralLabel: type.pluralLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectionCallbacks != null && selectedCount > 0) ...[
          const LibraryToolbarDividerLine(),
          LibrarySelectionToolbarBand(
            selectedCount: selectedCount,
            totalSelectableCount: totalSelectableCount,
            callbacks: selectionCallbacks!,
          ),
        ],
        if (showChromeRow) ...[
          const LibraryToolbarDividerLine(),
          LibraryToolbarChromeRow(
            collectionStatusScope: collectionStatusScope,
            onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
            activeViewPreset: activeViewPreset,
            onViewPresetSelected: onViewPresetSelected,
            pinnedViewPresets: pinnedViewPresets,
            onTogglePinnedViewPreset: onTogglePinnedViewPreset,
            sortFavorites: sortFavorites,
            activeSortFavoriteId: activeSortFavoriteId,
            onSortFavoriteSelected: onSortFavoriteSelected,
            pinnedSortFavoriteIds: pinnedSortFavoriteIds,
            onTogglePinnedSortFavorite: onTogglePinnedSortFavorite,
            columnFavoritePresets: columnFavoritePresets,
            activeColumnFavoriteLabel: activeColumnFavoriteLabel,
            onColumnFavoriteSelected: onColumnFavoriteSelected,
            pinnedColumnFavoriteKeys: pinnedColumnFavoriteKeys,
            onTogglePinnedColumnFavorite: onTogglePinnedColumnFavorite,
            onManageColumns: onManageColumns,
            canJumpToIssue: canJumpToIssue,
            onJumpToIssueSubmitted: onJumpToIssueSubmitted,
          ),
        ],
        if (showAlphabetRow) ...[
          const LibraryToolbarDividerLine(),
          LibraryToolbarAlphabetRow(
            letters: availableLetters,
            selectedLetter: selectedLetter,
            onLetterSelected: onLetterSelected!,
          ),
        ],
      ],
    );
  }
}

class LibraryToolbarChromeRow extends StatelessWidget {
  const LibraryToolbarChromeRow({
    super.key,
    required this.collectionStatusScope,
    this.onCollectionStatusScopeChanged,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.pinnedViewPresets = const {},
    this.onTogglePinnedViewPreset,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    this.onTogglePinnedColumnFavorite,
    required this.onManageColumns,
    this.canJumpToIssue = false,
    this.onJumpToIssueSubmitted,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final VoidCallback onManageColumns;
  final bool canJumpToIssue;
  final ValueChanged<String>? onJumpToIssueSubmitted;

  static const double _statusScopeDropdownHeight = 36;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        );
    final dropdownWidth = measureLibraryToolbarDropdownWidth(
      context,
      labels: LibraryCollectionStatusScope.values.map((scope) => scope.label),
      textStyle: dropdownTextStyle,
      leadingWidth: 20,
      leadingSpacing: 8,
      trailingWidth: 24,
      horizontalPadding: 24,
      minWidth: 132,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: onCollectionStatusScopeChanged == null
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: dropdownWidth,
                child: PopupMenuButton<LibraryCollectionStatusScope>(
                  key: const Key('collection-status-scope-dropdown'),
                  tooltip: 'Collection status scope',
                  initialValue: collectionStatusScope,
                  onSelected: onCollectionStatusScopeChanged!,
                  padding: EdgeInsets.zero,
                  menuPadding: const EdgeInsets.symmetric(vertical: 4),
                  position: PopupMenuPosition.under,
                  color: palette.panelRaised,
                  surfaceTintColor: Colors.transparent,
                  constraints: const BoxConstraints(
                    minWidth: 0,
                    maxWidth: double.infinity,
                  ).copyWith(minWidth: dropdownWidth, maxWidth: dropdownWidth),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: palette.divider),
                  ),
                  itemBuilder: (context) => [
                    for (final scope in LibraryCollectionStatusScope.values)
                      PopupMenuItem<LibraryCollectionStatusScope>(
                        value: scope,
                        height: _statusScopeDropdownHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LibraryCollectionStatusScopeMenuItem(
                          scope: scope,
                          isSelected: scope == collectionStatusScope,
                          accent: accent,
                          muted: palette.textMuted,
                          textColor: palette.textPrimary,
                        ),
                      ),
                  ],
                  child: _ScopeDropdownTrigger(
                    scope: collectionStatusScope,
                    accent: accent,
                    height: _statusScopeDropdownHeight,
                    textStyle: dropdownTextStyle,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ScopeDropdownTrigger extends StatelessWidget {
  const _ScopeDropdownTrigger({
    required this.scope,
    required this.accent,
    required this.height,
    this.textStyle,
  });

  final LibraryCollectionStatusScope scope;
  final Color accent;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final borderColor = libraryCollectionStatusScopeColor(
      scope,
      accent,
      palette.textMuted,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              LibraryCollectionStatusScopeBadge(
                scope: scope,
                accent: accent,
                muted: palette.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scope.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: borderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
