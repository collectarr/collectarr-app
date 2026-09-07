import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Serialization-boundary helpers shared by kind-owned catalog codecs.
///
/// These helpers only preserve the structural catalog envelope while a kind
/// performs its own typed decode. They do not know any catalog semantics.
Map<String, dynamic> catalogPayloadFor(CatalogItem item) => {
      ...item.toSyncPayload(),
      // The envelope identity is authoritative. A persisted raw payload may
      // contain an absent or stale id, but typed repositories must always
      // receive the identity being upserted.
      'id': item.id,
      'kind': item.kind,
    };

CatalogItem catalogItemWithTypedMetadata(
  CatalogItem item,
  Object? Function(Map<String, dynamic>) decode,
) {
  if (item.kindMetadata is! Map) return item;
  return item.withKindMetadata(decode(item.payload));
}

CatalogItem catalogProjection(
  String kind,
  String? id,
  String title,
  Object? rawPayload,
  Object? Function(Map<String, dynamic>) decode,
) {
  final payload = rawPayload is Map
      ? Map<String, dynamic>.from(rawPayload)
      : <String, dynamic>{};
  payload['id'] ??= id ?? '';
  payload['kind'] ??= kind;
  payload['title'] ??= title;
  final item = CatalogItem.fromJson(payload);
  return catalogItemWithTypedMetadata(item, decode);
}
