import '../book_module_dependencies.dart';
import '../config/book_kind_capabilities.dart';

final bookKindWorkspace = TypedLibraryKindWorkspace<BookWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: bookCatalogItemWorkspaceSchema.toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: bookCopyWorkspaceSchema.toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: bookKindHierarchy,
  trackingTopology: bookKindTrackingTopology,
);
