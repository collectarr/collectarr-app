import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed quality guard rejects incomplete catalog data', () {
    final incomplete = enrichSeedItem(
      seedCatalogItem(
        id: 'seed-comic-invalid',
        kind: 'comic',
        title: 'Incomplete fixture',
      ),
    );

    expect(
      () => validateSeedCatalogQuality([incomplete]),
      throwsA(isA<StateError>()),
    );
  });

  test('dev seed populates new libraries and image sets, and is idempotent',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedLocalDatabase(db);

    final catalogRows = await LibraryCatalogRepository(db).findAll();
    final typedGraphCounts = await devSeedTypedGraphCounts(db);
    final typedOwnedCounts = await devSeedTypedOwnedCounts(db);
    final typedTrackingCounts = await devSeedTypedTrackingCounts(db);
    final auxiliaryCounts = await devSeedAuxiliaryCounts(db);
    for (final entry in devSeedTypedGraphMinimumCounts.entries) {
      expect(
        typedGraphCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed seed graph for ${entry.key}',
      );
    }
    for (final entry in devSeedTypedOwnedMinimumCounts.entries) {
      expect(
        typedOwnedCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed owned seed data for ${entry.key}',
      );
    }
    for (final entry in devSeedTypedTrackingMinimumCounts.entries) {
      expect(
        typedTrackingCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed tracking seed data for ${entry.key}',
      );
    }
    for (final entry in devSeedAuxiliaryMinimumCounts.entries) {
      expect(
        auxiliaryCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete auxiliary seed data for ${entry.key}',
      );
    }
    final bookReleases = await db.select(db.bookReleaseRows).get();
    expect(
      bookReleases.every(
        (row) =>
            row.workId?.startsWith('seed-book-') == true &&
            row.displayTitle?.trim().isNotEmpty == true &&
            row.isbn?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'Book seed editions must retain typed edition metadata',
    );
    final boardGameEditions = await db.select(db.boardGameEditionRows).get();
    expect(
      boardGameEditions.every(
        (row) =>
            row.workId?.startsWith('seed-boardgame-') == true &&
            row.editionTitle?.trim().isNotEmpty == true &&
            row.minPlayers != null &&
            row.maxPlayers != null &&
            row.playingTimeMinutes != null,
      ),
      isTrue,
      reason: 'BoardGame seed editions must retain typed edition metadata',
    );
    final tvReleases = await db.select(db.tvReleaseRows).get();
    expect(
      tvReleases.every(
        (row) =>
            row.seriesId.startsWith('seed-tv-') &&
            row.title.trim().isNotEmpty &&
            row.episodeCount == 2,
      ),
      isTrue,
      reason: 'TV seed releases must retain series and episode metadata',
    );
    final musicTracks = await db.select(db.musicTrackRows).get();
    expect(
      musicTracks.every(
        (row) =>
            row.mediaId.startsWith('seed-music-') && row.durationMs != null,
      ),
      isTrue,
      reason: 'Music seed tracks must retain media and duration metadata',
    );
    const expectedCatalogCounts = devSeedCatalogCounts;
    for (final entry in expectedCatalogCounts.entries) {
      expect(_countKind(catalogRows, entry.key), entry.value,
          reason: 'Unexpected ${entry.key} seed count');
    }
    expect(catalogRows.map((row) => row.id).toSet(), hasLength(130));
    expect(catalogRows.every((row) => row.title.trim().isNotEmpty), isTrue);
    expect(
        catalogRows.every((row) =>
            row.coverImageUrl?.trim().isNotEmpty == true &&
            row.thumbnailImageUrl?.trim().isNotEmpty == true),
        isTrue);
    for (final row in catalogRows) {
      final kind = catalogMediaKindFromApiValue(row.kind);
      expect(kind, isNot(CatalogMediaKind.unknown),
          reason: 'Seed row has an unknown kind: ${row.id}');
      final barcode = row.barcode;
      expect(barcode, isNotNull,
          reason: 'Seed row is missing a barcode: ${row.id}');
      expect(
        resolveLibraryBarcodeForKind(kind, barcode!),
        isNotNull,
        reason: 'Seed barcode is not accepted by ${row.kind}: ${row.id}',
      );
    }
    final videoRows = catalogRows.where((row) =>
        row.kind == 'movie' || row.kind == 'tv' || row.kind == 'anime');
    expect(
        videoRows.every((row) =>
            row.payload['runtime_minutes'] is int &&
            row.payload['nr_discs'] is int),
        isTrue);
    final musicRows = catalogRows.where((row) => row.kind == 'music');
    expect(
        musicRows.every((row) =>
            row.payload['track_count'] is int &&
            (row.payload['tracks'] as List?)?.isNotEmpty == true),
        isTrue);

    final ownedRows = await db.select(db.ownedItemsCache).get();
    for (final entry in expectedCatalogCounts.entries) {
      final kindOwned = ownedRows
          .where((row) => row.itemId.startsWith('seed-${entry.key}-'))
          .toList();
      expect(kindOwned, hasLength(entry.value),
          reason: 'Unexpected ${entry.key} owned seed count');
    }
    expect(
        ownedRows
            .every((row) => catalogRows.any((item) => item.id == row.itemId)),
        isTrue);
    expect(ownedRows.map((row) => row.id).toSet(), hasLength(130));

    final comicOwnedRows = await db.select(db.comicOwnedItemsRows).get();
    final comicReadingRows = await db.select(db.comicReadingRows).get();
    expect(comicOwnedRows, hasLength(15));
    expect(comicReadingRows, hasLength(15));
    expect(comicOwnedRows.every((row) => row.itemId.startsWith('seed-comic-')),
        isTrue);

    final trackingRows = await db.select(db.trackingEntriesCache).get();
    for (final entry in expectedCatalogCounts.entries) {
      final kindTracking = trackingRows
          .where((row) => row.itemId.startsWith('seed-${entry.key}-'))
          .toList();
      expect(kindTracking, hasLength(entry.value),
          reason: 'Unexpected ${entry.key} tracking seed count');
    }
    final ownedIds = ownedRows.map((row) => row.id).toSet();
    expect(trackingRows.map((row) => row.id).toSet(), hasLength(130));
    expect(
        trackingRows.every((row) =>
            row.ownedItemId == null || ownedIds.contains(row.ownedItemId)),
        isTrue);

    final pickLists = PickListRepository(db);
    expect(
      await pickLists.getValues('manga.format', mediaKind: 'manga'),
      contains('Tankobon (Standard)'),
    );
    expect(
      await pickLists.getValues('music.country', mediaKind: 'music'),
      contains('GB'),
    );
    expect(
      await pickLists.getValues('book.language', mediaKind: 'book'),
      contains('Japanese'),
    );
    expect(
      await pickLists.getValues('music.genre', mediaKind: 'music'),
      contains('rock'),
    );
    expect(
      await pickLists.getValues('boardgame.category', mediaKind: 'boardgame'),
      contains('Strategy'),
    );
    expect(
      await pickLists.getValues('game.platform', mediaKind: 'game'),
      contains('Nintendo Switch'),
    );
    expect(
      await pickLists.getValues('comic.story_arc', mediaKind: 'comic'),
      contains('Chapter One'),
    );

    final customFields = CustomFieldRepository(db);
    final definitions = await customFields.listDefinitions();
    expect(definitions, hasLength(9));
    final definitionIds =
        definitions.map((definition) => definition.id).toSet();
    final customValues = (await customFields.listAllValues())
        .values
        .expand((values) => values)
        .toList();
    expect(customValues, hasLength(9));
    expect(
        customValues
            .every((value) => definitionIds.contains(value.fieldDefinitionId)),
        isTrue);
    final customFieldOwnedIds = ownedRows.map((row) => row.id).toSet();
    expect(
      customValues
          .every((value) => customFieldOwnedIds.contains(value.targetId)),
      isTrue,
      reason: 'Seed custom-field values must target an existing owned item',
    );

    final tvOwned =
        ownedRows.where((row) => row.itemId.startsWith('seed-tv-')).toList();
    final animeOwned =
        ownedRows.where((row) => row.itemId.startsWith('seed-anime-')).toList();
    final mangaOwned =
        ownedRows.where((row) => row.itemId.startsWith('seed-manga-')).toList();

    expect(tvOwned, hasLength(15));
    expect(animeOwned, hasLength(15));
    expect(mangaOwned, hasLength(15));
    expect(
        tvOwned.every((row) => (row.personalNotes ?? '').isNotEmpty), isTrue);
    expect(animeOwned.every((row) => (row.personalNotes ?? '').isNotEmpty),
        isTrue);
    expect(mangaOwned.every((row) => (row.personalNotes ?? '').isNotEmpty),
        isTrue);

    final tvFront =
        await _countImages(db, 'seed-owned-seed-tv-', 'front_cover');
    final animeFront =
        await _countImages(db, 'seed-owned-seed-anime-', 'front_cover');
    final mangaFront =
        await _countImages(db, 'seed-owned-seed-manga-', 'front_cover');
    expect(tvFront, 15);
    expect(animeFront, 15);
    expect(mangaFront, 15);

    final tvBack = await _countImages(db, 'seed-owned-seed-tv-', 'back_cover');
    final animeBack =
        await _countImages(db, 'seed-owned-seed-anime-', 'back_cover');
    final mangaBack =
        await _countImages(db, 'seed-owned-seed-manga-', 'back_cover');
    expect(tvBack, greaterThan(0));
    expect(animeBack, greaterThan(0));
    expect(mangaBack, greaterThan(0));

    final tvExtra =
        await _countImages(db, 'seed-owned-seed-tv-', 'detail_photo');
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
        (await LibraryCatalogRepository(db).findAll()).length;
    final imageCountAfterSecondSeed =
        (await db.select(db.itemImagesCache).get()).length;
    final typedGraphCountsAfterSecondSeed = await devSeedTypedGraphCounts(db);
    final typedOwnedCountsAfterSecondSeed = await devSeedTypedOwnedCounts(db);
    final typedTrackingCountsAfterSecondSeed =
        await devSeedTypedTrackingCounts(db);
    final auxiliaryCountsAfterSecondSeed = await devSeedAuxiliaryCounts(db);

    expect(catalogCountAfterSecondSeed, catalogCountAfterFirstSeed);
    expect(imageCountAfterSecondSeed, imageCountAfterFirstSeed);
    expect(typedGraphCountsAfterSecondSeed, typedGraphCounts);
    expect(typedOwnedCountsAfterSecondSeed, typedOwnedCounts);
    expect(typedTrackingCountsAfterSecondSeed, typedTrackingCounts);
    expect(auxiliaryCountsAfterSecondSeed, auxiliaryCounts);
  });
}

int _countKind(List<CatalogItem> rows, String kind) {
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
