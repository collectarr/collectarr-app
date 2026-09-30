import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Builds the schema-v1 transport payload consumed by a kind-owned catalog
/// decoder. The envelope identity is authoritative; typed repositories must
/// receive the identity being upserted even when a persisted raw payload has
/// an absent or stale id.
Map<String, dynamic> catalogTransportPayloadFor(CatalogItemDto item) {
  final payload = Map<String, dynamic>.from(item.payload)
    // This helper is the boundary to kind-owned decoders. The snapshot
    // version is envelope metadata and must not be interpreted as a field
    // owned by any catalog kind.
    ..remove('snapshot_version');
  return {
    ...payload,
    'id': item.id,
    'kind': item.kind,
  };
}
