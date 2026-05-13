import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_shelf_views.dart';
import 'package:collectarr_app/features/comics/comics_stats.dart';
import 'package:collectarr_app/features/comics/comics_toolbar.dart';
import 'package:collectarr_app/features/comics/comics_workspace_chrome.dart';
import 'package:collectarr_app/features/comics/comics_workspace_controls.dart';
import 'package:collectarr_app/features/comics/comics_workspace_projection.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class ComicsWorkspaceDesktopLayout extends StatelessWidget {
  const ComicsWorkspaceDesktopLayout({
    super.key,
    required this.projection,
    required this.shelfState,
    required this.queryController,
    required this.selectedSeries,
    required this.viewMode,
    required this.detailsLayout,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required this.visibleColumns,
    required this.columnWidths,
    required this.selectionMode,
    required this.selectedItemIds,
    required this.hasActiveFilters,
    required this.onEditFilters,
    required this.onEditColumns,
    required this.onSearch,
    required this.onAddComic,
    required this.onSelectItem,
    required this.onSelectSeries,
    required this.onClearSeries,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final ComicsWorkspaceProjection projection;
  final ShelfState shelfState;
  final TextEditingController queryController;
  final String? selectedSeries;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final bool selectionMode;
  final Set<String> selectedItemIds;
  final bool hasActiveFilters;
  final VoidCallback onEditFilters;
  final VoidCallback onEditColumns;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;
  final ValueChanged<String> onSelectSeries;
  final VoidCallback onClearSeries;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ComicsTopBar(totalCount: projection.totalCount),
        ComicsToolbar(
          controller: queryController,
          controlState: ComicsWorkspaceControlState(
            selection: ComicsSelectionControlState(
              enabled: selectionMode,
              selectedCount: selectedItemIds.length,
            ),
            utility: ComicsWorkspaceUtilityState(
              selectedSeries: selectedSeries,
              hasActiveFilters: hasActiveFilters,
              missingIssues: projection.missingIssues,
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
                selectedSeries: selectedSeries,
                missingIssues: projection.missingIssues,
              ),
              onEditFilters: onEditFilters,
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
          onClearSeries: onClearSeries,
        ),
        ComicsStatsBar(
          state: shelfState,
          selectedSeries: selectedSeries,
          missingIssues: projection.missingIssues,
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: LibrarySeriesSidebar(
                  series: projection.series,
                  selectedSeries: selectedSeries,
                  onSelectSeries: onSelectSeries,
                  backgroundColor: kClzPanel,
                  headerColor: const Color(0xFF303030),
                  dividerColor: kClzDivider,
                  accentColor: kClzAccent,
                  selectionColor: kClzSelection,
                  selectedBadgeColor: kClzYellow,
                  mutedTextColor: kClzTextMuted,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: ComicsDetailsAwareLayout(
                  content: ComicsShelfContent(
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
                    onAddComic: onAddComic,
                    onSelectItem: onSelectItem,
                  ),
                  detailsLayout: detailsLayout,
                  inspector: LibraryAwareComicInspector(
                    item: projection.selectedItem,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
