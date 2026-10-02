import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/library/ownership/collection_items_repository.dart';
import 'package:collectarr_app/features/library/ownership/owned_import_transport.dart';
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
  late CollectionItemsRepository collectionItems;
  late TrackingStorageRepository trackingRecords;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalogCache = CatalogTransportRepository(db);
    collectionItems = CollectionItemsRepository(db);
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
      collectionItems: collectionItems,
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

    test('supports CollectionItemTrackingTarget and resolves its CatalogEntityRef',
        () async {
      final owned = BookCollectionItem(
        id: CollectionItemId('owned-item-77'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'book-77',
        ),
        details: const BookOwnedDetails(),
        updatedAt: DateTime.now().toUtc(),
      );
      await catalogCache.upsertTransportItems([
        testCatalogItem(id: 'book-77', kind: 'book', title: 'Test Book'),
      ]);
      await collectionItems.replaceFromTransport(
        OwnedImportTransport(
          ref: CollectionItemRef(
            kind: CatalogMediaKind.book,
            id: CollectionItemId(owned.id.value),
          ),
          catalogRef: owned.catalogRef,
          payload: owned.toJson(),
        ),
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.owned(
          CollectionItemRef(
            kind: CatalogMediaKind.book,
            id: CollectionItemId(owned.id.value),
          ),
        ),
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.completed,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('book-77', kind: 'book'),
      ]))
              .single;
      expect(entry.collectionItemRef, CollectionItemRef.fromKey('book:owned-item-77'));
      expect(entry.catalogRef.kind.apiValue, 'book');
      expect(entry.status, MediaTrackingStatus.completed);
    });

    test('accepts a structural target when the owned row is unavailable',
        () async {
      await trackingMutations.upsertTrackingState(
        TrackingTarget.owned(
          const CollectionItemRef(
            kind: CatalogMediaKind.book,
            id: CollectionItemId('book-anchor-target'),
          ),
        ),
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('release'),
          id: 'variant-anchor',
          rootId: 'book-anchor-target',
          parentId: 'edition-anchor',
        ),
        status: MediaTrackingStatus.completed,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([
        testCatalogRef('book-anchor-target', kind: 'book'),
      ]))
              .single;
      expect(entry.collectionItemRef, CollectionItemRef.fromKey('book:book-anchor-target'));
      expect(entry.catalogRef.entityType, const CatalogEntityTypeId('release'));
      expect(entry.catalogRef.id, 'variant-anchor');
      expect(entry.catalogRef.rootId, 'book-anchor-target');
    });

    test('replaces an existing catalog target when explicitly cleared',
        () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-anchor-clear',
      );

      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(ref),
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('release'),
          id: 'variant-before-clear',
          rootId: 'book-anchor-clear',
          parentId: 'edition-before-clear',
        ),
      );
      await trackingMutations.upsertTrackingState(
        TrackingTarget.catalog(ref),
        targetRef: ref,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([ref]))
              .single;
      expect(entry.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
      expect(entry.catalogRef.id, ref.id);
    });

    test('rejects invalid or unresolvable tracking target with ArgumentError',
        () async {
      expect(
        () => trackingMutations.upsertTrackingState(
          TrackingTarget.owned(
            const CollectionItemRef(
              kind: CatalogMediaKind.book,
              id: CollectionItemId('non-existent-owned-id'),
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

    test('does not introduce hardcoded comic fallback kind', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId('release'),
        id: 'music-release-99',
        rootId: 'music-album-99',
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
      expect(entry.catalogRef.kind, isNot('comic'));
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

    test('owned sync preserves kind-owned tracking state on existing entries',
        () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'tv-owned-1',
      );
      final owned = TvCollectionItem(
        id: CollectionItemId('owned-tv-1'),
        catalogRef: ref,
        details: const TvOwnedDetails(),
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertTransportItems([
        testCatalogItem(
          id: ref.id,
          kind: ref.kind.apiValue,
          title: 'Tracked Show',
        ),
      ]);
      await collectionItems.replaceFromTransport(
        OwnedImportTransport(
          ref: CollectionItemRef(
            kind: CatalogMediaKind.tv,
            id: CollectionItemId(owned.id.value),
          ),
          catalogRef: owned.catalogRef,
          payload: owned.toJson(),
        ),
      );
      await trackingRecords.upsertStorageRecord(
        TvTrackingState(
          id: 'tracking-tv-1',
          catalogRef: ref,
          collectionItemRef: CollectionItemRef(
            kind: CatalogMediaKind.tv,
            id: CollectionItemId(owned.id.value),
          ),
          coordinates: TvTrackingCoordinates(
            seasonNumber: 4,
            episodeNumber: 9,
            episodeRatings: const {'4:9': 10},
          ),
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      await trackingMutations.syncOwnedTrackingState(
        CollectionItemRef(
          kind: CatalogMediaKind.tv,
          id: CollectionItemId(owned.id.value),
        ),
        catalogRef: owned.catalogRef,
        isDigital: owned.isDigital,
        targetRef: ref,
        status: MediaTrackingStatus.inProgress,
        progressCurrent: 9,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([ref]))
              .single;
      final coordinates = tvTrackingCoordinatesFor(entry);
      expect(coordinates.seasonNumber, 4);
      expect(coordinates.episodeNumber, 9);
      expect(coordinates.episodeRatings, const {'4:9': 10});
      expect(entry.progress.current, 9);
    });

    test('owned sync can explicitly replace its catalog target', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-owned-anchor-clear',
      );
      final owned = BookCollectionItem(
        id: CollectionItemId('owned-book-anchor-clear'),
        catalogRef: ref,
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('edition'),
          id: 'edition-owned-before-clear',
        ),
        details: const BookOwnedDetails(),
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertTransportItems([
        testCatalogItem(
          id: ref.id,
          kind: ref.kind.apiValue,
          title: 'Anchored Book',
        ),
      ]);
      await collectionItems.replaceFromTransport(
        OwnedImportTransport(
          ref: CollectionItemRef(
            kind: CatalogMediaKind.book,
            id: CollectionItemId(owned.id.value),
          ),
          catalogRef: owned.catalogRef,
          payload: owned.toJson(),
        ),
      );
      final collectionItemRef = CollectionItemRef(
        kind: CatalogMediaKind.book,
        id: CollectionItemId(owned.id.value),
      );
      await trackingMutations.syncOwnedTrackingState(
        collectionItemRef,
        catalogRef: owned.catalogRef,
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('edition'),
          id: 'edition-owned-before-clear',
          rootId: 'book-owned-anchor-clear',
        ),
        isDigital: owned.isDigital,
      );

      await trackingMutations.syncOwnedTrackingState(
        collectionItemRef,
        catalogRef: owned.catalogRef,
        targetRef: ref,
      );

      final entry =
          (await trackingRecords.findActiveStorageRecordsByCatalogRoots([ref]))
              .single;
      expect(entry.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
      expect(entry.catalogRef.id, ref.id);
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

    test('rejects an Owned ref from a different kind at the storage boundary',
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
            collectionItemRef: const CollectionItemRef(
              kind: CatalogMediaKind.book,
              id: CollectionItemId('book-owned'),
            ),
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
