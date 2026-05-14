import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicsShelfProjection {
  const ComicsShelfProjection({
    required this.entries,
    required this.items,
    required this.filterOptions,
    required this.hasActiveFilters,
  });

  final List<ShelfEntry> entries;
  final List<CatalogItem> items;
  final ComicsFilterOptions filterOptions;
  final bool hasActiveFilters;
}

final comicsShelfProjectionProvider =
    Provider.family<ComicsShelfProjection, ComicsShelfProjectionRequest>(
        (ref, request) {
  return projectComicsShelf(
    state: request.state,
    query: request.query,
    filters: request.filters,
  );
});

class ComicsShelfProjectionRequest {
  const ComicsShelfProjectionRequest({
    required this.state,
    required this.query,
    required this.filters,
  });

  final ShelfState state;
  final String query;
  final ComicsFilterSelection filters;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ComicsShelfProjectionRequest &&
            identical(other.state, state) &&
            other.query == query &&
            other.filters == filters;
  }

  @override
  int get hashCode => Object.hash(
        identityHashCode(state),
        query,
        filters,
      );
}

class ComicsFilterOptions {
  const ComicsFilterOptions({
    required this.grades,
    required this.conditions,
    required this.publishers,
    required this.releaseYears,
  });

  final List<String> grades;
  final List<String> conditions;
  final List<String> publishers;
  final List<String> releaseYears;

  factory ComicsFilterOptions.fromEntries(List<ShelfEntry> entries) {
    final grades = <String>{};
    final conditions = <String>{};
    final publishers = <String>{};
    final releaseYears = <String>{};

    for (final entry in entries) {
      _addFilterOption(grades, entry.ownedItem?.grade);
      _addFilterOption(conditions, entry.ownedItem?.condition);
      _addFilterOption(publishers, entry.catalogItem?.publisher);
      _addFilterOption(
        releaseYears,
        entry.catalogItem?.releaseYear?.toString(),
      );
    }

    return ComicsFilterOptions(
      grades: _sortedFilterOptions(grades),
      conditions: _sortedFilterOptions(conditions),
      publishers: _sortedFilterOptions(publishers),
      releaseYears: _sortedFilterOptions(releaseYears),
    );
  }
}

ComicsShelfProjection projectComicsShelf({
  required ShelfState state,
  required String query,
  required ComicsFilterSelection filters,
}) {
  final entries = filterComicsShelfEntries(
    entries: state.entries,
    query: query,
    filters: filters,
  );
  return ComicsShelfProjection(
    entries: entries,
    items: catalogItemsFromComicsShelf(entries),
    filterOptions: ComicsFilterOptions.fromEntries(state.entries),
    hasActiveFilters: filters.hasActiveFilters,
  );
}

List<CatalogItem> catalogItemsFromComicsShelf(List<ShelfEntry> entries) {
  return [
    for (final entry in entries)
      entry.catalogItem ??
          CatalogItem(
            id: entry.itemId,
            kind: comicsLibraryConfig.workspace.kind,
            title: entry.title,
          ),
  ];
}

List<ShelfEntry> filterComicsShelfEntries({
  required List<ShelfEntry> entries,
  required String query,
  required ComicsFilterSelection filters,
}) {
  final normalized = query.trim().toLowerCase();
  return [
    for (final entry in entries)
      if (_matchesOwnershipFilter(entry, filters.ownershipFilter) &&
          _matchesValueFilter(entry.ownedItem?.grade, filters.grade) &&
          _matchesValueFilter(entry.ownedItem?.condition, filters.condition) &&
          _matchesValueFilter(
              entry.catalogItem?.publisher, filters.publisher) &&
          _matchesValueFilter(
            entry.catalogItem?.releaseYear?.toString(),
            filters.releaseYear,
          ) &&
          _matchesMissingCoverFilter(entry, filters.missingCover) &&
          _matchesMissingMetadataFilter(entry, filters.missingMetadata) &&
          (normalized.isEmpty || _matchesEntryQuery(entry, normalized)))
        entry,
  ];
}

bool _matchesEntryQuery(ShelfEntry entry, String query) {
  final item = entry.catalogItem;
  if (entry.title.toLowerCase().contains(query)) {
    return true;
  }
  if (item == null) {
    return false;
  }
  return item.title.toLowerCase().contains(query) ||
      (item.itemNumber?.toLowerCase().contains(query) ?? false) ||
      (item.publisher?.toLowerCase().contains(query) ?? false) ||
      (item.variant?.toLowerCase().contains(query) ?? false) ||
      (item.barcode?.toLowerCase().contains(query) ?? false) ||
      (formatNullableComicDate(item.releaseDate)?.contains(query) ?? false) ||
      (item.releaseYear?.toString().contains(query) ?? false) ||
      (item.synopsis?.toLowerCase().contains(query) ?? false);
}

bool _matchesOwnershipFilter(
  ShelfEntry entry,
  ComicsOwnershipFilter ownershipFilter,
) {
  return switch (ownershipFilter) {
    ComicsOwnershipFilter.all => true,
    ComicsOwnershipFilter.owned => entry.isOwned,
    ComicsOwnershipFilter.wishlist => entry.isWishlisted,
    ComicsOwnershipFilter.missingGrade => entry.isMissingGrade,
  };
}

bool _matchesValueFilter(String? value, String? filter) {
  if (filter == null) {
    return true;
  }
  return value == filter;
}

bool _matchesMissingCoverFilter(ShelfEntry entry, bool enabled) {
  if (!enabled) {
    return true;
  }
  final coverUrl = entry.catalogItem?.displayCoverUrl?.trim();
  return coverUrl == null || coverUrl.isEmpty;
}

bool _matchesMissingMetadataFilter(ShelfEntry entry, bool enabled) {
  if (!enabled) {
    return true;
  }
  final item = entry.catalogItem;
  if (item == null) {
    return true;
  }
  return _isBlank(item.itemNumber) ||
      _isBlank(item.publisher) ||
      _isBlank(item.barcode) ||
      (item.releaseDate == null && item.releaseYear == null);
}

bool _isBlank(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty;
}

void _addFilterOption(Set<String> options, String? value) {
  final normalized = value?.trim();
  if (normalized != null && normalized.isNotEmpty) {
    options.add(normalized);
  }
}

List<String> _sortedFilterOptions(Set<String> values) {
  final options = values.toList(growable: false)
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return options;
}
