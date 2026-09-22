import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

/// Calendar's explicit semantic composition root.
///
/// Calendar owns event hosting and rendering; each kind owns the meaning of
/// its release dates and event titles.
final Map<CatalogMediaKind, LibraryCalendarContributor>
    libraryCalendarContributorsByKind = {
  CatalogMediaKind.anime: const AnimeCalendarContributor(),
  CatalogMediaKind.boardgame: const BoardGameCalendarContributor(),
  CatalogMediaKind.book: const BookCalendarContributor(),
  CatalogMediaKind.comic: const ComicCalendarContributor(),
  CatalogMediaKind.game: const GameCalendarContributor(),
  CatalogMediaKind.manga: const MangaCalendarContributor(),
  CatalogMediaKind.movie: const MovieCalendarContributor(),
  CatalogMediaKind.music: const MusicCalendarContributor(),
  CatalogMediaKind.tv: const TvCalendarContributor(),
};
