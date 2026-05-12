import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shelf state combines owned and wishlist records', () {
    final state = ShelfState.from(
      ownedItems: [
        OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          condition: 'Near Mint',
          grade: '9.8',
          pricePaidCents: 1200,
          currency: 'USD',
          updatedAt: DateTime.utc(2026, 5, 11),
        ),
        OwnedItem(
          id: 'owned-2',
          itemId: 'comic-2',
          condition: 'Fine',
          pricePaidCents: 800,
          currency: 'USD',
          updatedAt: DateTime.utc(2026, 5, 10),
        ),
      ],
      wishlistItems: [
        WishlistItem(
          id: 'wish-1',
          itemId: 'comic-3',
          createdAt: DateTime.utc(2026, 5, 9),
          updatedAt: DateTime.utc(2026, 5, 9),
        ),
      ],
      catalogItems: const {
        'comic-1': CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Saga',
          itemNumber: '1',
        ),
      },
    );

    expect(state.ownedCount, 2);
    expect(state.wishlistCount, 1);
    expect(state.missingGradeCount, 1);
    expect(state.totalPaidCents, 2000);
    expect(state.primaryCurrency, 'USD');
    expect(state.missingMetadataCount, 2);
    expect(state.gradeCounts, {'9.8': 1, 'Ungraded': 1});
    expect(state.conditionCounts, {'Near Mint': 1, 'Fine': 1});
    expect(state.entries.first.title, 'Saga #1');
  });
}
