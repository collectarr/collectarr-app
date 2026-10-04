import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatches every concrete kind collection item to its typed repository',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrLibraryEntryPersistence(db);
    final now = DateTime.utc(2026, 9, 6);

    await _storeComic(persistence, comicSeedLibraryEntries(now).first);
    await _storeManga(persistence, mangaSeedLibraryEntries(now).first);
    await _storeBook(persistence, bookSeedLibraryEntries(now).first);
    await _storeGame(persistence, gameSeedLibraryEntries(now).first);
    await _storeBoardGame(persistence, boardgameSeedLibraryEntries(now).first);
    await _storeMovie(persistence, movieSeedLibraryEntries(now).first);
    await _storeTv(persistence, tvSeedLibraryEntries(now).first);
    await _storeAnime(persistence, animeSeedLibraryEntries(now).first);
    await _storeMusic(persistence, musicSeedLibraryEntries(now).first);

    expect(await db.select(db.comicLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.mangaLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.bookLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.gameLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.boardGameLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.movieLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.tvLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.animeLibraryEntriesRows).get(), hasLength(1));
    expect(await db.select(db.musicLibraryEntriesRows).get(), hasLength(1));
  });

  test('preserves the complete seeded entry payload through each kind table',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrLibraryEntryPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);

    await _assertRoundTripComic(persistence, comicSeedLibraryEntries(now).first);
    await _assertRoundTripManga(persistence, mangaSeedLibraryEntries(now).first);
    await _assertRoundTripBook(persistence, bookSeedLibraryEntries(now).first);
    await _assertRoundTripGame(persistence, gameSeedLibraryEntries(now).first);
    await _assertRoundTripBoardGame(
      persistence,
      boardgameSeedLibraryEntries(now).first,
    );
    await _assertRoundTripMovie(persistence, movieSeedLibraryEntries(now).first);
    await _assertRoundTripTv(persistence, tvSeedLibraryEntries(now).first);
    await _assertRoundTripAnime(persistence, animeSeedLibraryEntries(now).first);
    await _assertRoundTripMusic(persistence, musicSeedLibraryEntries(now).first);
  });

  test('round-trips sync payloads through each concrete Entry table', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrLibraryEntryPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);

    await _assertSyncComic(persistence, comicSeedLibraryEntries(now).first);
    await _assertSyncManga(persistence, mangaSeedLibraryEntries(now).first);
    await _assertSyncBook(persistence, bookSeedLibraryEntries(now).first);
    await _assertSyncGame(persistence, gameSeedLibraryEntries(now).first);
    await _assertSyncBoardGame(
      persistence,
      boardgameSeedLibraryEntries(now).first,
    );
    await _assertSyncMovie(persistence, movieSeedLibraryEntries(now).first);
    await _assertSyncTv(persistence, tvSeedLibraryEntries(now).first);
    await _assertSyncAnime(persistence, animeSeedLibraryEntries(now).first);
    await _assertSyncMusic(persistence, musicSeedLibraryEntries(now).first);
  });
}

