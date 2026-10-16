class LibraryMediaSearchFieldLabels {
  const LibraryMediaSearchFieldLabels({
    required this.queryHint,
    required this.emptySearchMessage,
    this.libraryHint,
  });

  final String queryHint;
  final String emptySearchMessage;

  /// Placeholder of the library toolbar search; the generic "Search items..."
  /// when null.
  final String? libraryHint;
}

class LibraryMediaPreviewLabels {
  const LibraryMediaPreviewLabels({this.values = const {}});

  final Map<String, String> values;

  String labelFor(String id, {String fallback = ''}) {
    return values[id] ?? fallback;
  }
}

class LibraryMediaStatsLabels {
  const LibraryMediaStatsLabels({this.values = const {}});

  final Map<String, String> values;

  String labelFor(String id, {String fallback = ''}) {
    return values[id] ?? fallback;
  }
}
