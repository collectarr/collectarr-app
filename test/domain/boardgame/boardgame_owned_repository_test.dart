import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardGameOwnedRepository round-trips and soft-deletes copies',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameOwnedRepository(db);
    final item = BoardGameOwnedItem(
      id: const BoardGameOwnedItemId('owned-boardgame-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'boardgame',
        entityType: CatalogEntityType.work,
        id: 'boardgame-1',
      ),
      condition: 'Mint',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const BoardgameOwnedDetails(
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

  test('BoardGameOwnedRepository rejects a non-BoardGame reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameOwnedRepository(db);
    final item = BoardGameOwnedItem(
      id: const BoardGameOwnedItemId('owned-boardgame-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: 'game',
        entityType: CatalogEntityType.work,
        id: 'game-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });
}
