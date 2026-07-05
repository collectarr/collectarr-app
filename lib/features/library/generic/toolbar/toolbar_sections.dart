import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const double _kLibraryToolbarBandVerticalPadding = 2;
const double _kLibraryToolbarBandHorizontalPadding = 4;

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
    this.onMissingComics,
    this.onShareCollection,
    this.onCompareMetadataWithServer,
    this.groupMode,
    this.folderPreset,
    this.availableGroupModes,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.onGroupModeChanged,
    this.selectionCallbacks,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
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
  final VoidCallback? onMissingComics;
  final VoidCallback? onShareCollection;
  final VoidCallback? onCompareMetadataWithServer;
  final LibraryFolderPreset? folderPreset;
  final LibraryGroupMode? groupMode;
  final List<LibraryGroupMode>? availableGroupModes;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final ValueChanged<LibraryFolderPreset>? onGroupModeChanged;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final int selectedCount;
  final int totalSelectableCount;
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
    final selectionMode = selectionCallbacks != null && selectedCount > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: palette.divider))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kLibraryToolbarBandHorizontalPadding,
          vertical: _kLibraryToolbarBandVerticalPadding,
        ),
        child: SizedBox(
          height: kLibraryToolbarBandHeight,
          child: Row(
            children: [
              Expanded(
                child: selectionMode
                    ? _LibraryDesktopInlineSelectionToolbar(
                        selectedCount: selectedCount,
                        totalSelectableCount: totalSelectableCount,
                        callbacks: selectionCallbacks!,
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (!viewState.isSidebarVisible &&
                                onGroupModeChanged != null) ...[
                              LibraryGroupModeMenuButton(
                                type: type,
                                folderPreset: folderPreset,
                                availableModes: availableGroupModes,
                                accent:
                                    libraryAccentForKind(type.workspace.kind),
                                icon: folderPreset == null
                                    ? Icons.account_tree_outlined
                                    : genericFolderPresetIcon(
                                        folderPreset!, type),
                                onChanged: onGroupModeChanged!,
                                sidebarVisible: viewState.isSidebarVisible,
                                onSidebarVisibilityChanged:
                                    onSidebarVisibilityChanged,
                                pinnedFolderPresets: pinnedFolderPresets,
                                onPinnedPresetsChanged:
                                    onPinnedFolderPresetsChanged,
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
                                iconOnly: true,
                              ),
                            const _LibraryDesktopToolbarSeparator(),
                            LibraryViewModeDropdown(
                              viewMode: viewState.viewMode,
                              onChanged: onViewModeChanged,
                              iconOnly: true,
                            ),
                            if (supportsMediaReleaseSplit) ...[
                              const _LibraryDesktopToolbarSeparator(),
                              _LibraryDesktopToolbarSection(
                                label: 'Scope',
                                child: PopupMenuButton<
                                    LibraryWorkspaceBrowserMode>(
                                  tooltip: 'Browser scope',
                                  initialValue: browserMode,
                                  onSelected: onBrowserModeChanged,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: LibraryWorkspaceBrowserMode.media,
                                      height: kLibraryToolbarPopupItemHeight,
                                      child: Text(mediaScopeLabel),
                                    ),
                                    const PopupMenuItem(
                                      value:
                                          LibraryWorkspaceBrowserMode.releases,
                                      height: kLibraryToolbarPopupItemHeight,
                                      child: Text('Releases'),
                                    ),
                                  ],
                                  child: _LibraryToolbarSecondaryTrigger(
                                    icon: browserMode ==
                                            LibraryWorkspaceBrowserMode.media
                                        ? Icons.layers_outlined
                                        : Icons.inventory_2_outlined,
                                    tooltip: browserMode ==
                                            LibraryWorkspaceBrowserMode.media
                                        ? 'Scope: $mediaScopeLabel'
                                        : 'Scope: Releases',
                                  ),
                                ),
                              ),
                            ],
                            const _LibraryDesktopToolbarSeparator(),
                            LibraryDetailsLayoutDropdown(
                              detailsLayout: viewState.detailsLayout,
                              onChanged: onDetailsLayoutChanged,
                              iconOnly: true,
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
                            ] else if (viewState
                                .viewMode.supportsCoverSize) ...[
                              const _LibraryDesktopToolbarSeparator(),
                              _LibraryDesktopToolbarSection(
                                label: 'Covers',
                                child: LibraryCoverSizeSlider(
                                  viewMode: viewState.viewMode,
                                  coverSize: viewState.coverSize,
                                  minCoverSize:
                                      adapter.viewProfile.minCoverSize,
                                  maxCoverSize:
                                      adapter.viewProfile.maxCoverSize,
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
                  if (folderPreset != null && onGroupModeChanged != null)
                    _LibraryFolderPresetChip(
                      label: genericFolderPresetLabel(folderPreset!, type),
                      icon: genericFolderPresetIcon(folderPreset!, type),
                      onPressed: onFolders,
                      onReset: folderPreset! ==
                              LibraryFolderPreset.single(
                                libraryDefaultGroupMode(type),
                              )
                          ? null
                          : () => onGroupModeChanged!(
                                LibraryFolderPreset.single(
                                  libraryDefaultGroupMode(type),
                                ),
                              ),
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
                    onMissingComics: onMissingComics,
                    onShareCollection: onShareCollection,
                    onCompareMetadataWithServer: onCompareMetadataWithServer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryDesktopInlineSelectionToolbar extends StatelessWidget {
  const _LibraryDesktopInlineSelectionToolbar({
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
    final secondaryButtonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: palette.textPrimary,
      backgroundColor: librarySelectionToolbarSecondaryAction(context),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: librarySelectionToolbarBorder(context)),
      ),
    );
    final primaryButtonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: palette.textPrimary,
      backgroundColor: librarySelectionToolbarPrimaryAction(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: librarySelectionToolbarBorder(context).withValues(alpha: 0.82),
        ),
      ),
    );
    return SizedBox(
      height: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: librarySelectionToolbarSurface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: librarySelectionToolbarBorder(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              TextButton(
                onPressed: callbacks.onClearSelection,
                style: secondaryButtonStyle,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Select all visible items',
                child: TextButton(
                  onPressed: callbacks.onSelectAll,
                  style: primaryButtonStyle,
                  child: const Text('Select all'),
                ),
              ),
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: librarySelectionToolbarBorder(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: LibrarySelectionControls(
                    callbacks: callbacks,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: librarySelectionToolbarCountChip(context),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: librarySelectionToolbarBorder(context)
                        .withValues(alpha: 0.86),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    '$selectedCount of $totalSelectableCount selected',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                  ),
                ),
              ),
            ],
          ),
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
    return child;
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

class _LibraryToolbarSecondaryTrigger extends StatelessWidget {
  const _LibraryToolbarSecondaryTrigger({
    required this.icon,
    this.tooltip,
  });

  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final trigger = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: SizedBox(
        height: kLibraryToolbarTextDropdownHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: palette.textPrimary),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip!.trim().isEmpty) {
      return trigger;
    }
    return Tooltip(message: tooltip, child: trigger);
  }
}

class _LibraryFolderPresetChip extends StatelessWidget {
  const _LibraryFolderPresetChip({
    required this.label,
    required this.icon,
    this.onPressed,
    this.onReset,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 14),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      onPressed: onPressed,
      onDeleted: onReset,
      deleteIcon: const Icon(Icons.restart_alt, size: 14),
      deleteButtonTooltipMessage: 'Reset folders',
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
    this.onSearchInputChanged,
    required this.onClearBucket,
    this.onClearSearch,
    this.searchActive = false,
    this.searchSuggestions = const <LibraryToolbarSearchSuggestion>[],
    this.onSearchSuggestionSelected,
    this.onCollectionStatusScopeChanged,
    this.selectedLetter,
    this.onLetterSelected,
    this.onRandomPick,
    this.onScanCover,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
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
  final ValueChanged<String>? onSearchInputChanged;
  final VoidCallback onClearBucket;
  final VoidCallback? onClearSearch;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> searchSuggestions;
  final ValueChanged<LibraryToolbarSearchSuggestion>?
      onSearchSuggestionSelected;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;

  @override
  Widget build(BuildContext context) {
    final showChromeRow = onCollectionStatusScopeChanged != null;
    final showAlphabetRow = onLetterSelected != null;
    final leftControls = Row(
      mainAxisSize: MainAxisSize.min,
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
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: leftControls,
              ),
            ),
          ),
          if (showAlphabetRow)
            Expanded(
              flex: 4,
              child: Center(
                child: LibraryToolbarAlphabetRow(
                  letters: availableLetters,
                  selectedLetter: selectedLetter,
                  onLetterSelected: onLetterSelected!,
                ),
              ),
            )
          else
            const Spacer(flex: 4),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 380,
                child: LibraryToolbarSearch(
                  controller: searchController,
                  hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
                  onScanBarcode: onScan,
                  onScanCover: onScanCover,
                  selectedFilterLabel: selectedBucket,
                  onSearch: onSearchChanged,
                  onClearFilter: onClearBucket,
                  onChanged: onSearchInputChanged,
                  selectionColor: appPalette(context).selection,
                  searchTarget: searchTarget,
                  searchTargetOptions: searchTargetOptions,
                  onSearchTargetChanged: onSearchTargetChanged,
                  onClearSearch: onClearSearch,
                  searchActive: searchActive,
                  suggestions: searchSuggestions,
                  onSuggestionSelected: onSearchSuggestionSelected,
                ),
              ),
            ),
          ),
        ],
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
    this.showBottomBorder = true,
  });

  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySelectionCallbacks callbacks;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final secondaryButtonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: palette.textPrimary,
      backgroundColor: librarySelectionToolbarSecondaryAction(context),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: librarySelectionToolbarBorder(context)),
      ),
    );
    final primaryButtonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: palette.textPrimary,
      backgroundColor: librarySelectionToolbarPrimaryAction(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: librarySelectionToolbarBorder(context).withValues(alpha: 0.82),
        ),
      ),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: librarySelectionToolbarSurface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: showBottomBorder
              ? BorderSide(color: librarySelectionToolbarBorder(context))
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: callbacks.onClearSelection,
            style: secondaryButtonStyle,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Select all visible items',
            child: TextButton(
              onPressed: callbacks.onSelectAll,
              style: primaryButtonStyle,
              child: const Text('Select all'),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: librarySelectionToolbarBorder(context),
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: librarySelectionToolbarCountChip(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: librarySelectionToolbarBorder(context)
                    .withValues(alpha: 0.86),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                '$selectedCount of $totalSelectableCount selected',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
              ),
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
    this.onSearchInputChanged,
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
    this.onCompareMetadataWithServer,
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
    this.selectionCallbacks,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
    this.onClearSearch,
    this.searchActive = false,
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
  final ValueChanged<String>? onSearchInputChanged;
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
  final VoidCallback? onCompareMetadataWithServer;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback? onClearSearch;
  final bool searchActive;

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
                      ? (searchActive
                          ? [
                              IconButton(
                                tooltip: 'Clear search',
                                onPressed: onClearSearch,
                                icon: const Icon(Icons.clear, size: 18),
                              ),
                            ]
                          : null)
                      : [
                          if (searchActive)
                            IconButton(
                              tooltip: 'Clear search',
                              onPressed: onClearSearch,
                              icon: const Icon(Icons.clear, size: 18),
                            ),
                          IconButton(
                            tooltip: 'Clear scope chip',
                            onPressed: onClearBucket,
                            icon: const Icon(Icons.clear, size: 18),
                          ),
                        ],
                  onChanged: onSearchInputChanged,
                  onSubmitted: onSearchChanged,
                ),
              ),
              if (searchTargetOptions.isNotEmpty &&
                  onSearchTargetChanged != null) ...[
                const SizedBox(width: 6),
                PopupMenuButton<LibrarySearchTarget>(
                  tooltip: 'Search scope',
                  onSelected: onSearchTargetChanged,
                  itemBuilder: (context) => [
                    for (final option in searchTargetOptions)
                      PopupMenuItem<LibrarySearchTarget>(
                        value: option,
                        child: Text(_librarySearchTargetLabel(option)),
                      ),
                  ],
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _librarySearchTargetLabel(searchTarget),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              if (onFolders != null) ...[
                Tooltip(
                  message: 'Folders',
                  child: IconButton.filledTonal(
                    onPressed: onFolders,
                    icon: const Icon(Icons.folder_outlined),
                  ),
                ),
                const SizedBox(width: 4),
              ],
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
                onCompareMetadataWithServer: onCompareMetadataWithServer,
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
            showBottomBorder: !showChromeRow,
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
                        height: kLibraryToolbarTextDropdownHeight,
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
                    height: kLibraryToolbarTextDropdownHeight,
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

String _librarySearchTargetLabel(LibrarySearchTarget target) {
  return switch (target) {
    LibrarySearchTarget.all => 'Albums & Tracks',
    LibrarySearchTarget.mediaOnly => 'Albums',
    LibrarySearchTarget.tracksOnly => 'Tracks',
  };
}
