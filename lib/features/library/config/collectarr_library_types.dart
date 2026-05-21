import 'package:collectarr_app/features/library/config/comics_library_config.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/config/planned_library_configs.dart';

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
