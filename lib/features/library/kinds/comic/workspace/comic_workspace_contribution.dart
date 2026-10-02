import '../comic_module_dependencies.dart';
import '../config/comic_kind_capabilities.dart';

final comicKindWorkspace = TypedLibraryKindWorkspace<ComicWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: comicCatalogItemWorkspaceSchema.toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: comicCopyWorkspaceSchema.toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: comicKindHierarchy,
  trackingTopology: comicKindTrackingTopology,
);
