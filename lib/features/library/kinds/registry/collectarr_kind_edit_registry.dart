import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

final Map<CatalogMediaKind, LibraryEditCapabilitySet>
    collectarrKindEditCapabilities =
    releasedKindContributions(<CatalogMediaKind, LibraryEditCapabilitySet>{
  CatalogMediaKind.anime: animeKindEditCapabilities,
  CatalogMediaKind.boardgame: boardGameKindEditCapabilities,
  CatalogMediaKind.book: bookKindEditCapabilities,
  CatalogMediaKind.comic: comicKindEditCapabilities,
  CatalogMediaKind.game: gameKindEditCapabilities,
  CatalogMediaKind.gameHardware: gameHardwareKindEditCapabilities,
  CatalogMediaKind.gameToy: gameToyKindEditCapabilities,
  CatalogMediaKind.movie: movieKindEditCapabilities,
  CatalogMediaKind.music: musicKindEditCapabilities,
});
