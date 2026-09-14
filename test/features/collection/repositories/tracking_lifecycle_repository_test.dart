import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_import.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_storage_codecs.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_lifecycle.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV codec reconstructs hierarchy coordinates from sync payload', () {
    const codec = TvTrackingLifecycleCodec();
    final updatedAt = DateTime.utc(2026, 9, 6, 12);
    final entry = TvTrackingLifecycle(
      id: 'tv-sync-1',
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.tv,
        entityType: CatalogEntityTypeId('work'),
        id: 'tv-1',
      ),
      coordinates: TvTrackingCoordinates(
        seasonNumber: 3,
        episodeNumber: 7,
        episodeRatings: const {'3:7': 10},
      ),
      updatedAt: updatedAt,
    );

    final restored = codec.fromSyncPayload(
      payload: codec.toSyncPayload(entry),
      id: entry.id,
      updatedAt: updatedAt,
    );
    expect(
        restored.catalogRef.entityType, const CatalogEntityTypeId('episode'));
    final coordinates = tvTrackingCoordinatesFor(restored);
    expect(coordinates.seasonNumber, 3);
    expect(coordinates.episodeNumber, 7);
    expect(coordinates.episodeRatings, {'3:7': 10});
  });

  test('round-trips TV tracking coordinates through the TV codec', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingStorageRepository(
      db,
      codecs: collectarrTrackingStorageCodecs,
    );

    await repository.upsertStorageRecord(
      TvTrackingLifecycle(
        id: 'tv-tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.tv,
          entityType: CatalogEntityTypeId('episode'),
          id: 'episode-1',
          rootId: 'tv-1',
        ),
        coordinates: TvTrackingCoordinates(
          seasonNumber: 2,
          episodeNumber: 4,
          episodeRatings: const {'2:4': 9},
        ),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    );

    final entry = await repository.findStorageRecordByRef(
      const TrackingLifecycleRef(
        kind: CatalogMediaKind.tv,
        id: 'tv-tracking-1',
      ),
    );
    final typed = await db.select(db.tvTrackingRows).getSingle();
    expect(entry?.catalogRef.entityType, const CatalogEntityTypeId('episode'));
    expect(entry?.catalogRef.id, 'episode-1');
    expect(entry?.catalogRef.rootId, 'tv-1');
    final coordinates = tvTrackingCoordinatesFor(entry!);
    expect(coordinates.seasonNumber, 2);
    expect(coordinates.episodeNumber, 4);
    expect(coordinates.episodeRatings, {'2:4': 9});
    expect(typed.seasonNumber, 2);
    expect(typed.episodeNumber, 4);
    expect(typed.episodeRatingsJson, '{"2:4":9}');
    expect(
      repository.toSyncPayload(entry),
      containsPair('episode_ratings', {'2:4': 9}),
    );
    expect(repository.toSyncPayload(entry), containsPair('season_number', 2));

    final summary = (await repository.listActiveSummaries()).single;
    expect(
        summary.ref,
        const TrackingLifecycleRef(
          kind: CatalogMediaKind.tv,
          id: 'tv-tracking-1',
        ));
    expect(summary.progress.current, isNull);
    expect(summary.progress.total, isNull);
  });

  test('sync payload boundary keeps concrete lifecycle out of sync callers',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingStorageRepository(
      db,
      codecs: collectarrTrackingStorageCodecs,
    );
    const ref = TrackingLifecycleRef(
      kind: CatalogMediaKind.movie,
      id: 'movie-sync-boundary-1',
    );
    await repository.upsertStorageRecord(
      MovieTrackingLifecycle(
        id: ref.id,
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: CatalogEntityTypeId('work'),
          id: 'movie-sync-boundary',
        ),
        progressCurrent: 2,
        progressTotal: 10,
        updatedAt: DateTime.utc(2026, 9, 14),
      ),
    );

    final serialized = await repository.syncPayloadByRef(ref);
    expect(serialized, isNotNull);
    expect(serialized!.ref, ref);
    expect(serialized.payload['progress_current'], 2);

    final restoredDb = LocalDatabase(NativeDatabase.memory());
    addTearDown(restoredDb.close);
    final restoredRepository = TrackingStorageRepository(
      restoredDb,
      codecs: collectarrTrackingStorageCodecs,
    );
    await restoredRepository.upsertSyncPayloads([
      TrackingStorageSyncInput(
        ref: ref,
        payload: serialized.payload,
        updatedAt: DateTime.utc(2026, 9, 15),
      ),
    ]);
    final restored = await restoredRepository.findSummaryByRef(ref);
    expect(restored?.progress.current, 2);
    expect(restored?.progress.total, 10);
  });

  test('does not persist hierarchy coordinates for a non-episodic kind',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingStorageRepository(
      db,
      codecs: collectarrTrackingStorageCodecs,
    );

    await repository.upsertStorageRecord(
      MovieTrackingLifecycle(
        id: 'movie-tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: CatalogEntityTypeId('work'),
          id: 'movie-1',
        ),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    );

    final entry = await repository.findStorageRecordByRef(
      const TrackingLifecycleRef(
        kind: CatalogMediaKind.movie,
        id: 'movie-tracking-1',
      ),
    );
    expect(await db.select(db.tvTrackingRows).get(), isEmpty);
    expect(
      repository.toSyncPayload(entry!),
      isNot(contains('season_number')),
    );
    expect(
      repository.toSyncPayload(entry),
      isNot(contains('episode_number')),
    );
  });

  test('applies schema-v1 tracking imports at the persistence boundary',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingStorageRepository(
      db,
      codecs: collectarrTrackingStorageCodecs,
    );
    const catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: CatalogEntityTypeId('work'),
      id: 'comic-import-1',
    );
    const ownedRef = OwnedItemRef(
      kind: CatalogMediaKind.comic,
      id: OwnedItemId('owned-import-1'),
    );

    final results = await repository.upsertImportedAll([
      TrackingStorageImport(
        entryId: 'tracking-import-1',
        catalogRef: catalogRef,
        ownedRef: ownedRef,
        now: DateTime.utc(2026, 9, 14),
        rating: 9,
        status: 'Completed',
      ),
    ]);

    expect(results, hasLength(1));
    expect(results.single.catalogRef, catalogRef);
    expect(results.single.payload['status'], 'Completed');
    expect(results.single.payload['rating'], 9);
    final persisted =
        await repository.findStorageRecordByRef(results.single.ref);
    expect(persisted?.ownedRef, ownedRef);
    expect(persisted?.rating, 9);
  });
}
