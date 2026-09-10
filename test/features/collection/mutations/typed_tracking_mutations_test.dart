import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/tmdb/tv_tracking_import_contribution.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late TrackingMutations trackingMutations;
  late CatalogTransportRepository catalogCache;
  late OwnedItemsRepository ownedItems;
  late TrackingEntriesCacheRepository trackingEntries;
  late MutationOrigin? observedOrigin;

  setUp(() {
    observedOrigin = null;
    db = LocalDatabase(NativeDatabase.memory());
    catalogCache = CatalogTransportRepository(db);
    ownedItems = OwnedItemsRepository(db);
    trackingEntries = TrackingEntriesCacheRepository(
      db,
      codecs: collectarrTrackingEntryCodecs,
    );
    final runner = CollectionMutationRunner(
      database: db,
      events: CollectionEventBus(),
      mutationOriginHandler: (origin) => observedOrigin = origin,
    );

    trackingMutations = TrackingMutations(
      trackingEntries: trackingEntries,
      trackingUnits: TrackingUnitsCacheRepository(
        db,
        codecs: collectarrTrackingUnitCodecs,
      ),
      watchSessions: WatchSessionsRepository(
        db,
        codecs: collectarrWatchSessionCodecs,
      ),
      ownedItems: ownedItems,
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
        entityType: const CatalogEntityTypeId('work'),
        id: 'movie-target-1',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        sourceType: TrackingSourceType.streaming,
        status: MediaTrackingStatus.inProgress,
        rating: 8,
      );

      final entry = (await trackingEntries.findActiveByCatalogRoots([
        testCatalogRef('movie-target-1', kind: 'movie'),
      ]))
          .single;
      expect(entry.catalogRef.kind.apiValue, 'movie');
      expect(entry.catalogRef.id, 'movie-target-1');
      expect(entry.sourceType, TrackingSourceType.streaming);
      expect(entry.status, MediaTrackingStatus.inProgress);
      expect(entry.rating, 8);
    });

    test('supports OwnedItemTrackingTarget and resolves its CatalogEntityRef',
        () async {
      final owned = BookOwnedItem(
        id: BookOwnedItemId('owned-item-77'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: const CatalogEntityTypeId('work'),
          id: 'book-77',
        ),
        details: const BookOwnedDetails(),
        updatedAt: DateTime.now().toUtc(),
      );
      await catalogCache.upsertAll([
        testCatalogItem(id: 'book-77', kind: 'book', title: 'Test Book'),
      ]);
      await ownedItems.upsertTyped(CatalogMediaKind.book, owned);

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.owned(
          OwnedItemRef(
            kind: CatalogMediaKind.book,
            id: OwnedItemId(owned.id.value),
          ),
        ),
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.completed,
      );

      final entry = (await trackingEntries.findActiveByCatalogRoots([
        testCatalogRef('book-77', kind: 'book'),
      ]))
          .single;
      expect(entry.ownedRef, OwnedItemRef.fromKey('book:owned-item-77'));
      expect(entry.catalogRef.kind.apiValue, 'book');
      expect(entry.status, MediaTrackingStatus.completed);
    });

    test('accepts a structural target when the owned row is unavailable',
        () async {
      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.owned(
          const OwnedItemRef(
            kind: CatalogMediaKind.book,
            id: OwnedItemId('book-anchor-target'),
          ),
        ),
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: const CatalogEntityTypeId('release'),
          id: 'variant-anchor',
          rootId: 'book-anchor-target',
          parentId: 'edition-anchor',
        ),
        status: MediaTrackingStatus.completed,
      );

      final entry = (await trackingEntries.findActiveByCatalogRoots([
        testCatalogRef('book-anchor-target', kind: 'book'),
      ]))
          .single;
      expect(entry.ownedRef, OwnedItemRef.fromKey('book:book-anchor-target'));
      expect(entry.catalogRef.entityType, const CatalogEntityTypeId('release'));
      expect(entry.catalogRef.id, 'variant-anchor');
      expect(entry.catalogRef.rootId, 'book-anchor-target');
    });

    test('replaces an existing catalog target when explicitly cleared',
        () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: const CatalogEntityTypeId('work'),
        id: 'book-anchor-clear',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('release'),
          id: 'variant-before-clear',
          rootId: 'book-anchor-clear',
          parentId: 'edition-before-clear',
        ),
      );
      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        targetRef: ref,
      );

      final entry =
          (await trackingEntries.findActiveByCatalogRoots([ref])).single;
      expect(entry.catalogRef.entityType, const CatalogEntityTypeId('work'));
      expect(entry.catalogRef.id, ref.id);
    });

    test('rejects invalid or unresolvable tracking target with ArgumentError',
        () async {
      expect(
        () => trackingMutations.upsertTrackingEntry(
          TrackingTarget.owned(
            const OwnedItemRef(
              kind: CatalogMediaKind.book,
              id: OwnedItemId('non-existent-owned-id'),
            ),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles unknown tracking source cleanly', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.game,
        entityType: const CatalogEntityTypeId('work'),
        id: 'game-100',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        sourceType: trackingSourceTypeFromValue('unknown_source'),
        status: MediaTrackingStatus.planned,
      );

      final entry = (await trackingEntries.findActiveByCatalogRoots([
        testCatalogRef('game-100', kind: 'game'),
      ]))
          .single;
      expect(entry.sourceType, isNull);
    });

    test('preserves typed unit ratings map', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: const CatalogEntityTypeId('work'),
        id: 'tv-series-1',
      );

      const unitRatings = {
        'ep:tv-series-1:1:1': 9,
        'ep:tv-series-1:1:2': 10,
      };

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.inProgress,
        customizeEntry: (entry) =>
            tvTrackingEntryFor(entry).copyWithCoordinates(
          seasonNumber: 2,
          episodeNumber: 4,
          episodeRatings: unitRatings,
        ),
      );

      final entry = (await trackingEntries.findActiveByCatalogRoots([
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
        entityType: const CatalogEntityTypeId('work'),
        id: 'music-album-99',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.completed,
      );

      final entry = (await trackingEntries.findActiveByCatalogRoots([
        testCatalogRef('music-album-99', kind: 'music'),
      ]))
          .single;
      expect(entry.catalogRef.kind.apiValue, 'music');
      expect(entry.catalogRef.kind, isNot('comic'));
    });

    test('forwards file import origin through tracking mutation', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.anime,
        entityType: const CatalogEntityTypeId('work'),
        id: 'anime-import-1',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.completed,
        origin: MutationOrigin.fileImport,
      );

      expect(observedOrigin, MutationOrigin.fileImport);
    });

    test('keeps TV season coordinates in the TV import contribution', () async {
      final seasonItem = testCatalogItem(
        id: 'tmdb-local:tv:123:season:2',
        kind: 'tv',
        title: 'Season 2',
      );

      await const TvTrackingImportContribution().addLocalOnlySeasonEntry(
        trackingMutations,
        seasonItem,
        seasonNumber: 2,
        status: MediaTrackingStatus.completed,
      );

      final entry = (await trackingEntries.listActive()).single;
      expect(entry.catalogRef.kind.apiValue, 'tv');
      expect(tvTrackingCoordinatesFor(entry).seasonNumber, 2);
      expect(
        trackingEntries.toSyncPayload(entry)['season_number'],
        2,
      );
    });

    test('owned sync preserves kind-owned tracking state on existing entries',
        () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: const CatalogEntityTypeId('work'),
        id: 'tv-owned-1',
      );
      final owned = TvOwnedItem(
        id: TvOwnedItemId('owned-tv-1'),
        catalogRef: ref,
        details: const TvOwnedDetails(),
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertAll([
        testCatalogItem(
          id: ref.id,
          kind: ref.kind.apiValue,
          title: 'Tracked Show',
        ),
      ]);
      await ownedItems.upsertTyped(CatalogMediaKind.tv, owned);
      await trackingEntries.upsert(
        TvTrackingEntry(
          id: 'tracking-tv-1',
          catalogRef: ref,
          ownedRef: OwnedItemRef(
            kind: CatalogMediaKind.tv,
            id: OwnedItemId(owned.id.value),
          ),
          coordinates: TvTrackingCoordinates(
            seasonNumber: 4,
            episodeNumber: 9,
            episodeRatings: const {'4:9': 10},
          ),
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      await trackingMutations.syncOwnedTrackingEntry(
        OwnedItemRef(
          kind: CatalogMediaKind.tv,
          id: OwnedItemId(owned.id.value),
        ),
        catalogRef: owned.catalogRef,
        isDigital: owned.isDigital,
        targetRef: ref,
        status: MediaTrackingStatus.inProgress,
        progressCurrent: 9,
      );

      final entry =
          (await trackingEntries.findActiveByCatalogRoots([ref])).single;
      final coordinates = tvTrackingCoordinatesFor(entry);
      expect(coordinates.seasonNumber, 4);
      expect(coordinates.episodeNumber, 9);
      expect(coordinates.episodeRatings, const {'4:9': 10});
      expect(entry.progressCurrent, 9);
    });

    test('owned sync can explicitly replace its catalog target', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: const CatalogEntityTypeId('work'),
        id: 'book-owned-anchor-clear',
      );
      final owned = BookOwnedItem(
        id: BookOwnedItemId('owned-book-anchor-clear'),
        catalogRef: ref,
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('edition'),
          id: 'edition-owned-before-clear',
        ),
        details: const BookOwnedDetails(),
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertAll([
        testCatalogItem(
          id: ref.id,
          kind: ref.kind.apiValue,
          title: 'Anchored Book',
        ),
      ]);
      await ownedItems.upsertTyped(CatalogMediaKind.book, owned);
      final ownedRef = OwnedItemRef(
        kind: CatalogMediaKind.book,
        id: OwnedItemId(owned.id.value),
      );
      await trackingMutations.syncOwnedTrackingEntry(
        ownedRef,
        catalogRef: owned.catalogRef,
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId('edition'),
          id: 'edition-owned-before-clear',
          rootId: 'book-owned-anchor-clear',
        ),
        isDigital: owned.isDigital,
      );

      await trackingMutations.syncOwnedTrackingEntry(
        ownedRef,
        catalogRef: owned.catalogRef,
        targetRef: ref,
      );

      final entry =
          (await trackingEntries.findActiveByCatalogRoots([ref])).single;
      expect(entry.catalogRef.entityType, const CatalogEntityTypeId('work'));
      expect(entry.catalogRef.id, ref.id);
    });

    test('updateTrackingEntry applies explicit clears', () async {
      const ref = CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: const CatalogEntityTypeId('work'),
        id: 'book-clear-1',
      );
      final existing = TrackingEntry(
        id: 'tracking-clear-1',
        catalogRef: ref,
        status: MediaTrackingStatus.completed,
        rating: 9,
        startedAt: DateTime.utc(2026, 6, 1),
        finishedAt: DateTime.utc(2026, 6, 2),
        notes: 'Finished',
        updatedAt: DateTime.utc(2026, 6, 2),
      );
      await trackingEntries.upsert(existing);

      await trackingMutations.updateTrackingEntry(
        existing.copyWith(
          status: null,
          rating: null,
          startedAt: null,
          finishedAt: null,
          notes: null,
        ),
      );

      final updated = await trackingEntries.findById(existing.id);
      expect(updated?.status, isNull);
      expect(updated?.rating, isNull);
      expect(updated?.startedAt, isNull);
      expect(updated?.finishedAt, isNull);
      expect(updated?.notes, isNull);
    });
  });
}
