import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';

AnimeMediaFormValues animeMediaFormValuesFrom(AnimeMedia media) =>
    AnimeMediaFormValues(
      title: media.title,
      sortTitle: media.sortTitle ?? '',
      description: media.description ?? '',
      coverImageUrl: media.coverImageUrl ?? '',
      animeType: media.animeType ?? '',
      season: _text(media.rawPayload['season']) ?? '',
      sourceMaterial: _text(media.rawPayload['source_material']) ?? '',
      originalLanguage: media.originalLanguage ?? '',
      genres: _strings(media.rawPayload['genres']),
      themes: _strings(media.rawPayload['themes']),
      studios: _strings(media.rawPayload['studios']),
      producers: _strings(media.rawPayload['producers']),
      licensors: _strings(media.rawPayload['licensors']),
      status: media.status ?? '',
      seasonYear: _int(media.rawPayload['season_year']),
      episodeCount: media.episodeCount,
      episodeRuntimeMinutes: _int(media.rawPayload['episode_runtime_minutes']),
      startDate: media.originalAirDate,
      endDate: media.endDate,
      nativeTitle: _text(media.rawPayload['native_title']) ?? '',
      romajiTitle: _text(media.rawPayload['romaji_title']) ?? '',
      englishTitle: _text(media.rawPayload['english_title']) ?? '',
      alternateTitles: _strings(media.rawPayload['alternate_titles']),
      country: _text(media.rawPayload['country']) ?? 'JP',
      creators: [for (final credit in media.contributions) credit.name],
      characters: [
        for (final appearance in media.characterAppearances)
          appearance.characterName,
      ],
    );

AnimeMedia animeMediaFromFormValues({
  required AnimeMedia original,
  required AnimeMediaFormValues values,
}) =>
    AnimeMedia(
      id: original.id,
      title: values.title.trim(),
      animeType: _nullable(values.animeType),
      characterAppearances: original.characterAppearances,
      contributions: original.contributions,
      description: _nullable(values.description),
      endDate: values.endDate,
      episodeCount: values.episodeCount,
      episodes: original.episodes,
      identifiers: original.identifiers,
      originalAirDate: values.startDate,
      originalLanguage: _nullable(values.originalLanguage),
      sortTitle: _nullable(values.sortTitle),
      status: _nullable(values.status),
      releases: original.releases,
      rawPayload: {
        ..._withoutKeys(original.rawPayload, const {
          'id',
          'kind',
          'title',
          'anime_type',
          'type',
          'description',
          'synopsis',
          'end_date',
          'episode_count',
          'original_air_date',
          'original_language',
          'sort_title',
          'status',
          'genres',
          'studios',
          'producers',
          'licensors',
          'themes',
          'season',
          'season_year',
          'source_material',
          'episode_runtime_minutes',
          'cover_image_url',
          'native_title',
          'romaji_title',
          'english_title',
          'alternate_titles',
          'country',
          'creators',
          'characters',
        }),
        'genres': List<String>.unmodifiable(values.genres),
        'studios': List<String>.unmodifiable(values.studios),
        'producers': List<String>.unmodifiable(values.producers),
        'licensors': List<String>.unmodifiable(values.licensors),
        'themes': List<String>.unmodifiable(values.themes),
        'season': _nullable(values.season),
        'season_year': values.seasonYear,
        'source_material': _nullable(values.sourceMaterial),
        'episode_runtime_minutes': values.episodeRuntimeMinutes,
        'cover_image_url': _nullable(values.coverImageUrl),
        'native_title': _nullable(values.nativeTitle),
        'romaji_title': _nullable(values.romajiTitle),
        'english_title': _nullable(values.englishTitle),
        'alternate_titles': List<String>.unmodifiable(values.alternateTitles),
        'country': _nullable(values.country),
      },
    );

AnimeReleaseFormValues animeReleaseFormValuesFrom(AnimeRelease release) =>
    AnimeReleaseFormValues(
      title: release.title,
      format: release.format ?? '',
      region: release.regionCode ?? '',
      language: release.language ?? '',
      releaseDate: release.releaseDate,
      publisher: release.publisher ?? '',
      distributor: release.distributor ?? '',
      barcode: release.barcode ?? '',
      mediaCount: release.mediaCount,
      audioTracks: release.audioTracks,
      subtitles: release.subtitles,
      description: release.description ?? '',
      coverImageUrl: release.coverImageUrl ?? '',
      variant: _text(release.rawPayload['variant']) ?? '',
    );

AnimeRelease animeReleaseFromFormValues({
  required AnimeRelease original,
  required AnimeReleaseFormValues values,
}) =>
    AnimeRelease(
      id: original.id,
      title: values.title.trim(),
      seriesId: original.seriesId,
      coverImageKey: original.coverImageKey,
      coverImageUrl: _nullable(values.coverImageUrl),
      description: _nullable(values.description),
      format: _nullable(values.format),
      language: _nullable(values.language),
      regionCode: _nullable(values.region),
      releaseDate: values.releaseDate,
      publisher: _nullable(values.publisher),
      distributor: _nullable(values.distributor),
      barcode: _nullable(values.barcode),
      mediaCount: values.mediaCount,
      audioTracks: List<String>.unmodifiable(values.audioTracks),
      subtitles: List<String>.unmodifiable(values.subtitles),
      media: original.media,
      episodeMappings: original.episodeMappings,
      rawPayload: {
        ..._withoutKeys(original.rawPayload, const {
          'id',
          'kind',
          'release_title',
          'title',
          'format',
          'format_label',
          'region',
          'region_code',
          'language',
          'release_date',
          'publisher',
          'distributor',
          'barcode',
          'sku',
          'media_count',
          'disc_count',
          'audio_tracks',
          'language_audio',
          'subtitles',
          'language_subtitles',
          'description',
          'synopsis',
          'cover_image_url',
          'variant',
        }),
        'variant': _nullable(values.variant),
      },
    );

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => _nullable(value?.toString() ?? '');

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

List<String> _strings(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final item in value)
      if (_text(item) case final text?) text,
  ];
}

Map<String, dynamic> _withoutKeys(
  Map<String, dynamic> source,
  Set<String> keys,
) =>
    {
      for (final entry in source.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };
