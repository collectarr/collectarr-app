import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library projection prefers structured location path', () {
    final projection = LibraryProjectionItem.fromShelf(
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Batman',
        ),
        ownedItem: OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          locationId: 'loc-1',
          personalNotes: 'Newsstand copy',
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CGC',
          keyComic: true,
          keyReason: 'First appearance',
          updatedAt: DateTime.utc(2026, 5, 22),
        ),
        locationPath: 'Office › Shelf 2 › Short Box 1',
      ),
      comicsLibraryConfig,
    );

    expect(projection.entry.locationPath, 'Office › Shelf 2 › Short Box 1');
    expect(projection.entry.comic?.rawOrSlabbed, 'Slabbed');
    expect(projection.entry.comic?.gradingCompany, 'CGC');
    expect(projection.entry.comic?.keyComic, isTrue);
    expect(projection.entry.comic?.keyReason, 'First appearance');
    expect(projection.entry.notes, 'Newsstand copy');
  });

  test('library projection exposes bundle and release reference labels', () {
    final bundleProjection = LibraryProjectionItem.fromShelf(
      ShelfEntry(
        itemId: 'comic-2',
        catalogItem: CatalogItem(
          id: 'comic-2',
          kind: 'comic',
          title: 'Batman',
        ),
        ownedItem: OwnedItem(
          id: 'owned-2',
          itemId: 'comic-2',
          anchorType: 'bundle_release',
          bundleReleaseId: 'bundle-2',
          updatedAt: DateTime.utc(2026, 5, 23),
        ),
      ),
      comicsLibraryConfig,
    );
    final wishlistProjection = LibraryProjectionItem.fromShelf(
      ShelfEntry(
        itemId: 'comic-3',
        catalogItem: CatalogItem(
          id: 'comic-3',
          kind: 'comic',
          title: 'Detective Comics',
        ),
        wishlistItem: WishlistItem(
          id: 'wish-3',
          itemId: 'comic-3',
          anchorType: 'variant',
          editionId: 'edition-3',
          variantId: 'variant-3',
          createdAt: DateTime.utc(2026, 5, 23),
          updatedAt: DateTime.utc(2026, 5, 23),
        ),
      ),
      comicsLibraryConfig,
    );

    expect(bundleProjection.entry.primaryReferenceLabel, 'Owned as bundle');
    expect(
      wishlistProjection.entry.primaryReferenceLabel,
      'Wishlisted as physical release',
    );
  });
}