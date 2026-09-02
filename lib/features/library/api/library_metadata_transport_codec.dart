import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_catalog_item_view.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

abstract final class LibraryMetadataTransportCodec {
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
