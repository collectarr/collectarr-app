import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/inspector/comics_inspector.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_views.dart';
import 'package:collectarr_app/features/comics/stats/comics_stats.dart';
import 'package:collectarr_app/features/comics/comics_toolbar.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_chrome.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_controls.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_ctrl_scroll_zoom.dart';
import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/library_resizable_pane.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class ComicsWorkspaceDesktopLayout extends StatelessWidget {
  const ComicsWorkspaceDesktopLayout({
    super.key,
    required this.projection,
    required this.shelfState,
    required this.queryController,
    required this.selectedGroup,
    required this.onGroupModeChanged,
    required this.viewMode,
    required this.detailsLayout,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.visibleColumns,
    required this.columnWidths,
    required this.selectionMode,
    required this.selectedItemIds,
    required this.quickView,
    required this.hasActiveFilters,
    required this.activeFilterCount,
    required this.onQuickViewSelected,
    required this.onEditFilters,
    required this.onClearFilters,
    required this.onEditColumns,
    required this.onSearch,
    required this.onAddComic,
    required this.onSelectItem,
    required this.onSelectGroup,
    required this.onClearGroup,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
    required this.onCoverSizeChanged,
    required this.onSidebarWidthChanged,
    required this.onDetailsWidthChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
    this.onOpenLibraries,
    this.topBar,
  });

  final ComicsWorkspaceProjection projection;
  final ShelfState shelfState;
  final TextEditingController queryController;
  final String? selectedGroup;
  final ValueChanged<ComicsShelfGroupMode> onGroupModeChanged;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final double sidebarWidth;
  final double detailsWidth;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final bool selectionMode;
  final Set<String> selectedItemIds;
  final ComicsShelfQuickView? quickView;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final ValueChanged<ComicsShelfQuickView> onQuickViewSelected;
  final VoidCallback onEditFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onEditColumns;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;
  final ValueChanged<String> onSelectGroup;
  final VoidCallback onClearGroup;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<double> onSidebarWidthChanged;
  final ValueChanged<double> onDetailsWidthChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;
  final VoidCallback? onOpenLibraries;
  final Widget? topBar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSidebarWidth = maxLibraryPaneWidthForViewport(
          viewportWidth: constraints.maxWidth,
          preferredMaxWidth: kLibrarySidebarMaxWidth,
          viewportFraction: 0.34,
        );
        final effectiveSidebarWidth = clampLibraryPaneWidth(
          sidebarWidth,
          minWidth: kLibrarySidebarMinWidth,
          maxWidth: maxSidebarWidth,
        );
        final maxDetailsWidth = maxLibraryPaneWidthForViewport(
          viewportWidth: constraints.maxWidth,
          preferredMaxWidth: kLibraryDetailsMaxWidth,
          viewportFraction: 0.38,
        );
        return Column(
          children: [
            topBar ??
                ComicsTopBar(
                  totalCount: projection.totalCount,
                  onOpenLibraries: onOpenLibraries,
                ),
            ComicsToolbar(
              controller: queryController,
              controlState: ComicsWorkspaceControlState(
                selection: ComicsSelectionControlState(
                  enabled: selectionMode,
                  selectedCount: selectedItemIds.length,
                ),
                utility: ComicsWorkspaceUtilityState(
                  selectedSeries: projection.selectedSeries,
                  hasActiveFilters: hasActiveFilters,
                  activeFilterCount: activeFilterCount,
                  quickView: quickView,
                  missingIssues: projection.missingIssues,
                  duplicateGroups: projection.duplicateGroups,
                ),
                view: ComicsViewTableControlState(
                  counts: ComicsWorkspaceCounts(
                    shown: projection.visibleCount,
                    total: projection.totalCount,
                  ),
                  viewMode: viewMode,
                  detailsLayout: detailsLayout,
                  coverSize: coverSize,
                ),
              ),
              controlCallbacks: ComicsWorkspaceControlCallbacks(
                selection: ComicsSelectionControlCallbacks(
                  onSelectionModeChanged: onSelectionModeChanged,
                  onClearSelection: onClearSelection,
                  onBulkEdit: onBulkEdit,
                  onBulkMoveToOwned: onBulkMoveToOwned,
                  onBulkMoveToWishlist: onBulkMoveToWishlist,
                  onBulkRemove: onBulkRemove,
                ),
                utility: ComicsWorkspaceUtilityCallbacks(
                  onShowStats: () => showComicsStatsDashboardDialog(
                    context,
                    state: shelfState,
                    selectedSeries: projection.selectedSeries,
                    missingIssues: projection.missingIssues,
                  ),
                  onQuickViewSelected: onQuickViewSelected,
                  onEditFilters: onEditFilters,
                  onClearFilters: onClearFilters,
                ),
                view: ComicsViewTableControlCallbacks(
                  onEditColumns: onEditColumns,
                  onViewModeChanged: onViewModeChanged,
                  onDetailsLayoutChanged: onDetailsLayoutChanged,
                  onViewPresetSelected: onViewPresetSelected,
                  onCoverSizeChanged: onCoverSizeChanged,
                ),
              ),
              onSearch: onSearch,
              onAddComic: onAddComic,
              onScanBarcode: onScanBarcode,
              onRefreshMetadata: onRefreshMetadata,
              onClearSeries: onClearGroup,
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: effectiveSidebarWidth,
                    child: LibrarySeriesSidebar(
                      series: projection.groups,
                      selectedSeries: selectedGroup,
                      onSelectSeries: onSelectGroup,
                      title: projection.groupMode.label,
                      icon: projection.groupMode.icon,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ComicsGroupingMenu(
                            groupMode: projection.groupMode,
                            onChanged: onGroupModeChanged,
                          ),
                          IconButton(
                            tooltip: 'Clear group filter',
                            onPressed:
                                selectedGroup == null ? null : onClearGroup,
                            icon: const Icon(Icons.filter_alt_off, size: 18),
                          ),
                        ],
                      ),
                      backgroundColor: kClzPanel,
                      headerColor: const Color(0xFF303030),
                      dividerColor: kClzDivider,
                      accentColor: kClzAccent,
                      selectionColor: kClzSelection,
                      selectedBadgeColor: kClzYellow,
                      mutedTextColor: kClzTextMuted,
                    ),
                  ),
                  LibraryResizableDivider(
                    onDragDelta: (delta) => onSidebarWidthChanged(
                      clampLibraryPaneWidth(
                        effectiveSidebarWidth + delta,
                        minWidth: kLibrarySidebarMinWidth,
                        maxWidth: maxSidebarWidth,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LibraryDetailsAwareLayout(
                      content: LibraryCtrlScrollZoom(
                        coverSize: coverSize,
                        minCoverSize: kComicsMinCoverSize,
                        maxCoverSize: kComicsMaxCoverSize,
                        onCoverSizeChanged: onCoverSizeChanged,
                        child: ComicsShelfContent(
                          viewMode: viewMode,
                          items: projection.visibleItems,
                          selectedItemId: projection.selectedItem?.id,
                          selectedItemIds: selectedItemIds,
                          coverSize: coverSize,
                          sortColumn: sortColumn,
                          sortAscending: sortAscending,
                          visibleColumns: visibleColumns,
                          columnWidths: columnWidths,
                          onSortChanged: onSortChanged,
                          onColumnWidthChanged: onColumnWidthChanged,
                          onColumnReordered: onColumnReordered,
                          onAddComic: onAddComic,
                          hasActiveFilters: hasActiveFilters,
                          onClearFilters: onClearFilters,
                          onSelectItem: onSelectItem,
                          isSeriesView: projection.groupMode ==
                                  ComicsShelfGroupMode.series &&
                              selectedGroup != null,
                        ),
                      ),
                      detailsLayout: detailsLayout,
                      inspector: LibraryAwareComicInspector(
                        item: projection.selectedItem,
                      ),
                      rightWidth: detailsWidth,
                      maxRightWidth: maxDetailsWidth,
                      onRightWidthChanged: onDetailsWidthChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ComicsGroupingMenu extends StatelessWidget {
  const _ComicsGroupingMenu({
    required this.groupMode,
    required this.onChanged,
  });

  final ComicsShelfGroupMode groupMode;
  final ValueChanged<ComicsShelfGroupMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ComicsShelfGroupMode>(
      tooltip: 'Group by',
      icon: const Icon(Icons.tune, size: 18),
      initialValue: groupMode,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final mode in ComicsShelfGroupMode.values)
          PopupMenuItem(
            value: mode,
            child: ListTile(
              dense: true,
              leading: Icon(mode.icon),
              title: Text(mode.label),
            ),
          ),
      ],
    );
  }
}
