import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

typedef AnimeMediaValuesReader<T> = AnimeMediaFormValues Function(T value);
typedef AnimeReleaseValuesReader<T> = AnimeReleaseFormValues Function(T value);

List<LibraryFieldSpec<T>> animeMediaIdentityFields<T>({
  required AnimeMediaValuesReader<T> values,
  bool includeTitle = true,
}) =>
    [
      if (includeTitle)
        LibraryTextFieldSpec<T>(
          id: 'title',
          label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
        ),
      LibraryTextFieldSpec<T>(
        id: 'sort_title',
        label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<T>(
        id: 'description',
        label: 'Synopsis',
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
      LibraryImageFieldSpec<T, String>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => _nullable(values(draft).coverImageUrl),
        setValue: (draft, value) => values(draft).coverImageUrl = value ?? '',
      ),
    ];

List<LibraryFieldSpec<T>> animeMediaClassificationFields<T>({
  required AnimeMediaValuesReader<T> values,
  Iterable<String>? formatOptions,
  Iterable<String>? seasonOptions,
  Iterable<String>? sourceMaterialOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageSeason,
}) =>
    [
      _vocabulary<T>(
        id: 'anime_type',
        label: 'Anime format',
        value: (draft) => values(draft).animeType,
        setValue: (draft, value) => values(draft).animeType = value ?? '',
        options: formatOptions ?? AnimeVocabularies.format.builtIns,
        onManage: onManageFormat,
      ),
      _vocabulary<T>(
        id: 'season',
        label: 'Release season',
        value: (draft) => values(draft).season,
        setValue: (draft, value) => values(draft).season = value ?? '',
        options: seasonOptions ?? AnimeVocabularies.season.builtIns,
        onManage: onManageSeason,
      ),
      _vocabulary<T>(
        id: 'source_material',
        label: 'Source material',
        value: (draft) => values(draft).sourceMaterial,
        setValue: (draft, value) => values(draft).sourceMaterial = value ?? '',
        options: sourceMaterialOptions ??
            const [
              'Manga',
              'Light Novel',
              'Original',
              'Visual Novel',
              'Game',
              'Novel',
              'Other',
            ],
      ),
      _text<T>(
        id: 'original_language',
        label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
      _text<T>(
        id: 'genres',
        label: 'Genres',
        value: (draft) => values(draft).genres.join(', '),
        setValue: (draft, value) => values(draft).genres = _split(value),
      ),
      _text<T>(
        id: 'themes',
        label: 'Themes',
        value: (draft) => values(draft).themes.join(', '),
        setValue: (draft, value) => values(draft).themes = _split(value),
      ),
    ];

List<LibraryFieldSpec<T>> animeMediaProductionFields<T>({
  required AnimeMediaValuesReader<T> values,
  Iterable<String>? airingStatusOptions,
}) =>
    [
      _text<T>(
        id: 'studios',
        label: 'Studios',
        value: (draft) => values(draft).studios.join(', '),
        setValue: (draft, value) => values(draft).studios = _split(value),
      ),
      _text<T>(
        id: 'producers',
        label: 'Producers',
        value: (draft) => values(draft).producers.join(', '),
        setValue: (draft, value) => values(draft).producers = _split(value),
      ),
      _text<T>(
        id: 'licensors',
        label: 'Licensors',
        value: (draft) => values(draft).licensors.join(', '),
        setValue: (draft, value) => values(draft).licensors = _split(value),
      ),
      _vocabulary<T>(
        id: 'status',
        label: 'Airing status',
        value: (draft) => values(draft).status,
        setValue: (draft, value) => values(draft).status = value ?? '',
        options: airingStatusOptions ??
            const [
              'Currently Airing',
              'Finished Airing',
              'Not Yet Aired',
              'Cancelled',
            ],
      ),
    ];

List<LibraryFieldSpec<T>> animeMediaScheduleFields<T>({
  required AnimeMediaValuesReader<T> values,
}) =>
    [
      LibraryNumberFieldSpec<T>(
        id: 'season_year',
        label: 'Season year',
        value: (draft) => values(draft).seasonYear,
        setValue: (draft, value) => values(draft).seasonYear = value?.toInt(),
        minimum: 0,
      ),
      LibraryNumberFieldSpec<T>(
        id: 'episode_count',
        label: 'Episode count',
        value: (draft) => values(draft).episodeCount,
        setValue: (draft, value) => values(draft).episodeCount = value?.toInt(),
        minimum: 0,
      ),
      LibraryNumberFieldSpec<T>(
        id: 'episode_runtime_minutes',
        label: 'Episode runtime (minutes)',
        value: (draft) => values(draft).episodeRuntimeMinutes,
        setValue: (draft, value) =>
            values(draft).episodeRuntimeMinutes = value?.toInt(),
        minimum: 0,
      ),
      LibraryDateFieldSpec<T>(
        id: 'start_date',
        label: 'Start date',
        value: (draft) => values(draft).startDate,
        setValue: (draft, value) => values(draft).startDate = value,
      ),
      LibraryDateFieldSpec<T>(
        id: 'end_date',
        label: 'End date',
        value: (draft) => values(draft).endDate,
        setValue: (draft, value) => values(draft).endDate = value,
      ),
    ];

List<LibraryFieldSpec<T>> animeReleaseIdentityFields<T>({
  required AnimeReleaseValuesReader<T> values,
  Iterable<String>? formatOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageRegion,
}) =>
    [
      _text<T>(
        id: 'title',
        label: 'Title',
        value: (draft) => values(draft).title,
        setValue: (draft, value) => values(draft).title = value,
      ),
      _vocabulary<T>(
        id: 'format',
        label: 'Physical format',
        value: (draft) => values(draft).format,
        setValue: (draft, value) => values(draft).format = value ?? '',
        options: formatOptions ?? AnimeVocabularies.physicalFormat.builtIns,
        onManage: onManageFormat,
      ),
      _vocabulary<T>(
        id: 'region',
        label: 'Region',
        value: (draft) => values(draft).region,
        setValue: (draft, value) => values(draft).region = value ?? '',
        options: regionOptions ?? AnimeVocabularies.region.builtIns,
        onManage: onManageRegion,
      ),
      _text<T>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
      ),
      LibraryDateFieldSpec<T>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
    ];

List<LibraryFieldSpec<T>> animeReleasePublishingFields<T>({
  required AnimeReleaseValuesReader<T> values,
}) =>
    [
      _text<T>(
        id: 'publisher',
        label: 'Publisher / distributor',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
      ),
      _text<T>(
        id: 'barcode',
        label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      LibraryNumberFieldSpec<T>(
        id: 'media_count',
        label: 'Media count',
        value: (draft) => values(draft).mediaCount,
        setValue: (draft, value) => values(draft).mediaCount = value?.toInt(),
        minimum: 0,
      ),
      _text<T>(
        id: 'description',
        label: 'Description',
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
      _text<T>(
        id: 'audio_tracks',
        label: 'Audio languages',
        value: (draft) => values(draft).audioTracks.join(', '),
        setValue: (draft, value) => values(draft).audioTracks = _split(value),
      ),
      _text<T>(
        id: 'subtitles',
        label: 'Subtitle languages',
        value: (draft) => values(draft).subtitles.join(', '),
        setValue: (draft, value) => values(draft).subtitles = _split(value),
      ),
      LibraryImageFieldSpec<T, String>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => _nullable(values(draft).coverImageUrl),
        setValue: (draft, value) => values(draft).coverImageUrl = value ?? '',
      ),
    ];

LibraryVocabularyFieldSpec<T, String> _vocabulary<T>({
  required String id,
  required String label,
  required String Function(T draft) value,
  required void Function(T draft, String?) setValue,
  required Iterable<String> options,
  FutureOr<void> Function()? onManage,
}) =>
    LibraryVocabularyFieldSpec<T, String>(
      id: id,
      label: label,
      value: (draft) => _nullable(value(draft)),
      setValue: setValue,
      options: [
        for (final option in options)
          LibraryFieldOption(value: option, label: option),
      ],
      onManage: onManage == null ? null : (_) => onManage(),
    );

LibraryTextFieldSpec<T> _text<T>({
  required String id,
  required String label,
  required String Function(T draft) value,
  required void Function(T draft, String value) setValue,
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec<T>(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
