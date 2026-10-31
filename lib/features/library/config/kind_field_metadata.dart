import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

enum LibraryFieldValueType {
  text,
  number,
  boolean,
  date,
  partialDate,
}

enum LibraryFieldCardinality { one, many }

enum LibraryFieldSource { catalog, libraryEntry, derived }

/// Kind-owned field facts shared by surface-specific field definitions.
///
/// This describes field identity and availability. Typed value access, editing,
/// filtering, sorting, and export formatting remain in their owning surfaces.
final class LibraryKindFieldMetadata {
  const LibraryKindFieldMetadata({
    required this.id,
    required this.label,
    required this.valueType,
    required this.cardinality,
    required this.source,
    required this.sourcePath,
    this.searchable = false,
    this.filterable = false,
    this.sortable = false,
    this.groupable = false,
    this.exportable = false,
    this.editable = false,
    this.vocabulary,
  });

  final String id;
  final String label;
  final LibraryFieldValueType valueType;
  final LibraryFieldCardinality cardinality;
  final LibraryFieldSource source;
  final String sourcePath;
  final bool searchable;
  final bool filterable;
  final bool sortable;
  final bool groupable;
  final bool exportable;
  final bool editable;
  final VocabularyId<String>? vocabulary;
}
