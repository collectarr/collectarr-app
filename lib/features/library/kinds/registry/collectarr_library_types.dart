import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';

const collectarrLibraryTypes = LibraryTypeRegistry([
  comicsLibraryConfig,
  mangaLibraryConfig,
  animeLibraryConfig,
  booksLibraryConfig,
  gamesLibraryConfig,
  boardGamesLibraryConfig,
  moviesLibraryConfig,
  tvLibraryConfig,
  musicLibraryConfig,
]);