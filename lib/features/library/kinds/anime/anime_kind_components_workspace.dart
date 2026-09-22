import 'anime_module_dependencies.dart';
import 'anime_kind_components_capabilities.dart';

final animeKindWorkspace = TypedLibraryKindWorkspace<AnimeWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: animeLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: animeLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: AnimeSortIds.releaseDate,
            defaultGroup: AnimeGroupIds.releaseYear,
          )
          .toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<AnimeWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: animeLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: AnimeSortIds.status,
            defaultGroup: AnimeGroupIds.condition,
          )
          .toRegistry(),
      projector: const AnimeWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: animeKindHierarchy,
  trackingTopology: animeKindTrackingTopology,
);
