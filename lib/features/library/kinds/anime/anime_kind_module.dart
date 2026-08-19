import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/media/video/workspace/video_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';

import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';

final animeKindModule = LibraryKindSpec<AnimeWorkspaceDto, VideoOwnedDetails>(
  type: animeLibraryConfig,
  mediaAdapter: animeMediaAdapter,
  projector: const AnimeWorkspaceProjector(),
  ownedDetailsCodec: const VideoOwnedDetailsCodec(),
  fields: animeLibraryKindSchema.toRegistry(),
  add: const StandardLibraryAddCapability<VideoAddDraft>(
    kind: CatalogMediaKind.anime,
    initialDraftBuilder: VideoAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    animeLibraryConfig,
    createDraft: createVideoEditDraft,
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
  buildCardPresentation: buildVideoCardPresentation,
);
