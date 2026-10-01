import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';

final class ComicCoreMapper {
  const ComicCoreMapper._();

  /// Maps a Core catalog search result at the generic transport boundary.
  ///
  /// The result is immediately converted to the canonical Comic model so
  /// callers never need to reintroduce a generic catalog representation.
  static ComicCatalogItem fromCatalogItem(CatalogItemDto item) {
    return ComicCatalogItem.fromJson(catalogTransportPayloadFor(item));
  }
}
