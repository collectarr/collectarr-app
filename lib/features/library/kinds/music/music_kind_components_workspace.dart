part of 'music_kind_components.dart';

final musicKindWorkspace = TypedLibraryKindWorkspace<MusicWorkspaceProjection>(
  entityWorkspaces: {
    LibraryEntityScope.work:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.work,
      fields: musicReleaseGroupWorkspaceSchema.toRegistry(),
      projector: const MusicReleaseGroupWorkspaceProjector(),
    ),
    LibraryEntityScope.release:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.release,
      fields: musicReleaseWorkspaceSchema.toRegistry(),
      projector: const MusicReleaseWorkspaceProjector(),
    ),
    LibraryEntityScope.copy:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.copy,
      fields: musicOwnedCopyWorkspaceSchema.toRegistry(),
      projector: const MusicOwnedCopyWorkspaceProjector(),
    ),
  },
  hierarchy: musicKindHierarchy,
  trackingTopology: musicKindTrackingTopology,
  trackingTargetResolver: (node, rootRef) => switch (node) {
    LibraryReleaseRef(:final releaseId) => musicReleaseRefForRoot(
        rootRef,
        releaseId,
      ),
    _ => rootRef,
  },
);
