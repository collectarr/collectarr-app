import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class GameCatalogMapper {
  static GameCatalogItem mapMetadataItemToGame(LibraryMetadataItem item) {
    if (item.kindMetadata is! GameCatalogMetadata) {
      throw ArgumentError.value(
        item.kindMetadata,
        'item.kindMetadata',
        'Expected GameCatalogMetadata',
      );
    }
    final meta = item.kindMetadata as GameCatalogMetadata;

    final work = GameWorkMetadata(
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      releaseDate: item.releaseDate,
      platforms: meta.platforms,
      genres: meta.genres,
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
