import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class GameCatalogMapper {
  static GameCatalogItem mapMetadataItemToGame(LibraryMetadataItem item) {
    final meta = item.kindMetadata is GameCatalogMetadata
        ? item.kindMetadata as GameCatalogMetadata
        : null;
    final payload = item.kindMetadata.toSyncPayload();
    final catalogItem = item.toCatalogItem();

    final work = GameWorkMetadata(
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      releaseDate: item.releaseDate,
      platforms: (payload['platforms'] as List?)?.cast<String>() ??
          (meta?.platform != null ? [meta!.platform!] : const []),
      genres: meta?.genres ??
          (payload['genres'] as List?)?.cast<String>() ??
          const [],
    );

    final releases = catalogItem.editions.map((edition) {
      return GameRelease(
        id: edition.id,
        title: edition.title ?? '',
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
