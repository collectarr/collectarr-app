import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Book field facts shared by forms, workspace, and filters.
abstract final class BookFieldIdentities {
  static const subtitleId = 'book.subtitle';
  static const subtitleLabel = 'Subtitle';
  static const seriesId = 'book.series';
  static const seriesLabel = 'Series';
  static const publisherId = 'book.publisher';
  static const publisherLabel = 'Publisher';
  static const pageCountId = 'book.page_count';
  static const pageCountLabel = 'Page count';
  static const isbnId = 'book.isbn';
  static const isbnLabel = 'ISBN';
  static const releaseDateId = 'book.release_date';
  static const releaseDateLabel = 'Release Date';
  static const formatId = 'book.format';
  static const formatLabel = 'Format';

  static const publisherVocabulary = VocabularyId<String>('book.publisher');
  static const formatVocabulary = VocabularyId<String>('book.format');

  static const subtitle = LibraryKindFieldMetadata(
    id: subtitleId,
    label: subtitleLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'subtitle',
    searchable: true,
    editable: true,
  );
  static const series = LibraryKindFieldMetadata(
    id: seriesId,
    label: seriesLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'series_title',
    filterable: true,
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
    groupable: true,
    editable: true,
    vocabulary: publisherVocabulary,
  );
  static const pageCount = LibraryKindFieldMetadata(
    id: pageCountId,
    label: pageCountLabel,
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'page_count',
    sortable: true,
    editable: true,
  );
  static const isbn = LibraryKindFieldMetadata(
    id: isbnId,
    label: isbnLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'isbn',
    searchable: true,
    editable: true,
  );
  static const releaseDate = LibraryKindFieldMetadata(
    id: releaseDateId,
    label: releaseDateLabel,
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_date',
    sortable: true,
    editable: true,
  );
  static const format = LibraryKindFieldMetadata(
    id: formatId,
    label: formatLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'physical_format',
    filterable: true,
    groupable: true,
    editable: true,
    vocabulary: formatVocabulary,
  );

  static const all = <LibraryKindFieldMetadata>[
    subtitle,
    series,
    publisher,
    pageCount,
    isbn,
    releaseDate,
    format,
  ];
}
