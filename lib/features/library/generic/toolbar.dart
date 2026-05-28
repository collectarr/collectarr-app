import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryToolbar extends StatelessWidget {
  const LibraryToolbar({
    super.key,
    required this.type,
    required this.searchController,
    required this.viewState,
    required this.adapter,
    required this.counts,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onEditColumns,
    required this.onSortChanged,
    this.onEditSort,
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    required this.selectedBucket,
    required this.onClearBucket,
    required this.onRefreshMetadata,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
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
    this.canJumpToIssue = false,
    this.onJumpToIssueSubmitted,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.onEditFilters,
    this.activeFilterCount = 0,
    this.onRandomPick,
    this.onScanCover,
    this.onDownloadAllCovers,
    this.selectionEnabled = false,
    this.selectedCount = 0,
    this.selectionCallbacks,
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
    this.includeDesktopSecondaryBand = true,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final LibraryWorkspaceViewState viewState;
  final LibraryMediaAdapter adapter;
  final LibraryToolbarCounts counts;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onEditColumns;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final VoidCallback? onEditSort;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final String? selectedBucket;
  final VoidCallback onClearBucket;
  final VoidCallback onRefreshMetadata;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
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
  final bool canJumpToIssue;
  final ValueChanged<String>? onJumpToIssueSubmitted;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onEditFilters;
  final int activeFilterCount;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;
  final bool selectionEnabled;
  final int selectedCount;
  final LibrarySelectionCallbacks? selectionCallbacks;
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
  final bool includeDesktopSecondaryBand;

  @override
  Widget build(BuildContext context) {
    final targetAccent = libraryAccentForKind(type.workspace.kind);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetAccent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final accent = color ?? targetAccent;
        final palette = appPalette(context);
        return LibraryToolbarFrame(
          backgroundColor: palette.toolbar,
          dividerColor: palette.divider,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return _CompactLibraryToolbarContent(
                  type: type,
                  searchController: searchController,
                  accent: accent,
                  counts: counts,
                  viewMode: viewState.viewMode,
                  selectedBucket: selectedBucket,
                  onAdd: onAdd,
                  onScan: onScan,
                  onSearchChanged: onSearchChanged,
                  onRefreshMetadata: onRefreshMetadata,
                  onViewModeChanged: onViewModeChanged,
                  onDetailsLayoutChanged: onDetailsLayoutChanged,
                  onCoverSizeChanged: onCoverSizeChanged,
                  quickView: quickView,
                  onQuickViewSelected: onQuickViewSelected,
                  collectionStatusScope: collectionStatusScope,
                  onCollectionStatusScopeChanged:
                      onCollectionStatusScopeChanged,
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
                  onManageColumns: onEditColumns,
                  canJumpToIssue: canJumpToIssue,
                  onJumpToIssueSubmitted: onJumpToIssueSubmitted,
                  hasActiveFilters: hasActiveFilters,
                  onClearFilters: onClearFilters,
                  onEditFilters: onEditFilters,
                  activeFilterCount: activeFilterCount,
                  onRandomPick: onRandomPick,
                  onDownloadAllCovers: onDownloadAllCovers,
                  onSmartLists: onSmartLists,
                  onFolders: onFolders,
                  onReadingQueue: onReadingQueue,
                  onEditConditionPickList: onEditConditionPickList,
                  onEditGradePickList: onEditGradePickList,
                  onEditTagPickList: onEditTagPickList,
                  onEditSort: onEditSort,
                  availableLetters: availableLetters,
                  selectedLetter: selectedLetter,
                  onLetterSelected: onLetterSelected,
                  selectionCallbacks: selectionCallbacks,
                  selectedCount: selectedCount,
                );
              }

              final showChromeRow = onCollectionStatusScopeChanged != null;
              final showAlphabetRow = onLetterSelected != null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                          addForegroundColor:
                              _toolbarForegroundForAccent(accent),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 520,
                                        ),
                                        child: LibraryToolbarAlphabetRow(
                                          letters: availableLetters,
                                          selectedLetter: selectedLetter,
                                          onLetterSelected: onLetterSelected!,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 760,
                                    ),
                                    child: LibraryToolbarSearch(
                                      controller: searchController,
                                      hintText:
                                          'Search ${type.pluralLabel.toLowerCase()}...',
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (includeDesktopSecondaryBand)
                    LibraryDesktopSecondaryToolbar(
                      type: type,
                      viewState: viewState,
                      adapter: adapter,
                      counts: counts,
                      onEditColumns: onEditColumns,
                      onEditSort: onEditSort,
                      onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                      onViewModeChanged: onViewModeChanged,
                      onDetailsLayoutChanged: onDetailsLayoutChanged,
                      onCoverSizeChanged: onCoverSizeChanged,
                      selectedBucket: selectedBucket,
                      quickView: quickView,
                      activeSortFavoriteId: activeSortFavoriteId,
                      sortFavorites: sortFavorites,
                      hasActiveFilters: hasActiveFilters,
                      onQuickViewSelected: onQuickViewSelected,
                      onClearFilters: onClearFilters,
                      onEditFilters: onEditFilters,
                      activeFilterCount: activeFilterCount,
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
                  if (selectionCallbacks != null && selectedCount > 0) ...[
                    const _ToolbarDividerLine(),
                    _SelectionToolbarBand(
                      selectedCount: selectedCount,
                      callbacks: selectionCallbacks!,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (!viewState.isSidebarVisible &&
                      groupMode != null &&
                      onGroupModeChanged != null) ...[
                    LibraryGroupModeMenuButton(
                      type: type,
                      groupMode: groupMode!,
                      accent: libraryAccentForKind(type.workspace.kind),
                      icon: genericGroupModeIcon(groupMode!),
                      onChanged: onGroupModeChanged!,
                      sidebarVisible: false,
                      onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                      pinnedGroupModes: pinnedGroupModes,
                      onTogglePin: onTogglePinGroupMode,
                      iconOnly: true,
                    ),
                    const SizedBox(width: 6),
                  ],
                  LibraryViewModeDropdown(
                    viewMode: viewState.viewMode,
                    onChanged: onViewModeChanged,
                  ),
                  if (onEditSort != null) const SizedBox(width: 6),
                  if (onEditSort != null) ...[
                    LibraryToolbarSortButton(
                      onPressed: onEditSort!,
                      sortFavorites: sortFavorites,
                      activeSortFavoriteId: activeSortFavoriteId,
                    ),
                  ],
                ],
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
                if (counts.totalPricePaidCents > 0)
                  LibraryCollectionValueChip(
                    totalPaidCents: counts.totalPricePaidCents,
                    totalCoverCents: counts.totalCoverPriceCents,
                    totalSellCents: counts.totalSellPriceCents,
                    currency: counts.priceCurrency,
                  ),
                LibraryDetailsLayoutDropdown(
                  detailsLayout: viewState.detailsLayout,
                  onChanged: onDetailsLayoutChanged,
                ),
                LibraryCoverSizeSlider(
                  viewMode: viewState.viewMode,
                  coverSize: viewState.coverSize,
                  minCoverSize: adapter.viewProfile.minCoverSize,
                  maxCoverSize: adapter.viewProfile.maxCoverSize,
                  onChanged: onCoverSizeChanged,
                ),
                Tooltip(
                  message: 'Select columns',
                  child: LibraryWorkspaceIconButton(
                    onPressed: viewState.viewMode == LibraryViewMode.list
                        ? onEditColumns
                        : null,
                    icon: Icons.view_column,
                  ),
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

Color _toolbarForegroundForAccent(Color accent) {
  return Colors.white;
}

class _ToolbarDividerLine extends StatelessWidget {
  const _ToolbarDividerLine();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: appPalette(context).divider,
    );
  }
}

class _SelectionToolbarBand extends StatelessWidget {
  const _SelectionToolbarBand({
    required this.selectedCount,
    required this.callbacks,
  });

  final int selectedCount;
  final LibrarySelectionCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.select_all,
            size: 16,
            color: appPalette(context).textMuted,
          ),
          const SizedBox(width: 8),
          Text(
            'Selection',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          LibrarySelectionControls(
            selectedCount: selectedCount,
            callbacks: callbacks,
          ),
        ],
      ),
    );
  }
}

class _CompactLibraryToolbarContent extends StatelessWidget {
  const _CompactLibraryToolbarContent({
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
                            onPressed: onClearFilters,
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
                        icon:
                            const Icon(Icons.photo_size_select_large_outlined),
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
          const _ToolbarDividerLine(),
          _SelectionToolbarBand(
            selectedCount: selectedCount,
            callbacks: selectionCallbacks!,
          ),
        ],
        if (showChromeRow) ...[
          const _ToolbarDividerLine(),
          _ToolbarChromeRow(
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
          const _ToolbarDividerLine(),
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

class _ToolbarChromeRow extends StatelessWidget {
  const _ToolbarChromeRow({
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
          color: Colors.white,
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.panelRaised,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: libraryCollectionStatusScopeColor(
                          collectionStatusScope,
                          accent,
                          palette.textMuted,
                        ).withValues(alpha: 0.45),
                      ),
                    ),
                    child: SizedBox(
                      height: _statusScopeDropdownHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            LibraryCollectionStatusScopeBadge(
                              scope: collectionStatusScope,
                              accent: accent,
                              muted: palette.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                collectionStatusScope.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: dropdownTextStyle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

