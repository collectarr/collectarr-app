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
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
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
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.tv,
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    title: 'TV',
    icon: Icons.tv_outlined,
    accent: Color(0xFF00A7A0),
    preferencePrefix: 'tv',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'tmdb',
    providers: [tmdbMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.seasons,
    childrenTitleBuilder: _tvChildrenTitle,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildTvInspectorSections,
    detailPageBuilder: buildVideoLibraryDetailPage,
    showsDefaultPersonalSection: false,
  ),
  transfer: const LibraryTransferCapability(),
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

String _tvChildrenTitle(int count) => 'Seasons ($count)';
