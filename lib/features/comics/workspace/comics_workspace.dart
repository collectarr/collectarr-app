import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_compact_view.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_desktop.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const double _kDesktopBreakpoint = 980;

class ComicsWorkspace extends StatelessWidget {
  const ComicsWorkspace({
    super.key,
    required this.entries,
    required this.shelfState,
    required this.queryController,
    required this.selectedItemId,
    required this.selectedGroup,
    required this.groupMode,
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
    required this.onGroupModeChanged,
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

  final List<ShelfEntry> entries;
  final ShelfState shelfState;
  final TextEditingController queryController;
  final String? selectedItemId;
  final String? selectedGroup;
  final ComicsShelfGroupMode groupMode;
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
  final ValueChanged<ComicsShelfGroupMode> onGroupModeChanged;
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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _kDesktopBreakpoint;
    final projection = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: groupMode,
      selectedGroup: selectedGroup,
      selectedItemId: selectedItemId,
    );

    if (!isWide) {
      final compact = ComicsCompactView(
        items: projection.visibleItems,
        selectedItem: projection.selectedItem,
        selectedGroup: selectedGroup,
        queryController: queryController,
        onSearch: onSearch,
        onAddComic: onAddComic,
        onEditFilters: onEditFilters,
        hasActiveFilters: hasActiveFilters,
        activeFilterCount: activeFilterCount,
        duplicateGroups: projection.duplicateGroups,
        onClearFilters: onClearFilters,
        coverSize: coverSize,
        onCoverSizeChanged: onCoverSizeChanged,
        onScanBarcode: onScanBarcode,
        onRefreshMetadata: onRefreshMetadata,
        onSelectItem: onSelectItem,
        onClearGroup: onClearGroup,
      );
      if (topBar == null) {
        return compact;
      }
      return Column(
        children: [
          topBar!,
          Expanded(child: compact),
        ],
      );
    }

    return ComicsWorkspaceDesktopLayout(
      projection: projection,
      shelfState: shelfState,
      queryController: queryController,
      selectedGroup: selectedGroup,
      onGroupModeChanged: onGroupModeChanged,
      viewMode: viewMode,
      detailsLayout: detailsLayout,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      coverSize: coverSize,
      sidebarWidth: sidebarWidth,
      detailsWidth: detailsWidth,
      visibleColumns: visibleColumns,
      columnWidths: columnWidths,
      selectionMode: selectionMode,
      selectedItemIds: selectedItemIds,
      quickView: quickView,
      hasActiveFilters: hasActiveFilters,
      activeFilterCount: activeFilterCount,
      onQuickViewSelected: onQuickViewSelected,
      onEditFilters: onEditFilters,
      onClearFilters: onClearFilters,
      onEditColumns: onEditColumns,
      onSearch: onSearch,
      onAddComic: onAddComic,
      onSelectItem: onSelectItem,
      onSelectGroup: onSelectGroup,
      onClearGroup: onClearGroup,
      onScanBarcode: onScanBarcode,
      onRefreshMetadata: onRefreshMetadata,
      onViewModeChanged: onViewModeChanged,
      onDetailsLayoutChanged: onDetailsLayoutChanged,
      onViewPresetSelected: onViewPresetSelected,
      onSortChanged: onSortChanged,
      onColumnWidthChanged: onColumnWidthChanged,
      onColumnReordered: onColumnReordered,
      onCoverSizeChanged: onCoverSizeChanged,
      onSidebarWidthChanged: onSidebarWidthChanged,
      onDetailsWidthChanged: onDetailsWidthChanged,
      onSelectionModeChanged: onSelectionModeChanged,
      onClearSelection: onClearSelection,
      onBulkEdit: onBulkEdit,
      onBulkMoveToOwned: onBulkMoveToOwned,
      onBulkMoveToWishlist: onBulkMoveToWishlist,
      onBulkRemove: onBulkRemove,
      onOpenLibraries: onOpenLibraries,
      topBar: topBar,
    );
  }
}
