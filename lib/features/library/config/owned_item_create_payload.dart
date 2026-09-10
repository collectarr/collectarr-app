import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

/// Structural behavior contract for a kind-owned Owned create payload.
///
/// The payload implementation owns every personal-copy field and translates
/// it at the persistence boundary.
/// Generic collection code can invoke the behavior without reading any kind
/// field or inspecting the concrete payload.
abstract interface class OwnedItemCreatePayload {
  CatalogEntityRef get catalogRef;
  JsonEncodable get detailsDraft;
  bool? get isDigital;

  /// Builds the complete kind-owned aggregate.
  ///
  /// The structural command layer intentionally does not name the concrete
  /// return type. The generated kind persistence registry consumes this value
  /// immediately at the serialization boundary.
  Object toOwnedItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  });
}
