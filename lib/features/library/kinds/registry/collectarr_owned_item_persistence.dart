import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';

typedef _OwnedItemPersister = Future<void> Function(OwnedItem item);
typedef _OwnedItemReader = Future<List<OwnedItem>> Function();
typedef _OwnedItemFinder = Future<OwnedItem?> Function(String id);
typedef _OwnedItemDeleter = Future<void> Function(
  OwnedItem item,
  DateTime deletedAt,
);

/// Composition-root dispatch for the typed owned repositories.
///
/// The generic collection mutation layer still receives a serialized
/// collection projection. Dispatch immediately reconstructs the owning kind
/// and persists it through that kind's repository.
final class CollectarrOwnedItemPersistence {
  CollectarrOwnedItemPersistence(LocalDatabase database)
      : _persisters = {
          CatalogMediaKind.comic: (item) => ComicOwnedRepository(database)
              .upsert(ComicOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.manga: (item) => MangaOwnedRepository(database)
              .upsert(MangaOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.book: (item) => BookOwnedRepository(database)
              .upsert(BookOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.game: (item) => GameOwnedRepository(database)
              .upsert(GameOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.boardgame: (item) => BoardGameOwnedRepository(
                database,
              ).upsert(BoardGameOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.movie: (item) => MovieOwnedRepository(database)
              .upsert(MovieOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.tv: (item) => TvOwnedRepository(database)
              .upsert(TvOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.anime: (item) => AnimeOwnedRepository(database)
              .upsert(AnimeOwnedItemProjection.fromOwnedItem(item)),
          CatalogMediaKind.music: (item) => MusicOwnedRepository(database)
              .upsert(MusicOwnedItemProjection.fromOwnedItem(item)),
        },
        _readers = {
          CatalogMediaKind.comic: () async => (await ComicOwnedRepository(
                database,
              ).listActive())
                  .map(ComicOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.manga: () async => (await MangaOwnedRepository(
                database,
              ).listActive())
                  .map(MangaOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.book: () async => (await BookOwnedRepository(
                database,
              ).listActive())
                  .map(BookOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.game: () async => (await GameOwnedRepository(
                database,
              ).listActive())
                  .map(GameOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.boardgame: () async =>
              (await BoardGameOwnedRepository(
                database,
              ).listActive())
                  .map(BoardGameOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.movie: () async => (await MovieOwnedRepository(
                database,
              ).listActive())
                  .map(MovieOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.tv: () async => (await TvOwnedRepository(
                database,
              ).listActive())
                  .map(TvOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.anime: () async => (await AnimeOwnedRepository(
                database,
              ).listActive())
                  .map(AnimeOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
          CatalogMediaKind.music: () async => (await MusicOwnedRepository(
                database,
              ).listActive())
                  .map(MusicOwnedItemProjection.toOwnedItem)
                  .toList(growable: false),
        },
        _finders = {
          CatalogMediaKind.comic: (id) async => _toCommon(
                await ComicOwnedRepository(database)
                    .findById(ComicOwnedItemId(id)),
                ComicOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.manga: (id) async => _toCommon(
                await MangaOwnedRepository(database)
                    .findById(MangaOwnedItemId(id)),
                MangaOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.book: (id) async => _toCommon(
                await BookOwnedRepository(database)
                    .findById(BookOwnedItemId(id)),
                BookOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.game: (id) async => _toCommon(
                await GameOwnedRepository(database)
                    .findById(GameOwnedItemId(id)),
                GameOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.boardgame: (id) async => _toCommon(
                await BoardGameOwnedRepository(database)
                    .findById(BoardGameOwnedItemId(id)),
                BoardGameOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.movie: (id) async => _toCommon(
                await MovieOwnedRepository(database)
                    .findById(MovieOwnedItemId(id)),
                MovieOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.tv: (id) async => _toCommon(
                await TvOwnedRepository(database).findById(TvOwnedItemId(id)),
                TvOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.anime: (id) async => _toCommon(
                await AnimeOwnedRepository(database)
                    .findById(AnimeOwnedItemId(id)),
                AnimeOwnedItemProjection.toOwnedItem,
              ),
          CatalogMediaKind.music: (id) async => _toCommon(
                await MusicOwnedRepository(database)
                    .findById(MusicOwnedItemId(id)),
                MusicOwnedItemProjection.toOwnedItem,
              ),
        },
        _deleters = {
          CatalogMediaKind.comic: (item, deletedAt) => ComicOwnedRepository(
                database,
              ).markDeleted(
                ComicOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.manga: (item, deletedAt) => MangaOwnedRepository(
                database,
              ).markDeleted(
                MangaOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.book: (item, deletedAt) => BookOwnedRepository(
                database,
              ).markDeleted(
                BookOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.game: (item, deletedAt) => GameOwnedRepository(
                database,
              ).markDeleted(
                GameOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.boardgame: (item, deletedAt) =>
              BoardGameOwnedRepository(database).markDeleted(
                BoardGameOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.movie: (item, deletedAt) => MovieOwnedRepository(
                database,
              ).markDeleted(
                MovieOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.tv: (item, deletedAt) => TvOwnedRepository(
                database,
              ).markDeleted(
                TvOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.anime: (item, deletedAt) => AnimeOwnedRepository(
                database,
              ).markDeleted(
                AnimeOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
          CatalogMediaKind.music: (item, deletedAt) => MusicOwnedRepository(
                database,
              ).markDeleted(
                MusicOwnedItemProjection.fromOwnedItem(item),
                deletedAt,
              ),
        };

  final Map<CatalogMediaKind, _OwnedItemPersister> _persisters;
  final Map<CatalogMediaKind, _OwnedItemReader> _readers;
  final Map<CatalogMediaKind, _OwnedItemFinder> _finders;
  final Map<CatalogMediaKind, _OwnedItemDeleter> _deleters;

  Future<void> upsert(OwnedItem item) async {
    final persister = _persisters[item.catalogRef.mediaKind];
    if (persister == null) {
      throw StateError(
        'Cannot persist owned item without a supported kind: '
        '${item.catalogRef.kind}',
      );
    }
    await persister(item);
  }

  Future<void> upsertAll(Iterable<OwnedItem> items) async {
    for (final item in items) {
      await upsert(item);
    }
  }

  Future<List<OwnedItem>> listActive() async {
    final groups = await Future.wait(_readers.values.map((reader) => reader()));
    final items = groups.expand((group) => group).toList(growable: false);
    items.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return items;
  }

  Future<OwnedItem?> findById(String id) async {
    for (final finder in _finders.values) {
      final item = await finder(id);
      if (item != null) return item;
    }
    return null;
  }

  Future<List<OwnedItem>> findActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids = itemIds.toSet();
    if (ids.isEmpty) return const [];
    final items = await listActive();
    return items
        .where((item) => ids.contains(item.itemId))
        .toList(growable: false);
  }

  Future<void> markDeleted(OwnedItem item, DateTime deletedAt) async {
    final deleter = _deleters[item.catalogRef.mediaKind];
    if (deleter == null) {
      throw StateError(
        'Cannot delete owned item without a supported kind: '
        '${item.catalogRef.kind}',
      );
    }
    await deleter(item, deletedAt);
  }
}

OwnedItem? _toCommon<T>(
  T? item,
  OwnedItem Function(T item) project,
) {
  return item == null ? null : project(item);
}
