import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_duplicate_items.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:flutter/material.dart';

enum ComicsShelfGroupMode {
  series,
  publisher,
  year,
  grade,
  condition,
  wishlist,
}

extension ComicsShelfGroupModeLabels on ComicsShelfGroupMode {
  String get label {
    return switch (this) {
      ComicsShelfGroupMode.series => 'Series',
      ComicsShelfGroupMode.publisher => 'Publisher',
      ComicsShelfGroupMode.year => 'Year',
      ComicsShelfGroupMode.grade => 'Grade',
      ComicsShelfGroupMode.condition => 'Condition',
      ComicsShelfGroupMode.wishlist => 'Wishlist',
    };
  }

  IconData get icon {
    return switch (this) {
      ComicsShelfGroupMode.series => Icons.folder,
      ComicsShelfGroupMode.publisher => Icons.business,
      ComicsShelfGroupMode.year => Icons.calendar_month,
      ComicsShelfGroupMode.grade => Icons.workspace_premium,
      ComicsShelfGroupMode.condition => Icons.fact_check_outlined,
      ComicsShelfGroupMode.wishlist => Icons.star,
    };
  }
}

class ComicsWorkspaceProjection {
  const ComicsWorkspaceProjection({
    required this.groupMode,
    required this.groups,
    required this.selectedGroup,
    required this.visibleItems,
    required this.selectedItem,
    required this.missingIssues,
    required this.duplicateGroups,
    required this.totalCount,
  });

  factory ComicsWorkspaceProjection.fromItems({
    required List<CatalogItem> items,
    required String? selectedSeries,
    required String? selectedItemId,
    ComicsShelfGroupMode groupMode = ComicsShelfGroupMode.series,
    String? selectedGroup,
  }) {
    final activeGroup = selectedGroup ?? selectedSeries;
    final visibleItems = activeGroup == null
        ? items
        : items
            .where((item) => _itemGroupLabel(item, groupMode) == activeGroup)
            .toList(growable: false);
    return ComicsWorkspaceProjection(
      groupMode: groupMode,
      groups: _itemGroupBuckets(items, groupMode),
      selectedGroup: activeGroup,
      visibleItems: visibleItems,
      selectedItem: _selectedItem(visibleItems, selectedItemId),
      missingIssues:
          groupMode != ComicsShelfGroupMode.series || activeGroup == null
              ? const <int>[]
              : _missingIssueNumbers(visibleItems),
      duplicateGroups: const <ComicsDuplicateGroup>[],
      totalCount: items.length,
    );
  }

  factory ComicsWorkspaceProjection.fromEntries({
    required List<ShelfEntry> entries,
    required ComicsShelfGroupMode groupMode,
    required String? selectedGroup,
    required String? selectedItemId,
  }) {
    final source = [
      for (final entry in entries)
        _ComicsProjectionEntry(
          entry: entry,
          item: _catalogItemForEntry(entry),
        ),
    ];
    final visibleEntries = selectedGroup == null
        ? source
        : source
            .where(
              (entry) => _entryGroupLabel(entry, groupMode) == selectedGroup,
            )
            .toList(growable: false);
    final visibleItems = [
      for (final entry in visibleEntries) entry.item,
    ];
    return ComicsWorkspaceProjection(
      groupMode: groupMode,
      groups: _entryGroupBuckets(source, groupMode),
      selectedGroup: selectedGroup,
      visibleItems: visibleItems,
      selectedItem: _selectedItem(visibleItems, selectedItemId),
      missingIssues:
          groupMode != ComicsShelfGroupMode.series || selectedGroup == null
              ? const <int>[]
              : _missingIssueNumbers(visibleItems),
      duplicateGroups: duplicateComicsShelfGroups(entries),
      totalCount: source.length,
    );
  }

  final ComicsShelfGroupMode groupMode;
  final List<LibrarySeriesBucket> groups;
  final String? selectedGroup;
  final List<CatalogItem> visibleItems;
  final CatalogItem? selectedItem;
  final List<int> missingIssues;
  final List<ComicsDuplicateGroup> duplicateGroups;
  final int totalCount;

  List<LibrarySeriesBucket> get series => groups;
  String? get selectedSeries =>
      groupMode == ComicsShelfGroupMode.series ? selectedGroup : null;
  int get visibleCount => visibleItems.length;
}

class _ComicsProjectionEntry {
  const _ComicsProjectionEntry({
    required this.entry,
    required this.item,
  });

