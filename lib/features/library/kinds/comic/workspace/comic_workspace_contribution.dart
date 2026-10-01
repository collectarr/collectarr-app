import '../comic_module_dependencies.dart';
import '../config/comic_kind_capabilities.dart';

final comicKindWorkspace = TypedLibraryKindWorkspace<ComicWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: comicCatalogItemWorkspaceSchema.toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: comicCopyWorkspaceSchema.toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: comicKindHierarchy,
  trackingTopology: comicKindTrackingTopology,
);
