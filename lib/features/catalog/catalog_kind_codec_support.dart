import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Serialization-boundary helpers shared by kind-owned catalog codecs.
///
/// These helpers only preserve the structural catalog envelope while a kind
/// performs its own typed decode. They do not know any catalog semantics.
Map<String, dynamic> catalogPayloadFor(CatalogItemDto item) => {
      ...item.toSyncPayload(),
      // The envelope identity is authoritative. A persisted raw payload may
      // contain an absent or stale id, but typed repositories must always
      // receive the identity being upserted.
      'id': item.id,
      'kind': item.kind,
    };

Future<int> countCatalogProjectionValues(
  Iterable<CatalogItemDto> items, {
  required Iterable<String> fields,
  required String normalizedValue,
}) async {
  final fieldNames = fields.toSet();
  if (fieldNames.isEmpty || normalizedValue.trim().isEmpty) {
    return 0;
  }
  var count = 0;
  for (final item in items) {
    final matches = fieldNames.any((field) {
      final value = item.payload[field];
      return value is String &&
          _normalizeCatalogValue(value) == normalizedValue;
    });
    if (matches) count++;
  }
  return count;
}

String _normalizeCatalogValue(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
