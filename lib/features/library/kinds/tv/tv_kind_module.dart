import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_media_adapter.dart';
import 'package:collectarr_app/features/library/media/video/workspace/video_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';

import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';

final tvKindModule = LibraryKindSpec<TvWorkspaceDto, VideoOwnedDetails>(
  type: tvLibraryConfig,
  mediaAdapter: tvMediaAdapter,
  projector: const TvWorkspaceProjector(),
  ownedDetailsCodec: const VideoOwnedDetailsCodec(),
  fields: tvLibraryKindSchema.toRegistry(),
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
