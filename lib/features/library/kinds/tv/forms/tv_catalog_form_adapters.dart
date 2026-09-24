import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';

TvSeriesFormValues tvSeriesFormValuesFrom(TvSeries series) =>
    TvSeriesFormValues(
      title: series.title,
      sortTitle: series.sortTitle ?? '',
      description: series.description ?? '',
      network: series.network ?? '',
      status: series.status ?? '',
      streamingService: _text(series.rawPayload['streaming_service']) ?? '',
      originalLanguage: series.originalLanguage ?? '',
      contentRating: _text(series.rawPayload['content_rating']) ?? '',
      genres: _strings(series.rawPayload['genres']),
      creators: [for (final credit in series.contributions) credit.name],
      characters: [
        for (final appearance in series.characterAppearances)
          appearance.characterName,
      ],
      originalAirDate: series.originalAirDate,
      endDate: series.endDate,
    );

TvSeries tvSeriesFromFormValues({
  required TvSeries original,
  required TvSeriesFormValues values,
}) =>
    TvSeries(
      id: original.id,
      title: values.title.trim(),
      sortTitle: _nullable(values.sortTitle),
      description: _nullable(values.description),
      endDate: values.endDate,
      episodeCount: original.episodeCount,
      network: _nullable(values.network),
      originalAirDate: values.originalAirDate,
      originalLanguage: _nullable(values.originalLanguage),
      seasonCount: original.seasonCount,
      status: _nullable(values.status),
      seasons: original.seasons,
      releases: original.releases,
      media: original.media,
      releaseEpisodeMaps: original.releaseEpisodeMaps,
      contributions: original.contributions,
      identifiers: original.identifiers,
      characterAppearances: original.characterAppearances,
      rawPayload: {
        ..._withoutKeys(original.rawPayload, const {
          'title',
          'sort_title',
          'description',
          'end_date',
          'network',
          'original_air_date',
          'first_air_date',
          'original_language',
          'season_count',
          'status',
          'genres',
          'streaming_service',
          'content_rating',
          'creators',
          'characters',
        }),
        'genres': List<String>.unmodifiable(values.genres),
        'streaming_service': _nullable(values.streamingService),
        'content_rating': _nullable(values.contentRating),
        'creators': List<String>.unmodifiable(values.creators),
        'characters': List<String>.unmodifiable(values.characters),
      },
    );

TvReleaseFormValues tvReleaseFormValuesFrom(TvRelease release) =>
    TvReleaseFormValues(
      title: release.title,
      sortTitle: release.sortTitle ?? '',
      format: release.format ?? '',
      region: release.regionCode ?? '',
      releaseDate: release.releaseDate,
      publisher: release.publisher ?? '',
      barcode: release.sku ?? '',
      caseType: release.caseType ?? '',
      description: release.description ?? '',
      contentRating: release.contentRating ?? '',
      audioLanguages: release.languageAudio,
      subtitleLanguages: release.languageSubtitles,
      coverImageUrl: release.coverImageUrl ?? '',
    );

TvRelease tvReleaseFromFormValues({
  required TvRelease original,
  required TvReleaseFormValues values,
}) =>
    TvRelease(
      id: original.id,
      seriesId: original.seriesId,
      title: values.title.trim(),
      sortTitle: _nullable(values.sortTitle),
      description: _nullable(values.description),
      mediaCount: original.mediaCount,
      format: _nullable(values.format),
      regionCode: _nullable(values.region),
      releaseDate: values.releaseDate,
      publisher: _nullable(values.publisher),
      sku: _nullable(values.barcode),
      caseType: _nullable(values.caseType),
      episodeCount: original.episodeCount,
      seasonCount: original.seasonCount,
      runtimeMinutes: original.runtimeMinutes,
      languageAudio: List<String>.unmodifiable(values.audioLanguages),
      languageSubtitles: List<String>.unmodifiable(values.subtitleLanguages),
      contentRating: _nullable(values.contentRating),
      coverImageUrl: _nullable(values.coverImageUrl),
      coverImageKey: original.coverImageKey,
      media: original.media,
      episodeMappings: original.episodeMappings,
      rawPayload: _withoutKeys(original.rawPayload, const {
        'id',
        'series_id',
        'title',
        'sort_title',
        'description',
        'synopsis',
        'format',
        'format_label',
        'region',
        'region_code',
        'release_date',
        'publisher',
        'sku',
        'barcode',
        'case_type',
        'language_audio',
        'language_subtitles',
        'content_rating',
        'cover_image_url',
      }),
    );

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => _nullable(value?.toString() ?? '');

List<String> _strings(Object? value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

Map<String, dynamic> _withoutKeys(
  Map<String, dynamic> source,
  Set<String> keys,
) =>
    {
      for (final entry in source.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };
