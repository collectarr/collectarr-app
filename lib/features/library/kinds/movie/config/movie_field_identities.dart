import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Movie field facts shared by forms and workspace.
abstract final class MovieFieldIdentities {
  static const titleId = 'movie.title';
  static const titleLabel = 'Title';
  static const originalTitleId = 'movie.original_title';
  static const originalTitleLabel = 'Original Title';
  static const genreId = 'movie.genre';
  static const genreLabel = 'Genre';
  static const ageRatingId = 'movie.age_rating';
  static const ageRatingLabel = 'Age Rating';
  static const audienceRatingId = 'movie.audience_rating';
  static const audienceRatingLabel = 'Audience Rating';
  static const runtimeMinutesId = 'movie.runtime_minutes';
  static const runtimeMinutesLabel = 'Runtime (minutes)';
  static const formatId = 'movie.format';
  static const formatLabel = 'Format';
  static const releaseDateId = 'movie.release_date';
  static const releaseDateLabel = 'Release Date';
  static const barcodeId = 'movie.barcode';
  static const barcodeLabel = 'Barcode';

  static const genreVocabulary = VocabularyId<String>('movie.genre');
  static const formatVocabulary = VocabularyId<String>('movie.physical_format');

  static const title = LibraryKindFieldMetadata(
    id: titleId,
    label: titleLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'title',
    searchable: true,
    sortable: true,
    editable: true,
  );
  static const originalTitle = LibraryKindFieldMetadata(
    id: originalTitleId,
    label: originalTitleLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'original_title',
    searchable: true,
    editable: true,
  );
  static const genre = LibraryKindFieldMetadata(
    id: genreId,
    label: genreLabel,
    valueType: LibraryFieldValueType.textList,
    catalogPath: 'genres',
    searchable: true,
    groupable: true,
    editable: true,
    vocabulary: genreVocabulary,
  );
  static const ageRating = LibraryKindFieldMetadata(
    id: ageRatingId,
    label: ageRatingLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'age_rating',
    editable: true,
  );
  static const audienceRating = LibraryKindFieldMetadata(
    id: audienceRatingId,
    label: audienceRatingLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'audience_rating',
    groupable: true,
    editable: true,
  );
  static const runtimeMinutes = LibraryKindFieldMetadata(
    id: runtimeMinutesId,
    label: runtimeMinutesLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'runtime_minutes',
    sortable: true,
    editable: true,
  );
  static const format = LibraryKindFieldMetadata(
    id: formatId,
    label: formatLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'physical_format',
    groupable: true,
    editable: true,
    vocabulary: formatVocabulary,
  );
  static const releaseDate = LibraryKindFieldMetadata(
    id: releaseDateId,
    label: releaseDateLabel,
    valueType: LibraryFieldValueType.partialDate,
    catalogPath: 'release_date',
    origin: LibraryFieldValueOrigin.derived,
    sortable: true,
    editable: true,
  );
  static const barcode = LibraryKindFieldMetadata(
    id: barcodeId,
    label: barcodeLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'barcode',
    searchable: true,
    editable: true,
  );
}
