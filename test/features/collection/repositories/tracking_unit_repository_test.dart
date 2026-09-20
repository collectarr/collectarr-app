import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores coordinates in the matching kind table', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitStorageRepository(
      db,
      codecs: libraryTrackingUnitCodecs,
    );
    final completedAt = DateTime.utc(2026, 9, 5, 12);

    await repository.upsert(
      TvTrackingUnit(
        id: 'episode-1',
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.tv,
          entityType: CatalogEntityTypeId('episode'),
          id: 'series-1',
        ),
        seasonNumber: 2,
        episodeNumber: 4,
        completedAt: completedAt,
        updatedAt: completedAt,
      ),
    );

    final typed = await db.select(db.tvTrackingUnitRows).getSingle();
    expect(typed.targetRefJson, contains('series-1'));
    expect(typed.seasonNumber, 2);
    expect(typed.episodeNumber, 4);

    final roundTrip = await repository.findByRef(
      const TrackingUnitRef(kind: CatalogMediaKind.tv, id: 'episode-1'),
    );
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
    final repository = TrackingUnitStorageRepository(
      db,
      codecs: libraryTrackingUnitCodecs,
    );
    final now = DateTime.utc(2026, 9, 5);

    await repository.upsertAll([
      MangaTrackingUnit(
        id: 'chapter-1',
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.manga,
          entityType: CatalogEntityTypeId('work'),
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
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId('issue'),
          id: 'comic-1',
        ),
        issueNumber: '8A',
        completedAt: now,
        updatedAt: now,
      ),
    ]);

    final manga = await repository.findByRef(
      const TrackingUnitRef(kind: CatalogMediaKind.manga, id: 'chapter-1'),
    );
    final comic = await repository.findByRef(
      const TrackingUnitRef(kind: CatalogMediaKind.comic, id: 'issue-1'),
    );
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
    final repository = WatchSessionsRepository(
      db,
      codecs: libraryWatchSessionCodecs,
    );
    final now = DateTime.utc(2026, 9, 5);

    await repository.upsertAll([
      TvWatchSession(
        id: 'tv-session-1',
        seriesId: TvSeriesId('tv-1'),
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.tv,
          entityType: CatalogEntityTypeId('work'),
          id: 'tv-1',
        ),
        seasonNumber: 1,
        episodeNumber: 2,
        watchedAt: now,
        updatedAt: now,
      ),
      AnimeWatchSession(
        id: 'anime-session-1',
        targetRef: const CatalogEntityRef(
          kind: CatalogMediaKind.anime,
          entityType: CatalogEntityTypeId('work'),
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
    expect(
      await repository.listActiveByCatalogRefs([
        const CatalogEntityRef(
          kind: CatalogMediaKind.tv,
          entityType: CatalogEntityTypeId('work'),
          id: 'tv-1',
        ),
      ]),
      hasLength(1),
    );
    expect(
      (await repository.listActiveByCatalogRefs([
        const CatalogEntityRef(
          kind: CatalogMediaKind.anime,
          entityType: CatalogEntityTypeId('work'),
          id: 'anime-1',
        ),
      ]))
          .single
          .targetRef
          .kind
          .apiValue,
      'anime',
    );
  });

  test('rejects tracking units without a registered kind codec', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitStorageRepository(
      db,
      codecs: libraryTrackingUnitCodecs,
    );

    await expectLater(
      repository.upsert(
        TrackingUnitSummary(
          id: 'untyped-unit',
          targetRef: const CatalogEntityRef(
            kind: CatalogMediaKind.unknown,
            entityType: CatalogEntityTypeId('work'),
            id: 'item-1',
          ),
          completedAt: DateTime.utc(2026, 9, 5),
          updatedAt: DateTime.utc(2026, 9, 5),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
