import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates the fresh schema at current version', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 2);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 2);

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final names = tables.map((row) => row.data['name']).whereType<String>();

    expect(names, contains('library_entries'));
    expect(names, contains('catalog_items_cache'));
    expect(names, contains('comic_tracking_rows'));
    expect(names, contains('music_tracking_rows'));
    expect(names, contains('music_listen_events_rows'));
    expect(names, contains('anime_watch_session_rows'));
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

  test('creates all kind-tracking tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final expected = <String>[
      'library_entries',
      'anime_tracking_rows',
      'board_game_tracking_rows',
      'book_tracking_rows',
      'comic_tracking_rows',
      'game_tracking_rows',
      'manga_tracking_rows',
      'movie_tracking_rows',
      'music_tracking_rows',
      'tv_tracking_rows',
    ];
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final names = tables.map((row) => row.data['name']).whereType<String>();

    expect(names, containsAll(expected));
  });
}
