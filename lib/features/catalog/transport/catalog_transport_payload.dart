import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Builds the schema-v1 transport payload consumed by a kind-owned catalog
/// decoder. The envelope identity is authoritative; typed repositories must
/// receive the identity being upserted even when a persisted raw payload has
/// an absent or stale id.
Map<String, dynamic> catalogTransportPayloadFor(CatalogItemDto item) {
  // Snapshot versions describe the transport envelope, not catalog fields.
  // Strip them recursively because some API responses wrap the kind payload
  // (for example, Music) in a nested object.
  final payload = catalogPayloadWithoutSnapshotVersion(item.payload);
  return {
    ...payload,
    'id': item.id,
    'kind': item.kind,
  };
}

/// Removes the transport-only schema marker before a map is treated as
/// Catalog Item data or persisted as a catalog import payload.
Map<String, dynamic> catalogPayloadWithoutSnapshotVersion(
  Map<String, dynamic> value,
) =>
    _withoutSnapshotVersion(value);

Map<String, dynamic> _withoutSnapshotVersion(Map<String, dynamic> value) => {
      for (final entry in value.entries)
        if (entry.key != 'snapshot_version')
          entry.key: _stripNestedSnapshotVersions(entry.value),
    };

Object? _stripNestedSnapshotVersions(Object? value) {
  if (value is Map) {
    return _withoutSnapshotVersion(Map<String, dynamic>.from(value));
  }
  if (value is List) {
    return [for (final item in value) _stripNestedSnapshotVersions(item)];
  }
  return value;
}
