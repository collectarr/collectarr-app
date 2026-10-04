import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/dev/seeds/seed_catalog_item_factory.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import '../helpers/tracking_state_test_helpers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated seed registry covers every catalog kind', () {
    final kinds = collectarrDevSeedContributors
        .map((contributor) => contributor.kind)
        .map((kind) => kind.apiValue)
        .toList();

    expect(kinds.length, devSeedCatalogCounts.length);
    expect(kinds.toSet().length, kinds.length);
    expect(
      kinds,
      containsAll(devSeedCatalogCounts.keys.map((kind) => kind.apiValue)),
    );
    expect(
      collectarrDevSeedContributorsByKind.keys.toSet(),
      devSeedCatalogCounts.keys.toSet(),
    );
    for (final contributor in collectarrDevSeedContributors) {
      expect(
        collectarrDevSeedContributorsByKind[contributor.kind],
        same(contributor),
      );
      expect(contributor.catalogItems, isNotNull);
      expect(contributor.validateCatalog, isNotNull);
      expect(contributor.validateCatalogGraph, isNotNull);
      expect(contributor.validateBarcode, isNotNull);
      expect(contributor.entrySummaries, isNotNull);
      expect(contributor.validateEntry, isNotNull);
      expect(contributor.seedEntry, isNotNull);
      expect(contributor.trackingRecords, isNotNull);

      final entry = contributor.entrySummaries(DateTime.utc(2024, 1, 1));
      expect(entry, isNotEmpty);
      expect(
        entry.every(
          (item) => item.ref.kind == contributor.kind,
        ),
        isTrue,
        reason: 'Entry seed type mismatch for ${contributor.kind.apiValue}',
      );
    }
  });

  test('every kind seed script emits a complete deterministic source set', () {
    expect(
      () => validateDevSeedContributorCoverage(
        now: DateTime.utc(2024, 1, 1),
      ),
      returnsNormally,
    );
  });

  test('Comic seed validator accepts UPC supplemental barcodes', () {
    final issues = <String>[];

    validateComicSeedBarcode(
        issues, 'comic/seed-comic-01', '70985301254200111');

    expect(issues, isEmpty);
  });

  test('seed quality guard rejects incomplete catalog data', () {
    final incomplete = enrichSeedItem(
      seedCatalogItem(
        id: 'seed-comic-invalid',
        kind: CatalogMediaKind.comic,
        title: 'Incomplete fixture',
      ),
      defaults: comicDevSeedContributor.catalogDefaults,
    );

    expect(
      () => validateSeedCatalogQuality([incomplete]),
      throwsA(isA<StateError>()),
    );
  });

  test('seed quality guard rejects entry details under the wrong kind', () {
    final movie = movieSeedLibraryEntries(DateTime.utc(2024, 1, 1)).first;
    final mismatched = movie.copyWith(
      catalogRef: seedCatalogRef(CatalogMediaKind.comic, 'seed-comic-01'),
    );
    final mismatchedSummary = movieDevSeedContributor
        .entrySummaries(
          DateTime.utc(2024, 1, 1),
        )
        .first
        .copyWith(
          ref: LibraryEntryRef(
            kind: CatalogMediaKind.movie,
            id: LibraryEntryId(mismatched.id.value),
          ),
          catalogRef: mismatched.catalogRef,
        );

    expect(
      () => validateSeedEntryQuality([mismatchedSummary]),
      throwsA(isA<StateError>()),
    );
  });

  test('dev seed populates new libraries and image sets, and is idempotent',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await seedLocalDatabase(db);
    final verification = await verifyDevSeedDatabase(db);
    expect(
      verification.seededCatalogCount,
      devSeedCatalogCounts.values.fold<int>(0, (total, count) => total + count),
    );
    for (final entry in devSeedVocabularyMinimumCounts().entries) {
      expect(
        verification.vocabularyCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete ${entry.key} seed vocabulary',
      );
    }

    final catalogRows = await CatalogSnapshotRepository(db).findAll();
    final typedGraphCounts = await devSeedTypedGraphCounts(db);
    final typedGraphIntegrityIssues =
        await devSeedTypedGraphIntegrityIssues(db);
    final typedEntryCounts = await devSeedTypedEntryCounts(db);
    final typedTrackingCounts = await devSeedTypedTrackingCounts(db);
    final typedTrackingUnitCounts = await devSeedTypedTrackingUnitCounts(db);
    final auxiliaryCounts = await devSeedAuxiliaryCounts(db);
    expect(
      typedGraphIntegrityIssues,
      isEmpty,
      reason: 'Typed seed graph relationships must remain intact',
    );
    final typedEntryIntegrityIssues =
        await devSeedTypedEntryIntegrityIssues(db);
    expect(
      typedEntryIntegrityIssues,
      isEmpty,
      reason: 'Kind-entry seed rows must remain linked to common copies',
    );
    for (final entry in devSeedTypedGraphMinimumCounts.entries) {
      expect(
        typedGraphCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed seed graph for ${entry.key}',
      );
    }
    for (final entry in devSeedTypedEntryMinimumCounts.entries) {
      expect(
        typedEntryCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed entry seed data for ${entry.key}',
      );
    }
    for (final entry in devSeedTypedTrackingMinimumCounts.entries) {
      expect(
        typedTrackingCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed tracking seed data for ${entry.key}',
      );
    }
    for (final entry in devSeedTypedTrackingUnitMinimumCounts.entries) {
      expect(
        typedTrackingUnitCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete typed tracking-unit seed data for ${entry.key}',
      );
    }
    final comicTrackingUnits = await db.select(db.comicTrackingUnitRows).get();
    expect(
      comicTrackingUnits
          .every((row) => row.issueNumber?.trim().isNotEmpty == true),
      isTrue,
      reason: 'Comic tracking units must retain issue coordinates',
    );
    final mangaTrackingUnits = await db.select(db.mangaTrackingUnitRows).get();
    expect(
      mangaTrackingUnits.every(
        (row) => row.chapterNumber != null && row.chapterNumber! > 0,
      ),
      isTrue,
      reason: 'Manga tracking units must retain chapter coordinates',
    );
    final bookTrackingUnits = await db.select(db.bookTrackingUnitRows).get();
    expect(
      bookTrackingUnits.every(
        (row) => row.volumeNumber != null && row.volumeNumber! > 0,
      ),
      isTrue,
      reason: 'Book tracking units must retain volume coordinates',
    );
    final tvTrackingUnits = await db.select(db.tvTrackingUnitRows).get();
    expect(
      tvTrackingUnits.every(
        (row) =>
            row.seasonNumber != null &&
            row.seasonNumber! > 0 &&
            row.episodeNumber != null &&
            row.episodeNumber! > 0,
      ),
      isTrue,
      reason: 'TV tracking units must retain season/episode coordinates',
    );
    final animeTrackingUnits = await db.select(db.animeTrackingUnitRows).get();
    expect(
      animeTrackingUnits.every(
        (row) =>
            row.seasonNumber != null &&
            row.seasonNumber! > 0 &&
            row.episodeNumber != null &&
            row.episodeNumber! > 0,
      ),
      isTrue,
      reason: 'Anime tracking units must retain season/episode coordinates',
    );
    for (final entry in devSeedAuxiliaryMinimumCounts.entries) {
      expect(
        auxiliaryCounts[entry.key],
        greaterThanOrEqualTo(entry.value),
        reason: 'Incomplete auxiliary seed data for ${entry.key}',
      );
    }
    final bookItems = await CatalogItemCacheRepository(db).findAll(
      kind: CatalogMediaKind.book,
    );
    expect(
      bookItems.where((item) => item.id.startsWith('seed-book-')).every(
            (item) =>
                item.title.trim().isNotEmpty &&
                item.barcode?.trim().isNotEmpty == true,
          ),
      isTrue,
      reason: 'Book seed Catalog Items must retain title and ISBN data',
    );
    final boardGameItems = await CatalogItemCacheRepository(db).findAll(
      kind: CatalogMediaKind.boardgame,
    );
    expect(
      boardGameItems
          .where((item) => item.id.startsWith('seed-boardgame-'))
          .every(
        (item) {
          final editions = item.payload['editions'];
          if (editions is! Iterable || editions.isEmpty) return false;
          return editions.whereType<Map<Object?, Object?>>().every(
                (edition) =>
                    edition['work_id'] == item.id &&
                    edition['edition_title']?.toString().trim().isNotEmpty ==
                        true &&
                    edition['min_players'] is num &&
                    edition['max_players'] is num &&
                    edition['playing_time_minutes'] is num,
              );
        },
      ),
      isTrue,
      reason: 'BoardGame seed Catalog Items must retain edition metadata',
    );
    final tvItems = await CatalogItemCacheRepository(db).findAll(
      kind: CatalogMediaKind.tv,
    );
    final tvReleases = [
      for (final item in tvItems) ..._maps(item.payload['releases']),
    ];
    expect(
      tvReleases.every(
        (release) =>
            release['series_id']?.toString().startsWith('seed-tv-') == true &&
            release['title']?.toString().trim().isNotEmpty == true &&
            release['episode_count'] == 2,
      ),
      isTrue,
      reason: 'TV seed Catalog Items must retain release and episode metadata',
    );
    final musicItems = await CatalogItemCacheRepository(db).findAll(
      kind: CatalogMediaKind.music,
    );
    expect(
      musicItems.every(_hasMusicTracksWithDurations),
      isTrue,
      reason: 'Music seed tracks must retain album and duration metadata',
    );
    final boardGamePlaySessions =
        await db.select(db.boardGamePlaySessionsRows).get();
    expect(
      boardGamePlaySessions.every(
        (row) =>
            row.boardGameId.startsWith('seed-boardgame-') &&
            row.playersJson != '[]' &&
            row.scoresJson != '[]' &&
            row.durationMinutes != null,
      ),
      isTrue,
      reason: 'BoardGame seed play sessions must retain score data',
    );
    final tvWatchSessions = await db.select(db.tvWatchSessionRows).get();
    expect(
      tvWatchSessions.every(
        (row) =>
            row.seriesId.startsWith('seed-tv-') &&
            row.targetRefJson?.isNotEmpty == true &&
            row.seasonNumber != null &&
            row.episodeNumber != null,
      ),
      isTrue,
      reason: 'TV seed watch sessions must retain episode coordinates',
    );
    final animeWatchSessions = await db.select(db.animeWatchSessionRows).get();
    expect(
      animeWatchSessions.every(
        (row) =>
            row.seriesId.startsWith('seed-anime-') &&
            row.targetRefJson?.isNotEmpty == true &&
            row.seasonNumber != null &&
            row.episodeNumber != null,
      ),
      isTrue,
      reason: 'Anime seed watch sessions must retain episode coordinates',
    );
    final tvCustomEpisodes = await db.select(db.tvCustomEpisodeRows).get();
    final animeCustomEpisodes =
        await db.select(db.animeCustomEpisodeRows).get();
    expect(
      tvCustomEpisodes.every(
        (row) => row.seriesId.startsWith('seed-tv-') && row.title.isNotEmpty,
      ),
      isTrue,
      reason: 'TV seed custom episodes must retain titles',
    );
    expect(
      animeCustomEpisodes.every(
        (row) => row.seriesId.startsWith('seed-anime-') && row.title.isNotEmpty,
      ),
      isTrue,
      reason: 'Anime seed custom episodes must retain titles',
    );
    const expectedCatalogCounts = devSeedCatalogCounts;
    for (final entry in expectedCatalogCounts.entries) {
      expect(_countKind(catalogRows, entry.key), entry.value,
          reason: 'Unexpected ${entry.key} seed count');
    }
    final expectedSeedTotal = devSeedCatalogCounts.values
        .fold<int>(0, (total, count) => total + count);
    expect(
        catalogRows.map((row) => row.id).toSet(), hasLength(expectedSeedTotal));
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
    const videoKinds = <CatalogMediaKind>{
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
      CatalogMediaKind.anime,
    };
    final videoRows = catalogRows.where(
      (row) => videoKinds.contains(catalogMediaKindFromApiValue(row.kind)),
    );
    expect(
        videoRows.every((row) =>
            row.payload['runtime_minutes'] is int &&
            row.payload['nr_discs'] is int),
        isTrue);
    final musicRows = catalogRows.where(
      (row) => catalogMediaKindFromApiValue(row.kind) == CatalogMediaKind.music,
    );
    expect(
        musicRows.every((row) =>
            row.payload['track_count'] is int &&
            (row.payload['tracks'] as List?)?.isNotEmpty == true),
        isTrue);

    final entryRows = await LibraryEntriesRepository(db).listActiveSummaries();
    for (final entry in expectedCatalogCounts.entries) {
      final kindEntry = entryRows
          .where(
            (row) =>
                row.catalogRef?.id.startsWith('seed-${entry.key.apiValue}-') ??
                false,
          )
          .toList();
      expect(kindEntry, hasLength(entry.value),
          reason: 'Unexpected ${entry.key} entry seed count');
    }
    expect(
        entryRows.every((row) =>
            row.catalogRef != null &&
            catalogRows.any((item) => item.id == row.catalogRef!.id)),
        isTrue);
    expect(entryRows.map((row) => row.ref.id.value).toSet(),
        hasLength(expectedSeedTotal));
    final comicEntryRows = await db.select(db.comicLibraryEntriesRows).get();
    final comicReadingRows = await db.select(db.comicReadingRows).get();
    expect(comicEntryRows, hasLength(15));
    expect(comicReadingRows, hasLength(15));
    expect(
      comicReadingRows.every(
        (row) => row.status?.trim().isNotEmpty == true && row.rating != null,
      ),
      isTrue,
      reason: 'Comic seed reading rows must retain typed progress data',
    );
    expect(comicEntryRows.every((row) => row.itemId.startsWith('seed-comic-')),
        isTrue);

    final movieEntryRows = await db.select(db.movieLibraryEntriesRows).get();
    expect(movieEntryRows, hasLength(15));
    expect(
      movieEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-movie-') &&
            row.region?.trim().isNotEmpty == true &&
            row.packaging?.trim().isNotEmpty == true &&
            row.distributor?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'Movie seed copies must retain complete typed entries data',
    );

    final animeEntryRows = await db.select(db.animeLibraryEntriesRows).get();
    expect(animeEntryRows, hasLength(15));
    expect(
      animeEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-anime-') &&
            row.region?.trim().isNotEmpty == true &&
            row.packaging?.trim().isNotEmpty == true &&
            row.distributor?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'Anime seed copies must retain complete typed entries data',
    );

    final tvEntryRows = await db.select(db.tvLibraryEntriesRows).get();
    expect(tvEntryRows, hasLength(15));
    expect(
      tvEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-tv-') &&
            row.region?.trim().isNotEmpty == true &&
            row.packaging?.trim().isNotEmpty == true &&
            row.distributor?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'TV seed copies must retain complete typed entries data',
    );

    final musicEntryRows = await db.select(db.musicLibraryEntriesRows).get();
    expect(musicEntryRows, hasLength(15));
    expect(
      musicEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-music-') &&
            row.mediumDetailsJson.contains('storage_device') &&
            row.mediumDetailsJson.contains('storage_slot') &&
            row.mediumDetailsJson.contains('runout_text'),
      ),
      isTrue,
      reason: 'Music seed copies must retain complete typed entries data',
    );

    final gameEntryRows = await db.select(db.gameLibraryEntriesRows).get();
    expect(gameEntryRows, hasLength(15));
    expect(
      gameEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-game-') &&
            row.completeness?.trim().isNotEmpty == true &&
            row.hasBox == true &&
            row.hasManual == true &&
            row.coreRegion?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'Game seed copies must retain complete typed entries data',
    );

    final boardGameEntryRows =
        await db.select(db.boardGameLibraryEntriesRows).get();
    expect(boardGameEntryRows, hasLength(15));
    expect(
      boardGameEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-boardgame-') &&
            row.componentCompleteness?.trim().isNotEmpty == true &&
            row.editionLanguage?.trim().isNotEmpty == true &&
            row.editionRegion?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'BoardGame seed copies must retain complete typed entries data',
    );
    expect(boardGameEntryRows.any((row) => row.isSleeved), isTrue);
    expect(boardGameEntryRows.any((row) => row.hasCustomInsert), isTrue);
    expect(boardGameEntryRows.any((row) => row.hasPaintedMiniatures), isTrue);

    final bookEntryRows = await db.select(db.bookLibraryEntriesRows).get();
    expect(bookEntryRows, hasLength(15));
    expect(
      bookEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-book-') &&
            row.signedBy?.trim().isNotEmpty == true &&
            row.dustJacketPresent == true &&
            row.dustJacketCondition?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'Book seed copies must retain complete typed entries data',
    );

    final mangaEntryRows = await db.select(db.mangaLibraryEntriesRows).get();
    expect(mangaEntryRows, hasLength(15));
    expect(
      mangaEntryRows.every(
        (row) =>
            row.itemId.startsWith('seed-manga-') &&
            row.rawOrSlabbed?.trim().isNotEmpty == true &&
            row.signedBy?.trim().isNotEmpty == true &&
            row.obiStripPresent == true &&
            row.slipcoverPresent == true &&
            row.dustJacketPresent == true &&
            row.insertsPresent == true &&
            row.printing?.trim().isNotEmpty == true &&
            row.localizedEdition?.trim().isNotEmpty == true,
      ),
      isTrue,
      reason: 'Manga seed copies must retain complete typed entries data',
    );

    final trackingRows = await readTrackingStates(db);
    for (final entry in expectedCatalogCounts.entries) {
      final kindTracking = trackingRows
          .where((row) =>
              row.catalogRef.id.startsWith('seed-${entry.key.apiValue}-'))
          .toList();
      expect(kindTracking, hasLength(entry.value),
          reason: 'Unexpected ${entry.key} tracking seed count');
    }
    final libraryEntryRefs = entryRows.map((row) => row.ref.key).toSet();
    expect(trackingRows.map((row) => row.id).toSet(),
        hasLength(expectedSeedTotal));
    expect(
      trackingRows.every((row) {
        if (row.catalogRef.kind == CatalogMediaKind.music) {
          return row.libraryEntryRef == null;
        }
        return row.libraryEntryRef != null && libraryEntryRefs.contains(row.libraryEntryRef!.key);
      }),
      isTrue,
    );
    expect(
      trackingRows.every((row) =>
          row.status != null && row.rating != null && row.startedAt != null),
      isTrue,
      reason: 'Seed tracking rows must exercise typed status and dates',
    );

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
    final customFieldEntryIds = entryRows.map((row) => row.ref.key).toSet();
    expect(
      customValues
          .every((value) => customFieldEntryIds.contains(value.targetId)),
      isTrue,
      reason: 'Seed custom-field values must target an existing collection item',
    );

    final tvEntry = entryRows
        .where((row) => row.catalogRef?.id.startsWith('seed-tv-') ?? false)
        .toList();
    final animeEntry = entryRows
        .where(
          (row) => row.catalogRef?.id.startsWith('seed-anime-') ?? false,
        )
        .toList();
    final mangaEntry = entryRows
        .where(
          (row) => row.catalogRef?.id.startsWith('seed-manga-') ?? false,
        )
        .toList();

    expect(tvEntry, hasLength(15));
    expect(animeEntry, hasLength(15));
    expect(mangaEntry, hasLength(15));
    expect(tvEntry.every((row) => (row.notes ?? '').isNotEmpty), isTrue);
    expect(animeEntry.every((row) => (row.notes ?? '').isNotEmpty), isTrue);
    expect(mangaEntry.every((row) => (row.notes ?? '').isNotEmpty), isTrue);

    final tvFront =
        await _countImages(db, 'seed-entry-seed-tv-', 'front_cover');
    final animeFront =
        await _countImages(db, 'seed-entry-seed-anime-', 'front_cover');
    final mangaFront =
        await _countImages(db, 'seed-entry-seed-manga-', 'front_cover');
    expect(tvFront, 15);
    expect(animeFront, 15);
    expect(mangaFront, 15);

    final tvBack = await _countImages(db, 'seed-entry-seed-tv-', 'back_cover');
    final animeBack =
        await _countImages(db, 'seed-entry-seed-anime-', 'back_cover');
    final mangaBack =
        await _countImages(db, 'seed-entry-seed-manga-', 'back_cover');
    expect(tvBack, greaterThan(0));
    expect(animeBack, greaterThan(0));
    expect(mangaBack, greaterThan(0));

    final tvExtra =
        await _countImages(db, 'seed-entry-seed-tv-', 'detail_photo');
    final animeExtra =
        await _countImages(db, 'seed-entry-seed-anime-', 'detail_photo');
    final mangaExtra =
        await _countImages(db, 'seed-entry-seed-manga-', 'detail_photo');
    expect(tvExtra, greaterThan(0));
    expect(animeExtra, greaterThan(0));
    expect(mangaExtra, greaterThan(0));

    final catalogCountAfterFirstSeed = catalogRows.length;
    final imageCountAfterFirstSeed =
        (await db.select(db.itemImagesCache).get()).length;

    await seedLocalDatabase(db);

    final catalogCountAfterSecondSeed =
        (await CatalogSnapshotRepository(db).findAll()).length;
    final imageCountAfterSecondSeed =
        (await db.select(db.itemImagesCache).get()).length;
    final typedGraphCountsAfterSecondSeed = await devSeedTypedGraphCounts(db);
    final typedEntryCountsAfterSecondSeed = await devSeedTypedEntryCounts(db);
    final typedTrackingCountsAfterSecondSeed =
        await devSeedTypedTrackingCounts(db);
    final typedTrackingUnitCountsAfterSecondSeed =
        await devSeedTypedTrackingUnitCounts(db);
    final auxiliaryCountsAfterSecondSeed = await devSeedAuxiliaryCounts(db);

    expect(catalogCountAfterSecondSeed, catalogCountAfterFirstSeed);
    expect(imageCountAfterSecondSeed, imageCountAfterFirstSeed);
    expect(typedGraphCountsAfterSecondSeed, typedGraphCounts);
    expect(typedEntryCountsAfterSecondSeed, typedEntryCounts);
    expect(typedTrackingCountsAfterSecondSeed, typedTrackingCounts);
    expect(typedTrackingUnitCountsAfterSecondSeed, typedTrackingUnitCounts);
    expect(auxiliaryCountsAfterSecondSeed, auxiliaryCounts);
  });
}

