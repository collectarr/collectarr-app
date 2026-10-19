import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates the fresh schema at current version', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 3);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);

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
    expect(names, contains('game_tracking_rows'));
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
    'release schema exactly matches the physical released-kind tables',
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
      expect(names, hasLength(22));
      expect(names.where((name) => name.endsWith('_rows')).toSet(), {
        'music_tracking_rows',
        'music_listen_events_rows',
        'game_tracking_rows',
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

  test('upgrades a schema 1 database by adding borrower contact columns',
      () async {
    // A released schema 1 pick-list table with one borrower.
    final db = LocalDatabase(NativeDatabase.memory(setup: (raw) {
      raw.execute('CREATE TABLE pick_list_values_cache ('
          'id TEXT NOT NULL PRIMARY KEY, list_name TEXT NOT NULL, '
          'media_kind TEXT NULL, value TEXT NOT NULL, sort_name TEXT NULL, '
          'is_hidden INTEGER NOT NULL DEFAULT 0, '
          'sort_order INTEGER NOT NULL DEFAULT 0)');
      raw.execute("INSERT INTO pick_list_values_cache (id, list_name, value) "
          "VALUES ('b1', 'borrower', 'Alex')");
      raw.execute('PRAGMA user_version = 1');
    }));
    addTearDown(db.close);

    final row = await db.select(db.pickListValuesCache).getSingle();
    expect(row.value, 'Alex');
    expect(row.email, isNull);
    expect(row.address, isNull);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
  });

  test('upgrades a schema 2 database by creating the Game tables', () async {
    final db = LocalDatabase(NativeDatabase.memory(setup: (raw) {
      raw.execute(
          'CREATE TABLE library_entries (id TEXT NOT NULL PRIMARY KEY)');
      raw.execute("INSERT INTO library_entries (id) VALUES ('e1')");
      raw.execute('PRAGMA user_version = 2');
    }));
    addTearDown(db.close);

    final kept = await db
        .customSelect('SELECT id FROM library_entries')
        .map((row) => row.read<String>('id'))
        .get();
    expect(kept, ['e1']);
    expect(await db.select(db.gameTrackingRows).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
  });
}
