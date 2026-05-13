import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_compact_view.dart';
import 'package:collectarr_app/features/comics/comics_workspace_desktop.dart';
import 'package:collectarr_app/features/comics/comics_workspace_projection.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const double _kDesktopBreakpoint = 980;

class ComicsWorkspace extends StatelessWidget {
  const ComicsWorkspace({
    super.key,
    required this.items,
    required this.shelfState,
    required this.queryController,
    required this.selectedItemId,
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

  final List<CatalogItem> items;
  final ShelfState shelfState;
  final TextEditingController queryController;
  final String? selectedItemId;
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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _kDesktopBreakpoint;
    final projection = ComicsWorkspaceProjection.fromItems(
      items: items,
      selectedSeries: selectedSeries,
      selectedItemId: selectedItemId,
    );

    if (!isWide) {
      return ComicsCompactView(
        items: projection.visibleItems,
        selectedItem: projection.selectedItem,
        selectedSeries: selectedSeries,
        queryController: queryController,
        onSearch: onSearch,
        onAddComic: onAddComic,
        onEditFilters: onEditFilters,
        hasActiveFilters: hasActiveFilters,
        coverSize: coverSize,
        onCoverSizeChanged: onCoverSizeChanged,
        onScanBarcode: onScanBarcode,
        onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
        onSelectItem: onSelectItem,
        onClearSeries: onClearSeries,
      );
    }

    return ComicsWorkspaceDesktopLayout(
      projection: projection,
      shelfState: shelfState,
      queryController: queryController,
      selectedSeries: selectedSeries,
      viewMode: viewMode,
      detailsLayout: detailsLayout,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      coverSize: coverSize,
      visibleColumns: visibleColumns,
      columnWidths: columnWidths,
      selectionMode: selectionMode,
      selectedItemIds: selectedItemIds,
      hasActiveFilters: hasActiveFilters,
      onEditFilters: onEditFilters,
      onEditColumns: onEditColumns,
      onSearch: onSearch,
      onAddComic: onAddComic,
      onSelectItem: onSelectItem,
      onSelectSeries: onSelectSeries,
      onClearSeries: onClearSeries,
      onScanBarcode: onScanBarcode,
      onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
      onViewModeChanged: onViewModeChanged,
      onDetailsLayoutChanged: onDetailsLayoutChanged,
      onViewPresetSelected: onViewPresetSelected,
      onSortChanged: onSortChanged,
      onColumnWidthChanged: onColumnWidthChanged,
      onCoverSizeChanged: onCoverSizeChanged,
      onSelectionModeChanged: onSelectionModeChanged,
      onClearSelection: onClearSelection,
      onBulkEdit: onBulkEdit,
      onBulkMoveToOwned: onBulkMoveToOwned,
      onBulkMoveToWishlist: onBulkMoveToWishlist,
      onBulkRemove: onBulkRemove,
    );
  }
}

void _showMetadataRefreshPlaceholder(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Metadata refresh is not wired yet')),
  );
}
