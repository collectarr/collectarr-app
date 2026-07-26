import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class GameCatalogMapper {
  const GameCatalogMapper._();

  static GameCatalogItem mapDtoToGame(CatalogItemDto dto) {
    final game = dto.game;

    final work = GameWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      platforms: game?.platforms ?? const [],
      genres: dto.genres ?? const [],
    );

    final releases = dto.editions.map((edition) {
      return GameRelease(
        id: edition.id,
        title: edition.title,
        platform: edition.region,
        publisher: edition.publisher,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        format: edition.physicalFormatLabel ?? edition.physicalFormat,
      );
    }).toList();

    return GameCatalogItem(
      id: dto.id,
      work: work,
      releases: releases,
    );
  }

  static GameCatalogItem mapWorkspaceEntryToGame(LibraryWorkspaceEntry entry) {
    final game = entry.game;

    final work = GameWorkMetadata(
      title: entry.title,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      releaseDate: entry.releaseDate,
      platforms: game?.platforms ?? const [],
      genres: entry.genres ?? const [],
    );

    final releases = entry.editions.map((edition) {
      return GameRelease(
        id: edition.id,
        title: edition.title,
        platform: edition.region,
        publisher: edition.publisher,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        format: edition.physicalFormatLabel ?? edition.physicalFormat,
      );
    }).toList();

    return GameCatalogItem(
      id: entry.id,
      work: work,
      releases: releases,
    );
  }

  static GameCatalogItem mapMetadataItemToGame(LibraryMetadataItem item) {
    final game = item.game;

    final work = GameWorkMetadata(
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      releaseDate: item.releaseDate,
      platforms: game?.platforms ?? const [],
      genres: item.genres ?? const [],
    );

    final releases = item.editions.map((edition) {
      return GameRelease(
        id: edition.id,
        title: edition.title,
        platform: edition.region,
        publisher: edition.publisher,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        format: edition.physicalFormatLabel ?? edition.physicalFormat,
      );
    }).toList();

    return GameCatalogItem(
      id: item.id,
      work: work,
      releases: releases,
    );
  }
}
