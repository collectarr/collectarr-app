import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_catalog_target_capability.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_topology.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/release/library_release_detail_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_components.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';

final Map<CatalogMediaKind, MediaTrackingProfile>
    collectarrKindTrackingProfiles =
    Map.unmodifiable(<CatalogMediaKind, MediaTrackingProfile>{
  CatalogMediaKind.anime: animeKindTrackingProfile,
  CatalogMediaKind.boardgame: boardGameKindTrackingProfile,
  CatalogMediaKind.book: bookKindTrackingProfile,
  CatalogMediaKind.comic: comicKindTrackingProfile,
  CatalogMediaKind.game: gameKindTrackingProfile,
  CatalogMediaKind.manga: mangaKindTrackingProfile,
  CatalogMediaKind.movie: movieKindTrackingProfile,
  CatalogMediaKind.music: musicKindTrackingProfile,
  CatalogMediaKind.tv: tvKindTrackingProfile,
});

final Map<CatalogMediaKind, LibraryHierarchyCapability>
    collectarrKindHierarchies =
    Map.unmodifiable(<CatalogMediaKind, LibraryHierarchyCapability>{
  CatalogMediaKind.anime: animeKindHierarchy,
  CatalogMediaKind.boardgame: boardGameKindHierarchy,
  CatalogMediaKind.book: bookKindHierarchy,
  CatalogMediaKind.comic: comicKindHierarchy,
  CatalogMediaKind.game: gameKindHierarchy,
  CatalogMediaKind.manga: mangaKindHierarchy,
  CatalogMediaKind.movie: movieKindHierarchy,
  CatalogMediaKind.music: musicKindHierarchy,
  CatalogMediaKind.tv: tvKindHierarchy,
});

final Map<CatalogMediaKind, LibraryKindTopology> collectarrKindTopologies =
    Map.unmodifiable(<CatalogMediaKind, LibraryKindTopology>{
  CatalogMediaKind.anime: animeKindTopology,
  CatalogMediaKind.boardgame: boardGameKindTopology,
  CatalogMediaKind.book: bookKindTopology,
  CatalogMediaKind.comic: comicKindTopology,
  CatalogMediaKind.game: gameKindTopology,
  CatalogMediaKind.manga: mangaKindTopology,
  CatalogMediaKind.movie: movieKindTopology,
  CatalogMediaKind.music: musicKindTopology,
  CatalogMediaKind.tv: tvKindTopology,
});

final Map<CatalogMediaKind, LibraryInspectorCapability>
    collectarrKindInspectors =
    Map.unmodifiable(<CatalogMediaKind, LibraryInspectorCapability>{
  CatalogMediaKind.anime: animeKindInspector,
  CatalogMediaKind.boardgame: boardGameKindInspector,
  CatalogMediaKind.book: bookKindInspector,
  CatalogMediaKind.comic: comicKindInspector,
  CatalogMediaKind.game: gameKindInspector,
  CatalogMediaKind.manga: mangaKindInspector,
  CatalogMediaKind.movie: movieKindInspector,
  CatalogMediaKind.music: musicKindInspector,
  CatalogMediaKind.tv: tvKindInspector,
});

final Map<CatalogMediaKind, WorkProjectionCapability<LibraryWorkspaceDto>>
    collectarrKindWorkCapabilities = Map.unmodifiable(
  <CatalogMediaKind, WorkProjectionCapability<LibraryWorkspaceDto>>{
    CatalogMediaKind.anime: animeKindWorkCapability,
    CatalogMediaKind.boardgame: boardGameKindWorkCapability,
    CatalogMediaKind.book: bookKindWorkCapability,
    CatalogMediaKind.comic: comicKindWorkCapability,
    CatalogMediaKind.game: gameKindWorkCapability,
    CatalogMediaKind.manga: mangaKindWorkCapability,
    CatalogMediaKind.movie: movieKindWorkCapability,
    CatalogMediaKind.music: musicKindWorkCapability,
    CatalogMediaKind.tv: tvKindWorkCapability,
  },
);

final Map<CatalogMediaKind, ReleaseProjectionCapability<LibraryWorkspaceDto>?>
    collectarrKindReleaseCapabilities = Map.unmodifiable(
  <CatalogMediaKind, ReleaseProjectionCapability<LibraryWorkspaceDto>?>{
    CatalogMediaKind.anime: animeKindReleaseCapability,
    CatalogMediaKind.boardgame: boardGameKindReleaseCapability
        as ReleaseProjectionCapability<LibraryWorkspaceDto>?,
    CatalogMediaKind.book: bookKindReleaseCapability
        as ReleaseProjectionCapability<LibraryWorkspaceDto>?,
    CatalogMediaKind.comic: comicKindReleaseCapability
        as ReleaseProjectionCapability<LibraryWorkspaceDto>?,
    CatalogMediaKind.game: gameKindReleaseCapability
        as ReleaseProjectionCapability<LibraryWorkspaceDto>?,
    CatalogMediaKind.manga: mangaKindReleaseCapability
        as ReleaseProjectionCapability<LibraryWorkspaceDto>?,
    CatalogMediaKind.movie: movieKindReleaseCapability,
    CatalogMediaKind.music: musicKindReleaseCapability
        as ReleaseProjectionCapability<LibraryWorkspaceDto>?,
    CatalogMediaKind.tv: tvKindReleaseCapability,
  },
);

