import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';

typedef AnimeSeriesDtoFetcher = Future<AnimeSeriesDto> Function(String id);

/// Maps generated Core Anime DTOs into Anime-owned domain models.
final class AnimeCoreMapper {
  const AnimeCoreMapper._();

  static AnimeMedia fromSeriesDto(AnimeSeriesDto dto) {
    _validateKind(dto.kind, 'series', dto.raw);
    final raw = dto.toJson();
    return AnimeMedia(
      id: AnimeMediaId(dto.id),
      title: dto.title,
      animeType: _textValue(raw['anime_type']),
      characterAppearances: _mapCharacters(dto.characterAppearances),
      contributions: _mapContributors(dto.contributions),
      description: dto.description,
      endDate: dto.endDate,
      episodeCount: dto.episodeCount,
      episodes: [
        for (final entry in dto.episodes)
          if (entry is Map)
            fromEpisodePayload(
              Map<String, dynamic>.from(entry),
              seriesId: AnimeMediaId(dto.id),
            ),
      ],
      identifiers: _mapIdentifiers(dto.identifiers),
      originalAirDate: dto.originalAirDate,
      originalLanguage: dto.originalLanguage,
      sortTitle: dto.sortTitle,
      status: dto.status,
      releases: _mapReleases(raw['releases'] ?? raw['editions']),
      rawPayload: raw,
    );
  }

  static AnimeEpisode fromEpisodePayload(
    Map<String, dynamic> json, {
    AnimeMediaId? seriesId,
  }) {
    _validateKind(json['kind']?.toString(), 'episode', json);
    final resolvedSeriesId = _textValue(json['series_id']) ?? seriesId?.value;
    if (resolvedSeriesId == null || resolvedSeriesId.isEmpty) {
      throw const FormatException('Anime episode is missing series_id');
    }
    return AnimeEpisode.fromJson({
      ...json,
      'series_id': resolvedSeriesId,
    });
  }

  static AnimeRelease fromReleasePayload(Map<String, dynamic> json) {
    _validateKind(json['kind']?.toString(), 'release', json);
    return AnimeRelease.fromJson(json);
  }

  static List<AnimeContributor> _mapContributors(List<dynamic> entries) => [
        for (final entry in entries)
          if (entry is Map)
            AnimeContributor.fromJson(Map<String, dynamic>.from(entry)),
      ];

  static List<AnimeCharacterAppearance> _mapCharacters(List<dynamic> entries) =>
      [
        for (final entry in entries)
          if (entry is Map)
            AnimeCharacterAppearance.fromJson(Map<String, dynamic>.from(entry)),
      ];

  static List<AnimeIdentifier> _mapIdentifiers(List<dynamic> entries) => [
        for (final entry in entries)
          if (entry is Map)
            AnimeIdentifier.fromJson(Map<String, dynamic>.from(entry)),
      ];

  static List<AnimeRelease> _mapReleases(Object? entries) => [
        for (final entry in entries is Iterable ? entries : const <dynamic>[])
          if (entry is Map)
            fromReleasePayload(Map<String, dynamic>.from(entry)),
      ];

  static void _validateKind(
    String? kind,
    String dtoType,
    Map<String, dynamic> raw,
  ) {
    final rawKind = _textValue(raw['kind']) ?? _textValue(kind);
    if (rawKind != null && rawKind.toLowerCase() != 'anime') {
      throw StateError('Expected an anime Core DTO for $dtoType, got $rawKind');
    }
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
