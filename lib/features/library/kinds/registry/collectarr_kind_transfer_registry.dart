import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_components.dart';

final Map<CatalogMediaKind, LibraryTransferCapability> collectarrKindTransfers =
    Map.unmodifiable(<CatalogMediaKind, LibraryTransferCapability>{
  CatalogMediaKind.anime: animeKindTransfer,
  CatalogMediaKind.boardgame: boardGameKindTransfer,
  CatalogMediaKind.book: bookKindTransfer,
  CatalogMediaKind.comic: comicKindTransfer,
  CatalogMediaKind.game: gameKindTransfer,
  CatalogMediaKind.manga: mangaKindTransfer,
  CatalogMediaKind.movie: movieKindTransfer,
  CatalogMediaKind.music: musicKindTransfer,
  CatalogMediaKind.tv: tvKindTransfer,
});