final Map<CatalogMediaKind, LibraryReleaseDetailSource?>
    collectarrKindReleaseDetailSources = Map.unmodifiable(
  <CatalogMediaKind, LibraryReleaseDetailSource?>{
    CatalogMediaKind.anime: animeKindReleaseDetailSource,
    CatalogMediaKind.boardgame:
        boardGameKindReleaseDetailSource as LibraryReleaseDetailSource?,
    CatalogMediaKind.book:
        bookKindReleaseDetailSource as LibraryReleaseDetailSource?,
    CatalogMediaKind.comic:
        comicKindReleaseDetailSource as LibraryReleaseDetailSource?,
    CatalogMediaKind.game:
        gameKindReleaseDetailSource as LibraryReleaseDetailSource?,
    CatalogMediaKind.manga:
        mangaKindReleaseDetailSource as LibraryReleaseDetailSource?,
    CatalogMediaKind.movie: movieKindReleaseDetailSource,
    CatalogMediaKind.music:
        musicKindReleaseDetailSource as LibraryReleaseDetailSource?,
    CatalogMediaKind.tv: tvKindReleaseDetailSource,
  },
);

final Map<CatalogMediaKind, LibraryCatalogTargetCapability>
    collectarrKindCatalogTargets =
    Map.unmodifiable(<CatalogMediaKind, LibraryCatalogTargetCapability>{
  CatalogMediaKind.anime: animeKindCatalogTarget,
  CatalogMediaKind.boardgame: boardGameKindCatalogTarget,
  CatalogMediaKind.book: bookKindCatalogTarget,
  CatalogMediaKind.comic: comicKindCatalogTarget,
  CatalogMediaKind.game: gameKindCatalogTarget,
  CatalogMediaKind.manga: mangaKindCatalogTarget,
  CatalogMediaKind.movie: movieKindCatalogTarget,
  CatalogMediaKind.music: musicKindCatalogTarget,
  CatalogMediaKind.tv: tvKindCatalogTarget,
});

final Map<CatalogMediaKind, LibraryKindToolbarModule?> collectarrKindToolbars =
    Map.unmodifiable(<CatalogMediaKind, LibraryKindToolbarModule?>{
  CatalogMediaKind.anime: animeKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.boardgame: boardGameKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.book: bookKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.comic: comicKindToolbar,
  CatalogMediaKind.game: gameKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.manga: mangaKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.movie: movieKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.music: musicKindToolbar as LibraryKindToolbarModule?,
  CatalogMediaKind.tv: tvKindToolbar as LibraryKindToolbarModule?,
});

final Map<CatalogMediaKind, List<LibrarySearchTarget>>
    collectarrKindSearchTargetOptions =
    Map.unmodifiable(<CatalogMediaKind, List<LibrarySearchTarget>>{
  CatalogMediaKind.anime: animeKindSearchTargetOptions,
  CatalogMediaKind.boardgame: boardGameKindSearchTargetOptions,
  CatalogMediaKind.book: bookKindSearchTargetOptions,
  CatalogMediaKind.comic: comicKindSearchTargetOptions,
  CatalogMediaKind.game: gameKindSearchTargetOptions,
  CatalogMediaKind.manga: mangaKindSearchTargetOptions,
  CatalogMediaKind.movie: movieKindSearchTargetOptions,
  CatalogMediaKind.music: musicKindSearchTargetOptions,
  CatalogMediaKind.tv: tvKindSearchTargetOptions,
});

final Map<CatalogMediaKind, LibraryWorkspaceViewProfile>
    collectarrKindViewProfiles =
    Map.unmodifiable(<CatalogMediaKind, LibraryWorkspaceViewProfile>{
  CatalogMediaKind.anime: animeKindViewProfile,
  CatalogMediaKind.boardgame: boardGameKindViewProfile,
  CatalogMediaKind.book: bookKindViewProfile,
  CatalogMediaKind.comic: comicKindViewProfile,
  CatalogMediaKind.game: gameKindViewProfile,
  CatalogMediaKind.manga: mangaKindViewProfile,
  CatalogMediaKind.movie: movieKindViewProfile,
  CatalogMediaKind.music: musicKindViewProfile,
  CatalogMediaKind.tv: tvKindViewProfile,
});

final Map<CatalogMediaKind, LibraryKindWorkspace> collectarrKindWorkspaces = {
  CatalogMediaKind.anime: animeKindWorkspace,
  CatalogMediaKind.boardgame: boardGameKindWorkspace,
  CatalogMediaKind.book: bookKindWorkspace,
  CatalogMediaKind.comic: comicKindWorkspace,
  CatalogMediaKind.game: gameKindWorkspace,
  CatalogMediaKind.manga: mangaKindWorkspace,
  CatalogMediaKind.movie: movieKindWorkspace,
  CatalogMediaKind.music: musicKindWorkspace,
  CatalogMediaKind.tv: tvKindWorkspace,
};

final Map<CatalogMediaKind, LibraryFacetModule> collectarrKindFacetModules = {
  CatalogMediaKind.anime: animeLibraryFacetModule,
  CatalogMediaKind.boardgame: boardGameLibraryFacetModule,
  CatalogMediaKind.book: bookLibraryFacetModule,
  CatalogMediaKind.comic: comicLibraryFacetModule,
  CatalogMediaKind.game: gameLibraryFacetModule,
  CatalogMediaKind.manga: mangaLibraryFacetModule,
  CatalogMediaKind.movie: movieLibraryFacetModule,
  CatalogMediaKind.music: musicLibraryFacetModule,
  CatalogMediaKind.tv: tvLibraryFacetModule,
};
