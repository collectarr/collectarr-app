import 'package:collectarr_app/features/library/generic/projection_item.dart';

/// Kinds choose the semantic values used by the shared alphabet filter.
class LibraryAlphabetField {
  const LibraryAlphabetField(
      {required this.id, required this.label, required this.values});
  final String id;
  final String label;
  final Iterable<String> Function(LibraryProjectionView) values;
  static const title =
      LibraryAlphabetField(id: 'title', label: 'Title', values: _titles);
  static Iterable<String> _titles(LibraryProjectionView item) =>
      [item.dto.primaryLabel];
}
