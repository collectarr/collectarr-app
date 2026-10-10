import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/foundation.dart';

@immutable
final class LibrarySearchDocument {
  const LibrarySearchDocument({
    required this.itemId,
    required this.normalizedTokens,
    this.containedTokens = const [],
  });

  final String itemId;
  final List<String> normalizedTokens;
  final List<String> containedTokens;

  bool matches(
    String query, {
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    for (final token in [
      if (searchTarget.includesMedia) ...normalizedTokens,
      if (searchTarget.includesTracks) ...containedTokens,
    ]) {
      if (token.contains(trimmed)) return true;
    }
    return false;
  }
}

class LibrarySearchIndex {
  final Map<String, LibrarySearchDocument> _documents = {};
  final Map<String, Object> _sources = {};

  LibrarySearchDocument getOrBuild(
    LibraryProjectionItem item, [
    Map<String, List<String>> customFieldValuesByItem = const {},
    Iterable<String> searchFieldValues = const [],
    Iterable<String> containedSearchValues = const [],
  ]) {
    final key = item.target.stableKey;
    final existing = _documents[key];
    // Custom field values are supplied by the caller and may change between
    // executions while the projection engine is reused. Rebuild in that case
    // instead of returning a document that was indexed without the new values.
    if (existing != null &&
        customFieldValuesByItem.isEmpty &&
        identical(_sources[key], item.source)) {
      return existing;
    }

    final tokens = <String>{};
    final dto = item.dto;
    final card = libraryCardPresentationForEntry(item);
    final source = item.source;

    void add(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        tokens.add(value.trim().toLowerCase());
      }
    }

    add(dto.primaryLabel);
    add(source.title);
    add(source.catalogSummary?.primaryLabel);
    add(source.catalogSummary?.subtitle);
    for (final token in source.catalogSearchTokens) {
      add(token);
    }
    add(card.seriesTitle);
    add(card.itemNumber);
    add(card.variant);
    add(card.format);
    for (final token in searchFieldValues) {
      add(token);
    }
    if (card.releaseDate != null) {
      add(card.releaseDate!.year.toString());
    }
    add(source.locationPath);

    for (final targetId in customFieldTargetIds(
      source: source,
      target: item.target,
    )) {
      final cfValues = customFieldValuesByItem[targetId];
      if (cfValues == null) continue;
      for (final value in cfValues) {
        add(value);
      }
    }

    final doc = LibrarySearchDocument(
      itemId: item.target.id,
      normalizedTokens: List<String>.unmodifiable(tokens),
      containedTokens: List<String>.unmodifiable({
        for (final value in containedSearchValues)
          if (value.trim().isNotEmpty) value.trim().toLowerCase(),
      }),
    );
    _documents[key] = doc;
    _sources[key] = item.source;
    return doc;
  }

  void clear() {
    _documents.clear();
    _sources.clear();
  }
}
