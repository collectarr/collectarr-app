import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_components.dart';

final Map<CatalogMediaKind, LibraryEditCapabilitySet>
    collectarrKindEditCapabilities =
    Map.unmodifiable(<CatalogMediaKind, LibraryEditCapabilitySet>{
  CatalogMediaKind.anime: animeKindEditCapabilities,
  CatalogMediaKind.boardgame: boardGameKindEditCapabilities,
  CatalogMediaKind.book: bookKindEditCapabilities,
  CatalogMediaKind.comic: comicKindEditCapabilities,
  CatalogMediaKind.game: gameKindEditCapabilities,
  CatalogMediaKind.manga: mangaKindEditCapabilities,
  CatalogMediaKind.movie: movieKindEditCapabilities,
  CatalogMediaKind.music: musicKindEditCapabilities,
  CatalogMediaKind.tv: tvKindEditCapabilities,
});
