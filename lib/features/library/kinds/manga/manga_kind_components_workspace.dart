part of 'manga_kind_components.dart';

final mangaKindWorkspace = TypedLibraryKindWorkspace<MangaWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: mangaLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: mangaLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: MangaSortIds.releaseDate,
            defaultGroup: MangaGroupIds.publisher,
          )
          .toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<MangaWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: mangaLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: MangaSortIds.status,
            defaultGroup: MangaGroupIds.condition,
          )
          .toRegistry(),
      projector: const MangaWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: mangaKindHierarchy,
  trackingTopology: mangaKindTrackingTopology,
);
