import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book root keeps its cover and contained printing data', () {
    final item = BookCatalogItem(
      id: 'book-1',
      title: 'Example Book',
      catalogMetadata: const BookCatalogMetadata(title: 'Example Book'),
      coverImageUrl: 'https://example.test/book-cover.jpg',
      printings: const [
        BookCatalogPrinting(
          id: 'printing-1',
          printingNumber: 1,
          isbn: '9780000000001',
        ),
      ],
    );

    final dto = BookWorkspaceDto(
      common: WorkspaceCommonProjection(
        title: item.title,
        coverImageUrl: item.coverImageUrl,
      ),
      personal: PersonalCopyProjection(),
      book: item,
    );

    expect(dto.coverImageUrl, 'https://example.test/book-cover.jpg');
    expect(dto.book.printings.single.isbn, '9780000000001');
  });

  test('personal copy projection prefers the typed tracking row rating', () {
    final owned = testCollectionItem(
      id: 'owned-1',
      itemId: 'book-1',
      kind: 'book',
      rating: 3,
    );
    final catalog = testLibraryWorkspaceSource(
      itemId: 'book-1',
      kind: 'book',
      collectionItem: owned,
    );
    final source = LibraryWorkspaceSource(
      itemId: catalog.itemId,
      catalogData: catalog.catalogData,
      collectionItemSummary: testCollectionItemSummary(owned),
      trackingSummary: TrackingSummary(
        id: 'tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'book-1',
        ),
        status: MediaTrackingStatus.inProgress,
        rating: 8,
        updatedAt: DateTime.utc(2026, 1, 2),
        deletedAt: null,
      ),
    );

    expect(PersonalCopyProjection.fromShelf(source).rating, 8);
    expect(
      PersonalCopyProjection.fromShelf(source).trackingStatus,
      'In progress',
    );
  });
}
