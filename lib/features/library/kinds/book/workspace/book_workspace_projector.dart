import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<BookWorkspaceDto> {
  const BookWorkspaceProjector();

  @override
  BookWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    return BookWorkspaceDto(
      common: _bookCommonProjection(source, entity, catalog.book),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
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

WorkspaceCommonProjection _bookCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  BookCatalogItem book,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: book.title,
    overrideSynopsis: book.synopsis,
    overrideReleaseDate: book.releaseDate,
    overrideCoverImageUrl: book.coverImageUrl,
  );
}
