import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/foundation.dart';

@immutable
final class LibrarySearchDocument {
  const LibrarySearchDocument({
    required this.itemId,
    required this.normalizedTokens,
  });

  final String itemId;
  final List<String> normalizedTokens;

  bool matches(
    String query, {
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    for (final token in normalizedTokens) {
      if (token.contains(trimmed)) return true;
    }
    return false;
  }
}

class LibrarySearchIndex {
  final Map<String, LibrarySearchDocument> _documents = {};

  LibrarySearchDocument getOrBuild(
    LibraryProjectionItem item, [
    Map<String, List<String>> customFieldValuesByItem = const {},
  ]) {
    final existing = _documents[item.node.id];
    if (existing != null) return existing;

    final tokens = <String>{};
    final dto = item.dto;
    final card = libraryCardPresentationForEntry(item);
    final source = item.source;

    void add(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        tokens.add(value.trim().toLowerCase());
      }
    }

    add(dto.title);
    add(source.catalogSummary?.title);
    add(source.catalogSummary?.subtitle);
    for (final token in source.catalogSearchTokens) {
      add(token);
    }
    add(card.seriesTitle);
    add(card.itemNumber);
    add(card.variant);
    add(card.format);
    for (final token in dto.searchTokens) {
      add(token);
    }
    if (card.releaseDate != null) {
      add(card.releaseDate!.year.toString());
    }
    add(source.locationPath);

    final ownedRefKey = source.ownedRef?.key;
    if (ownedRefKey != null) {
      final cfValues = customFieldValuesByItem[ownedRefKey];
      if (cfValues != null) {
        for (final v in cfValues) {
          add(v);
        }
      }
    }

    final doc = LibrarySearchDocument(
      itemId: item.node.id,
      normalizedTokens: List<String>.unmodifiable(tokens),
    );
    _documents[item.node.id] = doc;
    return doc;
  }

  void clear() => _documents.clear();
}
