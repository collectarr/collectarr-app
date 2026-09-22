import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

final Map<CatalogMediaKind, LibraryAdminContributor>
    libraryAdminContributorsByKind = {
  CatalogMediaKind.anime: const AnimeAdminContributor(),
  CatalogMediaKind.boardgame: const BoardGameAdminContributor(),
  CatalogMediaKind.book: const BookAdminContributor(),
  CatalogMediaKind.comic: const ComicAdminContributor(),
  CatalogMediaKind.game: const GameAdminContributor(),
  CatalogMediaKind.manga: const MangaAdminContributor(),
  CatalogMediaKind.movie: const MovieAdminContributor(),
  CatalogMediaKind.music: const MusicAdminContributor(),
  CatalogMediaKind.tv: const TvAdminContributor(),
};
