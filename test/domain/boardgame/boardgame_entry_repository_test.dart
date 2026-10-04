import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardGameEntryRepository round-trips and soft-deletes copies',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameEntryRepository(db);
    final item = BoardGameLibraryEntry(
      id: const LibraryEntryId('entry-boardgame-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.boardgame,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'boardgame-1',
      ),
      condition: 'Mint',
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const BoardgameEntryDetails(
        componentCompleteness: 'Complete',
        isSleeved: true,
        hasCustomInsert: true,
        hasPaintedMiniatures: true,
        storageNotes: 'Shelf 3',
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.itemId, item.itemId);
    expect(restored?.condition, 'Mint');
    expect(restored?.details.componentCompleteness, 'Complete');
    expect(restored?.details.hasCustomInsert, true);
    expect((await repository.listActive()).single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('BoardGameEntryRepository rejects a non-BoardGame reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameEntryRepository(db);
    final item = BoardGameLibraryEntry(
      id: const LibraryEntryId('entry-boardgame-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.game,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'game-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });
}
