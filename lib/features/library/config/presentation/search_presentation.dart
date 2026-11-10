import 'package:flutter/widgets.dart';

class LibraryMediaSearchFieldLabels {
  const LibraryMediaSearchFieldLabels({
    required this.queryHint,
    required this.emptySearchMessage,
    this.libraryHint,
    this.addSearchTabLabel = 'Title',
    this.addSearchTabIcon,
    this.identifierTabLabel = 'Barcode',
    this.identifierFieldLabel = 'Barcode / UPC / ISBN',
    this.identifierHint = 'Scan or enter barcode / UPC / ISBN...',
    this.identifierFirst = false,
  });

  final String queryHint;
  final String identifierTabLabel;
  final String identifierFieldLabel;
  final String identifierHint;
  final bool identifierFirst;

  /// The Add dialog's text-search tab, such as "Artist & Title".
  final String addSearchTabLabel;

  /// The text-search tab's icon; a magnifier when null.
  final IconData? addSearchTabIcon;
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
