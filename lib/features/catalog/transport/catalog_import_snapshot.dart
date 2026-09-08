import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Opaque catalog snapshot crossing from a kind-owned import profile into the
/// catalog transport writer.
///
/// Collection orchestration can carry identity and kind without receiving the
/// canonical catalog DTO. The transport repository unwraps the DTO only when
/// it reaches the persistence boundary.
final class CatalogImportSnapshot {
  const CatalogImportSnapshot._(this._item);

  factory CatalogImportSnapshot.fromItem(CatalogItemDto item) {
    return CatalogImportSnapshot._(item);
  }

  final CatalogItemDto _item;

  String get id => _item.id;
  CatalogMediaKind get kind => _item.mediaKind;
  String get title => _item.title;

  CatalogItemDto toTransportItem() => _item;
}
