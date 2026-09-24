import '../anime_module_dependencies.dart';
import '../config/anime_kind_capabilities.dart';

final animeKindWorkspace = TypedLibraryKindWorkspace<AnimeWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: animeWorkWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: animeReleaseWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: animeCopyWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: animeKindHierarchy,
  trackingTopology: animeKindTrackingTopology,
);
