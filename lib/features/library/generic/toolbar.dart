import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
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

  @override
  Widget build(BuildContext context) {
    final targetAccent = libraryAccentForKind(type.workspace.kind);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetAccent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final accent = color ?? targetAccent;
        return LibraryToolbarFrame(
          backgroundColor: kAppToolbar,
          dividerColor: kAppDivider,
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

              final showChromeRow = onCollectionStatusScopeChanged != null ||
                  onViewPresetSelected != null ||
                  (sortFavorites.isNotEmpty &&
                      onSortFavoriteSelected != null) ||
                  (columnFavoritePresets.isNotEmpty &&
                      onColumnFavoriteSelected != null) ||
                  canJumpToIssue;
              final showAlphabetRow =
                  availableLetters.isNotEmpty && onLetterSelected != null;

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
                        const LibraryWorkspaceSeparator(color: kAppDivider),
                        LibraryToolbarSearch(
                          controller: searchController,
                          hintText:
                              'Search ${type.pluralLabel.toLowerCase()}...',
                          selectedFilterLabel: selectedBucket,
                          onSearch: onSearchChanged,
                          onClearFilter: onClearBucket,
                          onChanged: onSearchChanged,
                          selectionColor: kAppSelection,
                        ),
                        const SizedBox(width: 8),
                        _ItemCountLabel(
                          shown: counts.shown,
                          total: counts.total,
                          pluralLabel: type.pluralLabel,
                        ),
                        if (counts.totalPricePaidCents > 0) ...[
                          const SizedBox(width: 8),
                          _CollectionValueChip(
                            totalPaidCents: counts.totalPricePaidCents,
                            totalCoverCents: counts.totalCoverPriceCents,
                            totalSellCents: counts.totalSellPriceCents,
                            currency: counts.priceCurrency,
                          ),
                        ],
                        const Spacer(),
                        LibraryWorkspaceControlStrip(
                          children: [
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
                              onEditSort: onEditSort,
                              onTransferFieldData: onTransferFieldData,
                              onReassignIndex: onReassignIndex,
                              onPrintReport: onPrintReport,
                              onShareCollection: onShareCollection,
                            ),
                            if (onEditFilters != null)
                              _FilterButton(
                                activeCount: activeFilterCount,
                                onPressed: onEditFilters!,
                              ),
                            LibraryViewTableControls(
                              state: LibraryViewTableControlState(
                                counts: LibraryWorkspaceCounts(
                                  shown: counts.shown,
                                  total: counts.total,
                                ),
                                viewMode: viewState.viewMode,
                                detailsLayout: viewState.detailsLayout,
                                isSidebarVisible: viewState.isSidebarVisible,
                                coverSize: viewState.coverSize,
                                minCoverSize: adapter.viewProfile.minCoverSize,
                                maxCoverSize: adapter.viewProfile.maxCoverSize,
                              ),
                              callbacks: LibraryViewTableControlCallbacks(
                                onEditColumns: onEditColumns,
                                onSidebarVisibilityChanged:
                                    onSidebarVisibilityChanged,
                                onViewModeChanged: onViewModeChanged,
                                onDetailsLayoutChanged: onDetailsLayoutChanged,
                                onCoverSizeChanged: onCoverSizeChanged,
                              ),
                            ),
                          ],
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
                      onTogglePinnedColumnFavorite:
                          onTogglePinnedColumnFavorite,
                      onManageColumns: onEditColumns,
                      canJumpToIssue: canJumpToIssue,
                      onJumpToIssueSubmitted: onJumpToIssueSubmitted,
                    ),
                  ],
                  if (showAlphabetRow) ...[
                    const _ToolbarDividerLine(),
                    _ToolbarAlphabetRow(
                      letters: availableLetters,
                      selectedLetter: selectedLetter,
                      onLetterSelected: onLetterSelected!,
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

Color _toolbarForegroundForAccent(Color accent) {
  return Colors.white;
}

class _ToolbarDividerLine extends StatelessWidget {
  const _ToolbarDividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: kAppDivider);
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
          const Icon(Icons.select_all, size: 16, color: kAppTextMuted),
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
    final showChromeRow = onCollectionStatusScopeChanged != null ||
        onViewPresetSelected != null ||
        (sortFavorites.isNotEmpty && onSortFavoriteSelected != null) ||
        (columnFavoritePresets.isNotEmpty &&
            onColumnFavoriteSelected != null) ||
        canJumpToIssue;
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
                        onPressed: () => _showCompactCoverSizeSheet(
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
                      _FilterButton(
                        activeCount: activeFilterCount,
                        onPressed: onEditFilters!,
                      ),
                    Tooltip(
                      message: 'Scan barcode',
                      child: IconButton.filledTonal(
                        onPressed: onScan,
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                    ),
                    Tooltip(
                      message: 'Refresh metadata',
                      child: IconButton.filledTonal(
                        onPressed: onRefreshMetadata,
                        icon: const Icon(Icons.sync),
                      ),
                    ),
                    _ItemCountLabel(
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
          _ToolbarAlphabetRow(
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

  @override
  Widget build(BuildContext context) {
    final pinnedViews = [
      for (final preset in LibraryWorkspacePreset.values)
        if (pinnedViewPresets.contains(preset)) preset,
    ];
    final pinnedSorts = [
      for (final favorite in sortFavorites)
        if (pinnedSortFavoriteIds.contains(favorite.id)) favorite,
    ];
    final pinnedColumns = [
      for (final preset in columnFavoritePresets)
        if (pinnedColumnFavoriteKeys.contains(libraryColumnFavoriteKey(preset)))
          preset,
    ];
    final showFavoriteRow = pinnedViews.isNotEmpty ||
        pinnedSorts.isNotEmpty ||
        pinnedColumns.isNotEmpty ||
        onViewPresetSelected != null ||
        onSortFavoriteSelected != null ||
        onColumnFavoriteSelected != null ||
        canJumpToIssue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCollectionStatusScopeChanged != null)
            SizedBox(
              width: double.infinity,
              height: 38,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final scope
                        in LibraryCollectionStatusScope.values) ...[
                      FilterChip(
                        avatar: Icon(scope.icon, size: 14),
                        label: Text(scope.label),
                        selected: collectionStatusScope == scope,
                        onSelected: (_) =>
                            onCollectionStatusScopeChanged!(scope),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
          if (onCollectionStatusScopeChanged != null && showFavoriteRow)
            const SizedBox(height: 6),
          if (showFavoriteRow)
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final preset in pinnedViews) ...[
                      _ToolbarPinnedChip(
                        icon: preset.icon,
                        label: preset.label,
                        selected: activeViewPreset == preset,
                        onPressed: onViewPresetSelected == null
                            ? null
                            : () => onViewPresetSelected!(preset),
                      ),
                      const SizedBox(width: 6),
                    ],
                    for (final favorite in pinnedSorts) ...[
                      _ToolbarPinnedChip(
                        icon: favorite.icon,
                        label: favorite.label,
                        selected: activeSortFavoriteId == favorite.id,
                        onPressed: onSortFavoriteSelected == null
                            ? null
                            : () => onSortFavoriteSelected!(favorite),
                      ),
                      const SizedBox(width: 6),
                    ],
                    for (final preset in pinnedColumns) ...[
                      _ToolbarPinnedChip(
                        icon: Icons.view_column,
                        label: preset.label,
                        selected: activeColumnFavoriteLabel == preset.label,
                        onPressed: onColumnFavoriteSelected == null
                            ? null
                            : () => onColumnFavoriteSelected!(preset),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (onViewPresetSelected != null)
                      PopupMenuButton<LibraryWorkspacePreset>(
                        initialValue: activeViewPreset,
                        tooltip: 'Views',
                        onSelected: onViewPresetSelected,
                        itemBuilder: (context) => [
                          for (final preset in LibraryWorkspacePreset.values)
                            PopupMenuItem<LibraryWorkspacePreset>(
                              value: preset,
                              child: ListTile(
                                dense: true,
                                leading: Icon(preset.icon, size: 18),
                                title: Text(preset.label),
                                trailing: preset == activeViewPreset
                                    ? const Icon(Icons.check, size: 18)
                                    : null,
                              ),
                            ),
                        ],
                        child: const _ToolbarChromeButton(
                          icon: Icons.grid_view,
                          label: 'Views',
                        ),
                      ),
                    if (onViewPresetSelected != null) const SizedBox(width: 6),
                    if (sortFavorites.isNotEmpty &&
                        onSortFavoriteSelected != null)
                      PopupMenuButton<LibrarySortFavorite>(
                        initialValue: _activeSortFavorite(),
                        tooltip: 'Sort',
                        onSelected: onSortFavoriteSelected,
                        itemBuilder: (context) => [
                          for (final favorite in sortFavorites)
                            PopupMenuItem<LibrarySortFavorite>(
                              value: favorite,
                              child: ListTile(
                                dense: true,
                                leading: Icon(favorite.icon, size: 18),
                                title: Text(favorite.label),
                                trailing: favorite.id == activeSortFavoriteId
                                    ? const Icon(Icons.check, size: 18)
                                    : null,
                              ),
                            ),
                        ],
                        child: const _ToolbarChromeButton(
                          icon: Icons.sort,
                          label: 'Sort',
                        ),
                      ),
                    if (sortFavorites.isNotEmpty &&
                        onSortFavoriteSelected != null)
                      const SizedBox(width: 6),
                    if (onColumnFavoriteSelected != null)
                      PopupMenuButton<Object>(
                        tooltip: 'Columns',
                        onSelected: (selection) {
                          if (selection is _ToolbarPresetSelection<
                              LibraryTableColumnPreset>) {
                            onColumnFavoriteSelected!(selection.value);
                            return;
                          }
                          if (selection is _ToolbarActionSelection) {
                            selection.onSelected();
                          }
                        },
                        itemBuilder: (context) => [
                          for (final preset in columnFavoritePresets)
                            PopupMenuItem<Object>(
                              value: _ToolbarPresetSelection<
                                  LibraryTableColumnPreset>(
                                preset,
                              ),
                              child: ListTile(
                                dense: true,
                                leading:
                                    const Icon(Icons.view_column, size: 18),
                                title: Text(preset.label),
                                trailing:
                                    preset.label == activeColumnFavoriteLabel
                                        ? const Icon(Icons.check, size: 18)
                                        : null,
                              ),
                            ),
                          const PopupMenuDivider(),
                          PopupMenuItem<Object>(
                            value: _ToolbarActionSelection(onManageColumns),
                            child: const ListTile(
                              dense: true,
                              leading: Icon(Icons.tune, size: 18),
                              title: Text('Manage columns...'),
                            ),
                          ),
                        ],
                        child: const _ToolbarChromeButton(
                          icon: Icons.view_column,
                          label: 'Columns',
                        ),
                      ),
                    if (onColumnFavoriteSelected != null)
                      const SizedBox(width: 6),
                    if (onTogglePinnedViewPreset != null ||
                        onTogglePinnedSortFavorite != null ||
                        onTogglePinnedColumnFavorite != null)
                      _ToolbarChromeButton(
                        icon: Icons.push_pin_outlined,
                        label: 'Manage favorites',
                        onPressed: () => _showManageFavoritesSheet(context),
                      ),
                    if ((onTogglePinnedViewPreset != null ||
                            onTogglePinnedSortFavorite != null ||
                            onTogglePinnedColumnFavorite != null) &&
                        canJumpToIssue &&
                        onJumpToIssueSubmitted != null)
                      const SizedBox(width: 6),
                    if (canJumpToIssue && onJumpToIssueSubmitted != null)
                      SizedBox(
                        width: 190,
                        child: _InlineIssueJumpField(
                          onSubmitted: onJumpToIssueSubmitted!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  LibrarySortFavorite? _activeSortFavorite() {
    for (final favorite in sortFavorites) {
      if (favorite.id == activeSortFavoriteId) {
        return favorite;
      }
    }
    return null;
  }

  Future<void> _showManageFavoritesSheet(BuildContext context) {
    final pinnedViews = Set<LibraryWorkspacePreset>.from(pinnedViewPresets);
    final pinnedSorts = Set<String>.from(pinnedSortFavoriteIds);
    final pinnedColumns = Set<String>.from(pinnedColumnFavoriteKeys);

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Pinned favorites',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (onTogglePinnedViewPreset != null) ...[
                    const _ToolbarSheetSectionTitle('Views'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in LibraryWorkspacePreset.values)
                          FilterChip(
                            avatar: Icon(preset.icon, size: 14),
                            label: Text(preset.label),
                            selected: pinnedViews.contains(preset),
                            onSelected: (_) {
                              setModalState(() {
                                if (!pinnedViews.add(preset)) {
                                  pinnedViews.remove(preset);
                                }
                              });
                              onTogglePinnedViewPreset!(preset);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (onTogglePinnedSortFavorite != null &&
                      sortFavorites.isNotEmpty) ...[
                    const _ToolbarSheetSectionTitle('Sorts'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final favorite in sortFavorites)
                          FilterChip(
                            avatar: Icon(favorite.icon, size: 14),
                            label: Text(favorite.label),
                            selected: pinnedSorts.contains(favorite.id),
                            onSelected: (_) {
                              setModalState(() {
                                if (!pinnedSorts.add(favorite.id)) {
                                  pinnedSorts.remove(favorite.id);
                                }
                              });
                              onTogglePinnedSortFavorite!(favorite);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (onTogglePinnedColumnFavorite != null &&
                      columnFavoritePresets.isNotEmpty) ...[
                    const _ToolbarSheetSectionTitle('Columns'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in columnFavoritePresets)
                          FilterChip(
                            avatar: const Icon(Icons.view_column, size: 14),
                            label: Text(preset.label),
                            selected: pinnedColumns
                                .contains(libraryColumnFavoriteKey(preset)),
                            onSelected: (_) {
                              final key = libraryColumnFavoriteKey(preset);
                              setModalState(() {
                                if (!pinnedColumns.add(key)) {
                                  pinnedColumns.remove(key);
                                }
                              });
                              onTogglePinnedColumnFavorite!(preset);
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ToolbarAlphabetRow extends StatelessWidget {
  const _ToolbarAlphabetRow({
    required this.letters,
    required this.selectedLetter,
    required this.onLetterSelected,
  });

  final Set<String> letters;
  final String? selectedLetter;
  final ValueChanged<String?> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    final sortedLetters = letters.toList(growable: false)..sort();
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            ChoiceChip(
              selected: selectedLetter == null,
              onSelected: (_) => onLetterSelected(null),
              label: const Text('All'),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 6),
            for (final letter in sortedLetters) ...[
              ChoiceChip(
                selected: selectedLetter == letter,
                onSelected: (_) =>
                    onLetterSelected(selectedLetter == letter ? null : letter),
                label: Text(letter),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolbarChromeButton extends StatelessWidget {
  const _ToolbarChromeButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}

class _ToolbarPresetSelection<T> {
  const _ToolbarPresetSelection(this.value);

  final T value;
}

class _ToolbarActionSelection {
  const _ToolbarActionSelection(this.onSelected);

  final VoidCallback onSelected;
}

class _ToolbarPinnedChip extends StatelessWidget {
  const _ToolbarPinnedChip({
    required this.icon,
    required this.label,
    required this.selected,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      selected: selected,
      onSelected: onPressed == null ? null : (_) => onPressed!(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _InlineIssueJumpField extends StatefulWidget {
  const _InlineIssueJumpField({required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<_InlineIssueJumpField> createState() => _InlineIssueJumpFieldState();
}

class _InlineIssueJumpFieldState extends State<_InlineIssueJumpField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      final value = _controller.text.trim();
      if (value.isEmpty) {
        return;
      }
      widget.onSubmitted(value);
      _controller.clear();
    }

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Issue #',
        prefixIcon: const Icon(Icons.tag, size: 16),
        suffixIcon: IconButton(
          tooltip: 'Jump to issue',
          onPressed: submit,
          icon: const Icon(Icons.arrow_forward, size: 16),
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: (_) => submit(),
    );
  }
}

class _ToolbarSheetSectionTitle extends StatelessWidget {
  const _ToolbarSheetSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: kAppTextMuted,
            ),
      ),
    );
  }
}

void _showCompactCoverSizeSheet(
  BuildContext context,
  LibraryViewMode viewMode,
  ValueChanged<LibraryViewMode> onViewModeChanged,
  ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged,
  ValueChanged<double> onCoverSizeChanged,
) {
  final coverSizeEnabled = viewMode.supportsCoverSize;
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Grid view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.grid);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Cards view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.card);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_agenda),
            title: const Text('Flow view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.cardFlow);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('List view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.list);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.view_sidebar_outlined),
            title: const Text('Details on right'),
            onTap: () {
              Navigator.of(context).pop();
              onDetailsLayoutChanged(LibraryDetailsLayout.right);
            },
          ),
          ListTile(
            leading: const Icon(Icons.splitscreen_outlined),
            title: const Text('Details on bottom'),
            onTap: () {
              Navigator.of(context).pop();
              onDetailsLayoutChanged(LibraryDetailsLayout.bottom);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close_fullscreen_outlined),
            title: const Text('Hide details'),
            onTap: () {
              Navigator.of(context).pop();
              onDetailsLayoutChanged(LibraryDetailsLayout.hidden);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_size_select_small),
            title: const Text('Small covers'),
            enabled: coverSizeEnabled,
            onTap: coverSizeEnabled
                ? () {
                    Navigator.of(context).pop();
                    onCoverSizeChanged(96);
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.photo_size_select_large),
            title: const Text('Large covers'),
            enabled: coverSizeEnabled,
            onTap: coverSizeEnabled
                ? () {
                    Navigator.of(context).pop();
                    onCoverSizeChanged(188);
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: activeCount > 0,
      label: Text(activeCount.toString()),
      child: IconButton(
        icon: Icon(
          activeCount > 0 ? Icons.filter_alt : Icons.filter_alt_outlined,
          size: 20,
        ),
        tooltip: 'Edit filters',
        onPressed: onPressed,
      ),
    );
  }
}

class _ItemCountLabel extends StatelessWidget {
  const _ItemCountLabel({
    required this.shown,
    required this.total,
    required this.pluralLabel,
  });

  final int shown;
  final int total;
  final String pluralLabel;

  @override
  Widget build(BuildContext context) {
    final label = shown == total
        ? '$total ${pluralLabel.toLowerCase()}'
        : '$shown of $total ${pluralLabel.toLowerCase()}';
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: kAppTextMuted,
      ),
    );
  }
}

class _CollectionValueChip extends StatelessWidget {
  const _CollectionValueChip({
    required this.totalPaidCents,
    required this.totalCoverCents,
    required this.totalSellCents,
    required this.currency,
  });

  final int totalPaidCents;
  final int totalCoverCents;
  final int totalSellCents;
  final String? currency;

  String _fmt(int cents) {
    final cur = currency ?? 'USD';
    return '${(cents / 100).toStringAsFixed(2)} $cur';
  }

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (totalPaidCents > 0) parts.add('Paid ${_fmt(totalPaidCents)}');
    if (totalCoverCents > 0) parts.add('Cover ${_fmt(totalCoverCents)}');
    if (totalSellCents > 0) parts.add('Sold ${_fmt(totalSellCents)}');
    if (parts.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: parts.join('\n'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money,
                size: 13, color: Colors.greenAccent.withValues(alpha: 0.8)),
            const SizedBox(width: 3),
            Text(
              _fmt(totalPaidCents > 0 ? totalPaidCents : totalCoverCents),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
