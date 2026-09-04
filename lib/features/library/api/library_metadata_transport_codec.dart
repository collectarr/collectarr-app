import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_catalog_item_view.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

abstract final class LibraryMetadataTransportCodec {
  /// Converts either the current library view or the legacy catalog DTO at
  /// the persistence boundary. Callers in Library/Collection should keep
  /// working with [LibraryMetadataItem] after this point.
  static LibraryMetadataItem? fromUnknown(Object? item) {
    if (item is LibraryMetadataItem) return item;
    if (item is CatalogItem) return fromCatalogItem(item);
    return null;
  }

  static LibraryMetadataItem fromCatalogItem(CatalogItem item) {
    return LibraryCatalogItemView.fromCatalogItem(item);
  }

  static LibraryMetadataItem fromMetadataMap(Map<String, dynamic> json) {
    return LibraryCatalogItemView.fromMetadataMap(json);
  }

  static CatalogItem toCatalogItem(LibraryMetadataItem item) {
    return CatalogItem.fromJson(toSyncPayload(item));
  }

  static Map<String, dynamic> toSyncPayload(LibraryMetadataItem item) {
    return item.toSyncPayload();
  }
}
