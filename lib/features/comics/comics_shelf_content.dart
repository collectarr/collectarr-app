import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_shelf_grid.dart';
import 'package:collectarr_app/features/comics/comics_shelf_table.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class ComicsShelfContent extends StatelessWidget {
  const ComicsShelfContent({
    super.key,
    required this.viewMode,
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.sortColumn,
    required this.sortAscending,
    required this.visibleColumns,
    required this.columnWidths,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
    required this.onAddComic,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onSelectItem,
  });

  final LibraryViewMode viewMode;
  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;
  final VoidCallback onAddComic;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return switch (viewMode) {
      LibraryViewMode.grid => ComicsShelfCoverGrid(
          items: items,
          selectedItemId: selectedItemId,
          selectedItemIds: selectedItemIds,
          coverSize: coverSize,
          onAddComic: onAddComic,
          hasActiveFilters: hasActiveFilters,
          onClearFilters: onClearFilters,
          onSelectItem: onSelectItem,
        ),
      LibraryViewMode.card => ComicsShelfCardGrid(
          items: items,
          selectedItemId: selectedItemId,
          selectedItemIds: selectedItemIds,
          coverSize: coverSize,
          onAddComic: onAddComic,
          hasActiveFilters: hasActiveFilters,
          onClearFilters: onClearFilters,
          onSelectItem: onSelectItem,
        ),
      LibraryViewMode.list => ComicsShelfList(
          items: items,
          selectedItemId: selectedItemId,
          selectedItemIds: selectedItemIds,
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
        ),
    };
  }
}