LibraryEntryRef _comicRef(ComicLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.comic,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _mangaRef(MangaLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.manga,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _bookRef(BookLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _gameRef(GameLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.game,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _boardGameRef(BoardGameLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.boardgame,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _movieRef(MovieLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.movie,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _tvRef(TvLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.tv,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _animeRef(AnimeLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.anime,
      id: LibraryEntryId(item.id.value),
    );

LibraryEntryRef _musicRef(MusicLibraryEntry item) => LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId(item.id.value),
    );

Future<void> _storeComic(
  CollectarrLibraryEntryPersistence persistence,
  ComicLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.comic,
      item.toJson(),
    );

Future<void> _storeManga(
  CollectarrLibraryEntryPersistence persistence,
  MangaLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.manga,
      item.toJson(),
    );

Future<void> _storeBook(
  CollectarrLibraryEntryPersistence persistence,
  BookLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.book,
      item.toJson(),
    );

Future<void> _storeGame(
  CollectarrLibraryEntryPersistence persistence,
  GameLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.game,
      item.toJson(),
    );

Future<void> _storeBoardGame(
  CollectarrLibraryEntryPersistence persistence,
  BoardGameLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.boardgame,
      item.toJson(),
    );

Future<void> _storeMovie(
  CollectarrLibraryEntryPersistence persistence,
  MovieLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.movie,
      item.toJson(),
    );

Future<void> _storeTv(
  CollectarrLibraryEntryPersistence persistence,
  TvLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.tv,
      item.toJson(),
    );

Future<void> _storeAnime(
  CollectarrLibraryEntryPersistence persistence,
  AnimeLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.anime,
      item.toJson(),
    );

Future<void> _storeMusic(
  CollectarrLibraryEntryPersistence persistence,
  MusicLibraryEntry item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.music,
      item.toJson(),
    );

Future<void> _assertRoundTripComic(
  CollectarrLibraryEntryPersistence persistence,
  ComicLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.comic,
      item: item,
      ref: _comicRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripManga(
  CollectarrLibraryEntryPersistence persistence,
  MangaLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.manga,
      item: item,
      ref: _mangaRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripBook(
  CollectarrLibraryEntryPersistence persistence,
  BookLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.book,
      item: item,
      ref: _bookRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripGame(
  CollectarrLibraryEntryPersistence persistence,
  GameLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.game,
      item: item,
      ref: _gameRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripBoardGame(
  CollectarrLibraryEntryPersistence persistence,
  BoardGameLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.boardgame,
      item: item,
      ref: _boardGameRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripMovie(
  CollectarrLibraryEntryPersistence persistence,
  MovieLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.movie,
      item: item,
      ref: _movieRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripTv(
  CollectarrLibraryEntryPersistence persistence,
  TvLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.tv,
      item: item,
      ref: _tvRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripAnime(
  CollectarrLibraryEntryPersistence persistence,
  AnimeLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.anime,
      item: item,
      ref: _animeRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripMusic(
  CollectarrLibraryEntryPersistence persistence,
  MusicLibraryEntry item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.music,
      item: item,
      ref: _musicRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTrip<T>(
  CollectarrLibraryEntryPersistence persistence, {
  required CatalogMediaKind kind,
  required T item,
  required LibraryEntryRef ref,
  required Map<String, dynamic> json,
}) async {
  await persistence.replaceFromPayload(kind, json);
  final roundTrip = await persistence.payloadByRef(ref);
  expect(roundTrip, isNotNull, reason: ref.kind.apiValue);
  expect(
    roundTrip,
    equals(json),
    reason: 'entry payload was not lossless for ${ref.kind}',
  );
}

Future<void> _assertSyncComic(
  CollectarrLibraryEntryPersistence persistence,
  ComicLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.comic,
      item: item,
      ref: _comicRef(item),
    );

Future<void> _assertSyncManga(
  CollectarrLibraryEntryPersistence persistence,
  MangaLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.manga,
      item: item,
      ref: _mangaRef(item),
    );

Future<void> _assertSyncBook(
  CollectarrLibraryEntryPersistence persistence,
  BookLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.book,
      item: item,
      ref: _bookRef(item),
    );

Future<void> _assertSyncGame(
  CollectarrLibraryEntryPersistence persistence,
  GameLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.game,
      item: item,
      ref: _gameRef(item),
    );

Future<void> _assertSyncBoardGame(
  CollectarrLibraryEntryPersistence persistence,
  BoardGameLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.boardgame,
      item: item,
      ref: _boardGameRef(item),
    );

Future<void> _assertSyncMovie(
  CollectarrLibraryEntryPersistence persistence,
  MovieLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.movie,
      item: item,
      ref: _movieRef(item),
    );

Future<void> _assertSyncTv(
  CollectarrLibraryEntryPersistence persistence,
  TvLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.tv,
      item: item,
      ref: _tvRef(item),
    );

Future<void> _assertSyncAnime(
  CollectarrLibraryEntryPersistence persistence,
  AnimeLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.anime,
      item: item,
      ref: _animeRef(item),
    );

Future<void> _assertSyncMusic(
  CollectarrLibraryEntryPersistence persistence,
  MusicLibraryEntry item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.music,
      item: item,
      ref: _musicRef(item),
    );

Future<void> _assertSync<T>(
  CollectarrLibraryEntryPersistence persistence, {
  required CatalogMediaKind kind,
  required T item,
  required LibraryEntryRef ref,
}) async {
  await persistence.replaceFromPayload(
    kind,
    switch (item) {
      ComicLibraryEntry value => value.toJson(),
      MangaLibraryEntry value => value.toJson(),
      BookLibraryEntry value => value.toJson(),
      GameLibraryEntry value => value.toJson(),
      BoardGameLibraryEntry value => value.toJson(),
      MovieLibraryEntry value => value.toJson(),
      TvLibraryEntry value => value.toJson(),
      AnimeLibraryEntry value => value.toJson(),
      MusicLibraryEntry value => value.toJson(),
      _ => throw StateError('Unexpected entry contract item: $T'),
    },
  );
  final sync = await persistence.syncPayloadByRef(ref);
  expect(sync, isNotNull, reason: ref.kind.apiValue);
  expect(sync!.payload, isNotEmpty, reason: ref.kind.apiValue);
  expect(sync.isDeleted, isFalse, reason: ref.kind.apiValue);
}
