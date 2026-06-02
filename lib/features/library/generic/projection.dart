import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/generic/presentation.dart';
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
  try {
    return type.presentation.groupModeDefinitionFor(mode).label;
  } on StateError {
    return genericLibraryMediaPresentation.groupModeDefinitionFor(mode).label;
  }
}

String genericGroupModeSidebarTitle(
  LibraryGroupMode mode,
  LibraryTypeConfig type,
) {
  try {
    return type.presentation.groupModeDefinitionFor(mode).sidebarTitle;
  } on StateError {
    return genericLibraryMediaPresentation.groupModeDefinitionFor(mode)
        .sidebarTitle;
  }
}

IconData genericGroupModeIcon(
  LibraryGroupMode mode, [
  LibraryTypeConfig? type,
]) {
  try {
    return (type?.presentation ?? genericLibraryMediaPresentation)
        .groupModeDefinitionFor(mode)
        .icon;
  } on StateError {
    return genericLibraryMediaPresentation.groupModeDefinitionFor(mode).icon;
  }
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
    required LibraryMediaAdapter adapter,
    required LibraryWorkspaceViewState viewState,
    required String query,
    LibraryLinkedMetadataFilter? linkedMetadataFilter,
    required String? selectedBucket,
    required String? selectedItemId,
    required LibraryQuickView? quickView,
    LibraryCollectionStatusScope collectionStatusScope =
        LibraryCollectionStatusScope.all,
    required LibraryGroupMode groupMode,
    List<LibrarySeriesBucket>? overrideBuckets,
    Set<String>? constrainedItemIds,
    LibraryFilterSelection filterSelection = LibraryFilterSelection.none,
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<String> activeLoanOwnedItemIds = const {},
  }) {
    final allItems = libraryItemsForShelf(shelf, type);
    final normalizedQuery = query.trim().toLowerCase();
    final filteredItems = [
      for (final item in allItems)
        if (_matchesBucket(item, type, groupMode, selectedBucket) &&
            _matchesConstrainedItemIds(item, constrainedItemIds) &&
            _matchesCollectionStatusScope(item, collectionStatusScope) &&
            _matchesQuickView(item, quickView) &&
            _matchesFilter(
              item,
              filterSelection,
              activeLoanOwnedItemIds,
              customFieldValuesByDefinitionByItem,
            ) &&
            _matchesLinkedMetadataFilter(item, linkedMetadataFilter) &&
            _matchesQuery(
              item,
              normalizedQuery,
              customFieldValuesByItem,
            ))
          item,
    ]..sort((a, b) => adapter.compareEntriesByRules(
          a.entry,
          b.entry,
          viewState.sortRules,
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
  final allBucketLabel = genericAllBucketLabel(type);
  final counts = <String, int>{allBucketLabel: items.length};
  final isSeries = groupMode == LibraryGroupMode.series;
  final ownedCounts = isSeries
      ? <String, int>{
          allBucketLabel: items.where((item) => item.entry.isOwned).length,
        }
      : null;
  final coverUrls = <String, String?>{};
  final startYears = <String, int?>{};
  final bucketNumbers = isSeries ? <String, Set<int>>{} : null;
  final ownedNumbers = isSeries ? <String, Set<int>>{} : null;
  for (final item in items) {
    final bucket = genericBucketForItemMode(item, type, groupMode);
    counts[bucket] = (counts[bucket] ?? 0) + 1;
    final number = isSeries ? _wholeNumber(item.entry.itemNumber) : null;
    if (number != null) {
      bucketNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
    }
    if (isSeries && item.entry.isOwned) {
      ownedCounts![bucket] = (ownedCounts[bucket] ?? 0) + 1;
      if (number != null) {
        ownedNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
      }
    }
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
  final gapNumbers = <String, List<int>>{};
  if (ownedNumbers != null && bucketNumbers != null) {
    for (final entry in ownedNumbers.entries) {
      final sorted = entry.value.toList(growable: false)..sort();
      if (sorted.length < 2) continue;
      final existingNumbers = bucketNumbers[entry.key];
      if (existingNumbers == null || existingNumbers.length < 2) continue;
      final sortedExisting = existingNumbers.toList(growable: false)..sort();
      final missing = <int>[];
      for (final number in sortedExisting) {
        if (number < sorted.first || number > sorted.last) continue;
        if (entry.value.contains(number)) continue;
        missing.add(number);
        if (missing.length > 1000) break;
      }
      if (missing.isNotEmpty) gapNumbers[entry.key] = missing;
    }
  }
  final buckets = [
    for (final entry in counts.entries)
      LibrarySeriesBucket(
        title: entry.key,
        count: entry.value,
        coverUrl: coverUrls[entry.key],
        startYear: startYears[entry.key],
        ownedCount: ownedCounts?[entry.key],
        missingNumbers: gapNumbers[entry.key] ?? const <int>[],
      ),
  ];
  buckets.sort((a, b) {
    if (a.title == allBucketLabel) {
      return -1;
    }
    if (b.title == allBucketLabel) {
      return 1;
    }
    return a.title.compareTo(b.title);
  });
  return buckets;
}

final _issueNumberRegExp = RegExp(r'^\s*(\d+)');

int? _wholeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final match = _issueNumberRegExp.firstMatch(value);
  return match == null ? null : int.tryParse(match.group(1)!);
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

String genericBucketForItem(
    LibraryProjectionItem item, LibraryTypeConfig type) {
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
  return type.presentation.bucketLabelBuilder(
    LibraryBucketingContext(
      source: item.source,
      entry: item.entry,
      groupMode: groupMode,
    ),
  );
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

bool _matchesQuickView(
    LibraryProjectionItem item, LibraryQuickView? quickView) {
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

bool _matchesCollectionStatusScope(
  LibraryProjectionItem item,
  LibraryCollectionStatusScope scope,
) {
  final ownedItem = item.source.ownedItem;
  final isSold = ownedItem?.isSold == true;
  final collectionStatus = item.entry.collectionStatus?.trim().toLowerCase();
  final isWishlistOnly = item.source.isWishlisted && !item.source.isOwned;
  final isCatalogOnly = !item.source.isOwned && !item.source.isWishlisted;
  final isForSale = !isSold && collectionStatus == 'for_sale';
  final isOnOrder = !isSold && collectionStatus == 'on_order';
  final isInCollection =
      item.source.isOwned && !isSold && !isForSale && !isOnOrder;

  return switch (scope) {
    LibraryCollectionStatusScope.all => true,
    LibraryCollectionStatusScope.inCollection => isInCollection,
    LibraryCollectionStatusScope.forSale => isForSale,
    LibraryCollectionStatusScope.wishList => isWishlistOnly,
    LibraryCollectionStatusScope.onOrder => isOnOrder,
    LibraryCollectionStatusScope.sold => isSold,
    LibraryCollectionStatusScope.notInCollection => isCatalogOnly,
  };
}

bool _matchesFilter(
  LibraryProjectionItem item,
  LibraryFilterSelection filters,
  Set<String> activeLoanOwnedItemIds,
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
) {
  if (!filters.hasActiveFilters) {
    return true;
  }
  if (!libraryFilterMatches(item.entry, filters)) {
    return false;
  }
  if (!libraryTrackingStatusMatchesFilter(
    item.source.tracking.status,
    filters.trackingStatusFilter,
  )) {
    return false;
  }
  if (!_matchesLoanFilter(
      item, filters.loanStatusFilter, activeLoanOwnedItemIds)) {
    return false;
  }
  if (!_matchesDateRange(item, filters)) {
    return false;
  }
  if (!_matchesCustomField(
    item,
    filters,
    customFieldValuesByDefinitionByItem,
  )) {
    return false;
  }
  return true;
}

bool _matchesCustomField(
  LibraryProjectionItem item,
  LibraryFilterSelection filters,
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
) {
  final definitionId = filters.customFieldDefinitionId;
  if (definitionId == null || definitionId.isEmpty) {
    return true;
  }
  final ownedItemId = item.source.ownedItem?.id;
  if (ownedItemId == null) {
    return false;
  }
  final values = customFieldValuesByDefinitionByItem[ownedItemId];
  final actualValue = values?[definitionId]?.trim();
  if (actualValue == null || actualValue.isEmpty) {
    return false;
  }
  final expectedValue = filters.customFieldValue?.trim();
  if (expectedValue == null || expectedValue.isEmpty) {
    return true;
  }
  return actualValue == expectedValue;
}

bool _matchesLoanFilter(
  LibraryProjectionItem item,
  LibraryLoanStatusFilter filter,
  Set<String> activeLoanOwnedItemIds,
) {
  if (filter == LibraryLoanStatusFilter.all) {
    return true;
  }
  final ownedItemId = item.source.ownedItem?.id;
  if (ownedItemId == null) {
    return false;
  }
  final hasActiveLoan = activeLoanOwnedItemIds.contains(ownedItemId);
  return switch (filter) {
    LibraryLoanStatusFilter.all => true,
    LibraryLoanStatusFilter.onLoan => hasActiveLoan,
    LibraryLoanStatusFilter.available => !hasActiveLoan,
  };
}

bool _matchesDateRange(
  LibraryProjectionItem item,
  LibraryFilterSelection filters,
) {
  if (!filters.hasActiveDateRange) {
    return true;
  }
  final value = _filterDateForItem(item, filters.dateRangeField);
  if (value == null) {
    return false;
  }
  final candidate = DateUtils.dateOnly(value.toLocal());
  final from = filters.dateFrom == null
      ? null
      : DateUtils.dateOnly(filters.dateFrom!.toLocal());
  final to = filters.dateTo == null
      ? null
      : DateUtils.dateOnly(filters.dateTo!.toLocal());
  if (from != null && candidate.isBefore(from)) {
    return false;
  }
  if (to != null && candidate.isAfter(to)) {
    return false;
  }
  return true;
}

DateTime? _filterDateForItem(
  LibraryProjectionItem item,
  LibraryDateRangeField field,
) {
  final ownedItem = item.source.ownedItem;
  final trackingEntry = item.source.trackingEntry;
  return switch (field) {
    LibraryDateRangeField.updated => item.source.updatedAt,
    LibraryDateRangeField.purchased => ownedItem?.purchaseDate,
    LibraryDateRangeField.started =>
      trackingEntry?.startedAt ?? ownedItem?.startedAt,
    LibraryDateRangeField.finished =>
      trackingEntry?.finishedAt ?? ownedItem?.finishedAt,
  };
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
    entry.resolvedTitle,
    entry.title,
    entry.localizedTitle,
    entry.originalTitle,
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
  yield* _nonEmptyValues(entry.searchAliases);
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
  if (_containsQuery(entry.resolvedTitle, query) ||
      _containsQuery(entry.title, query) ||
      _containsQuery(entry.localizedTitle, query) ||
      _containsQuery(entry.originalTitle, query) ||
      _containsQuery(entry.itemNumber, query) ||
      _containsQuery(entry.publisher, query) ||
      _containsQuery(entry.variant, query) ||
      _containsQuery(entry.barcode, query) ||
      _containsQuery(entry.releaseYear?.toString(), query) ||
      _containsQuery(entry.condition, query) ||
      _containsQuery(entry.grade, query) ||
      _containsQuery(entry.locationPath, query)) {
    return true;
  }
  if (entry.searchAliases case final aliases?) {
    for (final alias in aliases) {
      if (_containsQuery(alias, query)) {
        return true;
      }
    }
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
