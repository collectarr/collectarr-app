import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_entity_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

final Map<CatalogMediaKind, LibraryEntityActionCapability>
    collectarrKindEntityActions =
    Map.unmodifiable(<CatalogMediaKind, LibraryEntityActionCapability>{
  CatalogMediaKind.anime: animeKindActions,
  CatalogMediaKind.boardgame: boardGameKindActions,
  CatalogMediaKind.book: bookKindActions,
  CatalogMediaKind.comic: comicKindActions,
  CatalogMediaKind.game: gameKindActions,
  CatalogMediaKind.manga: mangaKindActions,
  CatalogMediaKind.movie: movieKindActions,
  CatalogMediaKind.music: musicKindActions,
  CatalogMediaKind.tv: tvKindActions,
});
