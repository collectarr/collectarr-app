import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_catalog_target_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/metadata/music_metadata_compare.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/kinds/music/detail/music_personal_detail_fields.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_candidate_projection.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';

const _musicArtistFilterId = LibraryAddFilterId('music.artist');
const _musicLabelFilterId = LibraryAddFilterId('music.label');
const _musicYearFilterId = LibraryAddFilterId('music.year');

TransferableField _musicTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(MusicOwnedItem item) read,
  required MusicOwnedItem Function(MusicOwnedItem item, String? value) write,
  LibraryEditScope scope = LibraryEditScope.all,
}) {
  return TransferableField.typed<MusicOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MusicOwnedItem,
    read: read,
    write: write,
  );
}

final _musicUniversalTransferableFields =
    TransferableField.universalForTyped<MusicOwnedItem>(
  decode: (value) => value as MusicOwnedItem,
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

final _musicTransferableFields = <TransferableField>[
  _musicTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
];

const _musicAddChrome = LibraryAddChromeConfig(
  mediaReferenceLabel: 'Album',
  trackScopeSummary:
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
  mediaReferenceHelperLabel: 'Track or save the album itself.',
  editionReferenceHelperLabel:
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
);

Iterable<String?> _musicLinkedMetadataValues(MusicReleaseGroup group) => [
      group.artist,
      group.primaryRelease?.publisher,
      group.primaryRelease?.countryCode,
      group.primaryRelease?.language,
      ...?group.primaryRelease?.contributions
          .map((credit) => credit.displayName),
      ...group.genres,
    ];

MusicReleaseGroup? _musicLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

MetadataSearchQuery _musicMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = _musicLinkedMetadata(source);
  final release = metadata?.primaryRelease;
  return MetadataSearchQuery(
    query: title,
    barcode: release?.barcode ?? release?.upc,
    publisher: release?.publisher,
    year: metadata?.originalReleaseDate?.year,
    limit: 5,
  );
}

const musicLibraryFacetModule = LibraryFacetModule(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
);

MusicOwnedItem _musicTransferOwnedItem(Object value) {
  if (value is MusicOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MusicOwnedItem');
}

final musicKindPresentation = musicLibraryMediaPresentation;

final musicKindPhysicalMediaFormats = musicPhysicalMediaFormats;

final musicKindSearchTargetOptions = const <LibrarySearchTarget>[
    LibrarySearchTarget.all,
    LibrarySearchTarget.mediaOnly,
    LibrarySearchTarget.tracksOnly,
  ];

final musicKindTrackingProfile = musicTrackingProfile;

final musicKindTitleCapability = const DefaultTitleProjectionCapability();

final musicKindReleaseCapability = null;

final musicKindReleaseDetailSource = null;

final musicKindCatalogTarget = const MusicCatalogTargetCapability();

final LibraryRelationCapability? musicKindRelations = null;

final LibraryValueCapability? musicKindValue = null;

final musicKindToolbar = null;

final musicKindViewProfile = standardMediaWorkspaceViewProfile(
    CatalogMediaKind.music,
    const LibraryUiPolicy(),
  );

final musicKindIdentity = const LibraryKindIdentity(
    kind: CatalogMediaKind.music,
    singularLabel: 'Music',
    pluralLabel: 'Music',
    title: 'Music',
    icon: Icons.music_note,
    accent: Color(0xFFFDAD49),
    preferencePrefix: 'music',
    routeSegments: ['music'],
    mediaFamily: 'audio',
    normalizeCatalogLabels: true,
  );

final musicKindMetadata = const LibraryMetadataCapability(
    defaultProviderId: 'musicbrainz',
    catalogMetadataDecoder: MusicReleaseGroup.fromJson,
    searchQueryBuilder: _musicMetadataSearchQuery,
    supportsServerCompare: true,
    compareBuilder: buildMusicMetadataComparePanels,
    providers: [musicBrainzMetadataProvider],
  );

final musicKindHierarchy = const LibraryHierarchyCapability(
    childrenTitleBuilder: _musicChildrenTitle,
    fetchChildrenCallback: _fetchMusicTracks,
    supportsMediaReleaseSplit: true,
  );

final musicKindUiPolicy = const LibraryUiPolicy(
    coverAspectRatio: 1.0,
  );

final musicKindInspector = const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
    personalDetailFieldsBuilder: buildMusicPersonalDetailFields,
  );

final musicKindLinkedMetadata = TypedLibraryLinkedMetadataCapability<MusicReleaseGroup>(
    _musicLinkedMetadata,
    _musicLinkedMetadataValues,
  );

