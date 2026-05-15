import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic_library_projection_item.dart';
import 'package:collectarr_app/features/library/generic_library_quick_view.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

export 'generic_library_projection_item.dart';
export 'generic_library_quick_view.dart';

class GenericLibraryProjection {
  const GenericLibraryProjection({
    required this.allItems,
    required this.filteredItems,
    required this.buckets,
    required this.selectedItem,
    required this.counts,
  });

  factory GenericLibraryProjection.fromShelf({
    required ShelfState shelf,
    required LibraryTypeConfig type,
    required LibraryWorkspaceViewState viewState,
    required String query,
    required String? selectedBucket,
    required String? selectedItemId,
    required GenericQuickView? quickView,
  }) {
    final allItems = genericItemsForShelf(shelf, type);
    final normalizedQuery = query.trim().toLowerCase();
    final filteredItems = [
      for (final item in allItems)
        if (_matchesBucket(item, type, selectedBucket) &&
            _matchesQuickView(item, quickView) &&
            _matchesQuery(item, normalizedQuery))
          item,
    ]..sort((a, b) => compareLibraryWorkspaceEntries(
          a.entry,
          b.entry,
          viewState.sortColumn,
          viewState.sortAscending,
        ));
    final counts = _toolbarCountsForItems(
      allItems: allItems,
      shown: filteredItems.length,
    );
    return GenericLibraryProjection(
      allItems: allItems,
      filteredItems: filteredItems,
      buckets: genericBucketsForItems(allItems, type),
      selectedItem: genericSelectedItem(filteredItems, selectedItemId),
      counts: counts,
    );
  }

  final List<GenericLibraryItem> allItems;
  final List<GenericLibraryItem> filteredItems;
  final List<LibrarySeriesBucket> buckets;
  final GenericLibraryItem? selectedItem;
  final GenericToolbarCounts counts;
}

List<LibrarySeriesBucket> genericBucketsForItems(
  List<GenericLibraryItem> items,
  LibraryTypeConfig type,
) {
  final counts = <String, int>{genericAllBucketLabel(type): items.length};
  for (final item in items) {
    final bucket = genericBucketForItem(item, type);
    counts[bucket] = (counts[bucket] ?? 0) + 1;
  }
  final buckets = [
    for (final entry in counts.entries)
      LibrarySeriesBucket(title: entry.key, count: entry.value),
  ];
  buckets.sort((a, b) {
    if (a.title == genericAllBucketLabel(type)) {
      return -1;
    }
    if (b.title == genericAllBucketLabel(type)) {
      return 1;
    }
    return a.title.compareTo(b.title);
  });
  return buckets;
}

GenericLibraryItem? genericSelectedItem(
  List<GenericLibraryItem> items,
  String? selectedItemId,
) {
  for (final item in items) {
    if (item.entry.id == selectedItemId) {
      return item;
    }
  }
  return items.isEmpty ? null : items.first;
}

String genericBucketForItem(GenericLibraryItem item, LibraryTypeConfig type) {
  final entry = item.entry;
  final publisher = entry.publisher?.trim();
  if (type.workspace.kind == 'movie' ||
      type.workspace.kind == 'tv' ||
      type.workspace.kind == 'anime') {
    return entry.releaseYear?.toString() ??
        (entry.releaseDate?.year.toString() ?? 'Unknown year');
  }
  if (type.workspace.kind == 'music' &&
      publisher != null &&
      publisher.isNotEmpty) {
    return publisher;
  }
  if ((type.workspace.kind == 'book' ||
          type.workspace.kind == 'game' ||
          type.workspace.kind == 'boardgame' ||
          type.workspace.kind == 'manga') &&
      publisher != null &&
      publisher.isNotEmpty) {
    return publisher;
  }
  final title = entry.title.trim();
  return title.isEmpty ? 'Unknown' : title.characters.first.toUpperCase();
}

String genericAllBucketLabel(LibraryTypeConfig type) {
  return '[All ${type.pluralLabel}]';
}

bool _matchesBucket(
  GenericLibraryItem item,
  LibraryTypeConfig type,
  String? selectedBucket,
) {
  return selectedBucket == null ||
      genericBucketForItem(item, type) == selectedBucket;
}

bool _matchesQuickView(GenericLibraryItem item, GenericQuickView? quickView) {
  return switch (quickView) {
    null => true,
    GenericQuickView.owned => item.entry.isOwned,
    GenericQuickView.wishlist => item.entry.isWishlisted,
    GenericQuickView.missingCovers => item.entry.hasMissingCover,
    GenericQuickView.missingMetadata => item.entry.hasMissingMetadata,
  };
}

bool _matchesQuery(GenericLibraryItem item, String query) {
  if (query.isEmpty) {
    return true;
  }
  final entry = item.entry;
  return _containsQuery(entry.title, query) ||
      _containsQuery(entry.itemNumber, query) ||
      _containsQuery(entry.publisher, query) ||
      _containsQuery(entry.variant, query) ||
      _containsQuery(entry.barcode, query) ||
      _containsQuery(entry.releaseYear?.toString(), query) ||
      _containsQuery(entry.condition, query) ||
      _containsQuery(entry.grade, query) ||
      _containsQuery(entry.storageBox, query);
}

GenericToolbarCounts _toolbarCountsForItems({
  required List<GenericLibraryItem> allItems,
  required int shown,
}) {
  var owned = 0;
  var wishlist = 0;
  var missingCover = 0;
  var missingMetadata = 0;
  for (final item in allItems) {
    final entry = item.entry;
    if (entry.isOwned) {
      owned += 1;
    }
    if (entry.isWishlisted) {
      wishlist += 1;
    }
    if (entry.hasMissingCover) {
      missingCover += 1;
    }
    if (entry.hasMissingMetadata) {
      missingMetadata += 1;
    }
  }
  return GenericToolbarCounts(
    shown: shown,
    total: allItems.length,
    owned: owned,
    wishlist: wishlist,
    missingCover: missingCover,
    missingMetadata: missingMetadata,
  );
}

bool _containsQuery(String? value, String query) {
  return value != null && value.toLowerCase().contains(query);
}
