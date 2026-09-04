import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';

typedef GameWorkDtoFetcher = Future<GameWorkDto> Function(String id);
typedef GameReleaseDtoFetcher = Future<GameReleaseDto> Function(String id);

final class GameCoreMapper {
  const GameCoreMapper._();

  static GameMedia fromWorkDto(GameWorkDto dto) {
    _validateKind(dto.kind, 'work', dto.raw);
    return GameMedia(
      id: GameMediaId(dto.id),
      title: dto.title,
      sortTitle: dto.sortTitle,
      description: dto.description,
      releaseDate: dto.releaseDateValue,
      originalLanguage: dto.originalLanguage,
      publisher: dto.publisher,
      subtitle: dto.subtitle,
      platforms: List<String>.from(dto.platforms),
      identifiers: List<String>.from(dto.identifiers),
      companyRoles: List<String>.from(dto.companyRoles),
      ageRatings: List<String>.from(dto.ageRatings),
      genres: List<String>.from(dto.genres),
      searchAliases: List<String>.from(dto.searchAliases),
      releases: _mapReleases(dto.releases),
      rawPayload: dto.toJson(),
    );
  }

  static GameRelease fromReleaseDto(GameReleaseDto dto) {
    _validateKind(dto.kind, 'release', dto.raw);
    return GameRelease(
      id: dto.id,
      title: dto.title,
      workId: _textValue(dto.workId),
      platform: dto.platform,
      releaseDate: dto.releaseDateValue,
      regionCode: dto.regionCode,
      format: dto.format,
      publisher: dto.publisher,
      catalogNumber: dto.catalogNumber,
      releaseStatus: dto.releaseStatus,
      language: dto.language,
      barcode: dto.barcodeValue,
      coverImageUrl: dto.coverImageUrlValue,
      rawPayload: dto.toJson(),
    );
  }

  static List<GameRelease> _mapReleases(List<dynamic> entries) {
    return [
      for (final entry in entries)
        if (entry is Map<Object?, Object?>)
          fromReleaseDto(
            GameReleaseDto.fromJson(Map<String, dynamic>.from(entry)),
          ),
    ];
  }

  static void _validateKind(
    String? kind,
    String dtoType,
    Map<String, dynamic> raw,
  ) {
    final rawKind = _textValue(raw['kind']) ?? _textValue(kind);
    if (rawKind != null && rawKind.toLowerCase() != 'game') {
      throw StateError('Expected a game Core DTO for $dtoType, got $rawKind');
    }
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
