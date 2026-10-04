import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameEntryRepository round-trips and soft-deletes typed copies',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = GameEntryRepository(db);
    final item = GameLibraryEntry(
      id: const LibraryEntryId('entry-game-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.game,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'game-1',
      ),
      condition: 'Mint',
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const GameEntryDetails(
        completeness: 'Complete',
        hasBox: true,
        hasManual: true,
        priceChartingId: 'pc-123',
        coreRegion: 'NTSC-U',
        valueIsLocked: false,
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.itemId, item.itemId);
    expect(restored?.condition, 'Mint');
    expect(restored?.details.completeness, 'Complete');
    expect(restored?.details.hasManual, true);
    final active = await repository.listActive();
    expect(active, hasLength(1));
    expect(active.single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('GameEntryRepository rejects a non-Game catalog reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = GameEntryRepository(db);
    final item = GameLibraryEntry(
      id: const LibraryEntryId('entry-game-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });
}
