import 'book_module_dependencies.dart';
import 'book_kind_components_capabilities.dart';

final bookKindWorkspace = TypedLibraryKindWorkspace<BookWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: bookLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: bookLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: BookSortIds.releaseDate,
            defaultGroup: BookGroupIds.publisher,
          )
          .toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<BookWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: bookLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: BookSortIds.status,
            defaultGroup: BookGroupIds.condition,
          )
          .toRegistry(),
      projector: const BookWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: bookKindHierarchy,
  trackingTopology: bookKindTrackingTopology,
);
