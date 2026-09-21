import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
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
    requireEntityBelongsToSource(source, entity);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog.book, entity);
    return BookWorkspaceDto(
      common: _bookCommonProjection(source, entity, catalog.book, release),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      book: catalog.book,
      release: release,
      metadata: catalog.metadata,
    );
  }
}

BookRelease? _releaseForEntity(
  BookCatalogItem book,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in book.releases) {
    if (release.id == releaseId) return release;
  }
  throw StateError(
    'Book release "$releaseId" is not present in the canonical work graph',
  );
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
  BookRelease? release,
) {
  final selected = release ?? book.primaryRelease;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: release?.title ?? book.title,
    overrideSynopsis: release?.description ?? book.synopsis,
    overrideReleaseDate:
        selected?.releaseDate ?? book.work.originalPublicationDate,
    overrideCoverImageUrl: selected?.coverImageUrl ?? book.coverImageUrl,
  );
}
