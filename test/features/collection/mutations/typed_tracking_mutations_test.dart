import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_import_contributions.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late TrackingMutations trackingMutations;
  late LibraryCatalogRepository catalogCache;
  late OwnedItemsCacheRepository ownedItems;
  late TrackingEntriesCacheRepository trackingEntries;
  late MutationOrigin? observedOrigin;

  setUp(() {
    observedOrigin = null;
    db = LocalDatabase(NativeDatabase.memory());
    catalogCache = LibraryCatalogRepository(db);
    ownedItems = OwnedItemsCacheRepository(db);
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
      catalogCache: catalogCache,
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
        kind: 'movie',
        entityType: CatalogEntityType.work,
        id: 'movie-target-1',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        sourceType: TrackingSourceType.streaming,
        status: MediaTrackingStatus.inProgress,
        rating: 8,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds(['movie-target-1']))
              .single;
      expect(entry.catalogRef.kind, 'movie');
      expect(entry.catalogRef.id, 'movie-target-1');
      expect(entry.sourceType, TrackingSourceType.streaming);
      expect(entry.status, MediaTrackingStatus.inProgress);
      expect(entry.rating, 8);
    });

    test('supports OwnedItemTrackingTarget and resolves its CatalogEntityRef',
        () async {
      final owned = OwnedItem(
        id: 'owned-item-77',
        catalogRef: const CatalogEntityRef(
          kind: 'book',
          entityType: CatalogEntityType.work,
          id: 'book-77',
        ),
        details: const GenericOwnedDetails(),
        updatedAt: DateTime.now().toUtc(),
      );
      await catalogCache.upsertAll([
        testCatalogItem(id: 'book-77', kind: 'book', title: 'Test Book'),
      ]);
      await ownedItems.upsert(owned);

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.owned(owned.id),
        sourceType: TrackingSourceType.physical,
        status: MediaTrackingStatus.completed,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds(['book-77'])).single;
      expect(entry.ownedItemId, 'owned-item-77');
      expect(entry.catalogRef.kind, 'book');
      expect(entry.status, MediaTrackingStatus.completed);
    });

    test('resolves a structural anchor when the owned row is unavailable',
        () async {
      await catalogCache.upsertAll([
        testCatalogItem(
          id: 'book-anchor-target',
          kind: 'book',
          title: 'Anchored Book',
        ),
      ]);

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.owned('book-anchor-target'),
        anchor: PersonalItemAnchor.fromRaw(
          anchorType: PersonalItemAnchorType.variant.apiValue,
          editionId: 'edition-anchor',
          variantId: 'variant-anchor',
        ),
        status: MediaTrackingStatus.completed,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds(['variant-anchor']))
              .single;
      expect(entry.ownedItemId, 'book-anchor-target');
      expect(entry.catalogRef.entityType, CatalogEntityType.release);
      expect(entry.catalogRef.id, 'variant-anchor');
      expect(entry.editionId, 'edition-anchor');
      expect(entry.variantId, 'variant-anchor');
    });

    test('replaces an existing catalog anchor when explicitly cleared',
        () async {
      const ref = CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-anchor-clear',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        anchor: PersonalItemAnchor.fromRaw(
          anchorType: PersonalItemAnchorType.variant.apiValue,
          editionId: 'edition-before-clear',
          variantId: 'variant-before-clear',
        ),
      );
      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        anchor: null,
        replaceAnchor: true,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds([ref.id])).single;
      expect(entry.anchor, isNull);
      expect(entry.editionId, isNull);
      expect(entry.variantId, isNull);
      expect(entry.bundleReleaseId, isNull);
    });

    test('rejects invalid or unresolvable tracking target with ArgumentError',
        () async {
      expect(
        () => trackingMutations.upsertTrackingEntry(
          TrackingTarget.owned('non-existent-owned-id'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles unknown tracking source cleanly', () async {
      const ref = CatalogEntityRef(
        kind: 'game',
        entityType: CatalogEntityType.work,
        id: 'game-100',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        sourceType: trackingSourceTypeFromValue('unknown_source'),
        status: MediaTrackingStatus.planned,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds(['game-100'])).single;
      expect(entry.sourceType, isNull);
    });

    test('preserves typed unit ratings map', () async {
      const ref = CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: 'tv-series-1',
      );

      const unitRatings = {
        'ep:tv-series-1:1:1': 9,
        'ep:tv-series-1:1:2': 10,
      };

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.inProgress,
        customizeEntry: (entry) => entry.copyWith(
          seasonNumber: 2,
          episodeNumber: 4,
          episodeRatings: unitRatings,
        ),
      );

      final entry =
          (await trackingEntries.findActiveByItemIds(['tv-series-1'])).single;
      expect(entry.seasonNumber, 2);
      expect(entry.episodeNumber, 4);
      expect(entry.episodeRatings, equals(unitRatings));
    });

    test('does not introduce hardcoded comic fallback kind', () async {
      const ref = CatalogEntityRef(
        kind: 'music',
        entityType: CatalogEntityType.work,
        id: 'music-album-99',
      );

      await trackingMutations.upsertTrackingEntry(
        TrackingTarget.catalog(ref),
        status: MediaTrackingStatus.completed,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds(['music-album-99']))
              .single;
      expect(entry.catalogRef.kind, 'music');
      expect(entry.catalogRef.kind, isNot('comic'));
    });

    test('forwards file import origin through tracking mutation', () async {
      const ref = CatalogEntityRef(
        kind: 'anime',
        entityType: CatalogEntityType.work,
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

      await tvTrackingImportContribution.addLocalOnlySeasonEntry(
        trackingMutations,
        seasonItem,
        seasonNumber: 2,
        status: MediaTrackingStatus.completed,
      );

      final entry = (await trackingEntries.listActive()).single;
      expect(entry.catalogRef.kind, 'tv');
      expect(entry.seasonNumber, 2);
      expect(
        trackingEntries.toSyncPayload(entry)['season_number'],
        2,
      );
    });

    test('owned sync preserves kind-owned tracking state on existing entries',
        () async {
      const ref = CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: 'tv-owned-1',
      );
      final owned = OwnedItem(
        id: 'owned-tv-1',
        catalogRef: ref,
        details: const GenericOwnedDetails(),
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertAll([
        testCatalogItem(id: ref.id, kind: ref.kind, title: 'Tracked Show'),
      ]);
      await ownedItems.upsert(owned);
      await trackingEntries.upsert(
        TrackingEntry(
          id: 'tracking-tv-1',
          catalogRef: ref,
          ownedItemId: owned.id,
          seasonNumber: 4,
          episodeNumber: 9,
          episodeRatings: const {'4:9': 10},
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      await trackingMutations.syncOwnedTrackingEntry(
        owned,
        status: MediaTrackingStatus.inProgress,
        progressCurrent: 9,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds([ref.id])).single;
      expect(entry.seasonNumber, 4);
      expect(entry.episodeNumber, 9);
      expect(entry.episodeRatings, const {'4:9': 10});
      expect(entry.progressCurrent, 9);
    });

    test('owned sync can explicitly clear an inherited anchor', () async {
      const ref = CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-owned-anchor-clear',
      );
      final owned = OwnedItem(
        id: 'owned-book-anchor-clear',
        catalogRef: ref,
        anchor: PersonalItemAnchor.fromRaw(
          anchorType: PersonalItemAnchorType.edition.apiValue,
          editionId: 'edition-owned-before-clear',
        ),
        details: const GenericOwnedDetails(),
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await catalogCache.upsertAll([
        testCatalogItem(id: ref.id, kind: ref.kind, title: 'Anchored Book'),
      ]);
      await ownedItems.upsert(owned);
      await trackingMutations.syncOwnedTrackingEntry(owned);

      await trackingMutations.syncOwnedTrackingEntry(
        owned,
        anchor: null,
        replaceAnchor: true,
      );

      final entry =
          (await trackingEntries.findActiveByItemIds([ref.id])).single;
      expect(entry.anchor, isNull);
      expect(entry.editionId, isNull);
      expect(entry.variantId, isNull);
      expect(entry.bundleReleaseId, isNull);
    });

    test('updateTrackingEntry applies explicit clears', () async {
      const ref = CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
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
