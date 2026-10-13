import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Manga field facts shared by forms, workspace, and filters.
abstract final class MangaFieldIdentities {
  static const seriesId = 'manga.series';
  static const seriesLabel = 'Series';
  static const publisherId = 'manga.publisher';
  static const publisherLabel = 'Publisher';

  static const publisherVocabulary = VocabularyId<String>('manga.publisher');

  static const series = LibraryKindFieldMetadata(
    id: seriesId,
    label: seriesLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'series_title',
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );
  static const publisher = LibraryKindFieldMetadata(
    id: publisherId,
    label: publisherLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'publisher',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
    vocabulary: publisherVocabulary,
  );

  static const all = <LibraryKindFieldMetadata>[series, publisher];
}
