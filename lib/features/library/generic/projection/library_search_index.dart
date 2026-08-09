import 'package:flutter/foundation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

@immutable
final class LibrarySearchDocument {
  const LibrarySearchDocument({
    required this.itemId,
    required this.normalizedText,
  });

  final String itemId;
  final String normalizedText;

  bool matches(String query) {
    if (query.isEmpty) return true;
    return normalizedText.contains(query);
  }
}

class LibrarySearchIndex {
  final Map<String, LibrarySearchDocument> _documents = {};

  LibrarySearchDocument getOrBuild(
    LibraryProjectionItem item,
    String Function() textSupplier,
  ) {
    final existing = _documents[item.node.id];
    if (existing != null) return existing;

    final doc = LibrarySearchDocument(
      itemId: item.node.id,
      normalizedText: textSupplier().trim().toLowerCase(),
    );
    _documents[item.node.id] = doc;
    return doc;
  }

  void clear() => _documents.clear();
}
