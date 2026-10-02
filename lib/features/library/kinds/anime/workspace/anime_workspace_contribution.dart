import '../anime_module_dependencies.dart';
import '../config/anime_kind_capabilities.dart';

final animeKindWorkspace = TypedLibraryKindWorkspace<AnimeWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: animeWorkWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: animeCopyWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: animeKindHierarchy,
  trackingTopology: animeKindTrackingTopology,
);
