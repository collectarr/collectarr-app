import 'catalog_entity_ref.dart';
import 'owned_item_projection.dart';

/// Validates a structural catalog target before it crosses a persistence or
/// feature boundary. The target's entity semantics remain owned by its kind.
void requireKnownCatalogRef(
  CatalogEntityRef ref, [
  String name = 'catalogRef',
]) {
  if (!ref.isKnown) {
    throw ArgumentError.value(
      ref,
      name,
      'Expected a known catalog reference with a non-empty id.',
    );
  }
}

/// Validates an owned-copy reference before it is persisted by a global
/// feature. A bare string id is never a valid cross-kind target.
void requireKnownOwnedRef(
  OwnedItemRef ref, [
  String name = 'ownedRef',
]) {
  if (ref.kind.isUnknown || ref.id.value.trim().isEmpty) {
    throw ArgumentError.value(
      ref,
      name,
      'Expected a known owned reference with a non-empty id.',
    );
  }
}

/// Ensures an owned copy and its optional catalog target belong to the same
/// kind before a global feature stores both references together.
void requireMatchingOwnedCatalogKinds(
  CatalogEntityRef catalogRef,
  OwnedItemRef ownedRef, {
  String catalogName = 'catalogRef',
  String ownedName = 'ownedRef',
}) {
  requireKnownCatalogRef(catalogRef, catalogName);
  requireKnownOwnedRef(ownedRef, ownedName);
  if (catalogRef.kind != ownedRef.kind) {
    throw ArgumentError(
      'The $ownedName kind (${ownedRef.kind.apiValue}) must match '
      'the $catalogName kind (${catalogRef.kind.apiValue}).',
    );
  }
}
