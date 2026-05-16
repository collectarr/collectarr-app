import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

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

  test(
      'adds catalog snapshot columns for existing schema version one databases',
      () async {
    final rawDb = sqlite3.sqlite3.openInMemory();
    rawDb.execute('''
      CREATE TABLE catalog_cache (
        id TEXT NOT NULL PRIMARY KEY,
        kind TEXT NOT NULL,
        title TEXT NOT NULL,
        item_number TEXT NULL,
        synopsis TEXT NULL,
        cover_image_url TEXT NULL,
        publisher TEXT NULL,
        release_date INTEGER NULL,
        release_year INTEGER NULL,
        barcode TEXT NULL,
        variant TEXT NULL,
        cached_at INTEGER NOT NULL
      );
      PRAGMA user_version = 1;
    ''');
    final db = LocalDatabase(
      NativeDatabase.opened(rawDb, closeUnderlyingOnClose: true),
    );
    addTearDown(db.close);

    await db.into(db.catalogCache).insert(
          CatalogCacheCompanion.insert(
            id: 'comic-1',
            kind: 'comic',
            title: 'Superman, Vol. 4',
            thumbnailImageUrl:
                const Value('https://cdn.example/superman-thumb.jpg'),
            editionTitle: const Value('Direct market edition'),
            physicalFormat: const Value('single-issue'),
            physicalFormatLabel: const Value('Single Issue'),
            cachedAt: DateTime.utc(2026, 5, 11),
          ),
        );

    final catalog = await db.select(db.catalogCache).getSingle();

    expect(catalog.thumbnailImageUrl, 'https://cdn.example/superman-thumb.jpg');
    expect(catalog.editionTitle, 'Direct market edition');
    expect(catalog.physicalFormat, 'single-issue');
    expect(catalog.physicalFormatLabel, 'Single Issue');
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
}
