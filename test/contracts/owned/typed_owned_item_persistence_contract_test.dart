import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatches every concrete kind owned copy to its typed repository',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrOwnedItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6);

    await _storeComic(persistence, comicSeedOwnedItems(now).first);
    await _storeManga(persistence, mangaSeedOwnedItems(now).first);
    await _storeBook(persistence, bookSeedOwnedItems(now).first);
    await _storeGame(persistence, gameSeedOwnedItems(now).first);
    await _storeBoardGame(persistence, boardgameSeedOwnedItems(now).first);
    await _storeMovie(persistence, movieSeedOwnedItems(now).first);
    await _storeTv(persistence, tvSeedOwnedItems(now).first);
    await _storeAnime(persistence, animeSeedOwnedItems(now).first);
    await _storeMusic(persistence, musicSeedOwnedItems(now).first);

    expect(await db.select(db.comicOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.mangaOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.bookOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.gameOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.boardGameOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.movieOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.tvOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.animeOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.musicOwnedItemsRows).get(), hasLength(1));
  });

  test('preserves the complete seeded owned payload through each kind table',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrOwnedItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);

    await _assertRoundTripComic(persistence, comicSeedOwnedItems(now).first);
    await _assertRoundTripManga(persistence, mangaSeedOwnedItems(now).first);
    await _assertRoundTripBook(persistence, bookSeedOwnedItems(now).first);
    await _assertRoundTripGame(persistence, gameSeedOwnedItems(now).first);
    await _assertRoundTripBoardGame(
      persistence,
      boardgameSeedOwnedItems(now).first,
    );
    await _assertRoundTripMovie(persistence, movieSeedOwnedItems(now).first);
    await _assertRoundTripTv(persistence, tvSeedOwnedItems(now).first);
    await _assertRoundTripAnime(persistence, animeSeedOwnedItems(now).first);
    await _assertRoundTripMusic(persistence, musicSeedOwnedItems(now).first);
  });

  test('round-trips sync payloads through each concrete Owned table', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrOwnedItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);

    await _assertSyncComic(persistence, comicSeedOwnedItems(now).first);
    await _assertSyncManga(persistence, mangaSeedOwnedItems(now).first);
    await _assertSyncBook(persistence, bookSeedOwnedItems(now).first);
    await _assertSyncGame(persistence, gameSeedOwnedItems(now).first);
    await _assertSyncBoardGame(
      persistence,
      boardgameSeedOwnedItems(now).first,
    );
    await _assertSyncMovie(persistence, movieSeedOwnedItems(now).first);
    await _assertSyncTv(persistence, tvSeedOwnedItems(now).first);
    await _assertSyncAnime(persistence, animeSeedOwnedItems(now).first);
    await _assertSyncMusic(persistence, musicSeedOwnedItems(now).first);
  });
}

