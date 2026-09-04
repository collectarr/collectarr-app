import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

/// Maps generated Core TV DTOs directly into TV-owned domain models.
final class TvCoreMapper {
  const TvCoreMapper._();

  static TvEpisode fromEpisodeDto(TvEpisodeDto dto) {
    return TvEpisode(
      id: dto.id,
      seriesId: _text(dto.raw['series_id']) ?? '',
      seasonId: dto.seasonId,
      seasonNumber: _int(dto.raw['season_number']),
      episodeNumber: dto.episodeNumber,
      title: dto.episodeTitle,
      originalTitle: _text(dto.raw['original_title']),
      description: dto.description,
      airDate: dto.airDateValue,
      runtimeMinutes: dto.runtimeMinutes,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      rawPayload: Map<String, dynamic>.from(dto.toJson()),
    );
  }

  static TvSeason fromSeasonDto(TvSeasonDto dto) {
    return TvSeason(
      id: dto.id,
      seriesId: dto.seriesId,
      seasonNumber: dto.seasonNumber,
      title: dto.title,
      description: dto.description,
      airDate: dto.airDateValue,
      episodeCount: dto.episodeCount,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      episodes: [
        for (final episode in dto.episodes) fromEpisodeDto(episode),
      ],
      rawPayload: Map<String, dynamic>.from(dto.toJson()),
    );
  }

  static TvReleaseMedia fromReleaseMediaDto(TvReleaseMediaDto dto) {
    return TvReleaseMedia(
      id: dto.id,
      releaseId: dto.releaseId,
      mediaNumber: dto.mediaNumber,
      mediaType: dto.mediaType,
      title: dto.titleValue,
      episodeCount: dto.episodeCount,
      runtimeMinutes: dto.runtimeMinutes,
      regionCode: dto.regionCode,
      encoding: dto.encoding,
      aspectRatio: dto.aspectRatio,
      color: dto.color,
      audioTracks: dto.audioTracks,
      subtitles: dto.subtitles,
      layers: dto.layers,
      frameRate: dto.frameRate,
      bitDepth: dto.bitDepth,
      resolution: dto.resolution,
      hdrFormat: dto.hdrFormat,
      episodes: _maps(dto.raw['episodes'])
          .map((json) => fromEpisodeDto(TvEpisodeDto.fromJson(json)))
          .toList(growable: false),
      rawPayload: Map<String, dynamic>.from(dto.toJson()),
    );
  }

  static TvReleaseEpisodeMap fromReleaseEpisodeMapDto(
    TvReleaseEpisodeMapDto dto,
  ) {
    return TvReleaseEpisodeMap(
      id: dto.id,
      releaseId: dto.releaseId,
      mediaId: dto.mediaId,
      episodeId: dto.episodeId,
      discNumber: dto.discNumber,
      sequenceNumber: dto.sequenceNumber,
    );
  }

  static TvRelease fromReleaseDto(TvReleaseDto dto) {
    return TvRelease(
      id: dto.id,
      seriesId: dto.seriesId,
      title: dto.titleValue,
      sortTitle: dto.sortTitle,
      description: dto.description,
      mediaCount: dto.mediaCount,
      format: dto.format,
      regionCode: dto.regionCode,
      releaseDate: dto.releaseDateValue,
      publisher: dto.publisher,
      sku: dto.sku,
      caseType: dto.caseType,
      episodeCount: dto.episodeCount,
      seasonCount: dto.seasonCount,
      runtimeMinutes: dto.runtimeMinutes,
      languageAudio: dto.languageAudio,
      languageSubtitles: dto.languageSubtitles,
      contentRating: dto.contentRating,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      media: [
        for (final media in dto.media) fromReleaseMediaDto(media),
      ],
      episodeMappings: [
        for (final mapping in dto.episodeMappings)
          fromReleaseEpisodeMapDto(mapping),
      ],
      rawPayload: Map<String, dynamic>.from(dto.toJson()),
    );
  }

  static TvSeries fromSeriesDto(TvSeriesDto dto) {
    _validateKind(dto.kind);
    final rawReleases = _maps(dto.raw['releases']);
    return TvSeries(
      id: dto.id,
      title: dto.title,
      sortTitle: dto.sortTitle,
      description: dto.description,
      endDate: dto.endDate,
      episodeCount: dto.episodeCount,
      network: dto.network,
      originalAirDate: dto.originalAirDate,
      originalLanguage: dto.originalLanguage,
      seasonCount: dto.seasonCount,
      status: dto.status,
      seasons: [
        for (final value in dto.seasons)
          if (_seasonFromValue(value) case final season?) season,
      ],
      releases: [
        for (final json in rawReleases)
          fromReleaseDto(TvReleaseDto.fromJson(json)),
      ],
      media: [
        for (final value in dto.media)
          if (_mediaFromValue(value) case final media?) media,
      ],
      releaseEpisodeMaps: [
        for (final json in _maps(dto.raw['episode_mappings']))
          fromReleaseEpisodeMapDto(TvReleaseEpisodeMapDto.fromJson(json)),
      ],
      contributions: _maps(dto.contributions)
          .map(TvContributor.fromJson)
          .toList(growable: false),
      identifiers: _maps(dto.identifiers)
          .map(TvIdentifier.fromJson)
          .toList(growable: false),
      characterAppearances: _maps(dto.characterAppearances)
          .map(TvCharacterAppearance.fromJson)
          .toList(growable: false),
      rawPayload: Map<String, dynamic>.from(dto.toJson()),
    );
  }

  static TvSeason? _seasonFromValue(Object? value) {
    if (value is TvSeasonDto) return fromSeasonDto(value);
    if (value is Map) {
      return fromSeasonDto(
          TvSeasonDto.fromJson(Map<String, dynamic>.from(value)));
    }
    return null;
  }

  static TvReleaseMedia? _mediaFromValue(Object? value) {
    if (value is TvReleaseMediaDto) return fromReleaseMediaDto(value);
    if (value is Map) {
      return fromReleaseMediaDto(
        TvReleaseMediaDto.fromJson(Map<String, dynamic>.from(value)),
      );
    }
    return null;
  }

  static void _validateKind(String? kind) {
    if (kind?.trim().toLowerCase() != 'tv') {
      throw StateError('TV Core mapping received ${kind ?? 'unknown'} data');
    }
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    if (value is! Iterable) return const <Map<String, dynamic>>[];
    return [
      for (final entry in value)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }
}
