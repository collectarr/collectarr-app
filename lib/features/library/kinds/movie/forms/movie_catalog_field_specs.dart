import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

typedef MovieFormValuesReader<TDraft> = MovieCatalogFormValues Function(
    TDraft draft);

List<LibraryFieldSpec<TDraft>> movieWorkIdentityFields<TDraft>({
  required MovieFormValuesReader<TDraft> values,
  bool includeTitle = true,
}) =>
    [
      if (includeTitle)
        LibraryTextFieldSpec<TDraft>(
          id: 'title',
          label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
        ),
      LibraryTextFieldSpec<TDraft>(
        id: 'sort_title',
        label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description',
        label: 'Synopsis',
        value: (draft) => values(draft).workDescription,
        setValue: (draft, value) => values(draft).workDescription = value,
        maxLines: 4,
      ),
    ];

List<LibraryFieldSpec<TDraft>> movieWorkClassificationFields<TDraft>({
  required MovieFormValuesReader<TDraft> values,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'genres',
        label: 'Genres',
        value: (draft) => values(draft).genres.join(', '),
        setValue: (draft, value) => values(draft).genres = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_language',
        label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'age_rating',
        label: 'Age rating',
        value: (draft) => values(draft).ageRating,
        setValue: (draft, value) => values(draft).ageRating = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'audience_rating',
        label: 'Audience rating',
        value: (draft) => values(draft).audienceRating,
        setValue: (draft, value) => values(draft).audienceRating = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'runtime_minutes',
        label: 'Runtime (minutes)',
        value: (draft) => values(draft).runtimeMinutes,
        setValue: (draft, value) =>
            values(draft).runtimeMinutes = value?.toInt(),
        minimum: 0,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'work_release_date',
        label: 'Release date',
        value: (draft) => values(draft).workReleaseDate,
        setValue: (draft, value) => values(draft).workReleaseDate = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'subtitle',
        label: 'Subtitle',
        value: (draft) => values(draft).subtitle,
        setValue: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'directors',
        label: 'Director(s)',
        value: (draft) => values(draft).directors,
        setValue: (draft, value) => values(draft).directors = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'characters',
        label: 'Characters',
        value: (draft) => values(draft).characters,
        setValue: (draft, value) => values(draft).characters = value,
      ),
    ];

List<LibraryFieldSpec<TDraft>> movieReleaseIdentityFields<TDraft>({
  required MovieFormValuesReader<TDraft> values,
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'release_title',
        label: 'Release title',
        value: (draft) => values(draft).releaseTitle,
        setValue: (draft, value) => values(draft).releaseTitle = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'format',
        label: 'Format',
        value: (draft) => _nullableText(values(draft).format),
        setValue: (draft, value) => values(draft).format = value ?? '',
        options: _options(
          formatOptions ?? MovieVocabularies.physicalFormat.builtIns,
        ),
        onManage: onManageFormat == null ? null : (_) => onManageFormat(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'region',
        label: 'Region',
        value: (draft) => _nullableText(values(draft).region),
        setValue: (draft, value) => values(draft).region = value ?? '',
        options: _options(regionOptions ?? MovieVocabularies.region.builtIns),
        onManage: onManageRegion == null ? null : (_) => onManageRegion(),
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'release_year',
        label: 'Release year',
        value: (draft) => values(draft).releaseYear,
        setValue: (draft, value) => values(draft).releaseYear = value?.toInt(),
        minimum: 1,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
    ];

List<LibraryFieldSpec<TDraft>> movieReleasePublishingFields<TDraft>({
  required MovieFormValuesReader<TDraft> values,
  Iterable<String>? distributorOptions,
  FutureOr<void> Function()? onManageDistributor,
}) =>
    [
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'distributor',
        label: 'Studio / distributor',
        value: (draft) => _nullableText(values(draft).distributor),
        setValue: (draft, value) => values(draft).distributor = value ?? '',
        options: _options(
          distributorOptions ?? MovieVocabularies.distributor.builtIns,
        ),
        onManage:
            onManageDistributor == null ? null : (_) => onManageDistributor(),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'release_description',
        label: 'Description',
        value: (draft) => values(draft).releaseDescription,
        setValue: (draft, value) => values(draft).releaseDescription = value,
        maxLines: 4,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'barcode',
        label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'item_number',
        label: 'Item number',
        value: (draft) => values(draft).itemNumber,
        setValue: (draft, value) => values(draft).itemNumber = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'variant',
        label: 'Variant',
        value: (draft) => values(draft).variant,
        setValue: (draft, value) => values(draft).variant = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'back_cover_image_url',
        label: 'Back cover image URL',
        value: (draft) => values(draft).backCoverImageUrl,
        setValue: (draft, value) => values(draft).backCoverImageUrl = value,
      ),
    ];

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];

List<String> _split(String value) => value
    .split(RegExp(r'[,;\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
