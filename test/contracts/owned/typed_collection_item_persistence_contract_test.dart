import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_collection_item_persistence.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_collection_item.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatches every concrete kind collection item to its typed repository',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrCollectionItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6);

    await _storeComic(persistence, comicSeedCollectionItems(now).first);
    await _storeManga(persistence, mangaSeedCollectionItems(now).first);
    await _storeBook(persistence, bookSeedCollectionItems(now).first);
    await _storeGame(persistence, gameSeedCollectionItems(now).first);
    await _storeBoardGame(persistence, boardgameSeedCollectionItems(now).first);
    await _storeMovie(persistence, movieSeedCollectionItems(now).first);
    await _storeTv(persistence, tvSeedCollectionItems(now).first);
    await _storeAnime(persistence, animeSeedCollectionItems(now).first);
    await _storeMusic(persistence, musicSeedCollectionItems(now).first);

    expect(await db.select(db.comicCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.mangaCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.bookCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.gameCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.boardGameCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.movieCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.tvCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.animeCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.musicCollectionItemsRows).get(), hasLength(1));
  });

  test('preserves the complete seeded owned payload through each kind table',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrCollectionItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);

    await _assertRoundTripComic(persistence, comicSeedCollectionItems(now).first);
    await _assertRoundTripManga(persistence, mangaSeedCollectionItems(now).first);
    await _assertRoundTripBook(persistence, bookSeedCollectionItems(now).first);
    await _assertRoundTripGame(persistence, gameSeedCollectionItems(now).first);
    await _assertRoundTripBoardGame(
      persistence,
      boardgameSeedCollectionItems(now).first,
    );
    await _assertRoundTripMovie(persistence, movieSeedCollectionItems(now).first);
    await _assertRoundTripTv(persistence, tvSeedCollectionItems(now).first);
    await _assertRoundTripAnime(persistence, animeSeedCollectionItems(now).first);
    await _assertRoundTripMusic(persistence, musicSeedCollectionItems(now).first);
  });

  test('round-trips sync payloads through each concrete Owned table', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final persistence = CollectarrCollectionItemPersistence(db);
    final now = DateTime.utc(2026, 9, 6, 12);

    await _assertSyncComic(persistence, comicSeedCollectionItems(now).first);
    await _assertSyncManga(persistence, mangaSeedCollectionItems(now).first);
    await _assertSyncBook(persistence, bookSeedCollectionItems(now).first);
    await _assertSyncGame(persistence, gameSeedCollectionItems(now).first);
    await _assertSyncBoardGame(
      persistence,
      boardgameSeedCollectionItems(now).first,
    );
    await _assertSyncMovie(persistence, movieSeedCollectionItems(now).first);
    await _assertSyncTv(persistence, tvSeedCollectionItems(now).first);
    await _assertSyncAnime(persistence, animeSeedCollectionItems(now).first);
    await _assertSyncMusic(persistence, musicSeedCollectionItems(now).first);
  });
}

