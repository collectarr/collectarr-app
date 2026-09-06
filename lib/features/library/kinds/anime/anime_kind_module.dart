import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_editor_extension.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/release/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/add/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/stats/anime_stats_capability.dart';

const _animeSeriesFilterId = LibraryAddFilterId('anime.series');
const _animeStudioFilterId = LibraryAddFilterId('anime.studio');
const _animeYearFilterId = LibraryAddFilterId('anime.year');

const _animeAddChrome = LibraryAddChromeConfig(
  videoKindFilterOptions: [
    LibraryAddVideoKindFilterOption(
      kind: 'anime',
      label: 'Anime',
      icon: Icons.auto_awesome_outlined,
    ),
  ],
  defaultVideoKindFilters: {'anime'},
);

final _animeTransferableFields = <TransferableField>[
  TransferableField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as AnimeOwnedDetails?)?.features,
    write: (item, value) {
      final details =
          item.details as AnimeOwnedDetails? ?? const AnimeOwnedDetails();
      return item.copyWith(details: details.copyWith(features: value));
    },
  ),
  TransferableField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as AnimeOwnedDetails?)?.boxSetName,
    write: (item, value) {
      final details =
          item.details as AnimeOwnedDetails? ?? const AnimeOwnedDetails();
      return item.copyWith(details: details.copyWith(boxSetName: value));
    },
  ),
  TransferableField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as AnimeOwnedDetails?)?.packaging,
    write: (item, value) {
      final details =
          item.details as AnimeOwnedDetails? ?? const AnimeOwnedDetails();
      return item.copyWith(details: details.copyWith(packaging: value));
    },
  ),
];

Iterable<String?> _animeLinkedMetadataValues(AnimeMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      ...metadata.studios,
      ...metadata.producers,
      metadata.variant,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final animeKindModule = LibraryKindSpec<AnimeWorkspaceDto>(
  presentation: animeLibraryMediaPresentation,
  trackingProfile: animeTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  projector: const AnimeWorkspaceProjector(),
  fields: animeLibraryKindSchema.toRegistry(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.anime,
    singularLabel: 'Anime',
    pluralLabel: 'Anime',
    title: 'Anime',
    icon: Icons.movie_filter_outlined,
    accent: Color(0xFFC94DFF),
    preferencePrefix: 'anime',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'anilist',
    usesTreeProviderCandidates: true,
    providers: [anilistMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    fetchChildrenCallback: _fetchAnimeEpisodes,
    childrenTitleBuilder: _animeChildrenTitle,
    supportsMediaReleaseSplit: true,
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
    trackingEditor: LibraryTrackingEditorCapability(
      builder: buildAnimeTrackingEditorExtension,
    ),
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<AnimeMetadata>(
    _animeLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    kindFields: _animeTransferableFields,
  ),
  stats: const AnimeStatsCapability(),
  uiPolicy: const LibraryUiPolicy(
    wideDialog: true,
  ),
  add: StandardLibraryAddCapability<AnimeAddDraft>(
    kind: CatalogMediaKind.anime,
    initialDraftBuilder: AnimeAddDraft.new,
    manualDraftBuilder: AnimeAddManualDraft.new,
    ownedPayloadBuilder: (item, common, details) => AnimeOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as AnimeOwnedDetailsDraft,
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
    existingOwnedPayloadBuilder: AnimeOwnedItemCreatePayload.fromOwnedItem,
    search: LibraryAddSearchCapability(
      initialAdvancedFilters: {
        libraryAddVideoKindFilterId: {'anime'},
      },
      advancedFilterDescriptorsBuilder: buildAnimeAddAdvancedFilterFields,
      searchInputPredicate: libraryAddVideoHasSearchInput,
      kindSpecificPaneBuilder: buildLibraryAddVideoKindFilterRow,
      providerKindOverridesBuilder: (context) =>
          libraryAddVideoKindOverridesForChrome(_animeAddChrome, context),
      coreSearchInputBuilder: _buildAnimeCoreSearchInput,
      providerQueryBuilder: _buildAnimeProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _animeSeriesFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is AnimeMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _animeStudioFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is AnimeMetadata
                  ? [...metadata.studios, ...metadata.producers]
                  : const <Object?>[];
            },
            providerValues: (candidate) =>
                [candidate.publisher, candidate.summary],
          ),
          LibraryAddSearchRankField(
            id: _animeYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is AnimeMetadata
                  ? [metadata.seasonYear, metadata.startDate?.year]
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
      coreScopeForItem: _animeAddResultScope,
      providerScopeForCandidate: _animeAddProviderResultScope,
      coreGroupTitleBuilder: _animeAddGroupTitle,
      providerCandidateIsGroup: libraryAddVideoProviderCandidateIsGroup,
    ),
    manualPaneBuilder: buildAnimeAddManualPane,
    chrome: _animeAddChrome,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildAnimeLibraryEditDialog,
    presentation: animeLibraryEditPresentation,
    conditions: AnimeVocabularies.condition.builtIns,
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
    createDraft: createAnimeEditDraft,
    ownedDigitalFlagResolver: resolveAnimeOwnedDigitalFlag,
    ownedUpdatePayloadBuilder: AnimeOwnedItemUpdatePayload.fromCommand,
  ),
  providerMapper: const AnimeLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildAnimeCardPresentation,
);

String _animeChildrenTitle(int count) => 'Episodes ($count)';

Future<List<LibraryHierarchyNode>> _fetchAnimeEpisodes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final dto =
      await api.getAnimeSeriesDto(itemId).timeout(const Duration(seconds: 60));
  return AnimeHierarchyMapper.toLibraryNodes(
    AnimeCoreMapper.fromSeriesDto(dto),
  );
}

List<LibraryAddAdvancedFilterField<String>> buildAnimeAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _animeSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(_animeSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _animeStudioFilterId,
        key: const ValueKey('library-add-studio-field'),
        label: 'Studio',
        value: req.advancedFilterText(_animeStudioFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _animeYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_animeYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

LibraryMetadataSearchInput _buildAnimeCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalAnimeText(context.query),
    series: _optionalAnimeText(context.textValueFor(_animeSeriesFilterId)),
    publisher: _optionalAnimeText(context.textValueFor(_animeStudioFilterId)),
    year: int.tryParse(context.textValueFor(_animeYearFilterId)),
    barcode: _optionalAnimeText(context.barcode),
    limit: limit,
  );
}

String _buildAnimeProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_animeSeriesFilterId),
    context.textValueFor(_animeStudioFilterId),
    context.textValueFor(_animeYearFilterId),
    context.barcode,
  ]);
}

String? _optionalAnimeText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

LibraryAddVideoResultScope _animeAddResultScope(CatalogItem item) {
  final metadata = item.kindMetadata;
  if (metadata is AnimeMetadata) {
    if (metadata.series?.seasonNumber != null) {
      return LibraryAddVideoResultScope.season;
    }
    if ([
      metadata.itemNumber,
      metadata.editionTitle,
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

LibraryAddVideoResultScope _animeAddProviderResultScope(
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

String _animeAddGroupTitle(CatalogItem item) {
  final metadata = item.kindMetadata;
  if (metadata is AnimeMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
