import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';

final animeKindModule = LibraryKindModule(
  type: animeLibraryConfig,
  mediaAdapter: animeMediaAdapter,
  workspaceDtoFactory: AnimeWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: animeLibraryGroupDefinitions,
    sorts: animeLibrarySortDefinitions,
    columns: animeLibraryColumnDefinitions,
    defaultVisibleColumnIds: animeLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsSeriesIssueJump: true,
    defaultVideoDisplayLevel: VideoDisplayLevel.season,
    defaultVideoGrouping: VideoGroupingDefault.bySeries,
    videoSeriesEntryTypes: {'anime'},
    videoShelfDrilldownEntryTypes: {'anime'},
  ),
  providerMapper: const AnimeLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
