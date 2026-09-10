import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/metadata/music_metadata_compare.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/detail/music_personal_detail_fields.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
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

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';

const _musicArtistFilterId = LibraryAddFilterId('music.artist');
const _musicLabelFilterId = LibraryAddFilterId('music.label');
const _musicYearFilterId = LibraryAddFilterId('music.year');

const _musicAddChrome = LibraryAddChromeConfig(
  mediaReferenceLabel: 'Album',
  trackScopeSummary:
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
  mediaReferenceHelperLabel: 'Track or save the album itself.',
  editionReferenceHelperLabel:
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
);

Iterable<String?> _musicLinkedMetadataValues(MusicCatalogMetadata metadata) => [
      metadata.artist,
      metadata.series?.seriesTitle,
      metadata.publisher,
      metadata.recordLabel,
      metadata.publishing?.originalPublisher,
      metadata.variant,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

const musicLibraryFacetModule = LibraryFacetModule(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
);

final musicKindModule = LibraryKindSpec<MusicWorkspaceDto>(
  presentation: musicLibraryMediaPresentation,
  physicalMediaFormats: musicPhysicalMediaFormats,
  searchTargetOptions: const [
    LibrarySearchTarget.all,
    LibrarySearchTarget.mediaOnly,
    LibrarySearchTarget.tracksOnly,
  ],
  trackingProfile: musicTrackingProfile,
  identity: const LibraryKindIdentity(
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
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'musicbrainz',
    supportsServerCompare: true,
    compareBuilder: buildMusicMetadataComparePanels,
    providers: [musicBrainzMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    childrenTitleBuilder: _musicChildrenTitle,
    fetchChildrenCallback: _fetchMusicTracks,
    supportsMediaReleaseSplit: true,
  ),
  uiPolicy: const LibraryUiPolicy(
    coverAspectRatio: 1.0,
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
    personalDetailFieldsBuilder: buildMusicPersonalDetailFields,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<MusicCatalogMetadata>(
    _musicLinkedMetadataValues,
  ),
  transfer: const LibraryTransferCapability(),
  stats: const MusicStatsCapability(),
  add: StandardLibraryAddCapability<MusicAddDraft>(
    kind: CatalogMediaKind.music,
    initialDraftBuilder: MusicAddDraft.new,
    manualDraftBuilder: MusicAddManualDraft.new,
    ownedPayloadBuilder: (item, common, details) => MusicOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as MusicOwnedDetailsDraft,
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
              final metadata = item.kindMetadata;
              return metadata is MusicCatalogMetadata
                  ? [metadata.artist]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _musicLabelFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MusicCatalogMetadata
                  ? [metadata.publisher, metadata.publishing?.imprint]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _musicYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MusicCatalogMetadata
                  ? [
                      metadata.originalReleaseDate?.year,
                      metadata.recordingDate?.year,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildMusicAddManualPane,
    chrome: _musicAddChrome,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMusicLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(MusicVocabularies.all),
    presentation: musicLibraryEditPresentation,
    conditions: MusicVocabularies.condition.builtIns,
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    createDraft: createMusicEditDraft,
    ownedDigitalFlagResolver: resolveMusicOwnedDigitalFlag,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        MusicOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionGradeUpdatePayloadBuilder: (ownedItemId, condition, grade) =>
        MusicOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(grade),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, grade, locationId, tags) =>
            MusicOwnedItemUpdatePayload.partial(
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
        MusicOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) =>
        MusicOwnedItemUpdatePayload.partial(
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
        const MusicOwnedDetailsCodec().draftFromDetails(
          updated.details as MusicOwnedDetails,
        ),
      ),
    ),
    ownedDetailsResetPayloadBuilder: () =>
        MusicOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  ),
);

String _musicChildrenTitle(int count) => 'Discs ($count)';

Future<List<LibraryHierarchyNode>> _fetchMusicTracks({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final dto =
      await api.getMusicReleaseDto(itemId).timeout(const Duration(seconds: 60));
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
  hierarchy: musicKindModule.hierarchy,
);
