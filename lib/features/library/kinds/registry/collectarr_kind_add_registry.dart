import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

final Map<CatalogMediaKind, LibraryAddCapability> collectarrKindAdds =
    Map.unmodifiable(<CatalogMediaKind, LibraryAddCapability>{
  CatalogMediaKind.anime: animeKindAdd,
  CatalogMediaKind.boardgame: boardGameKindAdd,
  CatalogMediaKind.book: bookKindAdd,
  CatalogMediaKind.comic: comicKindAdd,
  CatalogMediaKind.game: gameKindAdd,
  CatalogMediaKind.manga: mangaKindAdd,
  CatalogMediaKind.movie: movieKindAdd,
  CatalogMediaKind.music: musicKindAdd,
  CatalogMediaKind.tv: tvKindAdd,
});
