import '../boardgame_module_dependencies.dart';
import '../config/boardgame_kind_capabilities.dart';

final boardGameKindWorkspace = TypedLibraryKindWorkspace<BoardGameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: boardgameCatalogItemWorkspaceSchema.toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: boardgameLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: boardGameKindHierarchy,
  trackingTopology: boardGameKindTrackingTopology,
);
