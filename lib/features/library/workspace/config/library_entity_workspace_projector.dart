import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

final class LibraryReleaseState {
  const LibraryReleaseState({
    required this.isOwned,
    required this.isWishlisted,
    required this.isTracked,
    this.trackingSummary,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool isTracked;
  final TrackingSummary? trackingSummary;
}

/// Projects one kind-owned entity into the generic workspace DTO boundary.
///
/// The entity ref carries the structural scope, so a projector has one
/// semantic operation instead of three methods that every kind had to fake.
abstract interface class LibraryEntityWorkspaceProjector<
    TDto extends LibraryWorkspaceDto> {
  TDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  });
}

/// Rejects a structural node that no longer belongs to the workspace source.
///
/// Workspace projections are often rebuilt from cached shelf data. A stale
/// release/copy node must not silently fall back to the source's primary
/// release or another owned item.
void requireEntityBelongsToSource(
  LibraryWorkspaceSource source,
  LibraryEntityRef entity,
) {
  final expectedWorkId = source.catalogRef?.rootScope.id ?? source.itemId;
  if (entity.workId != expectedWorkId) {
    throw StateError(
      'Library entity "${entity.id}" belongs to work "${entity.workId}", '
      'but the workspace source belongs to "$expectedWorkId"',
    );
  }

  if (entity case LibraryCopyRef(:final ownedRef)) {
    final sourceOwnedRef = source.ownedSummary?.ref;
    if (sourceOwnedRef != ownedRef) {
      throw StateError(
        'Library copy "${entity.id}" refers to owned item "${ownedRef.key}", '
        'but the workspace source contains '
        '"${sourceOwnedRef?.key ?? 'no owned item'}"',
      );
    }
  }
}

/// Rejects a node routed to the wrong entity workspace.
///
/// A projector is registered once per structural scope. Keeping that scope
/// explicit prevents a Work projector from silently rendering a Release (or
/// a Copy projector from rendering its parent Release) when a stale router
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
