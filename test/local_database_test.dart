import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores personal collection and wishlist data locally', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'comic-1',
            condition: const Value('Near Mint'),
            grade: const Value('9.8'),
            purchaseDate: Value(DateTime.utc(2026, 5, 11)),
            pricePaidCents: const Value(1299),
            currency: const Value('USD'),
            updatedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await db.into(db.wishlistItemsCache).insert(
          WishlistItemsCacheCompanion.insert(
            id: 'wish-1',
            itemId: 'comic-2',
            targetPriceCents: const Value(999),
            currency: const Value('USD'),
            createdAt: DateTime.utc(2026, 5, 11),
            updatedAt: DateTime.utc(2026, 5, 11),
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final wishlist = await db.select(db.wishlistItemsCache).getSingle();

    expect(owned.itemId, 'comic-1');
    expect(owned.purchaseDate?.toUtc(), DateTime.utc(2026, 5, 11));
    expect(owned.pricePaidCents, 1299);
    expect(wishlist.itemId, 'comic-2');
    expect(wishlist.targetPriceCents, 999);
  });
}
