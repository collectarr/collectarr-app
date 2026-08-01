import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';


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
