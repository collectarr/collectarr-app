import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class BoardGameCatalogMapper {
  const BoardGameCatalogMapper._();

  static BoardGameCatalogItem mapDtoToBoardGame(CatalogItemDto dto) {
    final payload = dto.toSyncPayload();
    final bgStats = (payload['board_game_stats'] as Map?) ?? payload;

    final work = BoardGameWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      genres: (payload['genres'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );

    final stats = BoardGameStatsMetadata(
      bggRank: bgStats['bgg_rank'] is num
          ? (bgStats['bgg_rank'] as num).toInt()
          : null,
      bggRating: bgStats['bgg_rating'] is num
          ? (bgStats['bgg_rating'] as num).toDouble()
          : null,
    );

    final releases = dto.editions.map((edition) {
      return BoardGameRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        barcode: edition.isbn ?? edition.upc,
        releaseDate: edition.releaseDate,
        language: edition.language,
      );
    }).toList();

    return BoardGameCatalogItem(
      id: dto.id,
      work: work,
      stats: stats,
      releases: releases,
    );
  }

  static BoardGameCatalogItem mapMetadataItemToBoardGame(
      LibraryMetadataItem item) {
    return mapDtoToBoardGame(CatalogItemDto.fromJson(item.toSyncPayload()));
  }
}
