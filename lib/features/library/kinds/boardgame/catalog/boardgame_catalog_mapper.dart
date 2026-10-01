import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

final class BoardGameCatalogMapper {
  const BoardGameCatalogMapper._();

  /// Maps one flat Core Board Game Catalog Item without manufacturing
  /// editions or variants.
  static BoardGameCatalogItem mapDtoToBoardGame(CatalogItemDto dto) {
    final rawMetadata = dto.kindMetadata;
    final metadata = rawMetadata is BoardGameMetadata
        ? rawMetadata
        : BoardGameMetadata.fromJson(catalogTransportPayloadFor(dto));
    return BoardGameCatalogItem(item: dto, metadata: metadata);
  }

  static BoardGameCatalogItem mapMetadataItemToBoardGame(
    CatalogItemDto item,
  ) =>
      mapDtoToBoardGame(item);
}
