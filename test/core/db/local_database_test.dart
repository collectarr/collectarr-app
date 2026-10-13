import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates the fresh schema at current version', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 1);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 1);

    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = tables.map((row) => row.data['name']).whereType<String>();

    expect(names, contains('library_entries'));
    expect(names, contains('library_collections'));
    expect(names, contains('library_collection_memberships'));
    expect(names, contains('catalog_items_cache'));
    expect(names, isNot(contains('comic_tracking_rows')));
    expect(names, contains('music_tracking_rows'));
    expect(names, contains('music_listen_events_rows'));
    expect(names, isNot(contains('anime_watch_session_rows')));
    expect(names, isNot(contains('comic_media_rows')));
    expect(names, isNot(contains('comic_library_entries_rows')));
    expect(names, isNot(contains('book_release_rows')));
    expect(names, isNot(contains('tv_episode_rows')));
    expect(names, isNot(contains('music_library_entries_rows')));
    expect(names, isNot(contains('anime_media_rows')));
    expect(names, isNot(contains('anime_episode_rows')));
    expect(names, isNot(contains('anime_release_rows')));
    expect(names, isNot(contains('music_album_rows')));
    expect(names, isNot(contains('music_medium_rows')));
    expect(names, isNot(contains('music_track_rows')));
  });

  test(
    'release schema exactly matches the physical Music-only tables',
    () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      final names = tables.map((row) => row.data['name'] as String).toSet();
      expect(names, db.allTables.map((table) => table.actualTableName).toSet());
      expect(names, hasLength(21));
      expect(names.where((name) => name.endsWith('_rows')).toSet(), {
        'music_tracking_rows',
        'music_listen_events_rows',
      });
      final columns = await db
          .customSelect('PRAGMA table_info(pick_list_values_cache)')
          .get();
      expect(
        columns.map((row) => row.data['name']),
        containsAll(['sort_name', 'is_hidden']),
      );
      expect(
        names,
        containsAll(['library_collections', 'library_collection_memberships']),
      );
    },
  );
}
