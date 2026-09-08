import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/detail/tv_video_detail_contribution.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_presentation_builder.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/release/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/detail/library_video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_editor_extension.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
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
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

const _tvShowFilterId = LibraryAddFilterId('tv.show');
const _tvNetworkFilterId = LibraryAddFilterId('tv.network');
const _tvYearFilterId = LibraryAddFilterId('tv.year');

const _tvAddChrome = LibraryAddChromeConfig(
  videoKindFilterOptions: [
    LibraryAddVideoKindFilterOption(
      scope: LibraryAddVideoSearchScope.tv,
      label: 'TV Shows',
      icon: Icons.tv_outlined,
    ),
  ],
  defaultVideoKindFilters: {LibraryAddVideoSearchScope.tv},
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

const tvLibraryFacetModule = LibraryFacetModule(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
);

final tvKindModule = LibraryKindSpec<TvWorkspaceDto>(
  presentation: tvLibraryMediaPresentation,
  physicalMediaFormats: tvPhysicalMediaFormats,
  trackingProfile: tvTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.tv,
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    title: 'TV',
    icon: Icons.tv_outlined,
    accent: Color(0xFF00A7A0),
    preferencePrefix: 'tv',
    routeSegments: ['tv', 'tv-shows', 'tvshows'],
    mediaFamily: 'video',
    normalizeCatalogLabels: true,
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
    videoDetailContributionBuilder: buildTvVideoDetailContribution,
    showsDefaultPersonalSection: false,
    trackingEditor: LibraryTrackingEditorCapability(
      builder: buildTvTrackingEditorExtension,
    ),
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
    ownedPayloadBuilder: (item, common, details) => TvOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as TvOwnedDetailsDraft,
      condition: common.condition,
      grade: common.grade,
      purchaseDate: common.purchaseDate,
      pricePaidCents: common.pricePaidCents,
      currency: common.currency,
      personalNotes: common.personalNotes,
      quantity: common.quantity,
      tags: common.tags,
      locationId: common.locationId,
      purchaseStore: common.purchaseStore,
      collectionStatus: common.collectionStatus,
      isDigital: common.isDigital,
    ),
    existingOwnedPayloadBuilder: TvOwnedItemCreatePayload.fromOwnedItem,
    search: LibraryAddSearchCapability(
      initialAdvancedFilters: {
        libraryAddVideoKindFilterId: {LibraryAddVideoSearchScope.tv},
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
    conditions: TvVocabularies.condition.builtIns,
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    createDraft: createTvEditDraft,
    ownedDigitalFlagResolver: resolveTvOwnedDigitalFlag,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        TvOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionGradeUpdatePayloadBuilder: (ownedItemId, condition, grade) =>
        TvOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(grade),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, grade, locationId, tags) =>
            TvOwnedItemUpdatePayload.partial(
      condition:
          condition == null ? const Patch.unchanged() : Patch.set(condition),
      grade: grade == null ? const Patch.unchanged() : Patch.set(grade),
      locationId:
          locationId == null ? const Patch.unchanged() : Patch.set(locationId),
      tags: tags == null ? const Patch.unchanged() : Patch.set(tags),
    ),
    ownedPersonalDetailsUpdatePayloadBuilder: (
      ownedItemId,
      purchaseDate,
      pricePaidCents,
      currency,
      personalNotes,
      purchaseStore,
      locationChanged,
      locationId,
    ) =>
        TvOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) =>
        TvOwnedItemUpdatePayload.partial(
      condition: Patch.set(updated.condition),
      grade: Patch.set(updated.grade),
      personalNotes: Patch.set(updated.personalNotes),
      locationId: Patch.set(updated.locationId),
      tags: Patch.set(updated.tags),
      currency: Patch.set(updated.currency),
      soldTo: Patch.set(updated.soldTo),
      purchaseStore: Patch.set(updated.purchaseStore),
      pricePaidCents: Patch.set(updated.pricePaidCents),
      sellPriceCents: Patch.set(updated.sellPriceCents),
      quantity: Patch.set(updated.quantity),
      indexNumber: Patch.set(updated.indexNumber),
      purchaseDate: Patch.set(updated.purchaseDate),
      soldAt: Patch.set(updated.soldAt),
      details: Patch.set(
        const TvOwnedDetailsCodec().draftFromDetails(
          updated.details as TvOwnedDetails,
        ),
      ),
    ),
    ownedDetailsResetPayloadBuilder: () =>
        TvOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  ),
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

LibraryAddVideoResultScope _tvAddResultScope(CatalogItemDto item) {
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

String _tvAddGroupTitle(CatalogItemDto item) {
  final metadata = item.kindMetadata;
  if (metadata is TvSeriesMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}

final tvKindWorkspace = TypedLibraryKindWorkspace<TvWorkspaceDto>(
  fields: tvLibraryKindSchema.toRegistry(),
  projector: const TvWorkspaceProjector(),
  hierarchy: tvKindModule.hierarchy,
);
