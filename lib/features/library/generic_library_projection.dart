import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic_library_projection_item.dart';
import 'package:collectarr_app/features/library/generic_library_quick_view.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

export 'generic_library_projection_item.dart';
export 'generic_library_quick_view.dart';

enum GenericLibraryGroupMode { series, title, publisher, year, ownership }

String genericGroupModeLabel(
  GenericLibraryGroupMode mode,
  LibraryTypeConfig type,
) {
  return switch (mode) {
    GenericLibraryGroupMode.series => 'Series',
    GenericLibraryGroupMode.title => 'Title',
    GenericLibraryGroupMode.publisher =>
      type.workspace.kind == 'music' ? 'Artist' : 'Publisher',
    GenericLibraryGroupMode.year => 'Year',
    GenericLibraryGroupMode.ownership => 'Ownership',
  };
}

String genericGroupModeSidebarTitle(
  GenericLibraryGroupMode mode,
  LibraryTypeConfig type,
) {
  return switch (mode) {
    GenericLibraryGroupMode.series => 'Series',
    GenericLibraryGroupMode.title => 'Titles',
    GenericLibraryGroupMode.publisher =>
      type.workspace.kind == 'music' ? 'Artists' : 'Publishers',
    GenericLibraryGroupMode.year => 'Years',
    GenericLibraryGroupMode.ownership => 'Ownership',
  };
}

IconData genericGroupModeIcon(GenericLibraryGroupMode mode) {
  return switch (mode) {
    GenericLibraryGroupMode.series => Icons.collections_bookmark_outlined,
    GenericLibraryGroupMode.title => Icons.sort_by_alpha,
    GenericLibraryGroupMode.publisher => Icons.business_outlined,
    GenericLibraryGroupMode.year => Icons.calendar_today_outlined,
    GenericLibraryGroupMode.ownership => Icons.inventory_2_outlined,
  };
}

List<GenericLibraryGroupMode> genericGroupModesForType(
  LibraryTypeConfig type,
) {
  if (type.workspace.kind == 'music') {
    return [
      GenericLibraryGroupMode.series,
      GenericLibraryGroupMode.publisher,
      GenericLibraryGroupMode.year,
      GenericLibraryGroupMode.title,
      GenericLibraryGroupMode.ownership,
    ];
  }
  if (type.workspace.kind == 'anime' ||
      type.workspace.kind == 'tv') {
    return [
      GenericLibraryGroupMode.series,
      GenericLibraryGroupMode.year,
      GenericLibraryGroupMode.publisher,
      GenericLibraryGroupMode.title,
      GenericLibraryGroupMode.ownership,
    ];
  }
  if (type.workspace.kind == 'manga') {
    return [
      GenericLibraryGroupMode.series,
      GenericLibraryGroupMode.publisher,
      GenericLibraryGroupMode.year,
      GenericLibraryGroupMode.title,
      GenericLibraryGroupMode.ownership,
    ];
  }
  if (type.workspace.kind == 'movie') {
    return [
      GenericLibraryGroupMode.year,
      GenericLibraryGroupMode.series,
      GenericLibraryGroupMode.publisher,
      GenericLibraryGroupMode.title,
      GenericLibraryGroupMode.ownership,
    ];
  }
  if (type.workspace.kind == 'book' ||
      type.workspace.kind == 'game' ||
      type.workspace.kind == 'boardgame') {
    return [
      GenericLibraryGroupMode.publisher,
      GenericLibraryGroupMode.series,
      GenericLibraryGroupMode.year,
      GenericLibraryGroupMode.title,
      GenericLibraryGroupMode.ownership,
    ];
  }
  return [
    GenericLibraryGroupMode.series,
    GenericLibraryGroupMode.title,
    GenericLibraryGroupMode.publisher,
    GenericLibraryGroupMode.year,
    GenericLibraryGroupMode.ownership,
  ];
}

