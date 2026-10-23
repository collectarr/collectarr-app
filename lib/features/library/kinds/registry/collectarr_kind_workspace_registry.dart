import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_target_vocabulary.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';

final Map<CatalogMediaKind, MediaTrackingProfile>
    collectarrKindTrackingProfiles =
    releasedKindContributions(<CatalogMediaKind, MediaTrackingProfile>{
  CatalogMediaKind.anime: animeKindTrackingProfile,
  CatalogMediaKind.boardgame: boardGameKindTrackingProfile,
  CatalogMediaKind.book: bookKindTrackingProfile,
  CatalogMediaKind.comic: comicKindTrackingProfile,
  CatalogMediaKind.game: gameKindTrackingProfile,
  CatalogMediaKind.gameHardware: gameHardwareKindTrackingProfile,
  CatalogMediaKind.gameToy: gameToyKindTrackingProfile,
  CatalogMediaKind.movie: movieKindTrackingProfile,
  CatalogMediaKind.music: musicKindTrackingProfile,
});

final Map<CatalogMediaKind, LibraryTrackingTopology>
    collectarrKindTrackingTopologies =
    releasedKindContributions(<CatalogMediaKind, LibraryTrackingTopology>{
  CatalogMediaKind.anime: animeKindTrackingTopology,
  CatalogMediaKind.boardgame: boardGameKindTrackingTopology,
  CatalogMediaKind.book: bookKindTrackingTopology,
  CatalogMediaKind.comic: comicKindTrackingTopology,
  CatalogMediaKind.game: gameKindTrackingTopology,
  CatalogMediaKind.gameHardware: gameHardwareKindTrackingTopology,
  CatalogMediaKind.gameToy: gameToyKindTrackingTopology,
  CatalogMediaKind.movie: movieKindTrackingTopology,
  CatalogMediaKind.music: musicKindTrackingTopology,
});

final Map<CatalogMediaKind, LibraryHierarchyCapability>
    collectarrKindHierarchies =
    releasedKindContributions(<CatalogMediaKind, LibraryHierarchyCapability>{
  CatalogMediaKind.anime: animeKindHierarchy,
  CatalogMediaKind.movie: movieKindHierarchy,
  CatalogMediaKind.music: musicKindHierarchy,
});

final Map<CatalogMediaKind, LibraryTargetVocabulary>
    collectarrKindEntityVocabularies =
    releasedKindContributions(<CatalogMediaKind, LibraryTargetVocabulary>{
  CatalogMediaKind.anime: animeKindEntityVocabulary,
  CatalogMediaKind.boardgame: boardGameKindEntityVocabulary,
  CatalogMediaKind.book: bookKindEntityVocabulary,
  CatalogMediaKind.comic: comicKindEntityVocabulary,
  CatalogMediaKind.game: gameKindEntityVocabulary,
  CatalogMediaKind.gameHardware: gameHardwareKindEntityVocabulary,
  CatalogMediaKind.gameToy: gameToyKindEntityVocabulary,
  CatalogMediaKind.movie: movieKindEntityVocabulary,
  CatalogMediaKind.music: musicKindEntityVocabulary,
});

final Map<CatalogMediaKind, LibraryInspectorCapability>
    collectarrKindInspectors =
    releasedKindContributions(<CatalogMediaKind, LibraryInspectorCapability>{
  CatalogMediaKind.anime: animeKindInspector,
  CatalogMediaKind.boardgame: boardGameKindInspector,
  CatalogMediaKind.book: bookKindInspector,
  CatalogMediaKind.comic: comicKindInspector,
  CatalogMediaKind.game: gameKindInspector,
  CatalogMediaKind.gameHardware: gameHardwareKindInspector,
  CatalogMediaKind.gameToy: gameToyKindInspector,
  CatalogMediaKind.movie: movieKindInspector,
  CatalogMediaKind.music: musicKindInspector,
});

final Map<CatalogMediaKind, LibraryKindToolbarModule?> collectarrKindToolbars =
    releasedKindContributions(<CatalogMediaKind, LibraryKindToolbarModule?>{
  CatalogMediaKind.anime: animeKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.boardgame: boardGameKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.book: bookKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.comic: comicKindToolbar,
  CatalogMediaKind.game: gameKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.gameHardware:
      gameHardwareKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.gameToy: gameToyKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.movie: movieKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.music: musicKindToolbar as LibraryKindToolbarModule?,
});

final Map<CatalogMediaKind, List<LibrarySearchTarget>>
    collectarrKindSearchTargetOptions =
    releasedKindContributions(<CatalogMediaKind, List<LibrarySearchTarget>>{
  CatalogMediaKind.anime: animeKindSearchTargetOptions,
  CatalogMediaKind.boardgame: boardGameKindSearchTargetOptions,
  CatalogMediaKind.book: bookKindSearchTargetOptions,
  CatalogMediaKind.comic: comicKindSearchTargetOptions,
  CatalogMediaKind.game: gameKindSearchTargetOptions,
  CatalogMediaKind.gameHardware: gameHardwareKindSearchTargetOptions,
  CatalogMediaKind.gameToy: gameToyKindSearchTargetOptions,
  CatalogMediaKind.movie: movieKindSearchTargetOptions,
  CatalogMediaKind.music: musicKindSearchTargetOptions,
});

final Map<CatalogMediaKind, LibraryWorkspaceViewProfile>
    collectarrKindViewProfiles =
    releasedKindContributions(<CatalogMediaKind, LibraryWorkspaceViewProfile>{
  CatalogMediaKind.anime: animeKindViewProfile,
  CatalogMediaKind.boardgame: boardGameKindViewProfile,
  CatalogMediaKind.book: bookKindViewProfile,
  CatalogMediaKind.comic: comicKindViewProfile,
  CatalogMediaKind.game: gameKindViewProfile,
  CatalogMediaKind.gameHardware: gameHardwareKindViewProfile,
  CatalogMediaKind.gameToy: gameToyKindViewProfile,
  CatalogMediaKind.movie: movieKindViewProfile,
  CatalogMediaKind.music: musicKindViewProfile,
});

final Map<CatalogMediaKind, LibraryKindWorkspace> collectarrKindWorkspaces = {
  CatalogMediaKind.anime: animeKindWorkspace,
  CatalogMediaKind.boardgame: boardGameKindWorkspace,
  CatalogMediaKind.book: bookKindWorkspace,
  CatalogMediaKind.comic: comicKindWorkspace,
  CatalogMediaKind.game: gameKindWorkspace,
  CatalogMediaKind.gameHardware: gameHardwareKindWorkspace,
  CatalogMediaKind.gameToy: gameToyKindWorkspace,
  CatalogMediaKind.movie: movieKindWorkspace,
  CatalogMediaKind.music: musicKindWorkspace,
};

final Map<CatalogMediaKind, LibraryFacetModule> collectarrKindFacetModules = {
  CatalogMediaKind.anime: animeLibraryFacetModule,
  CatalogMediaKind.boardgame: boardGameLibraryFacetModule,
  CatalogMediaKind.book: bookLibraryFacetModule,
  CatalogMediaKind.comic: comicLibraryFacetModule,
  CatalogMediaKind.game: gameLibraryFacetModule,
  CatalogMediaKind.gameHardware: gameHardwareLibraryFacetModule,
  CatalogMediaKind.gameToy: gameToyLibraryFacetModule,
  CatalogMediaKind.movie: movieLibraryFacetModule,
  CatalogMediaKind.music: musicLibraryFacetModule,
};
