import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/sync/data/sync_retry_mapper.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('entry retry serializes through the concrete kind model', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = ComicEntryRepository(db);
    final updatedAt = DateTime.utc(2026, 5, 12, 8);
    await repository.upsert(
      ComicLibraryEntry(
        id: LibraryEntryId('entry-retry'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'entry-retry',
        ),
        catalogData: const {'title': 'Retry entry'},
        condition: 'Near Mint',
        updatedAt: updatedAt,
        details: const ComicEntryDetails(rawOrSlabbed: 'raw'),
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'library_entry',
        entityId: 'entry-retry',
        reason: 'conflict',
        localPayload: {
          'kind': 'comic',
        },
      ),
      db: db,
      changedAt: updatedAt,
      uuid: const Uuid(),
    );

    expect(retry?.action, 'upsert');
    expect(retry?.entityId, 'entry-retry');
    expect(retry?.payload['id'], 'entry-retry');
    expect(retry?.payload['kind'], 'comic');
    expect(retry?.payload['catalog_data'], {'title': 'Retry entry'});
    expect(retry?.payload['personal_data'],
        containsPair('condition', 'Near Mint'));
    expect(retry?.payload['updated_at'], updatedAt.toIso8601String());
  });

  test('entry retry preserves typed tombstone action', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = ComicEntryRepository(db);
    await repository.upsert(
      ComicLibraryEntry(
        id: LibraryEntryId('entry-deleted-retry'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'entry-deleted-retry',
        ),
        catalogData: const {'title': 'Deleted retry entry'},
        updatedAt: DateTime.utc(2026, 5, 12, 8),
        deletedAt: DateTime.utc(2026, 5, 12, 7),
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'library_entry',
        entityId: 'entry-deleted-retry',
        reason: 'conflict',
        localPayload: {
          'kind': 'comic',
        },
      ),
      db: db,
      changedAt: DateTime.utc(2026, 5, 12, 9),
      uuid: const Uuid(),
    );

    expect(retry?.action, 'delete');
    expect(retry?.payload['deleted_at'],
        DateTime.utc(2026, 5, 12, 7).toIso8601String());
  });

  test('entry retry requires a kind in the rejected payload', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await ComicEntryRepository(db).upsert(
      ComicLibraryEntry(
        id: LibraryEntryId('entry-untyped-retry'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'entry-untyped-retry',
        ),
        catalogData: const {'title': 'Untyped retry entry'},
        updatedAt: DateTime.utc(2026, 5, 12, 8),
        details: const ComicEntryDetails(),
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'library_entry',
        entityId: 'entry-untyped-retry',
        reason: 'conflict',
      ),
      db: db,
      changedAt: DateTime.utc(2026, 5, 12, 9),
      uuid: const Uuid(),
    );

    expect(retry, isNull);
  });
}
