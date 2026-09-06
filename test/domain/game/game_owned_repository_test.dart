import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameOwnedRepository round-trips and soft-deletes typed copies',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = GameOwnedRepository(db);
    final item = GameOwnedItem(
      id: const GameOwnedItemId('owned-game-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'game',
        entityType: CatalogEntityType.work,
        id: 'game-1',
      ),
      condition: 'Mint',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const GameOwnedDetails(
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

  test('GameOwnedRepository rejects a non-Game catalog reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = GameOwnedRepository(db);
    final item = GameOwnedItem(
      id: const GameOwnedItemId('owned-game-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });
}
