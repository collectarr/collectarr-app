import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('stores catalog metadata needed for local filters', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.catalogCache).insert(
          CatalogCacheCompanion.insert(
            id: 'comic-1',
            kind: 'comic',
            payloadJson: jsonEncode({
              'id': 'comic-1',
              'kind': 'comic',
              'title': 'Superman, Vol. 4',
              'item_number': '8A',
              'thumbnail_image_url': 'https://cdn.example/superman-thumb.jpg',
              'edition_title': 'Direct market edition',
              'physical_format': 'single-issue',
              'physical_format_label': 'Single Issue',
              'publisher': 'DC',
              'release_date': '2016-10-05T00:00:00.000Z',
              'release_year': 2016,
              'barcode': '76194134192700811',
              'variant': 'Regular Cover',
            }),
            cachedAt: DateTime.utc(2026, 5, 11),
          ),
        );

    final catalog = await db.select(db.catalogCache).getSingle();

    final catalogPayload =
        jsonDecode(catalog.payloadJson) as Map<String, dynamic>;
    expect(catalogPayload['publisher'], 'DC');
    expect(catalogPayload['thumbnail_image_url'],
        'https://cdn.example/superman-thumb.jpg');
    expect(catalogPayload['edition_title'], 'Direct market edition');
    expect(catalogPayload['physical_format'], 'single-issue');
    expect(catalogPayload['physical_format_label'], 'Single Issue');
    expect(catalogPayload['release_date'], '2016-10-05T00:00:00.000Z');
    expect(catalogPayload['release_year'], 2016);
    expect(catalogPayload['barcode'], '76194134192700811');
    expect(catalogPayload['variant'], 'Regular Cover');
  });

  test('reports the reset v8 schema version', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 8);
  });

  test('migrates a v7 cache to v8 without losing existing cache rows',
      () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_migrate');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.catalogCache).insert(
          CatalogCacheCompanion.insert(
            id: 'comic-1',
            kind: 'comic',
            payloadJson: jsonEncode({'id': 'comic-1', 'title': 'Preserved'}),
            cachedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await old.customStatement(
      'DROP TABLE ${old.providerAccountsCache.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.providerItemLinksCache.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 7');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final catalog = await db.select(db.catalogCache).getSingle();
    expect(catalog.id, 'comic-1');
    final payload = jsonDecode(catalog.payloadJson) as Map<String, dynamic>;
    expect(payload['title'], 'Preserved');
    expect(await db.select(db.providerAccountsCache).get(), isEmpty);
    expect(await db.select(db.providerItemLinksCache).get(), isEmpty);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 8);
  });

  test('destructively rebuilds a higher-versioned cache to the v8 schema',
      () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_reset');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    // Simulate a cache created by an older build: a populated table plus a
    // higher on-disk schema version that Drift will not run onUpgrade for.
    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.catalogCache).insert(
          CatalogCacheCompanion.insert(
            id: 'comic-1',
            kind: 'comic',
            payloadJson: jsonEncode({
              'id': 'comic-1',
              'kind': 'comic',
              'title': 'Stale Cached Title',
            }),
            cachedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await old.customStatement('PRAGMA user_version = 13');
    await old.close();

    // Reopening with the reset schema version must wipe and recreate the cache.
    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final rows = await db.select(db.catalogCache).get();
    expect(rows, isEmpty, reason: 'destructive rebuild should clear the cache');

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 8);
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
            locationId: const Value('loc-box-6'),
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
    expect(owned.locationId, 'loc-box-6');
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
      testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        catalogRef: CatalogEntityRef(
          kind: 'comic',
          entityType: CatalogEntityType.work,
          id: 'comic-1',
        ),
        createdAt: DateTime.utc(2026, 5, 21),
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
      testOwnedItem(
        id: 'owned-digital-1',
        itemId: 'movie-1',
        catalogRef: CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.work,
          id: 'movie-1',
        ),
        isDigital: true,
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    );

    final owned = await repo.findById('owned-digital-1');
    final raw = await db.select(db.ownedItemsCache).getSingle();

    expect(owned?.isDigital, isTrue);
    expect(raw.isDigital, isTrue);
  });

  test('tracking entries repository preserves edition and progress refs',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TrackingEntriesCacheRepository(db);

    await repo.upsert(
      TrackingEntry(
        id: 'track-1',
        catalogRef: testCatalogRef('music-1', kind: 'music'),
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

  test('catalog cache repository preserves title sort and series tags',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CatalogCacheRepository(db);

    await repo.upsertMetadataItems([
      LibraryMetadataItem.fromMetadataMap({
        'id': 'book-1',
        'kind': 'book',
        'title': 'The Fellowship of the Ring',
        'sort_key': 'lord-of-the-rings-001',
        'series': {
          'series_id': 'series-1',
          'series_title': 'The Lord of the Rings',
          'volume_number': '1',
          'tags': 'Epic Fantasy, Middle-earth',
        },
        'publishing': {
          'subtitle': 'Being the First Part',
        },
      }),
    ]);

    final item = await repo.findById('book-1');

    expect(item, isA<CatalogItem>());
    expect(item!.sortKey, 'lord-of-the-rings-001');
    final seriesMap =
        item.payload['series'] is Map ? item.payload['series'] as Map : null;
    expect(seriesMap?['tags'], 'Epic Fantasy, Middle-earth');
    final pubMap = item.payload['publishing'] is Map
        ? item.payload['publishing'] as Map
        : null;
    expect(pubMap?['subtitle'], 'Being the First Part');
  });

  test('catalog cache repository preserves editions and variants', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CatalogCacheRepository(db);

    await repo.upsertMetadataItems([
      LibraryMetadataItem.fromMetadataMap({
        'id': 'album-1',
        'kind': 'music',
        'title': 'The Sacrament of Sin',
        'editions': [
          {
            'id': 'edition-deluxe',
            'title': 'Deluxe Box',
            'variants': [
              {
                'id': 'variant-red',
                'name': 'Red Vinyl',
                'is_primary': true,
              },
            ],
          },
        ],
      }),
    ]);

    final item = await repo.findById('album-1');

    expect(item?.editions, hasLength(1));
    expect(item?.editions.single.id, 'edition-deluxe');
    expect(item?.editions.single.variants.single.id, 'variant-red');
  });
}
