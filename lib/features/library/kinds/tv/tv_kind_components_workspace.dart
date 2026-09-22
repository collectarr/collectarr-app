import 'tv_module_dependencies.dart';
import 'tv_kind_components_capabilities.dart';

final tvKindWorkspace = TypedLibraryKindWorkspace<TvWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: tvLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: tvLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: TvSortIds.releaseDate,
            defaultGroup: TvGroupIds.releaseYear,
          )
          .toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: tvLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: TvSortIds.status,
            defaultGroup: TvGroupIds.condition,
          )
          .toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: tvKindHierarchy,
  trackingTopology: tvKindTrackingTopology,
);
