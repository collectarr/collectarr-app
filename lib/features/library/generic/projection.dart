import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/workspace/library_workspace_config.dart'
    show LibraryGroupMode;
export 'projection_item.dart';
export 'quick_view.dart';

class LibraryLinkedMetadataFilter {
  const LibraryLinkedMetadataFilter({required this.value});

  final String value;

  String get chipLabel => 'Metadata: $value';
}

String genericGroupModeLabel(
  LibraryGroupMode mode,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaGroupLabels(type);
  return switch (mode) {
    LibraryGroupMode.series => labels.series,
    LibraryGroupMode.storyArc => 'Story Arc',
    LibraryGroupMode.character => 'Character',
    LibraryGroupMode.title => 'Title',
    LibraryGroupMode.publisher => labels.publisher,
    LibraryGroupMode.year => 'Year',
    LibraryGroupMode.location => 'Location',
    LibraryGroupMode.ownership => 'Ownership',
    LibraryGroupMode.grade => 'Grade',
    LibraryGroupMode.condition => 'Condition',
  };
}

String genericGroupModeSidebarTitle(
  LibraryGroupMode mode,
  LibraryTypeConfig type,
) {
  final labels = libraryMediaGroupLabels(type);
  return switch (mode) {
    LibraryGroupMode.series => labels.seriesPlural,
    LibraryGroupMode.storyArc => 'Story Arcs',
    LibraryGroupMode.character => 'Characters',
    LibraryGroupMode.title => 'Titles',
    LibraryGroupMode.publisher => labels.publisherPlural,
    LibraryGroupMode.year => 'Years',
    LibraryGroupMode.location => 'Locations',
    LibraryGroupMode.ownership => 'Ownership',
    LibraryGroupMode.grade => 'Grades',
    LibraryGroupMode.condition => 'Conditions',
  };
}

IconData genericGroupModeIcon(LibraryGroupMode mode) {
  return switch (mode) {
    LibraryGroupMode.series => Icons.collections_bookmark_outlined,
    LibraryGroupMode.storyArc => Icons.auto_stories_outlined,
    LibraryGroupMode.character => Icons.groups_2_outlined,
    LibraryGroupMode.title => Icons.sort_by_alpha,
    LibraryGroupMode.publisher => Icons.business_outlined,
    LibraryGroupMode.year => Icons.calendar_today_outlined,
    LibraryGroupMode.location => Icons.place_outlined,
    LibraryGroupMode.ownership => Icons.inventory_2_outlined,
    LibraryGroupMode.grade => Icons.workspace_premium_outlined,
    LibraryGroupMode.condition => Icons.fact_check_outlined,
  };
}

List<LibraryGroupMode> libraryGroupModesForType(
  LibraryTypeConfig type,
) {
  return type.presentation.groupModes;
}

LibraryGroupMode libraryDefaultGroupMode(LibraryTypeConfig type) {
  return libraryGroupModesForType(type).first;
}

class LibraryProjection {
  const LibraryProjection({
    required this.allItems,
    required this.filteredItems,
    required this.buckets,
    required this.selectedItem,
    required this.counts,
  });

