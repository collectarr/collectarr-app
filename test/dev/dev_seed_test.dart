import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dev seed populates new libraries and image sets, and is idempotent', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedLocalDatabase(db);

    final catalogRows = await db.select(db.catalogCache).get();
    expect(_countKind(catalogRows, 'tv'), 10);
    expect(_countKind(catalogRows, 'anime'), 10);
    expect(_countKind(catalogRows, 'manga'), 10);

    final ownedRows = await db.select(db.ownedItemsCache).get();
    final tvOwned =
      ownedRows.where((row) => row.itemId.startsWith('seed-tv-')).toList();
    final animeOwned =
      ownedRows.where((row) => row.itemId.startsWith('seed-anime-')).toList();
    final mangaOwned = ownedRows
      .where((row) => row.itemId.startsWith('seed-manga-'))
      .toList();

    expect(tvOwned, hasLength(10));
    expect(animeOwned, hasLength(10));
    expect(mangaOwned, hasLength(10));
    expect(tvOwned.every((row) => (row.personalNotes ?? '').isNotEmpty), isTrue);
    expect(animeOwned.every((row) => (row.personalNotes ?? '').isNotEmpty), isTrue);
    expect(mangaOwned.every((row) => (row.personalNotes ?? '').isNotEmpty), isTrue);

    final tvFront = await _countImages(db, 'seed-owned-seed-tv-', 'front_cover');
    final animeFront =
      await _countImages(db, 'seed-owned-seed-anime-', 'front_cover');
    final mangaFront =
      await _countImages(db, 'seed-owned-seed-manga-', 'front_cover');
    expect(tvFront, 10);
    expect(animeFront, 10);
    expect(mangaFront, 10);

    final tvBack = await _countImages(db, 'seed-owned-seed-tv-', 'back_cover');
    final animeBack =
      await _countImages(db, 'seed-owned-seed-anime-', 'back_cover');
    final mangaBack =
      await _countImages(db, 'seed-owned-seed-manga-', 'back_cover');
    expect(tvBack, greaterThan(0));
    expect(animeBack, greaterThan(0));
    expect(mangaBack, greaterThan(0));

    final tvExtra = await _countImages(db, 'seed-owned-seed-tv-', 'detail_photo');
    final animeExtra =
      await _countImages(db, 'seed-owned-seed-anime-', 'detail_photo');
    final mangaExtra =
      await _countImages(db, 'seed-owned-seed-manga-', 'detail_photo');
    expect(tvExtra, greaterThan(0));
    expect(animeExtra, greaterThan(0));
    expect(mangaExtra, greaterThan(0));

    final catalogCountAfterFirstSeed = catalogRows.length;
    final imageCountAfterFirstSeed =
        (await db.select(db.itemImagesCache).get()).length;

    await seedLocalDatabase(db);

    final catalogCountAfterSecondSeed =
        (await db.select(db.catalogCache).get()).length;
    final imageCountAfterSecondSeed =
        (await db.select(db.itemImagesCache).get()).length;

    expect(catalogCountAfterSecondSeed, catalogCountAfterFirstSeed);
    expect(imageCountAfterSecondSeed, imageCountAfterFirstSeed);
  });
}

int _countKind(List<CatalogCacheData> rows, String kind) {
  return rows.where((row) => row.kind == kind).length;
}

Future<int> _countImages(
  LocalDatabase db,
  String ownedPrefix,
  String imageType,
) async {
  final rows = await db.select(db.itemImagesCache).get();
  return rows
      .where((row) =>
          row.ownedItemId.startsWith(ownedPrefix) && row.imageType == imageType)
      .length;
}
