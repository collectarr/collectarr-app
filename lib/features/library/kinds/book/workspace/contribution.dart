import '../book_module_dependencies.dart';
import '../config/book_kind_capabilities.dart';

final bookKindWorkspace = TypedLibraryKindWorkspace<BookWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<BookWorkspaceDto>(
    fields: bookCatalogItemWorkspaceSchema.toRegistry(),
    projector: const BookWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<BookWorkspaceDto>(
    fields: bookLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const BookWorkspaceProjector(),
  ),
  trackingTopology: bookKindTrackingTopology,
);
