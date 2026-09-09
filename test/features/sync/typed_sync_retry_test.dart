import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/sync/data/sync_retry_mapper.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('owned retry serializes through the concrete kind model', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = ComicOwnedRepository(db);
    final updatedAt = DateTime.utc(2026, 5, 12, 8);
    await repository.upsert(
      ComicOwnedItem(
        id: ComicOwnedItemId('owned-retry'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-retry',
        ),
        condition: 'Near Mint',
        updatedAt: updatedAt,
        details: const ComicOwnedDetails(rawOrSlabbed: 'raw'),
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'owned_item',
        entityId: 'owned-retry',
        reason: 'conflict',
        localPayload: {
          'catalog_ref': {
            'kind': 'comic',
            'entity_type': 'work',
            'id': 'comic-retry',
          },
        },
      ),
      db: db,
      changedAt: updatedAt,
      uuid: const Uuid(),
    );

    expect(retry?.action, 'upsert');
    expect(retry?.entityId, 'owned-retry');
    expect(retry?.payload['catalog_ref'], {
      'kind': 'comic',
      'entity_type': 'work',
      'id': 'comic-retry',
    });
    expect(retry?.payload['condition'], 'Near Mint');
    expect(retry?.payload, isNot(contains('id')));
    expect(retry?.payload, isNot(contains('updated_at')));
  });

  test('owned retry preserves typed tombstone action', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = ComicOwnedRepository(db);
    await repository.upsert(
      ComicOwnedItem(
        id: ComicOwnedItemId('owned-deleted-retry'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-deleted-retry',
        ),
        updatedAt: DateTime.utc(2026, 5, 12, 8),
        deletedAt: DateTime.utc(2026, 5, 12, 7),
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'owned_item',
        entityId: 'owned-deleted-retry',
        reason: 'conflict',
        localPayload: {
          'catalog_ref': {
            'kind': 'comic',
            'entity_type': 'work',
            'id': 'comic-deleted-retry',
          },
        },
      ),
      db: db,
      changedAt: DateTime.utc(2026, 5, 12, 9),
      uuid: const Uuid(),
    );

    expect(retry?.action, 'delete');
    expect(retry?.payload, isNot(contains('deleted_at')));
  });

  test('owned retry does not scan unrelated kinds without a typed ref',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await ComicOwnedRepository(db).upsert(
      ComicOwnedItem(
        id: ComicOwnedItemId('owned-untyped-retry'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId('work'),
          id: 'comic-untyped-retry',
        ),
        updatedAt: DateTime.utc(2026, 5, 12, 8),
        details: const ComicOwnedDetails(),
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'owned_item',
        entityId: 'owned-untyped-retry',
        reason: 'conflict',
      ),
      db: db,
      changedAt: DateTime.utc(2026, 5, 12, 9),
      uuid: const Uuid(),
    );

    expect(retry, isNull);
  });
}
