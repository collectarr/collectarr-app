import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

/// Exact canonical target selected by a kind-owned edit boundary.
///
/// The generic edit host may transport this value, but it must not infer a
/// kind's canonical identity from a catalog candidate or a browser mode.
final class LibraryCoreCorrectionTarget {
  const LibraryCoreCorrectionTarget({
    required this.scope,
    required this.entityId,
  });

  final LibraryEntityScope scope;
  final String entityId;
}

typedef LibraryCoreCorrectionTargetResolver = LibraryCoreCorrectionTarget
    Function({
  required LibraryEntityRef? node,
  required LibraryEntityScope? requestedScope,
  required CatalogEntityRef catalogRef,
});

/// Structural fallback used by kinds whose Core target is exactly their
/// Work/Release/Copy entity reference. The resolver is still registered by
/// each kind so a kind can replace this policy when its canonical identity
/// differs from the generic structural ref.
LibraryCoreCorrectionTarget resolveStructuralLibraryCoreCorrectionTarget({
  required LibraryEntityRef? node,
  required LibraryEntityScope? requestedScope,
  required CatalogEntityRef catalogRef,
}) {
  if (node case LibraryCopyRef(:final releaseId)) {
    if (releaseId.trim().isEmpty) {
      throw StateError('Copy correction requires a concrete parent Release.');
    }
    return LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.release,
      entityId: releaseId,
    );
  }
  if (node case LibraryReleaseRef(:final releaseId)) {
    if (releaseId.trim().isEmpty) {
      throw StateError('Release correction requires a concrete Release.');
    }
    return LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.release,
      entityId: releaseId,
    );
  }
  if (node case LibraryWorkRef(:final workId)) {
    if (workId.trim().isEmpty) {
      throw StateError('Work correction requires a concrete Work.');
    }
    return LibraryCoreCorrectionTarget(
      scope: LibraryEntityScope.work,
      entityId: workId,
    );
  }

  final scope = requestedScope ?? LibraryEntityScope.work;
  final entityId = switch (scope) {
    LibraryEntityScope.work => (catalogRef.rootId ?? catalogRef.id).trim(),
    LibraryEntityScope.release => catalogRef.id.trim(),
    LibraryEntityScope.copy => '',
  };
  if (entityId.isEmpty) {
    throw StateError(
      'Core correction requires a concrete ${scope.name} entity reference.',
    );
  }
  return LibraryCoreCorrectionTarget(scope: scope, entityId: entityId);
}
