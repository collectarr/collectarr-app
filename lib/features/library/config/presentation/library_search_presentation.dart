class LibraryMediaSearchFieldLabels {
  const LibraryMediaSearchFieldLabels({
    required this.queryHint,
    required this.emptySearchMessage,
  });

  final String queryHint;
  final String emptySearchMessage;
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
