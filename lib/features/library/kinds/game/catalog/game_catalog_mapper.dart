import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

final class GameCatalogMapper {
  const GameCatalogMapper._();

  /// Maps one flat Core Game Catalog Item without manufacturing editions.
  static GameCatalogItem mapMetadataItemToGame(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    final metadata = rawMetadata is GameCatalogMetadata
        ? rawMetadata
        : GameCatalogMetadata.fromJson(item.payload);
    return GameCatalogItem(item: item, metadata: metadata);
  }
}