GenericLibraryGroupMode genericDefaultGroupMode(LibraryTypeConfig type) {
  return genericGroupModesForType(type).first;
}

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
    required GenericLibraryGroupMode groupMode,
    Map<String, List<String>> customFieldValuesByItem = const {},
  }) {
    final allItems = genericItemsForShelf(shelf, type);
    final normalizedQuery = query.trim().toLowerCase();
    final filteredItems = [
      for (final item in allItems)
        if (_matchesBucket(item, type, groupMode, selectedBucket) &&
            _matchesQuickView(item, quickView) &&
            _matchesQuery(
              item,
              normalizedQuery,
              customFieldValuesByItem,
            ))
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
      buckets: genericBucketsForItems(allItems, type, groupMode),
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
  GenericLibraryGroupMode groupMode,
) {
  final counts = <String, int>{genericAllBucketLabel(type): items.length};
  for (final item in items) {
    final bucket = genericBucketForItemMode(item, type, groupMode);
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
  return genericBucketForItemMode(
    item,
    type,
    genericDefaultGroupMode(type),
  );
}

String genericBucketForItemMode(
  GenericLibraryItem item,
  LibraryTypeConfig type,
  GenericLibraryGroupMode groupMode,
) {
  final entry = item.entry;
  final publisher = entry.publisher?.trim();
  return switch (groupMode) {
    GenericLibraryGroupMode.series => entry.title.trim().isEmpty
        ? 'Unknown series'
        : entry.title.trim(),
    GenericLibraryGroupMode.year => entry.releaseYear?.toString() ??
        (entry.releaseDate?.year.toString() ?? 'Unknown year'),
    GenericLibraryGroupMode.publisher => publisher == null || publisher.isEmpty
        ? (type.workspace.kind == 'music'
            ? 'Unknown artist'
            : 'Unknown publisher')
        : publisher,
    GenericLibraryGroupMode.ownership => entry.isOwned
        ? 'Owned'
        : entry.isWishlisted
            ? 'Wishlist'
            : 'Catalog only',
    GenericLibraryGroupMode.title => _titleBucket(entry.title),
  };
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.characters.first.toUpperCase();
}

String genericAllBucketLabel(LibraryTypeConfig type) {
  return '[All ${type.pluralLabel}]';
}

bool _matchesBucket(
  GenericLibraryItem item,
  LibraryTypeConfig type,
  GenericLibraryGroupMode groupMode,
  String? selectedBucket,
) {
  return selectedBucket == null ||
      genericBucketForItemMode(item, type, groupMode) == selectedBucket;
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

bool _matchesQuery(
  GenericLibraryItem item,
  String query,
  Map<String, List<String>> customFieldValuesByItem,
) {
  if (query.isEmpty) {
    return true;
  }
  final entry = item.entry;
  if (_containsQuery(entry.title, query) ||
      _containsQuery(entry.itemNumber, query) ||
      _containsQuery(entry.publisher, query) ||
      _containsQuery(entry.variant, query) ||
      _containsQuery(entry.barcode, query) ||
      _containsQuery(entry.releaseYear?.toString(), query) ||
      _containsQuery(entry.condition, query) ||
      _containsQuery(entry.grade, query) ||
      _containsQuery(entry.storageBox, query)) {
    return true;
  }
  final ownedId = item.source.ownedItem?.id;
  if (ownedId != null) {
    final cfValues = customFieldValuesByItem[ownedId];
    if (cfValues != null) {
      for (final v in cfValues) {
        if (_containsQuery(v, query)) return true;
      }
    }
  }
  return false;
}

GenericToolbarCounts _toolbarCountsForItems({
  required List<GenericLibraryItem> allItems,
  required int shown,
}) {
  var owned = 0;
  var wishlist = 0;
  var missingCover = 0;
  var missingMetadata = 0;
  var totalPricePaid = 0;
  var totalCoverPrice = 0;
  var totalSellPrice = 0;
  String? currency;
  for (final item in allItems) {
    final entry = item.entry;
    final ownedItem = item.source.ownedItem;
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
    if (ownedItem != null) {
      totalPricePaid += ownedItem.pricePaidCents ?? 0;
      totalCoverPrice += ownedItem.coverPriceCents ?? 0;
      totalSellPrice += ownedItem.sellPriceCents ?? 0;
      currency ??= ownedItem.currency;
    }
  }
  return GenericToolbarCounts(
    shown: shown,
    total: allItems.length,
    owned: owned,
    wishlist: wishlist,
    missingCover: missingCover,
    missingMetadata: missingMetadata,
    totalPricePaidCents: totalPricePaid,
    totalCoverPriceCents: totalCoverPrice,
    totalSellPriceCents: totalSellPrice,
    priceCurrency: currency,
  );
}

bool _containsQuery(String? value, String query) {
  return value != null && value.toLowerCase().contains(query);
}
