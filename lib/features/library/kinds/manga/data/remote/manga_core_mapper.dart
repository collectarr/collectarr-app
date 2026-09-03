import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

typedef MangaWorkDtoFetcher = Future<MangaWorkDto> Function(String id);

final class MangaCoreMapper {
  const MangaCoreMapper._();

  static MangaMedia fromWorkDto(MangaWorkDto dto) {
    if (dto.kind != null && dto.kind != 'manga') {
      throw StateError('Expected a manga Core DTO, got ${dto.kind}');
    }

    return MangaMedia(
      id: dto.id,
      title: dto.title,
      sortTitle: dto.sortTitle,
      description: dto.description,
      firstPublicationDate: dto.firstPublicationDate,
      originalLanguage: dto.originalLanguage,
      originalPublicationDate: dto.originalPublicationDate,
      status: dto.status,
      subtitle: dto.subtitle,
      chapters: List<dynamic>.from(dto.chapters),
      characterAppearances: List<dynamic>.from(dto.characterAppearances),
      contributions: List<dynamic>.from(dto.contributions),
      identifiers: List<dynamic>.from(dto.identifiers),
      series: List<dynamic>.from(dto.series),
      rawPayload: dto.toJson(),
    );
  }
}
