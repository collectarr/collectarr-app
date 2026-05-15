import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
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

  test('collection mutations enqueue catalog snapshots from cache', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogCacheRepository(db).upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Absolute Batman',
        itemNumber: '1',
        coverImageUrl: 'https://cdn.example/absolute.jpg',
        thumbnailImageUrl: 'https://cdn.example/absolute-thumb.jpg',
        publisher: 'DC',
        releaseYear: 2024,
      ),
    ]);

    await container.read(collectionMutationsProvider).addItem('comic-1');

    final queued = await db.select(db.syncQueue).get();
    final snapshot =
        queued.where((row) => row.entityType == 'library_item_snapshot').single;
    expect(queued, hasLength(2));
    expect(snapshot.entityId, 'comic-1');
    expect(snapshot.payloadJson, contains('Absolute Batman'));
    expect(snapshot.payloadJson, contains('https://cdn.example/absolute.jpg'));
    expect(snapshot.payloadJson,
        contains('https://cdn.example/absolute-thumb.jpg'));
    expect(container.read(syncControllerProvider).pendingCount, 2);
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

  test('collection import resolves clz rows from local catalog cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogCacheRepository(db).upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '75960604716152011',
      ),
    ]);

    final imported =
        await container.read(collectionMutationsProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: '',
          status: 'owned',
          title: 'Different title from CSV',
          itemNumber: '520',
          barcode: '75960604716152011',
          grade: '7.5',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 1);
    expect(owned.itemId, 'comic-1');
    expect(owned.grade, '7.5');
    expect(
      queued.where((row) => row.entityType == 'library_item_snapshot'),
      hasLength(1),
    );
  });

  test('collection import uses media type when matching local catalog cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogCacheRepository(db).upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Dune',
        barcode: '1234567890',
      ),
      CatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Dune',
        barcode: '1234567890',
      ),
    ]);

    final imported =
        await container.read(collectionMutationsProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: '',
          kind: 'movie',
          status: 'owned',
          title: 'Dune',
          barcode: '1234567890',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    expect(imported, 1);
    expect(owned.itemId, 'movie-1');
  });

  test('collection import preview reports matched unresolved and skipped rows',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogCacheRepository(db).upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '75960604716152011',
      ),
    ]);

    final preview =
        await container.read(collectionMutationsProvider).previewImportRows(
      const [
        CollectionCsvRow(
          itemId: '',
          status: 'owned',
          title: 'The Amazing Spider-Man, Vol. 2',
          itemNumber: '520',
        ),
        CollectionCsvRow(
          itemId: '',
          status: 'owned',
          title: 'Unknown Series',
          itemNumber: '1',
        ),
        CollectionCsvRow(itemId: '', status: ''),
      ],
    );

    expect(preview.totalRows, 3);
    expect(preview.resolvedCount, 1);
    expect(preview.unresolvedCount, 1);
    expect(preview.skippedCount, 1);
    expect(preview.resolvedRows.single.itemId, 'comic-1');
  });

  test('collection import preview skips duplicate csv targets', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final mutations = container.read(collectionMutationsProvider);
    final preview = await mutations.previewImportRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '9.8',
        ),
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '7.5',
        ),
      ],
    );

    expect(preview.resolvedCount, 1);
    expect(preview.duplicateCount, 1);
    expect(preview.duplicateRows.single.grade, '7.5');
    expect(preview.reviewCount, 1);

    final imported = await mutations.importRows(preview.resolvedRows);
    final owned = await db.select(db.ownedItemsCache).get();
    expect(imported, 1);
    expect(owned, hasLength(1));
    expect(owned.single.grade, '9.8');
  });

  test('collection import preview reports existing owned conflicts', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final mutations = container.read(collectionMutationsProvider);

    await mutations.addItem('comic-1', grade: '4.0');

    final preview = await mutations.previewImportRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '7.5',
        ),
      ],
    );

    expect(preview.resolvedCount, 0);
    expect(preview.conflictCount, 1);
    expect(preview.conflictRows.single.itemId, 'comic-1');
  });

  test('collection import updates existing owned conflict without duplicate',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final mutations = container.read(collectionMutationsProvider);

    await mutations.addItem('comic-1', condition: 'Good', grade: '4.0');
    final original = await db.select(db.ownedItemsCache).getSingle();

    final imported = await mutations.importRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '7.5',
          storageBox: 'Box 6',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).get();
    expect(imported, 1);
    expect(owned, hasLength(1));
    expect(owned.single.id, original.id);
    expect(owned.single.condition, 'Good');
    expect(owned.single.grade, '7.5');
    expect(owned.single.storageBox, 'Box 6');
  });
}
