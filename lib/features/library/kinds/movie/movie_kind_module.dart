import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart'
    as movie_add;
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

final movieKindModule = LibraryKindModule(
  type: moviesLibraryConfig,
  mediaAdapter: moviesMediaAdapter,
  workspaceDtoFactory: MovieWorkspaceDto.fromEntry,
  add: LibraryKindAddModule(registerBuilders: movie_add.registerMovieAddBuilders),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    defaultVideoDisplayLevel: VideoDisplayLevel.titleWork,
    defaultVideoGrouping: VideoGroupingDefault.none,
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'movie', 'tv', 'anime'},
  ),
  providerMapper: const MovieLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
