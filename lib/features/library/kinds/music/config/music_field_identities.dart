import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Music field facts shared by forms, workspace, filters, and reports.
abstract final class MusicFieldIdentities {
  static const titleId = 'music.title';
  static const titleLabel = 'Title';
  static const title = LibraryKindFieldMetadata(
    id: titleId,
    label: titleLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'title',
    searchable: true,
    sortable: true,
    exportable: true,
    editable: true,
  );

  static const artistId = 'music.artist';
  static const artistLabel = 'Artist';
  static const artistVocabulary = VocabularyId<String>('music.artist');
  static const artist = LibraryKindFieldMetadata(
    id: artistId,
    label: artistLabel,
    valueType: LibraryFieldValueType.textList,
    catalogPath: 'artist_credits',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    exportable: true,
    editable: true,
    vocabulary: artistVocabulary,
  );

  static const publisherId = 'music.publisher';
  static const publisherLabel = 'Label';
  static const publisherVocabulary = VocabularyId<String>('music.record_label');
  static const publisher = LibraryKindFieldMetadata(
    id: publisherId,
    label: publisherLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'label',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    exportable: true,
    editable: true,
    vocabulary: publisherVocabulary,
  );

  static const genreId = 'music.genre';
  static const genreLabel = 'Genre';
  static const genreVocabulary = VocabularyId<String>('music.genre');
  static const genre = LibraryKindFieldMetadata(
    id: genreId,
    label: genreLabel,
    valueType: LibraryFieldValueType.textList,
    catalogPath: 'genres',
    searchable: true,
    filterable: true,
    groupable: true,
    exportable: true,
    editable: true,
    vocabulary: genreVocabulary,
  );

  static const formatId = 'music.format';
  static const formatLabel = 'Format';
  static const formatVocabulary = VocabularyId<String>('music.format');
  static const format = LibraryKindFieldMetadata(
    id: formatId,
    label: formatLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'discs[].format',
    origin: LibraryFieldValueOrigin.derived,
    filterable: true,
    groupable: true,
    exportable: true,
    editable: true,
    vocabulary: formatVocabulary,
  );

  static const packagingId = 'music.packaging';
  static const packagingLabel = 'Packaging';
  static const packagingVocabulary = VocabularyId<String>('music.packaging');
  static const packaging = LibraryKindFieldMetadata(
    id: packagingId,
    label: packagingLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'packaging',
    filterable: true,
    groupable: true,
    editable: true,
    vocabulary: packagingVocabulary,
  );

  static const boxSetId = 'music.box_set';
  static const boxSetLabel = 'Box Set';
  static const boxSetVocabulary = VocabularyId<String>('music.box_set');
  static const boxSet = LibraryKindFieldMetadata(
    id: boxSetId,
    label: boxSetLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'box_set',
    groupable: true,
    editable: true,
    vocabulary: boxSetVocabulary,
  );

  static const releaseDateId = 'music.release_date';
  static const releaseDateLabel = 'Release Date';
  static const releaseDate = LibraryKindFieldMetadata(
    id: releaseDateId,
    label: releaseDateLabel,
    valueType: LibraryFieldValueType.partialDate,
    catalogPath: 'release_date',
    sortable: true,
    groupable: true,
    exportable: true,
    editable: true,
  );

  static const barcodeId = 'music.barcode';
  static const barcodeLabel = 'Barcode';
  static const barcode = LibraryKindFieldMetadata(
    id: barcodeId,
    label: barcodeLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'barcode',
    searchable: true,
    exportable: true,
    editable: true,
  );

  static const catalogNumberId = 'music.catalog_number';
  static const catalogNumberLabel = 'Catalog Number';
  static const catalogNumber = LibraryKindFieldMetadata(
    id: catalogNumberId,
    label: catalogNumberLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'catalog_number',
    searchable: true,
    exportable: true,
    editable: true,
  );

  static const countryId = 'music.country';
  static const countryLabel = 'Country';
  static const countryVocabulary = VocabularyId<String>('music.country');
  static const country = LibraryKindFieldMetadata(
    id: countryId,
    label: countryLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'country',
    filterable: true,
    groupable: true,
    editable: true,
    vocabulary: countryVocabulary,
  );
}
