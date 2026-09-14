import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';

typedef MovieWorkDtoFetcher = Future<MovieWorkDto> Function(String id);

final class MovieCoreMapper {
  const MovieCoreMapper._();

  static MovieMedia fromWorkDto(MovieWorkDto dto) {
    _validateKind(dto.kind, 'work', dto.raw);
    return MovieMedia(
      id: MovieMediaId(dto.id),
      title: dto.title,
      ageRating: dto.ageRating,
      audienceRating: dto.audienceRating,
      characterAppearances: _mapCharacters(dto.characterAppearances),
      contributions: _mapContributors(dto.contributions),
      description: dto.description,
      externalLinks: _mapExternalLinks(dto.externalLinks),
      identifiers: _mapIdentifiers(dto.identifiers),
      originalLanguage: dto.originalLanguage,
      releaseDate: dto.releaseDateValue,
      releases: _mapReleases(dto.releases),
      runtimeMinutes: dto.runtimeMinutes,
      sortTitle: dto.sortTitle,
      subtitle: dto.subtitle,
      trailerUrls: _mapTrailerLinks(dto.trailerUrls),
      rawPayload: dto.toJson(),
    );
  }

  static MovieRelease fromReleasePayload(Map<String, dynamic> releaseJson) {
    _validateKind(releaseJson['kind']?.toString(), 'release', releaseJson);
    return MovieRelease.fromJson(releaseJson);
  }

  static List<MovieRelease> _mapReleases(List<dynamic> entries) {
    return [
      for (final entry in entries)
        if (entry is Map<Object?, Object?>)
          fromReleasePayload(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieContributor> _mapContributors(List<dynamic> entries) {
    return [
      for (final entry in entries)
        if (entry is Map<Object?, Object?>)
          MovieContributor.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieCharacterAppearance> _mapCharacters(List<dynamic> entries) {
    return [
      for (final entry in entries)
        if (entry is Map<Object?, Object?>)
          MovieCharacterAppearance.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieIdentifier> _mapIdentifiers(List<dynamic> entries) {
    return [
      for (final entry in entries)
        if (entry is Map<Object?, Object?>)
          MovieIdentifier.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }

  static List<MovieExternalLink> _mapExternalLinks(List<dynamic> entries) {
    return [for (final entry in entries) MovieExternalLink.fromJson(entry)];
  }

  static List<MovieTrailerLink> _mapTrailerLinks(List<dynamic> entries) {
    return [for (final entry in entries) MovieTrailerLink.fromJson(entry)];
  }

  static void _validateKind(
    String? kind,
    String dtoType,
    Map<String, dynamic> raw,
  ) {
    final rawKind = _textValue(raw['kind']) ?? _textValue(kind);
    if (rawKind != null && rawKind.toLowerCase() != 'movie') {
      throw StateError('Expected a movie Core DTO for $dtoType, got $rawKind');
    }
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
