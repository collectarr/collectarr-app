import 'catalog_entity_ref.dart';
import 'catalog_item_ref.dart';
import 'library_entry_projection.dart';

/// Validates a structural catalog target before it crosses a persistence or
/// feature boundary. The target's entity semantics remain entry by its kind.
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

/// Validates a personal collection entry before it is persisted by a global
/// feature. A bare string id is never a valid cross-kind target.
void requireKnownLibraryEntryRef(
  LibraryEntryRef ref, [
  String name = 'libraryEntryRef',
]) {
  if (ref.kind.isUnknown || ref.id.value.trim().isEmpty) {
    throw ArgumentError.value(
      ref,
      name,
      'Expected a known collection item with a kind and ID.',
    );
  }
}

/// Ensures a collection item and its optional catalog target belong to the same
/// kind before a global feature stores both references together.
void requireMatchingCatalogAndLibraryEntryKinds(
  CatalogEntityRef catalogRef,
  LibraryEntryRef libraryEntryRef, {
  String catalogName = 'catalogRef',
  String libraryEntryName = 'libraryEntryRef',
}) {
  requireKnownCatalogRef(catalogRef, catalogName);
  requireKnownLibraryEntryRef(libraryEntryRef, libraryEntryName);
  if (catalogRef.kind != libraryEntryRef.kind) {
    throw ArgumentError(
      'The $libraryEntryName kind (${libraryEntryRef.kind.apiValue}) must match '
      'the $catalogName kind (${catalogRef.kind.apiValue}).',
    );
  }
}

/// Validates a direct v1 Catalog Item identity at a global feature boundary.
void requireKnownCatalogItemRef(
  CatalogItemRef ref, [
  String name = 'catalogItemRef',
]) {
  if (ref.kind.isUnknown || ref.id.trim().isEmpty) {
    throw ArgumentError.value(
      ref,
      name,
      'Expected a known Catalog Item reference with a non-empty id.',
    );
  }
}
