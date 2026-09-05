import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores coordinates in the matching kind table', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitsCacheRepository(db);
    final completedAt = DateTime.utc(2026, 9, 5, 12);

    await repository.upsert(
      VideoTrackingUnit(
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
    expect(roundTrip, isA<VideoTrackingUnit>());
    expect((roundTrip! as VideoTrackingUnit).seasonNumber, 2);
    expect((roundTrip as VideoTrackingUnit).episodeNumber, 4);
    expect(roundTrip.toSyncPayload(), containsPair('season_number', 2));
    expect(roundTrip.toSyncPayload(), containsPair('episode_number', 4));
    expect(roundTrip.toSyncPayload().containsKey('volume_number'), isFalse);
  });

  test('round-trips print and comic coordinates through their own tables',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingUnitsCacheRepository(db);
    final now = DateTime.utc(2026, 9, 5);

    await repository.upsertAll([
      ReadingTrackingUnit(
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
    expect(manga, isA<ReadingTrackingUnit>());
    expect((manga! as ReadingTrackingUnit).volumeNumber, 3);
    expect((manga as ReadingTrackingUnit).chapterNumber, 18);
    expect(comic, isA<ComicTrackingUnit>());
    expect((comic! as ComicTrackingUnit).issueNumber, '8A');
    expect(await db.select(db.mangaTrackingUnitRows).get(), hasLength(1));
    expect(await db.select(db.comicTrackingUnitRows).get(), hasLength(1));
    expect(await db.select(db.bookTrackingUnitRows).get(), isEmpty);
  });

  test('migrates legacy generic coordinates into the typed TV table', () async {
    final directory = await Directory.systemTemp.createTemp(
      'collectarr_tracking_units_v23',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.customStatement('DROP TABLE tracking_units_cache');
    await old.customStatement('DROP TABLE tv_tracking_unit_rows');
    await old.customStatement('DROP TABLE anime_tracking_unit_rows');
    await old.customStatement('DROP TABLE book_tracking_unit_rows');
    await old.customStatement('DROP TABLE manga_tracking_unit_rows');
    await old.customStatement('DROP TABLE comic_tracking_unit_rows');
    await old.customStatement('''
      CREATE TABLE tracking_units_cache (
        id TEXT NOT NULL PRIMARY KEY,
        item_id TEXT NOT NULL,
        tracking_entry_id TEXT,
        owned_item_id TEXT,
        edition_id TEXT,
        variant_id TEXT,
        bundle_release_id TEXT,
        unit_type TEXT NOT NULL,
        season_number INTEGER,
        episode_number INTEGER,
        volume_number INTEGER,
        chapter_number INTEGER,
        issue_number TEXT,
        completed_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
    await old.customStatement(
      'INSERT INTO tracking_entries_cache '
      '(id, item_id, kind, status, updated_at) VALUES (?, ?, ?, ?, ?)',
      ['entry-1', 'series-legacy', 'tv', 'completed', 1000],
    );
    await old.customStatement(
      'INSERT INTO tracking_units_cache '
      '(id, item_id, tracking_entry_id, unit_type, season_number, '
      'episode_number, completed_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'legacy-episode',
        'series-legacy',
        'entry-1',
        'episode',
        4,
        7,
        1000,
        1000
      ],
    );
    await old.customStatement('PRAGMA user_version = 23');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final repository = TrackingUnitsCacheRepository(db);
    final unit = await repository.findById('legacy-episode');

    expect(unit, isA<VideoTrackingUnit>());
    expect((unit! as VideoTrackingUnit).seasonNumber, 4);
    expect((unit as VideoTrackingUnit).episodeNumber, 7);
    expect((await db.select(db.trackingUnitsCache).getSingle()).kind, 'tv');
    expect(await db.select(db.tvTrackingUnitRows).get(), hasLength(1));
    final columns = await db
        .customSelect(
          'PRAGMA table_info(tracking_units_cache)',
        )
        .get();
    expect(
      columns.map((row) => row.data['name']),
      isNot(contains('season_number')),
    );
  });
}
