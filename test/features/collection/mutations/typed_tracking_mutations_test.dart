import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/entries/entry_import_transport.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late TrackingMutations trackingMutations;
  late CatalogTransportRepository catalogCache;
  late LibraryEntriesRepository libraryEntries;
  late TrackingStorageRepository trackingRecords;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalogCache = CatalogTransportRepository(db);
    libraryEntries = LibraryEntriesRepository(db);
    trackingRecords = TrackingStorageRepository(
      db,
      codecs: libraryTrackingStorageCodecs,
    );
    final runner = CollectionMutationRunner(
      database: db,
      events: CollectionEventBus(),
    );

    trackingMutations = TrackingMutations(
      trackingRecords: trackingRecords,
      trackingUnits: TrackingUnitStorageRepository(
        db,
        codecs: libraryTrackingUnitCodecs,
      ),
      watchSessions: WatchSessionsRepository(
        db,
        codecs: libraryWatchSessionCodecs,
      ),
      libraryEntries: libraryEntries,
      syncQueue: SyncQueueRepository(db),
      mutationRunner: runner,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Typed Tracking Mutations Contract Tests', () {
    test('supports CatalogTrackingTarget with valid CatalogEntityRef',
        () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'movie-target-1',
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(ref),
        sourceType: TrackingSourceType.streaming,
        status: MediaTrackingStatus.inProgress,
        rating: 8,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('movie-target-1', kind: 'movie'),
      ]))
              .single;
      expect(entry.catalogRef.kind.apiValue, 'movie');
      expect(entry.catalogRef.id, 'movie-target-1');
      expect(entry.sourceType, TrackingSourceType.streaming);
      expect(entry.status, MediaTrackingStatus.inProgress);
      expect(entry.rating, 8);
    });

    test(
        'supports LibraryEntryTrackingTarget and resolves its CatalogEntityRef',
        () async {
      final entry = BookLibraryEntry(
        id: LibraryEntryId('entry-item-77'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'entry-item-77',
        ),
        catalogData: const {'title': 'Test Book'},
        details: const BookEntryDetails(),
        updatedAt: DateTime.now().toUtc(),
      );
      await catalogCache.upsertTransportItems([
        testCatalogItem(id: 'book-77', kind: 'book', title: 'Test Book'),
      ]);
      await libraryEntries.replaceFromTransport(
        EntryImportTransport(
          ref: LibraryEntryRef(
            kind: CatalogMediaKind.book,
            id: LibraryEntryId(entry.id.value),
          ),
          payload: LibraryEntryRecord(
            id: entry.id.value,
            kind: CatalogMediaKind.book,
            catalogData: const {'title': 'Test Book'},
            personalData: const {},
            updatedAt: entry.updatedAt,
          ).toJson(),
        ),
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.entry(
          LibraryEntryRef(
            kind: CatalogMediaKind.book,
            id: LibraryEntryId(entry.id.value),
          ),
        ),
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.completed,
      );

      final trackingEntry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('entry-item-77', kind: 'book'),
      ]))
              .single;
      expect(trackingEntry.libraryEntryRef,
          LibraryEntryRef.fromKey('book:entry-item-77'));
      expect(trackingEntry.catalogRef.kind.apiValue, 'book');
      expect(trackingEntry.status, MediaTrackingStatus.completed);
    });

    test('rejects invalid or unresolvable tracking target with ArgumentError',
        () async {
      expect(
        () => trackingMutations.upsertTrackingState(
          TrackingTarget.entry(
            const LibraryEntryRef(
              kind: CatalogMediaKind.book,
              id: LibraryEntryId('non-existent-entry-id'),
            ),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles unknown tracking source cleanly', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.game,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'game-100',
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(ref),
        sourceType: trackingSourceTypeFromValue('unknown_source'),
        status: MediaTrackingStatus.planned,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('game-100', kind: 'game'),
      ]))
              .single;
      expect(entry.sourceType, isNull);
    });

    test('preserves typed unit ratings map', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'tv-series-1',
      );

      const unitRatings = {
        'ep:tv-series-1:1:1': 9,
        'ep:tv-series-1:1:2': 10,
      };

      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.inProgress,
        kindPatch: TvTrackingCoordinatesPatch(
          seasonNumber: 2,
          episodeNumber: 4,
          episodeRatings: unitRatings,
          setSeasonNumber: true,
          setEpisodeNumber: true,
          setEpisodeRatings: true,
        ),
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('tv-series-1', kind: 'tv'),
      ]))
              .single;
      final coordinates = tvTrackingCoordinatesFor(entry);
      expect(coordinates.seasonNumber, 2);
      expect(coordinates.episodeNumber, 4);
      expect(coordinates.episodeRatings, equals(unitRatings));
    });

    test('uses the concrete Music Catalog Item tracking target', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'music-album-99',
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.completed,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('music-album-99', kind: 'music'),
      ]))
              .single;
      expect(entry.catalogRef.kind.apiValue, 'music');
      expect(entry.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
      expect(entry.catalogRef.id, 'music-album-99');
    });

    test('keeps TV season coordinates in the TV tracking patch', () async {
      final seasonItem = testCatalogItem(
        id: 'tv-item:123:season:2',
        kind: 'tv',
        title: 'Season 2',
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(CatalogEntityRef(
          id: seasonItem.id,
          kind: CatalogMediaKind.tv,
          entityType: CatalogEntityTypeId.catalogItem,
        )),
        status: MediaTrackingStatus.completed,
        kindPatch: const TvTrackingCoordinatesPatch(
          seasonNumber: 2,
          setSeasonNumber: true,
        ),
      );

      final entry = (await trackingRecords.listActiveStorageRecords()).single;
      expect(entry.catalogRef.kind.apiValue, 'tv');
      expect(tvTrackingCoordinatesFor(entry).seasonNumber, 2);
      expect(
        trackingRecords.toSyncPayload(entry)['season_number'],
        2,
      );
    });

    test('entry sync preserves kind-entry tracking state on existing entries',
        () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'entry-tv-1',
      );
      final entry = TvLibraryEntry(
        id: LibraryEntryId('entry-tv-1'),
        catalogRef: ref,
        details: const TvEntryDetails(),
        catalogData: const {'title': 'Tracked Show'},
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertTransportItems([
        testCatalogItem(
          id: ref.id,
          kind: ref.kind.apiValue,
          title: 'Tracked Show',
        ),
      ]);
      await libraryEntries.replaceFromTransport(
        EntryImportTransport(
          ref: LibraryEntryRef(
            kind: CatalogMediaKind.tv,
            id: LibraryEntryId(entry.id.value),
          ),
          payload: LibraryEntryRecord(
            id: entry.id.value,
            kind: CatalogMediaKind.tv,
            catalogData: const {'title': 'Tracked Show'},
            personalData: const {},
            updatedAt: entry.updatedAt,
          ).toJson(),
        ),
      );
      await trackingRecords.upsertStorageRecord(
        TvTrackingState(
          id: 'tracking-tv-1',
          catalogRef: ref,
          libraryEntryRef: LibraryEntryRef(
            kind: CatalogMediaKind.tv,
            id: LibraryEntryId(entry.id.value),
          ),
          coordinates: TvTrackingCoordinates(
            seasonNumber: 4,
            episodeNumber: 9,
            episodeRatings: const {'4:9': 10},
          ),
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      await trackingMutations.syncEntryTrackingState(
        LibraryEntryRef(
          kind: CatalogMediaKind.tv,
          id: LibraryEntryId(entry.id.value),
        ),
        catalogRef: entry.catalogRef,
        isDigital: entry.isDigital,
        status: MediaTrackingStatus.inProgress,
        progressCurrent: 9,
      );

      final trackingEntry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([ref]))
              .single;
      final coordinates = tvTrackingCoordinatesFor(trackingEntry);
      expect(coordinates.seasonNumber, 4);
      expect(coordinates.episodeNumber, 9);
      expect(coordinates.episodeRatings, const {'4:9': 10});
      expect(trackingEntry.progress.current, 9);
    });

    test('typed tracking repository applies explicit clears', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-clear-1',
      );
      final existing = BookTrackingState(
        id: 'tracking-clear-1',
        catalogRef: ref,
        status: MediaTrackingStatus.completed,
        rating: 9,
        startedAt: DateTime.utc(2026, 6, 1),
        finishedAt: DateTime.utc(2026, 6, 2),
        notes: 'Finished',
        updatedAt: DateTime.utc(2026, 6, 2),
      );
      await trackingRecords.upsertStorageRecord(existing);

      await trackingRecords.upsertStorageRecord(
        existing.copyWith(
          status: null,
          rating: null,
          startedAt: null,
          finishedAt: null,
          notes: null,
        ),
      );

      final updated = await trackingRecords.findStorageRecordByRef(
        const TrackingStateRef(
          kind: CatalogMediaKind.book,
          id: 'tracking-clear-1',
        ),
      );
      expect(updated?.status, isNull);
      expect(updated?.rating, isNull);
      expect(updated?.startedAt, isNull);
      expect(updated?.finishedAt, isNull);
      expect(updated?.notes, isNull);
    });

    test('rejects an Entry ref from a different kind at the storage boundary',
        () async {
      const catalogRef = CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'movie-kind-check',
      );

      expect(
        () => trackingRecords.upsertStorageRecord(
          MovieTrackingState(
            id: 'tracking-kind-check',
            catalogRef: catalogRef,
            libraryEntryRef: const LibraryEntryRef(
              kind: CatalogMediaKind.book,
              id: LibraryEntryId('book-entry'),
            ),
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
