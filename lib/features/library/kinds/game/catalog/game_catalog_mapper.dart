import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

class GameCatalogMapper {
  static GameCatalogItem mapMetadataItemToGame(CatalogItem item) {
    final rawMetadata = item.kindMetadata;
    final GameCatalogMetadata meta;
    if (rawMetadata is GameCatalogMetadata) {
      meta = rawMetadata;
    } else {
      meta = GameCatalogMetadata.fromJson(item.payload);
    }

    final work = GameWorkMetadata(
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      releaseDate: item.releaseDate,
      platforms: meta.platforms,
      genres: meta.genres,
    );

    final editionsPayload =
        item.kindMetadata.toSyncPayload()['editions'] as List?;
    final editions = editionsPayload != null
        ? editionsPayload
            .whereType<Map<String, dynamic>>()
            .map((e) => CatalogEdition.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <CatalogEdition>[];

    final releases = editions.map((edition) {
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
