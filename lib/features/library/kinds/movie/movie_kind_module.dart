import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/media/video/workspace/video_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';

import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';

final movieKindModule = LibraryKindSpec<MovieWorkspaceDto, VideoOwnedDetails>(
  type: moviesLibraryConfig,
  mediaAdapter: moviesMediaAdapter,
  projector: const MovieWorkspaceProjector(),
  ownedDetailsCodec: const VideoOwnedDetailsCodec(),
  fields: movieLibraryKindSchema.toRegistry(),
  add: const StandardLibraryAddCapability<VideoAddDraft>(
    kind: CatalogMediaKind.movie,
    initialDraftBuilder: VideoAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    moviesLibraryConfig,
    createDraft: createVideoEditDraft,
  ),
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
  buildCardPresentation: buildVideoCardPresentation,
);
