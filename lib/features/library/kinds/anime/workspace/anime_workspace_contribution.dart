import '../anime_module_dependencies.dart';
import '../config/anime_kind_capabilities.dart';

final animeKindWorkspace = TypedLibraryKindWorkspace<AnimeWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: animeCatalogItemWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: animeLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: animeKindHierarchy,
  trackingTopology: animeKindTrackingTopology,
);
