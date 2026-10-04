import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

typedef MovieFormValuesReader<TDraft> = MovieCatalogFormValues Function(
    TDraft draft);

/// Fields stored directly on one concrete Movie Catalog Item.
///
/// This Add schema intentionally has no separate Work or Release section.
List<LibraryFieldSpec<TDraft>> movieCatalogItemFields<TDraft>({
  required MovieFormValuesReader<TDraft> values,
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'sort_key',
        label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'synopsis',
        label: 'Synopsis',
        value: (draft) => values(draft).synopsis,
        setValue: (draft, value) => values(draft).synopsis = value,
        maxLines: 4,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'genres',
        label: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, selected) =>
            values(draft).genres = selected.toList(growable: false),
        options: const [],
        allowCustomValues: true,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_language',
        label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
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
      LibraryTextFieldSpec<TDraft>(
        id: 'edition_title',
        label: 'Edition title',
        value: (draft) => values(draft).editionTitle,
        setValue: (draft, value) => values(draft).editionTitle = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'physical_format',
        label: 'Format',
        value: (draft) => _nullableText(values(draft).format),
        setValue: (draft, value) => values(draft).format = value ?? '',
        options: _options(
          formatOptions ?? MovieVocabularies.physicalFormat.builtIns,
        ),
        onManage: onManageFormat == null ? null : (_) => onManageFormat(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'country',
        label: 'Country / region',
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
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'publisher',
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
        id: 'variant_name',
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
    ];

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
