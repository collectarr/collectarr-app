import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_custom_episode_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores coordinates in the matching kind table', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitsCacheRepository(
      db,
      codecs: collectarrTrackingUnitCodecs,
    );
    final completedAt = DateTime.utc(2026, 9, 5, 12);

    await repository.upsert(
      TvTrackingUnit(
        id: 'episode-1',
        targetRef: const CatalogEntityRef(
          kind: 'tv',
          entityType: CatalogEntityType.episode,
          id: 'series-1',
        ),
        seasonNumber: 2,
        episodeNumber: 4,
        completedAt: completedAt,
        updatedAt: completedAt,
      ),
    );

    final base = await db.select(db.trackingUnitsCache).getSingle();
    final typed = await db.select(db.tvTrackingUnitRows).getSingle();
    expect(base.kind, 'tv');
    expect(base.unitType, 'episode');
    expect(typed.seasonNumber, 2);
    expect(typed.episodeNumber, 4);

    final roundTrip = await repository.findById('episode-1');
    expect(roundTrip, isA<TvTrackingUnit>());
    expect((roundTrip! as TvTrackingUnit).seasonNumber, 2);
    expect((roundTrip as TvTrackingUnit).episodeNumber, 4);
    expect(roundTrip.toSyncPayload(), containsPair('season_number', 2));
    expect(roundTrip.toSyncPayload(), containsPair('episode_number', 4));
    expect(roundTrip.toSyncPayload().containsKey('volume_number'), isFalse);
  });

  test('round-trips print and comic coordinates through their own tables',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitsCacheRepository(
      db,
      codecs: collectarrTrackingUnitCodecs,
    );
    final now = DateTime.utc(2026, 9, 5);

    await repository.upsertAll([
      MangaTrackingUnit(
        id: 'chapter-1',
        targetRef: const CatalogEntityRef(
          kind: 'manga',
          entityType: CatalogEntityType.work,
          id: 'manga-1',
        ),
        volumeNumber: 3,
        chapterNumber: 18,
        completedAt: now,
        updatedAt: now,
      ),
      ComicTrackingUnit(
        id: 'issue-1',
        targetRef: const CatalogEntityRef(
          kind: 'comic',
          entityType: CatalogEntityType.issue,
          id: 'comic-1',
        ),
        issueNumber: '8A',
        completedAt: now,
        updatedAt: now,
      ),
    ]);

    final manga = await repository.findById('chapter-1');
    final comic = await repository.findById('issue-1');
    expect(manga, isA<MangaTrackingUnit>());
    expect((manga! as MangaTrackingUnit).volumeNumber, 3);
    expect((manga as MangaTrackingUnit).chapterNumber, 18);
    expect(comic, isA<ComicTrackingUnit>());
    expect((comic! as ComicTrackingUnit).issueNumber, '8A');
    expect(await db.select(db.mangaTrackingUnitRows).get(), hasLength(1));
    expect(await db.select(db.comicTrackingUnitRows).get(), hasLength(1));
    expect(await db.select(db.bookTrackingUnitRows).get(), isEmpty);
  });

  test('routes watch sessions to the TV and Anime owner tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = WatchSessionsCacheRepository(
      db,
      codecs: collectarrWatchSessionCodecs,
    );
    final now = DateTime.utc(2026, 9, 5);

    await repository.upsertAll([
      WatchSession(
        id: 'tv-session-1',
        targetRef: const CatalogEntityRef(
          kind: 'tv',
          entityType: CatalogEntityType.work,
          id: 'tv-1',
        ),
        seasonNumber: 1,
        episodeNumber: 2,
        watchedAt: now,
        updatedAt: now,
      ),
      WatchSession(
        id: 'anime-session-1',
        targetRef: const CatalogEntityRef(
          kind: 'anime',
          entityType: CatalogEntityType.work,
          id: 'anime-1',
        ),
        seasonNumber: 1,
        episodeNumber: 3,
        watchedAt: now,
        updatedAt: now,
      ),
    ]);

    expect(await db.select(db.tvWatchSessionRows).get(), hasLength(1));
    expect(await db.select(db.animeWatchSessionRows).get(), hasLength(1));
    expect(await repository.listActiveByItemId('tv-1'), hasLength(1));
    expect(
      (await repository.listActiveByItemId('anime-1')).single.targetRef.kind,
      'anime',
    );
  });

  test('routes custom episodes to the TV and Anime owner tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = CustomEpisodesCacheRepository(
      db,
      codecs: collectarrCustomEpisodeCodecs,
    );
    final now = DateTime.utc(2026, 9, 5);

    await repository.upsertAll([
      CustomEpisode(
        id: 'tv-custom-1',
        seriesRef: const CatalogEntityRef(
          kind: 'tv',
          entityType: CatalogEntityType.work,
          id: 'tv-1',
        ),
        seasonNumber: 1,
        episodeNumber: 9,
        title: 'TV special',
        updatedAt: now,
      ),
      CustomEpisode(
        id: 'anime-custom-1',
        seriesRef: const CatalogEntityRef(
          kind: 'anime',
          entityType: CatalogEntityType.work,
          id: 'anime-1',
        ),
        seasonNumber: 2,
        episodeNumber: 5,
        title: 'Anime special',
        updatedAt: now,
      ),
    ]);

    expect(await db.select(db.tvCustomEpisodeRows).get(), hasLength(1));
    expect(await db.select(db.animeCustomEpisodeRows).get(), hasLength(1));
    expect(
      (await repository.findById('anime-custom-1'))?.seriesRef.kind,
      'anime',
    );
  });

  test('rejects tracking units without a registered kind codec', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitsCacheRepository(
      db,
      codecs: collectarrTrackingUnitCodecs,
    );

    await expectLater(
      repository.upsert(
        TrackingUnit(
          id: 'untyped-unit',
          targetRef: const CatalogEntityRef(
            kind: 'unknown',
            entityType: CatalogEntityType.work,
            id: 'item-1',
          ),
          unitType: 'unit',
          completedAt: DateTime.utc(2026, 9, 5),
          updatedAt: DateTime.utc(2026, 9, 5),
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });
}
