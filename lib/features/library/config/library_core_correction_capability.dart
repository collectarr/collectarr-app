import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

/// Exact canonical target selected by a kind-entry edit boundary.
///
/// The generic edit host may transport this value, but it must not infer a
/// kind's canonical identity from a catalog candidate or a browser mode.
final class LibraryCoreCorrectionTarget {
  const LibraryCoreCorrectionTarget({
    required this.scope,
    required this.entityId,
  });

  /// Core field-schema scope. This may be kind-specific, such as
  /// `catalog_item`, even while other kinds still use structural scopes.
  final String scope;
  final String entityId;
}

typedef LibraryCoreCorrectionTargetResolver = LibraryCoreCorrectionTarget
    Function({
  required LibraryEntityRef? node,
  required LibraryEntityScope? requestedScope,
  required CatalogEntityRef catalogRef,
});

/// Uses the direct Catalog Item identity for source-neutral Core corrections.
/// Personal collection-item identity never changes the canonical correction
/// target.
LibraryCoreCorrectionTarget resolveStructuralLibraryCoreCorrectionTarget({
  required LibraryEntityRef? node,
  required LibraryEntityScope? requestedScope,
  required CatalogEntityRef catalogRef,
}) {
  if (node != null) {
    final catalogItemId = node.catalogItemId.trim();
    if (catalogItemId.isEmpty) {
      throw StateError('Catalog Item correction requires an item ID.');
    }
    return LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.catalogItem.apiValue,
      entityId: catalogItemId,
    );
  }

  final scope = requestedScope ?? LibraryEntityScope.catalogItem;
  final entityId = switch (scope) {
    LibraryEntityScope.catalogItem =>
      (catalogRef.rootId ?? catalogRef.id).trim(),
    LibraryEntityScope.libraryEntry => '',
  };
  if (entityId.isEmpty) {
    throw StateError(
      'Core correction requires a concrete ${scope.name} entity reference.',
    );
  }
  return LibraryCoreCorrectionTarget(
    scope: scope.apiValue,
    entityId: entityId,
  );
}
