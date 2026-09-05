import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';

typedef BoardGameWorkDtoFetcher = Future<BoardGameWorkDto> Function(String id);
typedef BoardGameEditionDtoFetcher = Future<BoardGameEditionDto> Function(
    String id);

final class BoardGameCoreMapper {
  const BoardGameCoreMapper._();

  static BoardGameMedia fromWorkDto(BoardGameWorkDto dto) {
    _validateKind(dto.kind, 'work', dto.raw);
    return BoardGameMedia(
      id: BoardGameMediaId(dto.id),
      title: dto.title,
      sortTitle: dto.sortTitle,
      description: dto.description,
      releaseDate: dto.releaseDateValue,
      originalLanguage: dto.originalLanguage,
      publisher: dto.publisher,
      subtitle: dto.subtitle,
      platforms: List<String>.from(dto.platforms),
      identifiers: List<String>.from(dto.identifiers),
      contributors: List<String>.from(dto.contributors),
      mechanics: List<String>.from(dto.mechanics),
      categories: List<String>.from(dto.categories),
      families: List<String>.from(dto.families),
      expansions: List<String>.from(dto.expansions),
      rankings: List<String>.from(dto.rankings),
      searchAliases: List<String>.from(dto.searchAliases),
      editions: _mapEditions(dto.raw['editions']),
      rawPayload: dto.toJson(),
    );
  }

  static BoardGameEdition fromEditionDto(BoardGameEditionDto dto) {
    _validateKind(dto.kind, 'edition', dto.raw);
    return BoardGameEdition(
      id: dto.id,
      title: dto.title,
      titleValue: dto.titleValue,
      workId: _textValue(dto.workId),
      editionTitle: dto.editionTitle,
      ageRating: dto.ageRating,
      audienceRating: dto.audienceRating,
      barcode: dto.barcodeValue,
      catalogNumber: dto.catalogNumber,
      country: dto.country,
      coverImageUrl: dto.coverImageUrlValue,
      description: dto.description,
      format: dto.format,
      language: dto.language,
      maxPlayers: dto.maxPlayers,
      minAge: dto.minAge,
      minPlayers: dto.minPlayers,
      playingTimeMinutes: dto.playingTimeMinutes,
      publisher: dto.publisher,
      releaseDate: dto.releaseDateValue,
      releaseStatus: dto.releaseStatus,
      rawPayload: dto.toJson(),
    );
  }

  static void _validateKind(
    String? kind,
    String dtoType,
    Map<String, dynamic> raw,
  ) {
    final rawKind = _textValue(raw['kind']) ?? _textValue(kind);
    if (rawKind != null && rawKind.toLowerCase() != 'boardgame') {
      throw StateError(
        'Expected a boardgame Core DTO for $dtoType, got $rawKind',
      );
    }
  }

  static List<BoardGameEdition> _mapEditions(Object? value) {
    if (value is! Iterable) return const <BoardGameEdition>[];
    return [
      for (final entry in value)
        if (entry is Map)
          fromEditionDto(
            BoardGameEditionDto.fromJson(Map<String, dynamic>.from(entry)),
          ),
    ];
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
