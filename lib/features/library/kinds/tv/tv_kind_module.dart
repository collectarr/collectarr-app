import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_media_adapter.dart';
import 'package:collectarr_app/features/library/media/video/workspace/video_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';


final tvKindModule = LibraryKindModule(
  type: tvLibraryConfig,
  mediaAdapter: tvMediaAdapter,
  workspaceDtoFactory: TvWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: tvLibraryGroupDefinitions,
    sorts: tvLibrarySortDefinitions,
    columns: tvLibraryColumnDefinitions,
    defaultVisibleColumnIds: tvLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
  ),
  workspaceBehavior: LibraryKindWorkspaceBehavior(
    showsSeasonGroupProgress: true,
    defaultVideoDisplayLevel: tvDefaultVideoDisplayLevel,
    defaultVideoGrouping: tvDefaultVideoGrouping,
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'tv'},
  ),
  providerMapper: const TvLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildVideoCardPresentation,
);
