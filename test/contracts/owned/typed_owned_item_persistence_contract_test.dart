import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
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

    for (final item in items) {
      final ref = collectarrTypedOwnedItemRef(item);
      await persistence.replaceFromPayload(
        ref.kind,
        collectarrTypedOwnedItemJson(item),
      );
    }

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
      final ref = collectarrTypedOwnedItemRef(item);
      await persistence.replaceFromPayload(
        ref.kind,
        collectarrTypedOwnedItemJson(item),
      );
      final roundTrip = await persistence.payloadByRef(ref);
      expect(roundTrip, isNotNull, reason: ref.kind.apiValue);
      expect(
        roundTrip,
        equals(collectarrTypedOwnedItemJson(item)),
        reason: 'owned payload was not lossless for ${ref.kind}',
      );
    }
  });

  test('round-trips sync payloads through each concrete Owned table', () async {
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
      final ref = collectarrTypedOwnedItemRef(item);
      await persistence.replaceFromPayload(
        ref.kind,
        collectarrTypedOwnedItemJson(item),
      );
      final sync = await persistence.syncPayloadByRef(ref);
      expect(sync, isNotNull, reason: ref.kind.apiValue);
      expect(sync!.payload, isNotEmpty, reason: ref.kind.apiValue);
      expect(sync.isDeleted, isFalse, reason: ref.kind.apiValue);
    }
  });
}
