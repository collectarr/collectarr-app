import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<BookWorkspaceDto> {
  const BookWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  BookWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    return BookWorkspaceDto(
      common: WorkspaceCommonProjection.fromStructuralShelf(
        source,
        entity,
        overrideTitle: catalog.title,
        overrideSynopsis: catalog.synopsis,
        overrideReleaseDate: catalog.releaseDate,
        overrideCoverImageUrl: catalog.coverImageUrl,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
      book: catalog.book,
      metadata: catalog.metadata,
    );
  }
}

BookWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final BookWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected BookWorkspaceCatalogData for book workspace');
}
