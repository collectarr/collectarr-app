import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_lifecycle_codecs.dart';
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
        entityType: const CatalogEntityTypeId('work'),
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
    final repository = TrackingLifecycleRepository(
      db,
      codecs: collectarrTrackingLifecycleCodecs,
    );

    await repository.upsert(
      TvTrackingLifecycle(
        id: 'tv-tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.tv,
          entityType: const CatalogEntityTypeId('episode'),
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

    final entry = await repository.findByRef(
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
  });

  test('does not persist hierarchy coordinates for a non-episodic kind',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingLifecycleRepository(
      db,
      codecs: collectarrTrackingLifecycleCodecs,
    );

    await repository.upsert(
      MovieTrackingLifecycle(
        id: 'movie-tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: const CatalogEntityTypeId('work'),
          id: 'movie-1',
        ),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    );

    final entry = await repository.findByRef(
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
}
