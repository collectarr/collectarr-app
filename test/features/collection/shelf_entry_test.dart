import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/test/helpers/test_owned_details.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  group('ShelfEntry Canonical Source Tests', () {
    test('ShelfEntry delegates personal collection fields cleanly', () {
      final now = DateTime.now();
      final owned = testOwnedItem(
        id: 'owned_1',
        catalogRef: const CatalogEntityRef(
          id: 'cat_1',
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
        ),
        condition: 'Near Mint',
        grade: '9.8',
        pricePaidCents: 1500,
        marketValueCents: 4500,
        currency: 'USD',
        purchaseStore: 'Midtown Comics',
        purchaseDate: now,
        personalNotes: 'First printing signed by author',
        tags: 'signed, key',
        ownerLabel: 'Alice',
        quantity: 2,
        createdAt: now,
        updatedAt: now,
      );

      final entry = ShelfEntry(
        itemId: 'cat_1',
        ownedSummary: testOwnedItemSummary(owned),
        locationPath: 'Box A / Row 1',
      );

      expect(entry.isOwned, isTrue);
      expect(entry.isWishlisted, isFalse);
      expect(entry.ownedSummary?.collectionValue, '9.8');
      expect(entry.pricePaidCents, 1500);
      expect(entry.marketValueCents, 4500);
      expect(entry.currency, 'USD');
      expect(entry.purchaseStore, 'Midtown Comics');
      expect(entry.purchaseDate, now);
      expect(entry.personalNotes, 'First printing signed by author');
      expect(entry.ownerLabel, 'Alice');
      expect(entry.quantity, 2);
      expect(entry.locationPath, 'Box A / Row 1');
    });

    test('ShelfEntry handles unowned / wishlisted items safely', () {
      final now = DateTime.now();
      final wishlist = WishlistItem(
        id: 'wish_1',
        catalogRef: const CatalogEntityRef(
          id: 'cat_2',
          kind: CatalogMediaKind.movie,
          entityType: const CatalogEntityTypeId('work'),
        ),
        notes: 'Looking for 4K edition',
        createdAt: now,
        updatedAt: now,
      );

      final entry = ShelfEntry(
        itemId: 'cat_2',
        wishlistItem: wishlist,
        fallbackOwnerLabel: 'Bob',
      );

      expect(entry.isOwned, isFalse);
      expect(entry.isWishlisted, isTrue);
      expect(entry.ownedSummary, isNull);
      expect(entry.pricePaidCents, isNull);
      expect(entry.ownerLabel, 'Bob');
      expect(entry.quantity, 0);
      expect(entry.hasNotes, isTrue);
    });
  });
}
