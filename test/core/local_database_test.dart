import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates the fresh schema at version 1', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 1);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 1);

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
    expect(names, contains('music_album_images_rows'));
    expect(names, contains('music_owned_items_rows'));
    expect(names, contains('music_tracking_rows'));
    expect(names, contains('music_listen_events_rows'));
    expect(names, isNot(contains('anime_media_rows')));
    expect(names, isNot(contains('anime_episode_rows')));
    expect(names, isNot(contains('anime_release_rows')));
    expect(names, isNot(contains('music_album_rows')));
    expect(names, isNot(contains('music_medium_rows')));
    expect(names, isNot(contains('music_track_rows')));
  });

  test('creates all kind-owned tables', () async {
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
      'music_album_images_rows',
      'music_owned_items_rows',
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
