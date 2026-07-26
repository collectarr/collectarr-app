import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class BoardGameCatalogMapper {
  const BoardGameCatalogMapper._();

  static BoardGameCatalogItem mapDtoToBoardGame(CatalogItemDto dto) {
    final bgStats = dto.boardGameStats;

    final work = BoardGameWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      genres: dto.genres ?? const [],
    );

    final stats = BoardGameStatsMetadata(
      bggRank: bgStats?.bggRank,
      bggRating: bgStats?.bggRating,
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

  static BoardGameCatalogItem mapWorkspaceEntryToBoardGame(LibraryWorkspaceEntry entry) {
    final work = BoardGameWorkMetadata(
      title: entry.title,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      genres: entry.genres ?? const [],
    );

    final stats = const BoardGameStatsMetadata(
      bggRank: null,
      bggRating: null,
    );

    final releases = entry.editions.map((edition) {
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
      id: entry.id,
      work: work,
      stats: stats,
      releases: releases,
    );
  }

  static BoardGameCatalogItem mapMetadataItemToBoardGame(LibraryMetadataItem item) {
    final work = BoardGameWorkMetadata(
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      genres: item.genres ?? const [],
    );

    final stats = const BoardGameStatsMetadata(
      bggRank: null,
      bggRating: null,
    );

    final releases = item.editions.map((edition) {
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
      id: item.id,
      work: work,
      stats: stats,
      releases: releases,
    );
  }
}
