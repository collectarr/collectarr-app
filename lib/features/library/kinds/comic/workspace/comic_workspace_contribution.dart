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
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<ComicWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: comicLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const ComicWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: comicKindHierarchy,
  trackingTopology: comicKindTrackingTopology,
);
