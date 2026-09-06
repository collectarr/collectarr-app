import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicOwnedRepository round-trips and soft-deletes typed copies',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicOwnedRepository(db);
    final item = MusicOwnedItem(
      id: const MusicOwnedItemId('owned-music-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'music',
        entityType: CatalogEntityType.work,
        id: 'music-1',
      ),
      condition: 'Mint',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const MusicOwnedDetails(
        storageDevice: 'Vinyl shelf',
        storageSlot: 'M-01',
        signedBy: 'Artist',
        matrixRunouts: [
          MusicMatrixRunout(side: 'A', runoutText: 'ABC-123 A1'),
        ],
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.itemId, item.itemId);
    expect(restored?.condition, 'Mint');
    expect(restored?.details.storageSlot, 'M-01');
    expect(restored?.details.signedBy, 'Artist');
    expect(restored?.details.matrixRunouts.single.runoutText, 'ABC-123 A1');
    final active = await repository.listActive();
    expect(active, hasLength(1));
    expect(active.single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('MusicOwnedRepository rejects a non-Music catalog reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicOwnedRepository(db);
    final item = MusicOwnedItem(
      id: const MusicOwnedItemId('owned-music-invalid'),
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
