import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book media falls back to primary release cover and reference ids', () {
    final item = BookCatalogItem(
      id: 'book-1',
      work: const BookWorkMetadata(title: 'Example Book'),
      publishing: const BookPublishingMetadata(),
      releases: [
        BookRelease(
          id: 'edition-1',
          title: 'Hardcover',
          variants: [
            BookVariantRef(
              id: 'variant-1',
              name: 'Hardcover',
              coverImageUrl: 'https://example.test/release-cover.jpg',
              isPrimary: true,
            ),
          ],
        ),
      ],
    );

    final dto = BookWorkspaceDto(
      common: WorkspaceCommonProjection(
        title: item.work.title,
        coverImageUrl:
            item.releases.firstOrNull?.variants.firstOrNull?.coverImageUrl,
      ),
      personal: PersonalCopyProjection(),
      book: item,
    );

    expect(dto.coverImageUrl, 'https://example.test/release-cover.jpg');
    expect(dto.book.releases, hasLength(1));
  });

  test('personal copy projection prefers the typed tracking row rating', () {
    final owned = testOwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      kind: 'book',
      rating: 3,
    );
    final catalog = testShelfEntry(
      itemId: 'book-1',
      kind: 'book',
      ownedItem: owned,
    );
    final source = ShelfEntry(
      itemId: catalog.itemId,
      catalogItem: catalog.catalogItem,
      ownedItem: owned,
      trackingEntry: TrackingEntry(
        id: 'tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: 'book',
          entityType: CatalogEntityType.work,
          id: 'book-1',
        ),
        rating: 8,
        updatedAt: DateTime.utc(2026, 1, 2),
        deletedAt: null,
      ),
    );

    expect(PersonalCopyProjection.fromShelf(source).rating, 8);
  });
}
