import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';

class ComicsWorkspaceProjection {
  const ComicsWorkspaceProjection({
    required this.series,
    required this.visibleItems,
    required this.selectedItem,
    required this.missingIssues,
    required this.totalCount,
  });

  factory ComicsWorkspaceProjection.fromItems({
    required List<CatalogItem> items,
    required String? selectedSeries,
    required String? selectedItemId,
  }) {
    final visibleItems = selectedSeries == null
        ? items
        : items
            .where((item) => item.title == selectedSeries)
            .toList(growable: false);
    return ComicsWorkspaceProjection(
      series: _seriesBuckets(items),
      visibleItems: visibleItems,
      selectedItem: _selectedItem(visibleItems, selectedItemId),
      missingIssues: selectedSeries == null
          ? const <int>[]
          : _missingIssueNumbers(visibleItems),
      totalCount: items.length,
    );
  }

  final List<LibrarySeriesBucket> series;
  final List<CatalogItem> visibleItems;
  final CatalogItem? selectedItem;
  final List<int> missingIssues;
  final int totalCount;

  int get visibleCount => visibleItems.length;
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

List<int> _missingIssueNumbers(List<CatalogItem> source) {
  final issueNumbers = <int>{};
  for (final item in source) {
    final issueNumber = _parseIssueNumber(item.itemNumber);
    if (issueNumber != null) {
      issueNumbers.add(issueNumber);
    }
  }
  final numbers = issueNumbers.toList(growable: false)..sort();
  if (numbers.length < 2) {
    return const [];
  }
  final missing = <int>[];
  for (var number = numbers.first; number <= numbers.last; number++) {
    if (!issueNumbers.contains(number)) {
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
