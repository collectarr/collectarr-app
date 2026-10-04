import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_characters_editor.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';

typedef MovieFormValuesReader<TDraft> = MovieCatalogFormValues Function(
    TDraft draft);

const movieMainFieldIds = <String>{
  'catalog_title',
  'sort_key',
  'original_title',
  'localized_title',
  'display_title',
  'search_aliases',
  'genres',
  'original_language',
  'language',
  'age_rating',
  'audience_rating',
  'runtime_minutes',
  'country',
  'publisher',
};

const movieEditionFieldIds = <String>{
  'subtitle',
  'edition_title',
  'physical_format',
  'release_year',
  'release_date',
  'barcode',
  'item_number',
  'variant_name',
};

const movieSpecsFieldIds = <String>{
  'audio_tracks',
  'subtitles',
  'screen_ratio',
  'layers',
  'color',
  'nr_discs',
};

const movieAllFieldIds = <String>{
  ...movieMainFieldIds,
  ...movieEditionFieldIds,
  ...movieSpecsFieldIds,
  'synopsis',
  'cover_image_url',
  'characters',
};

/// Fields stored directly on one concrete Movie Catalog Item.
///
/// This Add schema intentionally has no separate Work or Release section.
List<LibraryFieldSpec<TDraft>> movieCatalogItemFields<TDraft>({
  required MovieFormValuesReader<TDraft> values,
  Iterable<String>? formatOptions,
  Iterable<String>? genreOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  Iterable<String>? audioTrackOptions,
  Iterable<String>? subtitleOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'catalog_title',
        label: 'Title',
        value: (draft) => values(draft).title,
        setValue: (draft, value) => values(draft).title = value,
        validator: (draft) =>
            values(draft).title.trim().isEmpty ? 'Enter a title' : null,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'display_title',
        label: 'Display Title',
        value: (draft) => values(draft).displayTitle,
        setValue: (draft, value) => values(draft).displayTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'sort_key',
        label: 'Sort Title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
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
        id: 'search_aliases',
        label: 'Search Aliases',
        value: (draft) => values(draft).searchAliases,
        setValue: (draft, value) => values(draft).searchAliases = value,
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
        options: _options(
          genreOptions ?? MovieVocabularies.genre.builtIns,
        ),
        pickListKey: MovieVocabularyIds.genre.value,
        pluralLabel: 'Genres',
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
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'audio_tracks',
        label: 'Audio tracks',
        values: (draft) => values(draft).audioTracks.toSet(),
        setValues: (draft, selected) =>
            values(draft).audioTracks = selected.toList(growable: false),
        options: _options(
          audioTrackOptions ?? MovieVocabularies.audio.builtIns,
        ),
        pickListKey: MovieVocabularyIds.audio.value,
        pluralLabel: 'Audio tracks',
        allowCustomValues: true,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'subtitles',
        label: 'Subtitles',
        values: (draft) => values(draft).subtitles.toSet(),
        setValues: (draft, selected) =>
            values(draft).subtitles = selected.toList(growable: false),
        options: _options(
          subtitleOptions ?? MovieVocabularies.subtitles.builtIns,
        ),
        pickListKey: MovieVocabularyIds.subtitles.value,
        pluralLabel: 'Subtitles',
        allowCustomValues: true,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'screen_ratio',
        label: 'Screen ratio',
        value: (draft) => values(draft).screenRatio,
        setValue: (draft, value) => values(draft).screenRatio = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'layers',
        label: 'Layers',
        value: (draft) => values(draft).layers,
        setValue: (draft, value) => values(draft).layers = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'color',
        label: 'Color',
        value: (draft) => values(draft).color,
        setValue: (draft, value) => values(draft).color = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'nr_discs',
        label: 'Discs',
        value: (draft) => values(draft).nrDiscs,
        setValue: (draft, value) => values(draft).nrDiscs = value?.toInt(),
        minimum: 1,
      ),
      LibraryCustomFieldSpec<TDraft>(
        id: 'characters',
        label: 'Characters',
        builder: (context, draft) => MovieCharactersEditor(
          characters: values(draft).characters,
          onChanged: (characters) => values(draft).characters = characters,
        ),
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
        pickListKey: MovieVocabularyIds.physicalFormat.value,
        onManage: onManageFormat == null ? null : (_) => onManageFormat(),
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'country',
        label: 'Country / region',
        value: (draft) => _nullableText(values(draft).region),
        setValue: (draft, value) => values(draft).region = value ?? '',
        options: _options(regionOptions ?? MovieVocabularies.region.builtIns),
        pickListKey: MovieVocabularyIds.region.value,
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
        label: 'Release Date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) {
          final form = values(draft);
          form.releaseDate = value;
          form.releaseMonth = value?.month;
          form.releaseDay = value?.day;
          if (value != null) form.releaseYear = value.year;
        },
      ),
      LibraryVocabularyFieldSpec<TDraft, String>(
        id: 'publisher',
        label: 'Studio / distributor',
        value: (draft) => _nullableText(values(draft).distributor),
        setValue: (draft, value) => values(draft).distributor = value ?? '',
        options: _options(
          distributorOptions ?? MovieVocabularies.distributor.builtIns,
        ),
        pickListKey: MovieVocabularyIds.distributor.value,
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
        id: movieCoverImageUrlFieldId,
        label: 'Cover Image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
    ];

const movieCoverImageUrlFieldId = 'cover_image_url';

String? _nullableText(String value) => value.trim().isEmpty ? null : value;

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