  factory LibraryProjection.fromShelf({
    required ShelfState shelf,
    required LibraryTypeConfig type,
    required LibraryWorkspaceViewState viewState,
    required String query,
    LibraryLinkedMetadataFilter? linkedMetadataFilter,
    required String? selectedBucket,
    required String? selectedItemId,
    required LibraryQuickView? quickView,
    required LibraryGroupMode groupMode,
    List<LibrarySeriesBucket>? overrideBuckets,
    Set<String>? constrainedItemIds,
    LibraryFilterSelection filterSelection = LibraryFilterSelection.none,
    Map<String, List<String>> customFieldValuesByItem = const {},
  }) {
    final allItems = libraryItemsForShelf(shelf, type);
    final normalizedQuery = query.trim().toLowerCase();
    final filteredItems = [
      for (final item in allItems)
        if (_matchesBucket(item, type, groupMode, selectedBucket) &&
            _matchesConstrainedItemIds(item, constrainedItemIds) &&
            _matchesQuickView(item, quickView) &&
            _matchesFilter(item, filterSelection) &&
            _matchesLinkedMetadataFilter(item, linkedMetadataFilter) &&
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
    return LibraryProjection(
      allItems: allItems,
      filteredItems: filteredItems,
      buckets:
          overrideBuckets ?? libraryBucketsForItems(allItems, type, groupMode),
      selectedItem: librarySelectedItem(filteredItems, selectedItemId),
      counts: counts,
    );
  }

  final List<LibraryProjectionItem> allItems;
  final List<LibraryProjectionItem> filteredItems;
  final List<LibrarySeriesBucket> buckets;
  final LibraryProjectionItem? selectedItem;
  final LibraryToolbarCounts counts;
}

List<LibrarySeriesBucket> libraryBucketsForItems(
  List<LibraryProjectionItem> items,
  LibraryTypeConfig type,
  LibraryGroupMode groupMode,
) {
  final counts = <String, int>{genericAllBucketLabel(type): items.length};
  final coverUrls = <String, String?>{};
  final startYears = <String, int?>{};
  for (final item in items) {
    final bucket = genericBucketForItemMode(item, type, groupMode);
    counts[bucket] = (counts[bucket] ?? 0) + 1;
    if (!coverUrls.containsKey(bucket)) {
      coverUrls[bucket] = item.entry.displayCoverUrl;
    }
    final year = item.entry.releaseYear;
    if (year != null) {
      final existing = startYears[bucket];
      if (existing == null || year < existing) {
        startYears[bucket] = year;
      }
    }
  }
  final buckets = [
    for (final entry in counts.entries)
      LibrarySeriesBucket(
        title: entry.key,
        count: entry.value,
        coverUrl: coverUrls[entry.key],
        startYear: startYears[entry.key],
      ),
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

LibraryProjectionItem? librarySelectedItem(
  List<LibraryProjectionItem> items,
  String? selectedItemId,
) {
  if (selectedItemId == null) {
    return null;
  }
  for (final item in items) {
    if (item.entry.id == selectedItemId) {
      return item;
    }
  }
  return null;
}

String genericBucketForItem(LibraryProjectionItem item, LibraryTypeConfig type) {
  return genericBucketForItemMode(
    item,
    type,
    libraryDefaultGroupMode(type),
  );
}

String genericBucketForItemMode(
  LibraryProjectionItem item,
  LibraryTypeConfig type,
  LibraryGroupMode groupMode,
) {
  final entry = item.entry;
  final publisher = entry.publisher?.trim();
  final labels = libraryMediaGroupLabels(type);
  return switch (groupMode) {
    LibraryGroupMode.series => _seriesBucket(entry, labels.unknownSeries),
    LibraryGroupMode.storyArc => 'Story arc',
    LibraryGroupMode.character => 'Character',
    LibraryGroupMode.year => entry.releaseYear?.toString() ??
        (entry.releaseDate?.year.toString() ?? 'Unknown year'),
    LibraryGroupMode.publisher => publisher == null || publisher.isEmpty
        ? labels.unknownPublisher
        : publisher,
    LibraryGroupMode.location => _locationBucket(entry.storageBox),
    LibraryGroupMode.ownership => entry.isOwned
        ? 'Owned'
        : entry.isWishlisted
            ? 'Wishlist'
            : 'Catalog only',
    LibraryGroupMode.title => _titleBucket(entry.title),
    LibraryGroupMode.grade =>
      entry.grade?.trim().isNotEmpty == true ? entry.grade! : 'Ungraded',
    LibraryGroupMode.condition =>
      entry.condition?.trim().isNotEmpty == true
          ? entry.condition!
          : 'No condition',
  };
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _seriesBucket(LibraryWorkspaceEntry entry, String unknownLabel) {
  final seriesTitle = entry.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  final title = entry.title.trim();
  return title.isEmpty ? unknownLabel : title;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.characters.first.toUpperCase();
}

String genericAllBucketLabel(LibraryTypeConfig type) {
  return '[All ${type.pluralLabel}]';
}

bool _matchesBucket(
  LibraryProjectionItem item,
  LibraryTypeConfig type,
  LibraryGroupMode groupMode,
  String? selectedBucket,
) {
  return selectedBucket == null ||
      genericBucketForItemMode(item, type, groupMode) == selectedBucket;
}

bool _matchesConstrainedItemIds(
  LibraryProjectionItem item,
  Set<String>? constrainedItemIds,
) {
  return constrainedItemIds == null ||
      constrainedItemIds.contains(item.entry.id);
}

bool _matchesQuickView(LibraryProjectionItem item, LibraryQuickView? quickView) {
  return switch (quickView) {
    null => true,
    LibraryQuickView.owned => item.entry.isOwned,
    LibraryQuickView.wishlist => item.entry.isWishlisted,
    LibraryQuickView.missingCovers => item.entry.hasMissingCover,
    LibraryQuickView.missingMetadata => item.entry.hasMissingMetadata,
    LibraryQuickView.missingGrade => item.entry.isOwned &&
        (item.entry.grade == null || item.entry.grade!.trim().isEmpty),
  };
}

bool _matchesFilter(
  LibraryProjectionItem item,
  LibraryFilterSelection filters,
) {
  if (!filters.hasActiveFilters) return true;
  return libraryFilterMatches(item.entry, filters);
}

bool _matchesLinkedMetadataFilter(
  LibraryProjectionItem item,
  LibraryLinkedMetadataFilter? linkedMetadataFilter,
) {
  if (linkedMetadataFilter == null) {
    return true;
  }
  return libraryEntryMatchesLinkedMetadataFilter(
    item.entry,
    linkedMetadataFilter.value,
  );
}

bool libraryEntryMatchesLinkedMetadataFilter(
  LibraryWorkspaceEntry entry,
  String value,
) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }
  for (final candidate in _linkedMetadataCandidates(entry)) {
    if (candidate.trim().toLowerCase() == normalized) {
      return true;
    }
  }
  return false;
}

Iterable<String> _linkedMetadataCandidates(LibraryWorkspaceEntry entry) sync* {
  final series = entry.series;
  final publishing = entry.publishing;
  final game = entry.game;
  yield* _nonEmptyValues([
    entry.title,
    series?.seriesTitle,
    entry.itemNumber,
    entry.publisher,
    entry.variant,
    publishing?.imprint,
    publishing?.seriesGroup,
    entry.country,
    entry.language,
    entry.ageRating,
  ]);
  if (entry.creators case final creators?) {
    for (final credit in creators) {
      final name = credit['name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        yield name.trim();
      }
    }
  }
  yield* _nonEmptyValues(entry.characters);
  yield* _nonEmptyValues(entry.storyArcs);
  yield* _nonEmptyValues(entry.genres);
  if (game?.platforms case final platforms?) {
    yield* _nonEmptyValues(platforms);
  }
}

Iterable<String> _nonEmptyValues(Iterable<String?>? values) sync* {
  if (values == null) {
    return;
  }
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      yield value.trim();
    }
  }
}

bool _matchesQuery(
  LibraryProjectionItem item,
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

LibraryToolbarCounts _toolbarCountsForItems({
  required List<LibraryProjectionItem> allItems,
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
  return LibraryToolbarCounts(
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
