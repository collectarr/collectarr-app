import '../book_module_dependencies.dart';
import '../config/book_kind_capabilities.dart';

final bookKindWorkspace = TypedLibraryKindWorkspace<BookWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: bookCatalogItemWorkspaceSchema.toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: bookLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: bookKindHierarchy,
  trackingTopology: bookKindTrackingTopology,
);
