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
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: bookCopyWorkspaceSchema.toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: bookKindHierarchy,
  trackingTopology: bookKindTrackingTopology,
);
