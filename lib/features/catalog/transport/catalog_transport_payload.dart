import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Builds the schema-v1 transport payload consumed by a kind-owned catalog
/// decoder. The envelope identity is authoritative; typed repositories must
/// receive the identity being upserted even when a persisted raw payload has
/// an absent or stale id.
Map<String, dynamic> catalogTransportPayloadFor(CatalogItemDto item) => {
      ...item.toSyncPayload(),
      'id': item.id,
      'kind': item.kind,
    };
