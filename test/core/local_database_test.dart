import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates the complete current schema as version 3', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 3);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final names = tables.map((row) => row.data['name']).whereType<String>();

    expect(names, contains('comic_media_rows'));
    expect(names, contains('comic_owned_items_rows'));
    expect(names, contains('book_release_rows'));
    expect(names, contains('tv_episode_rows'));
    expect(names, contains('anime_watch_session_rows'));
    expect(names, contains('music_track_rows'));
  });

  test('creates all kind-owned tables with the current migration strategy',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final expected = <String>[
      'comic_media_rows',
      'manga_media_rows',
      'book_media_rows',
      'game_media_rows',
      'board_game_media_rows',
      'movie_media_rows',
      'tv_series_rows',
      'anime_media_rows',
      'music_medium_rows',
    ];
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final names = tables.map((row) => row.data['name']).whereType<String>();

    expect(names, containsAll(expected));
  });

  test('migrates Music owned release roots to their release group', () async {
    final directory = await Directory.systemTemp.createTemp(
      'collectarr-music-migration-',
    );
    final file = File('${directory.path}\\migration.sqlite');
    LocalDatabase? db;
    addTearDown(() async {
      await db?.close();
      await directory.delete(recursive: true);
    });

    final legacyDb = LocalDatabase(NativeDatabase(file));
    db = legacyDb;
    final group = MusicReleaseGroup(
      id: const MusicReleaseGroupId('group-migration'),
      title: 'Migrated group',
      releases: [
        MusicRelease(
          id: const MusicReleaseId('release-migration'),
          releaseGroupId: const MusicReleaseGroupId('group-migration'),
          title: 'Migrated release',
        ),
      ],
    );
    final release = group.primaryRelease!;
    await legacyDb.into(legacyDb.musicReleaseGroupRows).insert(
          MusicLocalMapper.toReleaseGroupRow(group),
        );
    await legacyDb.into(legacyDb.musicReleaseRows).insert(
          MusicLocalMapper.toReleaseRow(release),
        );
    await legacyDb.into(legacyDb.musicOwnedItemsRows).insert(
          MusicLocalMapper.toOwnedItemRow(
            MusicOwnedItem(
              id: const MusicOwnedItemId('owned-migration'),
              catalogRef: CatalogEntityRef(
                kind: CatalogMediaKind.music,
                entityType: CatalogEntityTypeId.root,
                id: release.id.value,
              ),
              targetRef: CatalogEntityRef(
                kind: CatalogMediaKind.music,
                entityType: const CatalogEntityTypeId('release'),
                id: release.id.value,
                rootId: release.id.value,
              ),
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ),
        );
    await legacyDb.customStatement('PRAGMA user_version = 2');
    await legacyDb.close();
    db = null;

    final migratedDb = LocalDatabase(NativeDatabase(file));
    db = migratedDb;
    final row =
        await migratedDb.select(migratedDb.musicOwnedItemsRows).getSingle();
    final target = jsonDecode(row.targetRefJson!) as Map<String, dynamic>;

    expect(migratedDb.schemaVersion, 3);
    expect(row.itemId, 'group-migration');
    expect(target['root_id'], 'group-migration');
  });
}