OwnedItemRef _comicRef(ComicOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.comic,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _mangaRef(MangaOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.manga,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _bookRef(BookOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.book,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _gameRef(GameOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.game,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _boardGameRef(BoardGameOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.boardgame,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _movieRef(MovieOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.movie,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _tvRef(TvOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.tv,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _animeRef(AnimeOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.anime,
      id: OwnedItemId(item.id.value),
    );

OwnedItemRef _musicRef(MusicOwnedItem item) => OwnedItemRef(
      kind: CatalogMediaKind.music,
      id: OwnedItemId(item.id.value),
    );

Future<void> _storeComic(
  CollectarrOwnedItemPersistence persistence,
  ComicOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.comic,
      item.toJson(),
    );

Future<void> _storeManga(
  CollectarrOwnedItemPersistence persistence,
  MangaOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.manga,
      item.toJson(),
    );

Future<void> _storeBook(
  CollectarrOwnedItemPersistence persistence,
  BookOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.book,
      item.toJson(),
    );

Future<void> _storeGame(
  CollectarrOwnedItemPersistence persistence,
  GameOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.game,
      item.toJson(),
    );

Future<void> _storeBoardGame(
  CollectarrOwnedItemPersistence persistence,
  BoardGameOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.boardgame,
      item.toJson(),
    );

Future<void> _storeMovie(
  CollectarrOwnedItemPersistence persistence,
  MovieOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.movie,
      item.toJson(),
    );

Future<void> _storeTv(
  CollectarrOwnedItemPersistence persistence,
  TvOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.tv,
      item.toJson(),
    );

Future<void> _storeAnime(
  CollectarrOwnedItemPersistence persistence,
  AnimeOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.anime,
      item.toJson(),
    );

Future<void> _storeMusic(
  CollectarrOwnedItemPersistence persistence,
  MusicOwnedItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.music,
      item.toJson(),
    );

Future<void> _assertRoundTripComic(
  CollectarrOwnedItemPersistence persistence,
  ComicOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.comic,
      item: item,
      ref: _comicRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripManga(
  CollectarrOwnedItemPersistence persistence,
  MangaOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.manga,
      item: item,
      ref: _mangaRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripBook(
  CollectarrOwnedItemPersistence persistence,
  BookOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.book,
      item: item,
      ref: _bookRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripGame(
  CollectarrOwnedItemPersistence persistence,
  GameOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.game,
      item: item,
      ref: _gameRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripBoardGame(
  CollectarrOwnedItemPersistence persistence,
  BoardGameOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.boardgame,
      item: item,
      ref: _boardGameRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripMovie(
  CollectarrOwnedItemPersistence persistence,
  MovieOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.movie,
      item: item,
      ref: _movieRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripTv(
  CollectarrOwnedItemPersistence persistence,
  TvOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.tv,
      item: item,
      ref: _tvRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripAnime(
  CollectarrOwnedItemPersistence persistence,
  AnimeOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.anime,
      item: item,
      ref: _animeRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripMusic(
  CollectarrOwnedItemPersistence persistence,
  MusicOwnedItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.music,
      item: item,
      ref: _musicRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTrip<T>(
  CollectarrOwnedItemPersistence persistence, {
  required CatalogMediaKind kind,
  required T item,
  required OwnedItemRef ref,
  required Map<String, dynamic> json,
}) async {
  await persistence.replaceFromPayload(kind, json);
  final roundTrip = await persistence.payloadByRef(ref);
  expect(roundTrip, isNotNull, reason: ref.kind.apiValue);
  expect(
    roundTrip,
    equals(json),
    reason: 'owned payload was not lossless for ${ref.kind}',
  );
}

Future<void> _assertSyncComic(
  CollectarrOwnedItemPersistence persistence,
  ComicOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.comic,
      item: item,
      ref: _comicRef(item),
    );

Future<void> _assertSyncManga(
  CollectarrOwnedItemPersistence persistence,
  MangaOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.manga,
      item: item,
      ref: _mangaRef(item),
    );

Future<void> _assertSyncBook(
  CollectarrOwnedItemPersistence persistence,
  BookOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.book,
      item: item,
      ref: _bookRef(item),
    );

Future<void> _assertSyncGame(
  CollectarrOwnedItemPersistence persistence,
  GameOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.game,
      item: item,
      ref: _gameRef(item),
    );

Future<void> _assertSyncBoardGame(
  CollectarrOwnedItemPersistence persistence,
  BoardGameOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.boardgame,
      item: item,
      ref: _boardGameRef(item),
    );

Future<void> _assertSyncMovie(
  CollectarrOwnedItemPersistence persistence,
  MovieOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.movie,
      item: item,
      ref: _movieRef(item),
    );

Future<void> _assertSyncTv(
  CollectarrOwnedItemPersistence persistence,
  TvOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.tv,
      item: item,
      ref: _tvRef(item),
    );

Future<void> _assertSyncAnime(
  CollectarrOwnedItemPersistence persistence,
  AnimeOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.anime,
      item: item,
      ref: _animeRef(item),
    );

Future<void> _assertSyncMusic(
  CollectarrOwnedItemPersistence persistence,
  MusicOwnedItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.music,
      item: item,
      ref: _musicRef(item),
    );

Future<void> _assertSync<T>(
  CollectarrOwnedItemPersistence persistence, {
  required CatalogMediaKind kind,
  required T item,
  required OwnedItemRef ref,
}) async {
  await persistence.replaceFromPayload(
    kind,
    switch (item) {
      ComicOwnedItem value => value.toJson(),
      MangaOwnedItem value => value.toJson(),
      BookOwnedItem value => value.toJson(),
      GameOwnedItem value => value.toJson(),
      BoardGameOwnedItem value => value.toJson(),
      MovieOwnedItem value => value.toJson(),
      TvOwnedItem value => value.toJson(),
      AnimeOwnedItem value => value.toJson(),
      MusicOwnedItem value => value.toJson(),
      _ => throw StateError('Unexpected owned contract item: $T'),
    },
  );
  final sync = await persistence.syncPayloadByRef(ref);
  expect(sync, isNotNull, reason: ref.kind.apiValue);
  expect(sync!.payload, isNotEmpty, reason: ref.kind.apiValue);
  expect(sync.isDeleted, isFalse, reason: ref.kind.apiValue);
}
