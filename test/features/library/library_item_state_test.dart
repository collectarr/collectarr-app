import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('library entry resolves combined owned and wishlist state', () {
    final item = CatalogItem(id: 'comic-1', kind: 'comic', title: 'Comic');
    final owned = testOwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      updatedAt: DateTime.utc(2026),
    );
    final wishlist = WishlistItem(
      id: 'wishlist-1',
      catalogRef: testCatalogRef('comic-1', kind: 'comic'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final entry = LibraryEntry(
      itemId: item.id,
      catalogItem: item,
      ownedItem: owned,
      wishlistItem: wishlist,
    );

    expect(entry.isOwned, isTrue);
    expect(entry.isWishlisted, isTrue);
    expect(entry.ownedItem, owned);
    expect(entry.wishlistItem, wishlist);
    expect(entry.subtitle, 'Owned and wishlisted');
  });

  test('library entry exposes tracking-only rows', () {
    final item = CatalogItem(id: 'comic-2', kind: 'comic', title: 'Comic 2');
    final entry = LibraryEntry(itemId: item.id, catalogItem: item);

    expect(entry.isOwned, isFalse);
    expect(entry.isWishlisted, isFalse);
    expect(entry.isTracked, isFalse);
    expect(entry.title, 'Comic 2');
  });
}
