import '../tv_module_dependencies.dart';
import '../config/tv_kind_capabilities.dart';

final tvKindWorkspace = TypedLibraryKindWorkspace<TvWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: tvWorkWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: tvReleaseWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: tvCopyWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: tvKindHierarchy,
  trackingTopology: tvKindTrackingTopology,
);
