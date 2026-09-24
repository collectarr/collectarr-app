import '../manga_module_dependencies.dart';
import '../config/manga_kind_capabilities.dart';

final mangaKindWorkspace = TypedLibraryKindWorkspace<MangaWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: mangaWorkWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: mangaReleaseWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: mangaCopyWorkspaceSchema.toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: mangaKindHierarchy,
  trackingTopology: mangaKindTrackingTopology,
);
