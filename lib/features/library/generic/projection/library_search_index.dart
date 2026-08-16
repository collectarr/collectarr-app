import 'package:collectarr_app/features/library/config/library_search_target.dart';
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
    final source = item.source;
    final catalog = source.catalogItem;

    void add(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        tokens.add(value.trim().toLowerCase());
      }
    }

    add(dto.title);
    add(dto.seriesTitle);
    add(dto.itemNumber);
    add(dto.publisher);
    add(dto.variant);
    add(dto.barcode);
    if (dto.releaseDate != null) {
      add(dto.releaseDate!.year.toString());
    }
    add(source.condition);
    add(source.grade);
    add(source.locationPath);

    if (catalog != null) {
      add(catalog.originalTitle);
      add(catalog.displayTitle);
      add(catalog.localizedTitle);
      final aliases = catalog.searchAliases;
      if (aliases != null) {
        for (final alias in aliases) {
          add(alias);
        }
      }
    }

    final ownedId = source.ownedItem?.id;
    if (ownedId != null) {
      final cfValues = customFieldValuesByItem[ownedId];
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
