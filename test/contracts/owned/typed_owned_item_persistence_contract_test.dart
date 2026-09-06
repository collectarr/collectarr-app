import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatches every concrete kind owned copy to its typed repository',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrOwnedItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6);
    final items = [
      comicSeedOwnedItems(now).first,
      mangaSeedOwnedItems(now).first,
      bookSeedOwnedItems(now).first,
      gameSeedOwnedItems(now).first,
      boardgameSeedOwnedItems(now).first,
      movieSeedOwnedItems(now).first,
      tvSeedOwnedItems(now).first,
      animeSeedOwnedItems(now).first,
      musicSeedOwnedItems(now).first,
    ];

    await persistence.upsertAll(items);

    expect(await db.select(db.comicOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.mangaOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.bookOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.gameOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.boardGameOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.movieOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.tvOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.animeOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.musicOwnedItemsRows).get(), hasLength(1));
  });

  test('preserves the complete seeded owned payload through each kind table',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrOwnedItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);
    final items = [
      comicSeedOwnedItems(now).first,
      mangaSeedOwnedItems(now).first,
      bookSeedOwnedItems(now).first,
      gameSeedOwnedItems(now).first,
      boardgameSeedOwnedItems(now).first,
      movieSeedOwnedItems(now).first,
      tvSeedOwnedItems(now).first,
      animeSeedOwnedItems(now).first,
      musicSeedOwnedItems(now).first,
    ];

    for (final item in items) {
      await persistence.upsert(item);
      final roundTrip = await persistence.findById(item.id);
      expect(roundTrip, isNotNull, reason: item.catalogRef.kind);
      expect(roundTrip!.toJson(), equals(item.toJson()),
          reason: 'owned payload was not lossless for ${item.catalogRef.kind}');
    }
  });
}
