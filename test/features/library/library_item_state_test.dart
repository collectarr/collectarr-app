import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library item state resolves owned and wishlist status', () {
    const item = CatalogItem(id: 'comic-1', kind: 'comic', title: 'Comic');
    final owned = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      updatedAt: DateTime.utc(2026),
    );

    final state = libraryItemStateFor(
      item: item,
      ownedByItemId: {'comic-1': owned},
      wishlistIds: {'comic-1'},
    );

    expect(state.isOwned, isTrue);
    expect(state.isWishlisted, isTrue);
    expect(state.ownedItem, owned);
    expect(state.statusLabel, 'Owned + Wishlist');
  });

  test('library item state handles empty library rows', () {
    const state = LibraryItemState();

    expect(state.isOwned, isFalse);
    expect(state.isWishlisted, isFalse);
    expect(state.statusLabel, 'Not in library');
  });
}
