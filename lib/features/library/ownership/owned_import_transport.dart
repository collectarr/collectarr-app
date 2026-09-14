import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';

/// Schema-v1 Owned payload waiting to cross into kind-owned persistence.
///
/// The payload is opaque to generic Collection code. The owning persistence
/// dispatcher decodes it using [ref.kind] and returns a structural mutation
/// result.
final class OwnedImportTransport {
  const OwnedImportTransport({
    required this.ref,
    required this.catalogRef,
    required this.payload,
  });

  final OwnedItemRef ref;
  final CatalogEntityRef catalogRef;
  final JsonMap payload;
}
