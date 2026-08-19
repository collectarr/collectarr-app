import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';

final tvKindModule = LibraryKindSpec<TvWorkspaceDto, TvOwnedDetails>(
  type: tvLibraryConfig,
  mediaAdapter: tvMediaAdapter,
  projector: const TvWorkspaceProjector(),
  ownedDetailsCodec: const TvOwnedDetailsCodec(),
  fields: tvLibraryKindSchema.toRegistry(),
  add: const StandardLibraryAddCapability<TvAddDraft>(
    kind: CatalogMediaKind.tv,
    initialDraftBuilder: TvAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    tvLibraryConfig,
    createDraft: createTvEditDraft,
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
  buildCardPresentation: buildTvCardPresentation,
);
