import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/legacy/anime_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/legacy/boardgame_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/legacy/book_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/legacy/game_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/legacy/manga_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/legacy/movie_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/legacy/music_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/legacy/tv_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';

/// Composition-root dispatch for the transitional common Owned write path.
///
/// This is intentionally the only place where a legacy [OwnedItem] is
/// translated into a complete concrete owned-copy model. Collection commands
/// retain their compatibility cache for now, but every mutation also reaches
/// the owning kind's repository immediately.
final class CollectarrOwnedItemPersistence {
  CollectarrOwnedItemPersistence(LocalDatabase database)
      : _comic = ComicOwnedRepository(database),
        _manga = MangaOwnedRepository(database),
        _book = BookOwnedRepository(database),
        _game = GameOwnedRepository(database),
        _boardGame = BoardGameOwnedRepository(database),
        _movie = MovieOwnedRepository(database),
        _tv = TvOwnedRepository(database),
        _anime = AnimeOwnedRepository(database),
        _music = MusicOwnedRepository(database);
  final ComicOwnedRepository _comic;
  final MangaOwnedRepository _manga;
  final BookOwnedRepository _book;
  final GameOwnedRepository _game;
  final BoardGameOwnedRepository _boardGame;
  final MovieOwnedRepository _movie;
  final TvOwnedRepository _tv;
  final AnimeOwnedRepository _anime;
  final MusicOwnedRepository _music;

  Future<void> upsert(OwnedItem item) async {
    switch (item.catalogRef.mediaKind) {
      case CatalogMediaKind.comic:
        await _comic.upsert(ComicOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.manga:
        await _manga.upsert(MangaOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.book:
        await _book.upsert(BookOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.game:
        await _game.upsert(GameOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.boardgame:
        await _boardGame
            .upsert(BoardGameOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.movie:
        await _movie.upsert(MovieOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.tv:
        await _tv.upsert(TvOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.anime:
        await _anime.upsert(AnimeOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.music:
        await _music.upsert(MusicOwnedItemLegacyAdapter.fromLegacy(item));
      case CatalogMediaKind.unknown:
        throw ArgumentError.value(
          item.catalogRef.kind,
          'item.catalogRef.kind',
          'Cannot persist an unknown owned-item kind',
        );
    }
  }

  Future<void> upsertAll(Iterable<OwnedItem> items) async {
    for (final item in items) {
      await upsert(item);
    }
  }
}