  final ShelfEntry entry;
  final CatalogItem item;
}

List<LibrarySeriesBucket> _itemGroupBuckets(
  List<CatalogItem> source,
  ComicsShelfGroupMode mode,
) {
  final counts = <String, int>{};
  for (final item in source) {
    final label = _itemGroupLabel(item, mode);
    counts[label] = (counts[label] ?? 0) + 1;
  }
  return _sortedBuckets(counts, mode);
}

List<LibrarySeriesBucket> _entryGroupBuckets(
  List<_ComicsProjectionEntry> source,
  ComicsShelfGroupMode mode,
) {
  final counts = <String, int>{};
  for (final entry in source) {
    final label = _entryGroupLabel(entry, mode);
    counts[label] = (counts[label] ?? 0) + 1;
  }
  return _sortedBuckets(counts, mode);
}

List<LibrarySeriesBucket> _sortedBuckets(
  Map<String, int> counts,
  ComicsShelfGroupMode mode,
) {
  final buckets = [
    for (final entry in counts.entries)
      LibrarySeriesBucket(title: entry.key, count: entry.value),
  ];
  buckets.sort((a, b) {
    if (mode == ComicsShelfGroupMode.year) {
      return _compareYearBuckets(a.title, b.title);
    }
    if (mode == ComicsShelfGroupMode.wishlist) {
      return _wishlistBucketOrder(a.title).compareTo(
        _wishlistBucketOrder(b.title),
      );
    }
    if (mode == ComicsShelfGroupMode.grade ||
        mode == ComicsShelfGroupMode.condition) {
      final leftOrder = _personalBucketOrder(a.title);
      final rightOrder = _personalBucketOrder(b.title);
      if (leftOrder != rightOrder) {
        return leftOrder.compareTo(rightOrder);
      }
    }
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
  return buckets;
}

String _entryGroupLabel(
  _ComicsProjectionEntry source,
  ComicsShelfGroupMode mode,
) {
  return switch (mode) {
    ComicsShelfGroupMode.grade => _nonEmpty(
        source.entry.ownedItem?.grade,
        source.entry.isOwned ? 'Ungraded' : 'Not owned',
      ),
    ComicsShelfGroupMode.condition => _nonEmpty(
        source.entry.ownedItem?.condition,
        source.entry.isOwned ? 'Unknown Condition' : 'Not owned',
      ),
    ComicsShelfGroupMode.wishlist => _wishlistLabel(source.entry),
    _ => _itemGroupLabel(source.item, mode),
  };
}

String _itemGroupLabel(CatalogItem item, ComicsShelfGroupMode mode) {
  return switch (mode) {
    ComicsShelfGroupMode.series => item.title,
    ComicsShelfGroupMode.publisher =>
      _nonEmpty(item.publisher, 'Unknown Publisher'),
    ComicsShelfGroupMode.year => item.releaseYear?.toString() ??
        item.releaseDate?.year.toString() ??
        'Unknown Year',
    ComicsShelfGroupMode.grade => 'Not owned',
    ComicsShelfGroupMode.condition => 'Not owned',
    ComicsShelfGroupMode.wishlist => 'Local',
  };
}

CatalogItem _catalogItemForEntry(ShelfEntry entry) {
  return entry.catalogItem ??
      CatalogItem(
        id: entry.itemId,
        kind: comicsLibraryConfig.workspace.kind,
        title: entry.title,
      );
}

String _wishlistLabel(ShelfEntry entry) {
  if (entry.isOwned && entry.isWishlisted) {
    return 'Owned + Wishlist';
  }
  if (entry.isWishlisted) {
    return 'Wishlist';
  }
  if (entry.isOwned) {
    return 'Owned';
  }
  return 'Local';
}

String _nonEmpty(String? value, String fallback) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

int _compareYearBuckets(String a, String b) {
  final left = int.tryParse(a);
  final right = int.tryParse(b);
  if (left != null && right != null) {
    return right.compareTo(left);
  }
  if (left != null) {
    return -1;
  }
  if (right != null) {
    return 1;
  }
  return a.toLowerCase().compareTo(b.toLowerCase());
}

int _wishlistBucketOrder(String title) {
  return switch (title) {
    'Owned' => 0,
    'Wishlist' => 1,
    'Owned + Wishlist' => 2,
    _ => 3,
  };
}

int _personalBucketOrder(String title) {
  return switch (title) {
    'Ungraded' || 'Unknown Condition' => 1,
    'Not owned' => 2,
    _ => 0,
  };
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