bool _hasMusicTracksWithDurations(CatalogItemDto item) {
  final musicValue = item.payload['music'];
  if (musicValue is! Map) return false;
  final music = Map<String, dynamic>.from(musicValue);
  final discsValue = music['discs'];
  if (discsValue is! Iterable) return false;
  for (final discValue in discsValue) {
    if (discValue is! Map) return false;
    final tracksValue = Map<String, dynamic>.from(discValue)['tracks'];
    if (tracksValue is! Iterable) return false;
    for (final trackValue in tracksValue) {
      if (trackValue is! Map) return false;
      final track = Map<String, dynamic>.from(trackValue);
      if (track['duration_ms'] is! num) return false;
    }
  }
  return true;
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}

int _countKind(List<CatalogItemDto> rows, CatalogMediaKind kind) {
  return rows
      .where((row) => catalogMediaKindFromApiValue(row.kind) == kind)
      .length;
}

Future<int> _countImages(
  LocalDatabase db,
  String entryPrefix,
  String imageType,
) async {
  final rows = await db.select(db.itemImagesCache).get();
  return rows.where((row) {
    final libraryEntryRef = libraryEntryRefFromSerialized(row.libraryEntryRefKey);
    return libraryEntryRef?.id.value.startsWith(entryPrefix) == true &&
        row.imageType == imageType;
  }).length;
}
