import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_compact_view.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_shelf_views.dart';
import 'package:collectarr_app/features/comics/comics_stats.dart';
import 'package:collectarr_app/features/comics/comics_toolbar.dart';
import 'package:collectarr_app/features/comics/comics_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
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
    final series = _seriesBuckets(items);
    final visibleItems = selectedSeries == null
        ? items
        : items
            .where((item) => item.title == selectedSeries)
            .toList(growable: false);
    final selectedItem = _selectedItem(visibleItems, selectedItemId);
    final missingIssues = selectedSeries == null
        ? const <int>[]
        : _missingIssueNumbers(visibleItems);

    if (!isWide) {
      return ComicsCompactView(
        items: visibleItems,
        selectedItem: selectedItem,
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

    return Column(
      children: [
        ComicsTopBar(totalCount: items.length),
        ComicsToolbar(
          controller: queryController,
          itemCount: visibleItems.length,
          totalCount: items.length,
          selectedSeries: selectedSeries,
          viewMode: viewMode,
          detailsLayout: detailsLayout,
          coverSize: coverSize,
          hasActiveFilters: hasActiveFilters,
          missingIssues: missingIssues,
          selectionMode: selectionMode,
          selectedCount: selectedItemIds.length,
          onSearch: onSearch,
          onAddComic: onAddComic,
          onEditFilters: onEditFilters,
          onEditColumns: onEditColumns,
          onScanBarcode: onScanBarcode,
          onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
          onShowStats: () => showComicsStatsDashboardDialog(
            context,
            state: shelfState,
            selectedSeries: selectedSeries,
            missingIssues: missingIssues,
          ),
          onClearSeries: onClearSeries,
          onViewModeChanged: onViewModeChanged,
          onDetailsLayoutChanged: onDetailsLayoutChanged,
          onViewPresetSelected: onViewPresetSelected,
          onCoverSizeChanged: onCoverSizeChanged,
          onSelectionModeChanged: onSelectionModeChanged,
          onClearSelection: onClearSelection,
          onBulkEdit: onBulkEdit,
          onBulkMoveToOwned: onBulkMoveToOwned,
          onBulkMoveToWishlist: onBulkMoveToWishlist,
          onBulkRemove: onBulkRemove,
        ),
        ComicsStatsBar(
          state: shelfState,
          selectedSeries: selectedSeries,
          missingIssues: missingIssues,
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: LibrarySeriesSidebar(
                  series: series,
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
                    items: visibleItems,
                    selectedItemId: selectedItem?.id,
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
                  inspector: LibraryAwareComicInspector(item: selectedItem),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<LibrarySeriesBucket> _seriesBuckets(List<CatalogItem> source) {
  final counts = <String, int>{};
  for (final item in source) {
    counts[item.title] = (counts[item.title] ?? 0) + 1;
  }
  final buckets = counts.entries
      .map(
        (entry) => LibrarySeriesBucket(
          title: entry.key,
          count: entry.value,
        ),
      )
      .toList(growable: false)
    ..sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
  return buckets;
}

void _showMetadataRefreshPlaceholder(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Metadata refresh is not wired yet')),
  );
}

List<int> _missingIssueNumbers(List<CatalogItem> source) {
  final numbers = {
    for (final item in source)
      if (_parseIssueNumber(item.itemNumber) != null)
        _parseIssueNumber(item.itemNumber)!,
  }.toList(growable: false)
    ..sort();
  if (numbers.length < 2) {
    return const [];
  }
  final missing = <int>[];
  for (var number = numbers.first; number <= numbers.last; number++) {
    if (!numbers.contains(number)) {
      missing.add(number);
    }
  }
  return missing;
}

CatalogItem? _selectedItem(List<CatalogItem> visibleItems, String? selectedId) {
  if (visibleItems.isEmpty) {
    return null;
  }
  if (selectedId == null) {
    return visibleItems.first;
  }
  for (final item in visibleItems) {
    if (item.id == selectedId) {
      return item;
    }
  }
  return visibleItems.first;
}

int? _parseIssueNumber(String? value) {
  if (value == null) {
    return null;
  }
  return int.tryParse(value.trim());
}
