import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_csv.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection mutations enqueue personal sync changes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(collectionMutationsProvider).addItem(
          'comic-1',
          editionId: 'edition-1',
          variantId: 'variant-1',
          condition: 'Near Mint',
          grade: '9.8',
        );

    final queued = await db.select(db.syncQueue).get();
    final owned = await db.select(db.ownedItemsCache).getSingle();
    expect(owned.editionId, 'edition-1');
    expect(owned.variantId, 'variant-1');
    expect(queued, hasLength(1));
    expect(queued.single.entityType, 'owned_item');
    expect(queued.single.action, 'upsert');
    expect(container.read(syncControllerProvider).pendingCount, 1);
  });

  test('collection updates can clear nullable personal details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(collectionMutationsProvider).addItem(
          'comic-1',
          condition: 'Near Mint',
          grade: '9.8',
          purchaseDate: DateTime.utc(2026, 5, 10),
          pricePaidCents: 1299,
          currency: 'USD',
          personalNotes: 'Signed copy',
        );
    final original = await db.select(db.ownedItemsCache).getSingle();

    await container.read(collectionMutationsProvider).updateItem(
          OwnedItem(
            id: original.id,
            itemId: original.itemId,
            condition: original.condition,
            grade: original.grade,
            purchaseDate: original.purchaseDate,
            pricePaidCents: original.pricePaidCents,
            currency: original.currency,
            personalNotes: original.personalNotes,
            updatedAt: original.updatedAt,
          ),
          condition: 'Near Mint',
          grade: '9.8',
        );

    final updated = await db.select(db.ownedItemsCache).getSingle();
    expect(updated.purchaseDate, isNull);
    expect(updated.pricePaidCents, isNull);
    expect(updated.currency, isNull);
    expect(updated.personalNotes, isNull);
  });

  test('collection import enqueues rows and refreshes pending count once',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionMutationsProvider).importRows(
      [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          condition: 'Near Mint',
          grade: '9.8',
          pricePaidCents: 1299,
          currency: 'USD',
        ),
        const CollectionCsvRow(itemId: 'comic-2', status: 'wishlist'),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 2);
    expect(owned, hasLength(1));
    expect(wishlist, hasLength(1));
    expect(queued, hasLength(2));
    expect(container.read(syncControllerProvider).pendingCount, 2);
  });

  test('collection import moves existing wishlist rows to owned in one batch',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final mutations = container.read(collectionMutationsProvider);

    await mutations.addToWishlist('comic-1');
    await mutations.importRows([
      const CollectionCsvRow(itemId: 'comic-1', status: 'owned'),
    ]);

    final owned = await db.select(db.ownedItemsCache).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();

    expect(owned, hasLength(1));
    expect(wishlist.single.deletedAt, isNotNull);
    expect(queued, hasLength(2));
    expect(
        queued.where((row) => row.entityType == 'wishlist_item').single.action,
        'delete');
  });
}
