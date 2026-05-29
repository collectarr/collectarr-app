import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores catalog metadata needed for local filters', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.catalogCache).insert(
          CatalogCacheCompanion.insert(
            id: 'comic-1',
            kind: 'comic',
            title: 'Superman, Vol. 4',
            itemNumber: const Value('8A'),
            thumbnailImageUrl:
                const Value('https://cdn.example/superman-thumb.jpg'),
            editionTitle: const Value('Direct market edition'),
            physicalFormat: const Value('single-issue'),
            physicalFormatLabel: const Value('Single Issue'),
            publisher: const Value('DC'),
            releaseDate: Value(DateTime.utc(2016, 10, 5)),
            releaseYear: const Value(2016),
            barcode: const Value('76194134192700811'),
            variant: const Value('Regular Cover'),
            cachedAt: DateTime.utc(2026, 5, 11),
          ),
        );

    final catalog = await db.select(db.catalogCache).getSingle();

    expect(catalog.publisher, 'DC');
    expect(catalog.thumbnailImageUrl, 'https://cdn.example/superman-thumb.jpg');
    expect(catalog.editionTitle, 'Direct market edition');
    expect(catalog.physicalFormat, 'single-issue');
    expect(catalog.physicalFormatLabel, 'Single Issue');
    expect(catalog.releaseDate?.toUtc(), DateTime.utc(2016, 10, 5));
    expect(catalog.releaseYear, 2016);
    expect(catalog.barcode, '76194134192700811');
    expect(catalog.variant, 'Regular Cover');
  });

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
            quantity: const Value(2),
            storageBox: const Value('Box 6'),
            keyComic: const Value(true),
            tags: const Value('signed,key'),
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
    expect(owned.quantity, 2);
    expect(owned.storageBox, 'Box 6');
    expect(owned.keyComic, isTrue);
    expect(owned.tags, 'signed,key');
    expect(wishlist.itemId, 'comic-2');
    expect(wishlist.targetPriceCents, 999);
  });

  test('stores tracking entries separately from owned copies', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.trackingEntriesCache).insert(
          TrackingEntriesCacheCompanion.insert(
            id: 'track-1',
            itemId: 'movie-1',
            sourceType: const Value('digital'),
            status: const Value('Watched'),
            rating: const Value(9),
            startedAt: Value(DateTime.utc(2026, 5, 23, 18)),
            finishedAt: Value(DateTime.utc(2026, 5, 23, 20, 35)),
            timesCompleted: const Value(1),
            notes: const Value('Watched on Plex'),
            updatedAt: DateTime.utc(2026, 5, 23, 20, 35),
          ),
        );

    final tracking = await db.select(db.trackingEntriesCache).getSingle();

    expect(tracking.itemId, 'movie-1');
    expect(tracking.sourceType, 'digital');
    expect(tracking.status, 'Watched');
    expect(tracking.rating, 9);
    expect(tracking.notes, 'Watched on Plex');
  });

  test('owned items repository preserves location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = OwnedItemsCacheRepository(db);

    await repo.upsert(
      OwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        createdAt: DateTime.utc(2026, 5, 21),
        storageBox: 'Short Box 1',
        ownerUserId: 'user-1',
        ownerLabel: 'user@example.com',
        locationId: 'loc-1',
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    );

    final owned = await repo.findById('owned-1');
    final raw = await db.select(db.ownedItemsCache).getSingle();

    expect(owned?.locationId, 'loc-1');
    expect(owned?.createdAt?.toUtc(), DateTime.utc(2026, 5, 21));
    expect(owned?.ownerUserId, 'user-1');
    expect(owned?.ownerLabel, 'user@example.com');
    expect(raw.locationId, 'loc-1');
    expect(raw.createdAt?.toUtc(), DateTime.utc(2026, 5, 21));
    expect(raw.ownerUserId, 'user-1');
    expect(raw.ownerLabel, 'user@example.com');
  });

  test('owned items repository preserves explicit digital flag', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = OwnedItemsCacheRepository(db);

    await repo.upsert(
      OwnedItem(
        id: 'owned-digital-1',
        itemId: 'movie-1',
        isDigital: true,
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    );

    final owned = await repo.findById('owned-digital-1');
    final raw = await db.select(db.ownedItemsCache).getSingle();

    expect(owned?.isDigital, isTrue);
    expect(raw.isDigital, isTrue);
  });

  test('tracking entries repository preserves edition and progress refs', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TrackingEntriesCacheRepository(db);

    await repo.upsert(
      TrackingEntry(
        id: 'track-1',
        itemId: 'music-1',
        editionId: 'edition-cd',
        variantId: 'variant-deluxe',
        sourceType: 'physical',
        status: 'Listened',
        progressCurrent: 10,
        progressTotal: 10,
        timesCompleted: 2,
        updatedAt: DateTime.utc(2026, 5, 23, 22),
      ),
    );

    final tracking = await repo.findById('track-1');
    final raw = await db.select(db.trackingEntriesCache).getSingle();

    expect(tracking?.editionId, 'edition-cd');
    expect(tracking?.variantId, 'variant-deluxe');
    expect(tracking?.timesCompleted, 2);
    expect(raw.progressCurrent, 10);
    expect(raw.progressTotal, 10);
  });

  test('stores pending personal sync changes locally', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);

    await queue.enqueue(
      SyncChange(
        id: 'sync-1',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '9.8'},
        clientChangedAt: DateTime.utc(2026, 5, 11, 10),
      ),
    );

    expect(await queue.pendingCount(), 1);
    final pending = await queue.listPending();
    expect(pending.single.entityType, 'owned_item');
    expect(pending.single.payload['grade'], '9.8');

    await queue.deleteMany(['sync-1']);
    expect(await queue.pendingCount(), 0);
  });

  test('keeps only latest pending sync change per entity', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);

    await queue.enqueue(
      SyncChange(
        id: 'sync-1',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '9.8'},
        clientChangedAt: DateTime.utc(2026, 5, 11, 10),
      ),
    );
    await queue.enqueue(
      SyncChange(
        id: 'sync-2',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '9.6'},
        clientChangedAt: DateTime.utc(2026, 5, 11, 11),
      ),
    );

    expect(await queue.pendingCount(), 1);
    final pending = await queue.listPending();
    expect(pending.single.id, 'sync-2');
    expect(pending.single.payload['grade'], '9.6');
  });

  test('deletes large sync queue batches without exceeding SQLite variables',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);
    final ids = [for (var index = 0; index < 1005; index++) 'sync-$index'];

    for (final id in ids) {
      await queue.enqueue(
        SyncChange(
          id: id,
          entityType: 'owned_item',
          entityId: 'owned-$id',
          action: 'upsert',
          payload: const {'item_id': 'comic-1'},
          clientChangedAt: DateTime.utc(2026, 5, 11),
        ),
      );
    }

    expect(await queue.pendingCount(), 1005);
    await queue.deleteMany(ids);
    expect(await queue.pendingCount(), 0);
  });

  test('catalog cache repository preserves title sort and series tags', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CatalogCacheRepository(db);

    await repo.upsertAll([
      CatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Fellowship of the Ring',
        sortKey: 'lord-of-the-rings-001',
        series: const CatalogSeriesDetails(
          seriesId: 'series-1',
          seriesTitle: 'The Lord of the Rings',
          volumeNumber: 1,
          tags: ['Epic Fantasy', 'Middle-earth'],
        ),
        publishing: const CatalogPublishingDetails(
          subtitle: 'Being the First Part',
        ),
      ),
    ]);

    final item = await repo.findById('book-1');

    expect(item, isA<CatalogItem>());
    expect(item!.sortKey, 'lord-of-the-rings-001');
    expect(item.series?.tags, ['Epic Fantasy', 'Middle-earth']);
    expect(item.publishing?.subtitle, 'Being the First Part');
  });

  test('catalog cache repository preserves editions and variants', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CatalogCacheRepository(db);

    await repo.upsertAll([
      CatalogItem(
        id: 'album-1',
        kind: 'music',
        title: 'The Sacrament of Sin',
        editions: [
          CatalogEdition(
            id: 'edition-deluxe',
            title: 'Deluxe Box',
            variants: [
              CatalogVariant(
                id: 'variant-red',
                name: 'Red Vinyl',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    ]);

    final item = await repo.findById('album-1');

    expect(item?.editions, hasLength(1));
    expect(item?.editions.single.id, 'edition-deluxe');
    expect(item?.editions.single.variants.single.id, 'variant-red');
  });
}
