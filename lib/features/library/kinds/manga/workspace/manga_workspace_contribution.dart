import '../manga_module_dependencies.dart';
import '../config/manga_kind_capabilities.dart';

final mangaKindWorkspace = TypedLibraryKindWorkspace<MangaWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: mangaCatalogItemWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: mangaLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: mangaKindHierarchy,
  trackingTopology: mangaKindTrackingTopology,
);
