import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class GenericToolbarCounts {
  const GenericToolbarCounts({
    this.shown = 0,
    this.total = 0,
    this.owned = 0,
    this.wishlist = 0,
    this.missingCover = 0,
    this.missingMetadata = 0,
  });

  final int shown;
  final int total;
  final int owned;
  final int wishlist;
  final int missingCover;
  final int missingMetadata;
}

enum GenericQuickView {
  owned,
  wishlist,
  missingCovers,
  missingMetadata,
}

extension GenericQuickViewUi on GenericQuickView {
  String get label {
    return switch (this) {
      GenericQuickView.owned => 'Owned',
      GenericQuickView.wishlist => 'Wishlist',
      GenericQuickView.missingCovers => 'Missing covers',
      GenericQuickView.missingMetadata => 'Missing metadata',
    };
  }

  IconData get icon {
    return switch (this) {
      GenericQuickView.owned => Icons.check_box,
      GenericQuickView.wishlist => Icons.star,
      GenericQuickView.missingCovers => Icons.image_not_supported_outlined,
      GenericQuickView.missingMetadata => Icons.manage_search,
    };
  }
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
    return GenericLibraryProjection(
      allItems: allItems,
      filteredItems: filteredItems,
      buckets: genericBucketsForItems(allItems, type),
      selectedItem: genericSelectedItem(filteredItems, selectedItemId),
      counts: GenericToolbarCounts(
        shown: filteredItems.length,
        total: allItems.length,
        owned: allItems.where((item) => item.entry.isOwned).length,
        wishlist: allItems.where((item) => item.entry.isWishlisted).length,
        missingCover:
            allItems.where((item) => item.entry.hasMissingCover).length,
        missingMetadata:
            allItems.where((item) => item.entry.hasMissingMetadata).length,
      ),
    );
  }

  final List<GenericLibraryItem> allItems;
  final List<GenericLibraryItem> filteredItems;
  final List<LibrarySeriesBucket> buckets;
  final GenericLibraryItem? selectedItem;
  final GenericToolbarCounts counts;
}

class GenericLibraryItem {
  const GenericLibraryItem({
    required this.source,
    required this.entry,
  });

  factory GenericLibraryItem.fromShelf(ShelfEntry source) {
    final item = source.catalogItem!;
    return GenericLibraryItem(
      source: source,
      entry: LibraryWorkspaceEntry(
        id: item.id,
        mediaType: item.kind,
        title: item.title,
        itemNumber: item.itemNumber,
        synopsis: item.synopsis,
        coverImageUrl: item.coverImageUrl,
        thumbnailImageUrl: item.thumbnailImageUrl,
        publisher: item.publisher,
        releaseDate: item.releaseDate,
        releaseYear: item.releaseYear,
        barcode: item.barcode,
        variant: item.variant,
        isOwned: source.isOwned,
        isWishlisted: source.isWishlisted,
        hasMissingCover: item.displayCoverUrl == null,
        hasMissingMetadata: genericHasMissingCoreMetadata(item),
        condition: source.ownedItem?.condition,
        grade: source.ownedItem?.grade,
        pricePaidCents: source.ownedItem?.pricePaidCents,
        currency: source.ownedItem?.currency,
        storageBox: source.ownedItem?.storageBox,
        updatedAt: source.updatedAt,
      ),
    );
  }

  final ShelfEntry source;
  final LibraryWorkspaceEntry entry;
}

List<GenericLibraryItem> genericItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type,
) {
  final kind = type.workspace.kind;
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null && source.catalogItem!.kind == kind)
        GenericLibraryItem.fromShelf(source),
  ];
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

bool genericHasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.barcode == null &&
      item.variant == null;
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
  return [
    entry.title,
    entry.itemNumber,
    entry.publisher,
    entry.variant,
    entry.barcode,
    entry.releaseYear?.toString(),
    entry.condition,
    entry.grade,
    entry.storageBox,
  ].whereType<String>().any((value) => value.toLowerCase().contains(query));
}
