import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_presentation_builder.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/release/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/detail/library_video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'package:collectarr_app/features/library/kinds/tv/stats/tv_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/add/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

const _tvShowFilterId = LibraryAddFilterId('tv.show');
const _tvNetworkFilterId = LibraryAddFilterId('tv.network');
const _tvYearFilterId = LibraryAddFilterId('tv.year');

const _tvAddChrome = LibraryAddChromeConfig(
  videoKindFilterOptions: [
    LibraryAddVideoKindFilterOption(
      kind: 'tv',
      label: 'TV Shows',
      icon: Icons.tv_outlined,
    ),
  ],
  defaultVideoKindFilters: {'tv'},
);

final _tvTransferableFields = <TransferableField>[
  TransferableField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as TvOwnedDetails?)?.features,
    write: (item, value) {
      final details = item.details as TvOwnedDetails? ?? const TvOwnedDetails();
      return item.copyWith(details: details.copyWith(features: value));
    },
  ),
  TransferableField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as TvOwnedDetails?)?.boxSetName,
    write: (item, value) {
      final details = item.details as TvOwnedDetails? ?? const TvOwnedDetails();
      return item.copyWith(details: details.copyWith(boxSetName: value));
    },
  ),
  TransferableField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as TvOwnedDetails?)?.packaging,
    write: (item, value) {
      final details = item.details as TvOwnedDetails? ?? const TvOwnedDetails();
      return item.copyWith(details: details.copyWith(packaging: value));
    },
  ),
];

Iterable<String?> _tvLinkedMetadataValues(TvSeriesMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.network,
      metadata.streamingService,
      metadata.variant,
      metadata.country,
      metadata.originalLanguage,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final tvKindModule = LibraryKindSpec<TvWorkspaceDto, TvOwnedDetails>(
  presentation: tvLibraryMediaPresentation,
  trackingProfile: tvTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  projector: const TvWorkspaceProjector(),
  ownedDetailsCodec: const TvOwnedDetailsCodec(),
  fields: tvLibraryKindSchema.toRegistry(),
  catalogMetadataDecoder: TvSeriesMetadata.fromJson,
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
  uiPolicy: const LibraryUiPolicy(
    wideDialog: true,
  ),
  hierarchy: const LibraryHierarchyCapability(
    fetchChildrenCallback: _fetchTvSeasons,
    childrenTitleBuilder: _tvChildrenTitle,
    supportsMediaReleaseSplit: true,
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildTvInspectorSections,
    detailPageBuilder: buildLibraryVideoDetailPage,
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<TvSeriesMetadata>(
    _tvLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    kindFields: _tvTransferableFields,
  ),
  stats: const TvStatsCapability(),
  add: StandardLibraryAddCapability<TvAddDraft>(
    kind: CatalogMediaKind.tv,
    initialDraftBuilder: TvAddDraft.new,
    manualDraftBuilder: TvAddManualDraft.new,
    search: LibraryAddSearchCapability(
      initialAdvancedFilters: {
        libraryAddVideoKindFilterId: {'tv'},
      },
      advancedFilterDescriptorsBuilder: buildTvAddAdvancedFilterFields,
      searchInputPredicate: libraryAddVideoHasSearchInput,
      kindSpecificPaneBuilder: buildLibraryAddVideoKindFilterRow,
      providerKindOverridesBuilder: (context) =>
          libraryAddVideoKindOverridesForChrome(_tvAddChrome, context),
      coreSearchInputBuilder: _buildTvCoreSearchInput,
      providerQueryBuilder: _buildTvProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _tvShowFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is TvSeriesMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _tvNetworkFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is TvSeriesMetadata
                  ? [
                      metadata.network,
                      metadata.streamingService,
                      ...metadata.productionCompanies,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) =>
                [candidate.publisher, candidate.summary],
          ),
          LibraryAddSearchRankField(
            id: _tvYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is TvSeriesMetadata
                  ? [
                      metadata.firstAirDate?.year,
                      metadata.lastAirDate?.year,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    resultPolicy: buildLibraryAddVideoResultPolicy(
      mediaLabel: 'Series',
      supportsSeasonScope: true,
      coreScopeForItem: _tvAddResultScope,
      providerScopeForCandidate: _tvAddProviderResultScope,
      coreGroupTitleBuilder: _tvAddGroupTitle,
      providerCandidateIsGroup: libraryAddVideoProviderCandidateIsGroup,
    ),
    manualPaneBuilder: buildTvAddManualPane,
    chrome: _tvAddChrome,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildTvLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(TvVocabularies.all),
    presentation: tvLibraryEditPresentation,
    conditions: kGeneralConditions,
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    createDraft: createTvEditDraft,
  ),
  providerMapper: const TvLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildTvCardPresentation,
);

String _tvChildrenTitle(int count) => 'Seasons ($count)';

Future<List<LibraryHierarchyNode>> _fetchTvSeasons({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final seasons = await api
      .getTvSeriesSeasonsDto(itemId)
      .timeout(const Duration(seconds: 60));
  final typedSeasons = [
    for (final season in seasons) TvCoreMapper.fromSeasonDto(season),
  ];
  return TvHierarchyMapper.toLibraryNodes(typedSeasons);
}

List<LibraryAddAdvancedFilterField<String>> buildTvAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _tvShowFilterId,
        key: const ValueKey('library-add-show-field'),
        label: 'Show / Series',
        value: req.advancedFilterText(_tvShowFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _tvNetworkFilterId,
        key: const ValueKey('library-add-network-field'),
        label: 'Network',
        value: req.advancedFilterText(_tvNetworkFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _tvYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_tvYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

LibraryMetadataSearchInput _buildTvCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalTvText(context.query),
    series: _optionalTvText(context.textValueFor(_tvShowFilterId)),
    publisher: _optionalTvText(context.textValueFor(_tvNetworkFilterId)),
    year: int.tryParse(context.textValueFor(_tvYearFilterId)),
    barcode: _optionalTvText(context.barcode),
    limit: limit,
  );
}

String _buildTvProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_tvShowFilterId),
    context.textValueFor(_tvNetworkFilterId),
    context.textValueFor(_tvYearFilterId),
    context.barcode,
  ]);
}

String? _optionalTvText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

LibraryAddVideoResultScope _tvAddResultScope(CatalogItem item) {
  final metadata = item.kindMetadata;
  if (metadata is TvSeriesMetadata) {
    if (metadata.seasonNumber != null ||
        metadata.series?.seasonNumber != null) {
      return LibraryAddVideoResultScope.season;
    }
    if ([
      metadata.itemNumber,
      metadata.physicalFormat,
      metadata.physicalFormatLabel,
      metadata.barcode,
      metadata.variant,
    ].any((value) => value?.trim().isNotEmpty == true)) {
      return LibraryAddVideoResultScope.release;
    }
  }
  return LibraryAddVideoResultScope.media;
}

LibraryAddVideoResultScope _tvAddProviderResultScope(
  ProviderCandidate candidate,
) {
  final candidateType = candidate.candidateType?.trim().toLowerCase();
  if (candidateType == 'season') {
    return LibraryAddVideoResultScope.season;
  }
  if (candidateType == 'release' ||
      candidateType == 'edition' ||
      candidateType == 'episode' ||
      candidateType == 'issue' ||
      candidate.issueNumber?.trim().isNotEmpty == true ||
      candidate.isVariant) {
    return LibraryAddVideoResultScope.release;
  }
  return LibraryAddVideoResultScope.media;
}

String _tvAddGroupTitle(CatalogItem item) {
  final metadata = item.kindMetadata;
  if (metadata is TvSeriesMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
