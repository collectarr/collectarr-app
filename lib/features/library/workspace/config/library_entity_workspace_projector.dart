import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

/// Projects one kind-entry entity into the generic workspace DTO boundary.
///
/// The entity ref carries the record scope, so each kind implements one
/// semantic projection rather than separate Work, Release, and Copy methods.
abstract interface class LibraryEntityWorkspaceProjector<
    TDto extends LibraryWorkspaceDto> {
  TDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  });
}

/// Rejects a structural node that no longer belongs to the workspace source.
///
/// Workspace projections are often rebuilt from cached shelf data. A stale
/// catalog/entry node must not silently fall back to the source's primary
/// item or another local entry.
void requireEntityBelongsToSource(
  LibraryWorkspaceSource source,
  LibraryEntityRef entity,
) {
  final expectedCatalogItemId =
      source.catalogRef?.rootScope.id ?? source.itemId;
  if (entity.catalogItemId != expectedCatalogItemId) {
    throw StateError(
      'Library entity "${entity.id}" belongs to Catalog Item "${entity.catalogItemId}", '
      'but the workspace source belongs to "$expectedCatalogItemId"',
    );
  }

  if (entity case LibraryEntryNodeRef(:final libraryEntryRef)) {
    final sourceLibraryEntryRef = source.libraryEntrySummary?.ref;
    if (sourceLibraryEntryRef != libraryEntryRef) {
      throw StateError(
        'Library entry "${entity.id}" refers to entry "${libraryEntryRef.key}", '
        'but the workspace source contains '
        '"${sourceLibraryEntryRef?.key ?? 'no collection item'}"',
      );
    }
  }
}

/// Rejects a node routed to the wrong entity workspace.
///
/// A projector is registered once per record scope. Keeping that scope
/// explicit prevents an Entry projector from rendering a Catalog Item (or
/// a Catalog Item projector from rendering an Entry) when a stale router
/// call supplies the wrong node.
void requireEntityScope(
  LibraryEntityRef entity,
  LibraryEntityScope expectedScope,
) {
  if (entity.scope != expectedScope) {
    throw StateError(
      'Workspace projector for ${expectedScope.apiValue} received '
      '${entity.scope.apiValue} entity "${entity.id}"',
    );
  }
}
