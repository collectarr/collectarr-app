import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/library_type_registry.dart';
import 'package:collectarr_app/features/library/planned_library_configs.dart';

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
