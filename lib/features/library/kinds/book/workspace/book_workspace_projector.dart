import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceProjector
    implements LibraryWorkspaceProjector<BookWorkspaceDto> {
  const BookWorkspaceProjector();

  @override
  BookWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return BookWorkspaceDto(
      common: _bookCommonProjection(source, node, catalog.book),
      personal: PersonalCopyProjection.fromShelf(source),
      book: catalog.book,
      metadata: catalog.metadata,
    );
  }

  @override
  BookWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final catalog = _catalogFor(source);
    return BookWorkspaceDto(
      common: _bookCommonProjection(source, node, catalog.book),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      book: catalog.book,
      metadata: catalog.metadata,
    );
  }

  @override
  BookWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}

BookWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final BookWorkspaceCatalogData catalog) return catalog;
  final transport = source.catalogTransport;
  if (transport != null) {
    return BookWorkspaceCatalogData.fromTransport(
      transport.mapTransport((item) => item),
    );
  }
  throw StateError('Expected BookWorkspaceCatalogData for book workspace');
}

WorkspaceCommonProjection _bookCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
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
