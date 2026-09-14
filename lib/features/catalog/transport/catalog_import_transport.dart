import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

/// A schema-v1 catalog snapshot waiting to cross into catalog persistence.
///
/// This is a transport value, not a catalog domain model or a search result.
/// A kind-owned importer creates it; the catalog transport repository decodes
/// it into the generated catalog DTO at the persistence boundary.
final class CatalogImportTransport {
  const CatalogImportTransport({
    required this.ref,
    required this.payload,
  });

  factory CatalogImportTransport.fromPayload(JsonMap payload) {
    final id = (payload['id'] as String?)?.trim();
    final kindValue = (payload['kind'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Catalog import payload is missing id.');
    }
    final kind = catalogMediaKindFromApiValue(kindValue);
    if (kind.isUnknown) {
      throw FormatException(
        'Catalog import payload has unsupported kind: $kindValue',
      );
    }
    return CatalogImportTransport(
      ref: CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityTypeId.root,
        id: id,
      ),
      payload: Map<String, dynamic>.unmodifiable(payload),
    );
  }

  final CatalogEntityRef ref;
  final JsonMap payload;
}
