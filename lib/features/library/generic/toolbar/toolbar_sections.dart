import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDesktopSecondaryToolbar extends StatelessWidget {
  const LibraryDesktopSecondaryToolbar({
    super.key,
    required this.type,
    required this.viewState,
    required this.adapter,
    required this.counts,
    required this.onEditColumns,
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
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
    this.pinnedGroupModes = const {},
    this.onTogglePinGroupMode,
    this.onGroupModeChanged,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceViewState viewState;
  final LibraryMediaAdapter adapter;
  final LibraryToolbarCounts counts;
  final VoidCallback onEditColumns;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
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
  final LibraryGroupMode? groupMode;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePinGroupMode;
  final ValueChanged<LibraryGroupMode>? onGroupModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                        groupMode: groupMode,
                        accent: libraryAccentForKind(type.workspace.kind),
                        icon: groupMode == null
                            ? Icons.account_tree_outlined
                            : genericGroupModeIcon(groupMode!),
                        onChanged: onGroupModeChanged!,
                        sidebarVisible: false,
                        onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                        pinnedGroupModes: pinnedGroupModes,
                        onTogglePin: onTogglePinGroupMode,
                        iconOnly: true,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (onEditSort != null) const SizedBox(width: 6),
                    if (onEditSort != null)
                      LibraryToolbarSortButton(
                        onPressed: onEditSort!,
                        sortFavorites: sortFavorites,
                        activeSortFavoriteId: activeSortFavoriteId,
                      ),
                    if (onEditSort != null) const SizedBox(width: 6),
                    LibraryViewModeDropdown(
                      viewMode: viewState.viewMode,
                      onChanged: onViewModeChanged,
                    ),
                    const SizedBox(width: 6),
                    LibraryDetailsLayoutDropdown(
                      detailsLayout: viewState.detailsLayout,
                      onChanged: onDetailsLayoutChanged,
                    ),
                    if (viewState.viewMode == LibraryViewMode.list) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Select columns',
                        child: LibraryWorkspaceIconButton(
                          onPressed: onEditColumns,
                          icon: Icons.view_column,
                        ),
                      ),
                    ] else if (viewState.viewMode.supportsCoverSize) ...[
                      const SizedBox(width: 6),
                      LibraryCoverSizeSlider(
                        viewMode: viewState.viewMode,
                        coverSize: viewState.coverSize,
                        minCoverSize: adapter.viewProfile.minCoverSize,
                        maxCoverSize: adapter.viewProfile.maxCoverSize,
                        onChanged: onCoverSizeChanged,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            LibraryWorkspaceControlStrip(
              children: [
                LibraryItemCountLabel(
                  shown: counts.shown,
                  total: counts.total,
                  pluralLabel: type.pluralLabel,
                ),
                if (selectedBucket != null)
                  LibraryToolbarScopeChip(
                    label: selectedBucket!,
                    onClear: onClearBucket,
                  ),
                if (counts.totalPricePaidCents > 0 ||
                    counts.totalCoverPriceCents > 0 ||
                    counts.totalSellPriceCents > 0)
                  LibraryCollectionValueChip(
                    totalPaidCents: counts.totalPricePaidCents,
                    totalCoverCents: counts.totalCoverPriceCents,
                    totalSellCents: counts.totalSellPriceCents,
                    currency: counts.priceCurrency,
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
    final palette = appPalette(context);
    final showChromeRow = onCollectionStatusScopeChanged != null;
    final showAlphabetRow = onLetterSelected != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
            const SizedBox(width: 8),
            LibraryCollectionStatusScopeDropdown(
              collectionStatusScope: collectionStatusScope,
              onCollectionStatusScopeChanged:
                  onCollectionStatusScopeChanged!,
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                if (showAlphabetRow)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: LibraryToolbarAlphabetRow(
                        letters: availableLetters,
                        selectedLetter: selectedLetter,
                        onLetterSelected: onLetterSelected!,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: LibraryToolbarSearch(
                      controller: searchController,
                      hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
                      onScanBarcode: onScan,
                      onScanCover: onScanCover,
                      selectedFilterLabel: selectedBucket,
                      onSearch: onSearchChanged,
                      onClearFilter: onClearBucket,
                      onChanged: onSearchChanged,
                      selectionColor: palette.selection,
                    ),
                  ),
                ),
              ],
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
    required this.callbacks,
  });

  final int selectedCount;
  final LibrarySelectionCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.highlight.withValues(alpha: 0.78),
        border: Border(
          top: BorderSide(color: palette.divider),
          bottom: BorderSide(color: palette.divider),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: palette.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checklist, size: 16, color: palette.textMuted),
                const SizedBox(width: 6),
                Text(
                  '$selectedCount selected',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: callbacks.onClearSelection,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Clear selection'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: palette.textMuted,
            ),
          ),
          LibrarySelectionControls(
            selectedCount: selectedCount,
            callbacks: callbacks,
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

class _ScopeDropdownTrigger extends StatefulWidget {
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
  State<_ScopeDropdownTrigger> createState() => _ScopeDropdownTriggerState();
}

class _ScopeDropdownTriggerState extends State<_ScopeDropdownTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final borderColor = libraryCollectionStatusScopeColor(
      widget.scope,
      widget.accent,
      palette.textMuted,
    ).withValues(alpha: 0.45);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _hovered
              ? Color.alphaBlend(
                  palette.surfaceSubtle.withValues(alpha: 0.45),
                  palette.panelRaised,
                )
              : palette.panelRaised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: SizedBox(
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                LibraryCollectionStatusScopeBadge(
                  scope: widget.scope,
                  accent: widget.accent,
                  muted: palette.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.scope.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: widget.textStyle,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: palette.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
