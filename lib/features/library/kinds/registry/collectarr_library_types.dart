import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_pane.dart';

final collectarrLibraryTypes = LibraryTypeRegistry([
  for (final module in collectarrKindModules) module.type,
]);

void registerLibraryAddBuilders() {
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.comic,
    (context, request) => ComicAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.manga,
    (context, request) => MangaAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.book,
    (context, request) => BookAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.anime,
    (context, request) => AnimeAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.movie,
    (context, request) => MovieAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.tv,
    (context, request) => TvAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.game,
    (context, request) => GameAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.boardgame,
    (context, request) => BoardgameAddManualPane(request: request),
  );
  LibraryAddRegistry.registerManualBuilder(
    CatalogMediaKind.music,
    (context, request) => MusicAddManualPane(request: request),
  );

  registerComicAddBuilders();
  registerMovieAddBuilders();
}
