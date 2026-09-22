import '../music_module_dependencies.dart';
import '../config/music_kind_capabilities.dart';

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
