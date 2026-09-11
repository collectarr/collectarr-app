import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
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
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/add/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/stats/anime_stats_capability.dart';

const _animeSeriesFilterId = LibraryAddFilterId('anime.series');
const _animeStudioFilterId = LibraryAddFilterId('anime.studio');
const _animeYearFilterId = LibraryAddFilterId('anime.year');

const _animeAddChrome = LibraryAddChromeConfig(
  videoKindFilterOptions: [
    LibraryAddVideoKindFilterOption(
      scope: LibraryAddVideoSearchScope.anime,
      label: 'Anime',
      icon: Icons.auto_awesome_outlined,
    ),
  ],
  defaultVideoKindFilters: {LibraryAddVideoSearchScope.anime},
);

TransferableField _animeTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(AnimeOwnedItem item) read,
  required AnimeOwnedItem Function(AnimeOwnedItem item, String? value) write,
  LibraryEditScope scope = LibraryEditScope.all,
}) {
  return TransferableField.typed<AnimeOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as AnimeOwnedItem,
    read: read,
    write: write,
  );
}

final _animeUniversalTransferableFields =
    TransferableField.universalForTyped<AnimeOwnedItem>(
  decode: (value) => value as AnimeOwnedItem,
  readCondition: (item) => item.condition,
  writeCondition: (item, value) => item.copyWith(condition: value),
  readPersonalNotes: (item) => item.personalNotes,
  writePersonalNotes: (item, value) => item.copyWith(personalNotes: value),
  readLocationId: (item) => item.locationId,
  writeLocationId: (item, value) => item.copyWith(locationId: value),
  readTags: (item) => item.tags,
  writeTags: (item, value) => item.copyWith(tags: value),
  readCurrency: (item) => item.currency,
  writeCurrency: (item, value) => item.copyWith(currency: value),
  readSoldTo: (item) => item.soldTo,
  writeSoldTo: (item, value) => item.copyWith(soldTo: value),
  readPurchaseStore: (item) => item.purchaseStore,
  writePurchaseStore: (item, value) => item.copyWith(purchaseStore: value),
  readPricePaidCents: (item) => item.pricePaidCents?.toString(),
  writePricePaidCents: (item, value) => item.copyWith(
    pricePaidCents: value == null ? null : int.tryParse(value),
  ),
  readSellPriceCents: (item) => item.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
    sellPriceCents: value == null ? null : int.tryParse(value),
  ),
  readQuantity: (item) => item.quantity.toString(),
  writeQuantity: (item, value) => item.copyWith(
    quantity: value == null ? 1 : int.tryParse(value) ?? 1,
  ),
  readIndexNumber: (item) => item.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
    indexNumber: value == null ? null : int.tryParse(value),
  ),
  readPurchaseDate: (item) => item.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
    purchaseDate: value == null ? null : DateTime.tryParse(value),
  ),
  readSoldAt: (item) => item.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
    soldAt: value == null ? null : DateTime.tryParse(value),
  ),
);

final _animeTransferableFields = <TransferableField>[
  _animeTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  _animeTransferField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.details.features,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(features: value));
    },
  ),
  _animeTransferField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.details.boxSetName,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(boxSetName: value));
    },
  ),
  _animeTransferField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.details.packaging,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(packaging: value));
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

AnimeMetadata? _animeLinkedMetadata(LibraryWorkspaceSource source) {
  final metadata = source.catalogTransport?.toTransportItem().kindMetadata;
  return metadata is AnimeMetadata ? metadata : null;
}

MetadataSearchQuery _animeMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final item = source.catalogTransport;
  return MetadataSearchQuery(
    query: title,
    barcode: item?.identifierCode,
    publisher: item?.publisher,
    year: item?.releaseYear,
    limit: 5,
  );
}

const animeLibraryFacetModule = LibraryFacetModule(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
);

