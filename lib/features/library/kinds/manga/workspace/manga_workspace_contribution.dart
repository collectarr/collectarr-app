import '../manga_module_dependencies.dart';
import '../config/manga_kind_capabilities.dart';

final mangaKindWorkspace = TypedLibraryKindWorkspace<MangaWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: mangaWorkWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: mangaCopyWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: mangaKindHierarchy,
  trackingTopology: mangaKindTrackingTopology,
);
