import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Anime field facts shared by Add forms and workspace.
abstract final class AnimeFieldIdentities {
  static const formatId = 'anime.format';
  static const formatLabel = 'Anime format';
  static const barcodeId = 'anime.barcode';
  static const barcodeLabel = 'Barcode';
  static const nativeTitleId = 'anime.native_title';
  static const nativeTitleLabel = 'Native Title';
  static const romajiTitleId = 'anime.romaji_title';
  static const romajiTitleLabel = 'Romaji Title';
  static const englishTitleId = 'anime.english_title';
  static const englishTitleLabel = 'English Title';

  static const formatVocabulary = VocabularyId<String>('anime.format');

  static const format = LibraryKindFieldMetadata(
    id: formatId,
    label: formatLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'format',
    searchable: true,
    groupable: true,
    editable: true,
    vocabulary: formatVocabulary,
  );
  static const barcode = LibraryKindFieldMetadata(
    id: barcodeId,
    label: barcodeLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'barcode',
    searchable: true,
    editable: true,
  );
  static const nativeTitle = LibraryKindFieldMetadata(
    id: nativeTitleId,
    label: nativeTitleLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'native_title',
    editable: true,
  );
  static const romajiTitle = LibraryKindFieldMetadata(
    id: romajiTitleId,
    label: romajiTitleLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'romaji_title',
    editable: true,
  );
  static const englishTitle = LibraryKindFieldMetadata(
    id: englishTitleId,
    label: englishTitleLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'english_title',
    editable: true,
  );

  static const all = <LibraryKindFieldMetadata>[
    format,
    barcode,
    nativeTitle,
    romajiTitle,
    englishTitle,
  ];
}