CollectionItemRef _comicRef(ComicCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.comic,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _mangaRef(MangaCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.manga,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _bookRef(BookCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.book,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _gameRef(GameCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.game,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _boardGameRef(BoardGameCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.boardgame,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _movieRef(MovieCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.movie,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _tvRef(TvCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.tv,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _animeRef(AnimeCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.anime,
      id: CollectionItemId(item.id.value),
    );

CollectionItemRef _musicRef(MusicCollectionItem item) => CollectionItemRef(
      kind: CatalogMediaKind.music,
      id: CollectionItemId(item.id.value),
    );

Future<void> _storeComic(
  CollectarrCollectionItemPersistence persistence,
  ComicCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.comic,
      item.toJson(),
    );

Future<void> _storeManga(
  CollectarrCollectionItemPersistence persistence,
  MangaCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.manga,
      item.toJson(),
    );

Future<void> _storeBook(
  CollectarrCollectionItemPersistence persistence,
  BookCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.book,
      item.toJson(),
    );

Future<void> _storeGame(
  CollectarrCollectionItemPersistence persistence,
  GameCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.game,
      item.toJson(),
    );

Future<void> _storeBoardGame(
  CollectarrCollectionItemPersistence persistence,
  BoardGameCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.boardgame,
      item.toJson(),
    );

Future<void> _storeMovie(
  CollectarrCollectionItemPersistence persistence,
  MovieCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.movie,
      item.toJson(),
    );

Future<void> _storeTv(
  CollectarrCollectionItemPersistence persistence,
  TvCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.tv,
      item.toJson(),
    );

Future<void> _storeAnime(
  CollectarrCollectionItemPersistence persistence,
  AnimeCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.anime,
      item.toJson(),
    );

Future<void> _storeMusic(
  CollectarrCollectionItemPersistence persistence,
  MusicCollectionItem item,
) =>
    persistence.replaceFromPayload(
      CatalogMediaKind.music,
      item.toJson(),
    );

Future<void> _assertRoundTripComic(
  CollectarrCollectionItemPersistence persistence,
  ComicCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.comic,
      item: item,
      ref: _comicRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripManga(
  CollectarrCollectionItemPersistence persistence,
  MangaCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.manga,
      item: item,
      ref: _mangaRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripBook(
  CollectarrCollectionItemPersistence persistence,
  BookCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.book,
      item: item,
      ref: _bookRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripGame(
  CollectarrCollectionItemPersistence persistence,
  GameCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.game,
      item: item,
      ref: _gameRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripBoardGame(
  CollectarrCollectionItemPersistence persistence,
  BoardGameCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.boardgame,
      item: item,
      ref: _boardGameRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripMovie(
  CollectarrCollectionItemPersistence persistence,
  MovieCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.movie,
      item: item,
      ref: _movieRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripTv(
  CollectarrCollectionItemPersistence persistence,
  TvCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.tv,
      item: item,
      ref: _tvRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripAnime(
  CollectarrCollectionItemPersistence persistence,
  AnimeCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.anime,
      item: item,
      ref: _animeRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTripMusic(
  CollectarrCollectionItemPersistence persistence,
  MusicCollectionItem item,
) =>
    _assertRoundTrip(
      persistence,
      kind: CatalogMediaKind.music,
      item: item,
      ref: _musicRef(item),
      json: item.toJson(),
    );

Future<void> _assertRoundTrip<T>(
  CollectarrCollectionItemPersistence persistence, {
  required CatalogMediaKind kind,
  required T item,
  required CollectionItemRef ref,
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
  CollectarrCollectionItemPersistence persistence,
  ComicCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.comic,
      item: item,
      ref: _comicRef(item),
    );

Future<void> _assertSyncManga(
  CollectarrCollectionItemPersistence persistence,
  MangaCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.manga,
      item: item,
      ref: _mangaRef(item),
    );

Future<void> _assertSyncBook(
  CollectarrCollectionItemPersistence persistence,
  BookCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.book,
      item: item,
      ref: _bookRef(item),
    );

Future<void> _assertSyncGame(
  CollectarrCollectionItemPersistence persistence,
  GameCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.game,
      item: item,
      ref: _gameRef(item),
    );

Future<void> _assertSyncBoardGame(
  CollectarrCollectionItemPersistence persistence,
  BoardGameCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.boardgame,
      item: item,
      ref: _boardGameRef(item),
    );

Future<void> _assertSyncMovie(
  CollectarrCollectionItemPersistence persistence,
  MovieCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.movie,
      item: item,
      ref: _movieRef(item),
    );

Future<void> _assertSyncTv(
  CollectarrCollectionItemPersistence persistence,
  TvCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.tv,
      item: item,
      ref: _tvRef(item),
    );

Future<void> _assertSyncAnime(
  CollectarrCollectionItemPersistence persistence,
  AnimeCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.anime,
      item: item,
      ref: _animeRef(item),
    );

Future<void> _assertSyncMusic(
  CollectarrCollectionItemPersistence persistence,
  MusicCollectionItem item,
) =>
    _assertSync(
      persistence,
      kind: CatalogMediaKind.music,
      item: item,
      ref: _musicRef(item),
    );

Future<void> _assertSync<T>(
  CollectarrCollectionItemPersistence persistence, {
  required CatalogMediaKind kind,
  required T item,
  required CollectionItemRef ref,
}) async {
  await persistence.replaceFromPayload(
    kind,
    switch (item) {
      ComicCollectionItem value => value.toJson(),
      MangaCollectionItem value => value.toJson(),
      BookCollectionItem value => value.toJson(),
      GameCollectionItem value => value.toJson(),
      BoardGameCollectionItem value => value.toJson(),
      MovieCollectionItem value => value.toJson(),
      TvCollectionItem value => value.toJson(),
      AnimeCollectionItem value => value.toJson(),
      MusicCollectionItem value => value.toJson(),
      _ => throw StateError('Unexpected owned contract item: $T'),
    },
  );
  final sync = await persistence.syncPayloadByRef(ref);
  expect(sync, isNotNull, reason: ref.kind.apiValue);
  expect(sync!.payload, isNotEmpty, reason: ref.kind.apiValue);
  expect(sync.isDeleted, isFalse, reason: ref.kind.apiValue);
}
