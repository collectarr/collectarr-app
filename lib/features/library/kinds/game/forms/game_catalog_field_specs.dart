import 'dart:async';

import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';

typedef GameFormValuesReader<TDraft> = GameCatalogFormValues Function(
  TDraft draft,
);

List<LibraryFieldSpec<TDraft>> gameMetadataFields<TDraft>({
  required GameFormValuesReader<TDraft> values,
  bool includeTitle = true,
  Set<String>? include,
  Iterable<String>? ageRatingOptions,
  Iterable<String>? platformOptions,
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
        id: 'display_title',
        label: 'Display Title',
        value: (draft) => values(draft).displayTitle,
        setValue: (draft, value) => values(draft).displayTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_title',
        label: 'Original Title',
        value: (draft) => values(draft).originalTitle,
        setValue: (draft, value) => values(draft).originalTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'localized_title',
        label: 'Localized Title',
        value: (draft) => values(draft).localizedTitle,
        setValue: (draft, value) => values(draft).localizedTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'sort_title',
        label: 'Sort Title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'subtitle',
        label: 'Subtitle',
        value: (draft) => values(draft).subtitle,
        setValue: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description',
        label: 'Description',
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'platforms',
        label: 'Platforms',
        values: (draft) => values(draft).platforms.toSet(),
        setValues: (draft, next) =>
            values(draft).platforms = next.toList(growable: false),
        options:
            _options(platformOptions ?? GameVocabularies.platform.builtIns),
        pickListKey: GameVocabularyIds.platform.value,
        allowCustomValues: true,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'identifiers',
        label: 'Identifiers',
        value: (draft) => values(draft).identifiers.join(', '),
        setValue: (draft, value) => values(draft).identifiers = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'company_roles',
        label: 'Companies and roles',
        value: (draft) => values(draft).companyRoles.join(', '),
        setValue: (draft, value) => values(draft).companyRoles = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'developers',
        label: 'Developers',
        value: (draft) => values(draft).developers.join(', '),
        setValue: (draft, value) => values(draft).developers = _split(value),
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'age_ratings',
        label: 'Age ratings',
        values: (draft) => values(draft).ageRatings.toSet(),
        setValues: (draft, next) =>
            values(draft).ageRatings = next.toList(growable: false),
        options: _options(
          ageRatingOptions ?? GameVocabularies.ageRating.builtIns,
        ),
        pickListKey: GameVocabularyIds.ageRating.value,
        allowCustomValues: true,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'genres',
        label: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) =>
            values(draft).genres = next.toList(growable: false),
        options: const [],
        allowCustomValues: true,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'search_aliases',
        label: 'Search Aliases',
        value: (draft) => values(draft).searchAliases.join(', '),
        setValue: (draft, value) => values(draft).searchAliases = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_language',
        label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'franchise',
        label: 'Franchise',
        value: (draft) => values(draft).franchise,
        setValue: (draft, value) => values(draft).franchise = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'toy_subtype',
        label: 'Toy subtype',
        value: (draft) => values(draft).toySubtype,
        setValue: (draft, value) => values(draft).toySubtype = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'toy_type',
        label: 'Toy type',
        value: (draft) => values(draft).toyType,
        setValue: (draft, value) => values(draft).toyType = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'series',
        label: 'Series',
        value: (draft) => values(draft).series,
        setValue: (draft, value) => values(draft).series = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'languages',
        label: 'Languages',
        value: (draft) => values(draft).languages.join(', '),
        setValue: (draft, value) => values(draft).languages = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'country',
        label: 'Country',
        value: (draft) => values(draft).country,
        setValue: (draft, value) => values(draft).country = value,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

List<LibraryFieldSpec<TDraft>> gameCatalogItemFields<TDraft>({
  required GameFormValuesReader<TDraft> values,
  Set<String>? include,
  String titleLabel = 'Edition title',
  Iterable<String>? regionOptions,
  Iterable<String>? formatOptions,
  String? Function(String value)? physicalFormatIdForValue,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageFormat,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'edition_title',
        label: titleLabel,
        value: (draft) => values(draft).editionTitle,
        setValue: (draft, value) => values(draft).editionTitle = value,
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'region',
        label: 'Region',
        value: (draft) => _nullable(values(draft).region),
        setValue: (draft, value) => values(draft).region = value ?? '',
        options: _options(regionOptions ?? GameVocabularies.region.builtIns),
        pickListKey: GameVocabularyIds.region.value,
        onManage: onManageRegion == null ? null : (_) => onManageRegion(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'format',
        label: 'Format',
        value: (draft) => _nullable(values(draft).format),
        setValue: (draft, value) {
          values(draft).format = value ?? '';
          if (physicalFormatIdForValue != null) {
            values(draft).physicalFormatId =
                value == null ? null : physicalFormatIdForValue(value);
          }
        },
        onManage: onManageFormat == null ? null : (_) => onManageFormat(),
        options: _options(formatOptions ?? GameVocabularies.edition.builtIns),
        pickListKey: GameVocabularyIds.edition.value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Release Date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'catalog_number',
        label: 'Catalog number',
        value: (draft) => values(draft).catalogNumber,
        setValue: (draft, value) => values(draft).catalogNumber = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'release_status',
        label: 'Release status',
        value: (draft) => values(draft).releaseStatus,
        setValue: (draft, value) => values(draft).releaseStatus = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'barcode',
        label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'thumbnail_image_url',
        label: 'Thumbnail image URL',
        value: (draft) => values(draft).thumbnailImageUrl,
        setValue: (draft, value) => values(draft).thumbnailImageUrl = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'release_year',
        label: 'Release year',
        value: (draft) => values(draft).releaseYear?.toDouble(),
        setValue: (draft, value) => values(draft).releaseYear = value?.toInt(),
        minimum: 1,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'variant',
        label: 'Variant',
        value: (draft) => values(draft).variant,
        setValue: (draft, value) => values(draft).variant = value,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

String? _nullable(String value) => value.trim().isEmpty ? null : value;

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
