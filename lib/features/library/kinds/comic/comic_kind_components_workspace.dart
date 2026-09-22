import 'comic_module_dependencies.dart';
import 'comic_kind_components_capabilities.dart';

final comicKindWorkspace = TypedLibraryKindWorkspace<ComicWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: comicLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: comicLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: ComicSortIds.releaseDate,
            defaultGroup: ComicGroupIds.publisher,
          )
          .toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: comicLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: ComicSortIds.status,
            defaultGroup: ComicGroupIds.condition,
          )
          .toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: comicKindHierarchy,
  trackingTopology: comicKindTrackingTopology,
);
