import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicEntryRepository round-trips and soft-deletes typed copies',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicEntryRepository(db);
    final item = MusicLibraryEntry(
      id: const LibraryEntryId('entry-music-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'entry-music-1',
      ),
      catalogData: const {'title': 'Album'},
      condition: 'Mint',
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const MusicEntryDetails(
        media: [
          MusicEntryMediumDetails(
            mediumIndex: 1,
            storageDevice: 'Vinyl shelf',
            storageSlot: 'M-01',
            matrixRunouts: [
              MusicMatrixRunout(side: 'A', runoutText: 'ABC-123 A1'),
            ],
          ),
        ],
        signedBy: 'Artist',
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.itemId, item.itemId);
    expect(restored?.condition, 'Mint');
    expect(restored?.details.media.single.storageSlot, 'M-01');
    expect(restored?.details.signedBy, 'Artist');
    expect(restored?.details.media.single.matrixRunouts.single.runoutText,
        'ABC-123 A1');
    final active = await repository.listActive();
    expect(active, hasLength(1));
    expect(active.single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('MusicEntryRepository rejects a non-Music catalog reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicEntryRepository(db);
    final item = MusicLibraryEntry(
      id: const LibraryEntryId('entry-music-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });

  test('MusicEntryRepository accepts a copy directly on its catalog item',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicEntryRepository(db);
    final item = MusicLibraryEntry(
      id: const LibraryEntryId('entry-music-catalog-item'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'entry-music-catalog-item',
      ),
      catalogData: const {'title': 'Album'},
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    await repository.upsert(item);
    expect(await repository.findById(item.id), isNotNull);
  });
}