AnimeOwnedItem _animeTransferOwnedItem(Object value) {
  if (value is AnimeOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected AnimeOwnedItem');
}

final animeKindModule = LibraryKindSpec<AnimeWorkspaceDto>(
  presentation: animeLibraryMediaPresentation,
  physicalMediaFormats: animePhysicalMediaFormats,
  trackingProfile: animeTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.anime,
    singularLabel: 'Anime',
    pluralLabel: 'Anime',
    title: 'Anime',
    icon: Icons.movie_filter_outlined,
    accent: Color(0xFFC94DFF),
    preferencePrefix: 'anime',
    routeSegments: ['anime'],
    mediaFamily: 'video',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'anilist',
    searchQueryBuilder: _animeMetadataSearchQuery,
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
    _animeLinkedMetadata,
    _animeLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _animeTransferableFields) field.key,
    ],
    kindFields: [
      ..._animeUniversalTransferableFields,
      ..._animeTransferableFields,
    ],
  ),
  stats: const AnimeStatsCapability(),
  uiPolicy: const LibraryUiPolicy(
    wideDialog: true,
  ),
  add: StandardLibraryAddCapability<AnimeAddDraft>(
    kind: CatalogMediaKind.anime,
    initialDraftBuilder: AnimeAddDraft.new,
    manualDraftBuilder: AnimeAddManualDraft.new,
    ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
        AnimeOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as AnimeOwnedDetailsDraft,
      condition: common.condition,
      grade: kindValue ?? draft.grade,
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
    digitalCopyFlagBuilder: (item) {
      final payload = item.toTransportItem().payload;
      final direct = payload['is_digital'];
      if (direct is bool) return direct;
      final format =
          (payload['physical_format'] ?? payload['physical_format_label'])
              ?.toString()
              .toLowerCase();
      if (format == 'digital' || format == 'ebook' || format == 'web') {
        return true;
      }
      final series = payload['series'];
      if (series is Map && series['is_digital'] is bool) {
        return series['is_digital'] as bool;
      }
      final publishing = payload['publishing'];
      if (publishing is Map && publishing['is_digital'] is bool) {
        return publishing['is_digital'] as bool;
      }
      return null;
    },
    search: LibraryAddSearchCapability(
      initialAdvancedFilters: {
        libraryAddVideoKindFilterId: {LibraryAddVideoSearchScope.anime},
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
              final metadata = item.toTransportItem().kindMetadata;
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
              final metadata = item.toTransportItem().kindMetadata;
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
              final metadata = item.toTransportItem().kindMetadata;
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
    ownedCollectionValueReader: (ownedItem) => ownedItem?.collectionValue,
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
    createDraft: createAnimeEditDraft,
    ownedDigitalFlagResolver: resolveAnimeOwnedDigitalFlag,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        AnimeOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue) =>
            AnimeOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue, locationId, tags) =>
            AnimeOwnedItemUpdatePayload.partial(
      condition:
          condition == null ? const Patch.unchanged() : Patch.set(condition),
      grade: collectionValue == null
          ? const Patch.unchanged()
          : Patch.set(collectionValue),
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
        AnimeOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) {
      final typed = _animeTransferOwnedItem(updated);
      return AnimeOwnedItemUpdatePayload.partial(
        condition: Patch.set(typed.condition),
        grade: Patch.set(typed.grade),
        personalNotes: Patch.set(typed.personalNotes),
        locationId: Patch.set(typed.locationId),
        tags: Patch.set(typed.tags),
        currency: Patch.set(typed.currency),
        soldTo: Patch.set(typed.soldTo),
        purchaseStore: Patch.set(typed.purchaseStore),
        pricePaidCents: Patch.set(typed.pricePaidCents),
        sellPriceCents: Patch.set(typed.sellPriceCents),
        quantity: Patch.set(typed.quantity),
        indexNumber: Patch.set(typed.indexNumber),
        purchaseDate: Patch.set(typed.purchaseDate),
        soldAt: Patch.set(typed.soldAt),
        details: Patch.set(
          const AnimeOwnedDetailsCodec().draftFromDetails(
            typed.details,
          ),
        ),
      );
    },
    ownedDetailsResetPayloadBuilder: () =>
        AnimeOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  ),
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

MetadataSearchQuery _buildAnimeCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalAnimeText(context.query),
    series: _optionalAnimeText(context.textValueFor(_animeSeriesFilterId)),
    publisher: _optionalAnimeText(context.textValueFor(_animeStudioFilterId)),
    year: int.tryParse(context.textValueFor(_animeYearFilterId)),
    barcode: _optionalAnimeText(context.identifierCode),
    limit: limit,
  );
}

String _buildAnimeProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_animeSeriesFilterId),
    context.textValueFor(_animeStudioFilterId),
    context.textValueFor(_animeYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalAnimeText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

LibraryAddVideoResultScope _animeAddResultScope(
    LibraryAddCatalogTransport item) {
  final metadata = item.toTransportItem().kindMetadata;
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

String _animeAddGroupTitle(LibraryAddCatalogTransport item) {
  final metadata = item.toTransportItem().kindMetadata;
  if (metadata is AnimeMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}

final animeKindWorkspace = TypedLibraryKindWorkspace<AnimeWorkspaceDto>(
  fields: animeLibraryKindSchema.toRegistry(),
  projector: const AnimeWorkspaceProjector(),
  hierarchy: animeKindModule.hierarchy,
);