final musicKindTransfer = LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _musicTransferableFields) field.key,
    ],
    kindFields: [
      ..._musicUniversalTransferableFields,
      ..._musicTransferableFields,
    ],
  );

final musicKindStats = const MusicStatsCapability();

final musicKindAdd = StandardLibraryAddCapability<MusicAddDraft>(
    kind: CatalogMediaKind.music,
    initialDraftBuilder: MusicAddDraft.new,
    providerCandidateProjectionBuilder:
        musicCatalogTransportFromProviderCandidate,
    coreCatalogProjectionBuilder: musicCatalogTransportFromCoreItem,
    manualDraftBuilder: MusicAddManualDraft.new,
    ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
        MusicOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as MusicOwnedDetailsDraft,
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
      final group =
          item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
      final format =
          group.primaryRelease?.mediums.firstOrNull?.mediumType?.toLowerCase();
      return format == null
          ? null
          : const {'digital', 'download', 'streaming', 'file'}
              .any(format.contains);
    },
    search: LibraryAddSearchCapability(
      advancedFilterDescriptorsBuilder: buildMusicAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildMusicCoreSearchInput,
      providerQueryBuilder: _buildMusicProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _musicArtistFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final group =
                  item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
              return [group.artist];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _musicLabelFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final group =
                  item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
              return [group.primaryRelease?.publisher];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _musicYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final group =
                  item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
              return [
                group.originalReleaseDate?.year,
                group.recordingDate?.year,
              ];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildMusicAddManualPane,
    chrome: _musicAddChrome,
  );

final musicKindEditCapabilities = LibraryEditCapabilitySet(
    editDialogBuilder: buildMusicLibraryEditDialog,
    mediaEditDialogBuilder: buildMusicReleaseGroupLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(MusicVocabularies.all),
    presentation: musicLibraryEditPresentation,
    conditions: MusicVocabularies.condition.builtIns,
    ownedCollectionValueReader: (ownedItem) =>
        ownedItem?.map<String>(music: (item) => item.grade),
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    createDraft: createMusicEditDraft,
    ownedDigitalFlagResolver: resolveMusicOwnedDigitalFlag,
    ownedFormatHintResolver: resolveMusicOwnedFormatHint,
    ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
        MusicOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
        MusicOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (_, condition, collectionValue, locationId, tags) =>
            MusicOwnedItemUpdatePayload.partial(
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
      _,
      purchaseDate,
      pricePaidCents,
      currency,
      personalNotes,
      purchaseStore,
      locationChanged,
      locationId,
    ) =>
        MusicOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (_, updated) {
      final typed = _musicTransferOwnedItem(updated);
      return MusicOwnedItemUpdatePayload.partial(
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
          const MusicOwnedDetailsCodec().draftFromDetails(
            typed.details,
          ),
        ),
      );
    },
    ownedDetailsResetPayloadBuilder: () =>
        MusicOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  );

String _musicChildrenTitle(int count) => 'Discs ($count)';

Future<List<LibraryHierarchyNode>> _fetchMusicTracks({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final groupDto = await api
      .getMusicReleaseGroupDto(itemId)
      .timeout(const Duration(seconds: 60));
  final group = MusicCoreMapper.fromReleaseGroupDto(groupDto);
  final summary = group.primaryRelease;
  if (summary == null) return const <LibraryHierarchyNode>[];
  final dto = await api
      .getMusicReleaseDto(summary.id.value)
      .timeout(const Duration(seconds: 60));
  final release = MusicCoreMapper.fromReleaseDto(dto);
  return MusicHierarchyMapper.toLibraryNodes(release);
}

List<LibraryAddAdvancedFilterField<String>> buildMusicAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _musicArtistFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Artist',
        value: req.advancedFilterText(_musicArtistFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _musicLabelFilterId,
        key: const ValueKey('library-add-label-field'),
        label: 'Record Label',
        value: req.advancedFilterText(_musicLabelFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _musicYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_musicYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildMusicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalMusicText(context.query),
    series: _optionalMusicText(context.textValueFor(_musicArtistFilterId)),
    publisher: _optionalMusicText(context.textValueFor(_musicLabelFilterId)),
    year: int.tryParse(context.textValueFor(_musicYearFilterId)),
    barcode: _optionalMusicText(context.identifierCode),
    limit: limit,
  );
}

String _buildMusicProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_musicArtistFilterId),
    context.textValueFor(_musicLabelFilterId),
    context.textValueFor(_musicYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalMusicText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

final musicKindWorkspace = TypedLibraryKindWorkspace<MusicWorkspaceDto>(
  fields: musicLibraryKindSchema.toRegistry(),
  projector: const MusicWorkspaceProjector(),
  hierarchy: musicKindHierarchy,
);
