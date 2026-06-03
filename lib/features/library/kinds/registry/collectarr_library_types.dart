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
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart'
    as comic_add;
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart'
    as movie_add;

const collectarrLibraryTypes = LibraryTypeRegistry([
  comicsLibraryConfig,
  mangaLibraryConfig,
  booksLibraryConfig,
  gamesLibraryConfig,
  boardGamesLibraryConfig,
  moviesLibraryConfig,
  tvLibraryConfig,
  animeLibraryConfig,
  musicLibraryConfig,
]);

// Register LibraryAdd builders from kinds so the generic dialog can remain
// decoupled and discover per-kind custom panes.
void registerLibraryAddBuilders() {
  // Register a default manual builder for all known library kinds so the
  // per-kind registry has a sane fallback and kinds can fully own their
  // manual UI when they choose to override it.
  for (final t in collectarrLibraryTypes.types) {
    LibraryAddRegistry.registerManualBuilder(
        t.workspace.kind, buildDefaultManualPane);
    // Provide an empty default kindSpecific factory so callers can always
    // invoke and merge results without null checks.
    LibraryAddRegistry.registerManualKindSpecificFactory(
        t.workspace.kind, () => <String, dynamic>{});
  }
  comic_add.registerComicAddBuilders();
  movie_add.registerMovieAddBuilders();
}

// NOTE: registration should be invoked from application init (e.g. main())
// to avoid module-load ordering issues in tests. Call `registerLibraryAddBuilders()`
// from a centralized initialization point when the app starts.
