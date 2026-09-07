import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('library entry resolves combined owned and wishlist state', () {
    final wishlist = WishlistItem(
      id: 'wishlist-1',
      catalogRef: testCatalogRef('comic-1', kind: 'comic'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final entry = LibraryEntry(
      itemId: 'comic-1',
      catalogSummary: CatalogDisplaySummary.work(
        kind: CatalogMediaKind.comic,
        id: 'comic-1',
        title: 'Comic',
      ),
      ownedSummary: OwnedItemSummary(
        ref: OwnedItemRef(
          kind: CatalogMediaKind.comic,
          id: OwnedItemId('owned-1'),
        ),
        title: 'Comic',
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
      ),
      wishlistItem: wishlist,
    );

    expect(entry.isOwned, isTrue);
    expect(entry.isWishlisted, isTrue);
    expect(entry.ownedSummary?.ref.id.value, 'owned-1');
    expect(entry.wishlistItem, wishlist);
    expect(entry.subtitle, 'Owned and wishlisted');
  });

  test('library entry exposes catalog-only rows', () {
    final entry = LibraryEntry(
      itemId: 'comic-2',
      catalogSummary: CatalogDisplaySummary.work(
        kind: CatalogMediaKind.comic,
        id: 'comic-2',
        title: 'Comic 2',
      ),
    );

    expect(entry.isOwned, isFalse);
    expect(entry.isWishlisted, isFalse);
    expect(entry.isTracked, isFalse);
    expect(entry.title, 'Comic 2');
  });
}
