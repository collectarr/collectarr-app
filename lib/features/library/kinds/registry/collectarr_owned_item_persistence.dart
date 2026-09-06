import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';

typedef _OwnedItemPersister = Future<void> Function(OwnedItem item);

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
        };

  final Map<CatalogMediaKind, _OwnedItemPersister> _persisters;

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
}
