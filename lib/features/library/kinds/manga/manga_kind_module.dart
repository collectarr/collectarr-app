import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_profile.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/stats/manga_stats_capability.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';

const _mangaSeriesFilterId = LibraryAddFilterId('manga.series');
const _mangaVolumeFilterId = LibraryAddFilterId('manga.volume');
const _mangaPublisherFilterId = LibraryAddFilterId('manga.publisher');
const _mangaYearFilterId = LibraryAddFilterId('manga.year');

String? _mangaHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final dto = item.dto;
  if (dto is! MangaWorkspaceDto) {
    return null;
  }
  if (dto.seriesTitle?.trim().isNotEmpty != true) {
    return 'Missing series title';
  }
  if (item.node.scope != LibraryBrowserScope.title &&
      dto.variant?.trim().isNotEmpty != true) {
    return 'Missing release variant';
  }
  return null;
}

final _mangaTransferableFields = <TransferableField>[
  TransferableField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.collectionValue,
    write: (item, value) => item.copyWith(collectionValue: value),
  ),
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => (item.details as MangaOwnedDetails?)?.signedBy,
    write: (item, value) {
      final details =
          item.details as MangaOwnedDetails? ?? const MangaOwnedDetails();
      return item.copyWith(details: details.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => (item.details as MangaOwnedDetails?)?.gradingCompany,
    write: (item, value) {
      final details =
          item.details as MangaOwnedDetails? ?? const MangaOwnedDetails();
      return item.copyWith(details: details.copyWith(gradingCompany: value));
    },
  ),
  TransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => (item.details as MangaOwnedDetails?)?.graderNotes,
    write: (item, value) {
      final details =
          item.details as MangaOwnedDetails? ?? const MangaOwnedDetails();
      return item.copyWith(details: details.copyWith(graderNotes: value));
    },
  ),
  TransferableField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) =>
        ((item.details as MangaOwnedDetails?)?.dustJacketPresent == true)
            ? 'true'
            : null,
    write: (item, value) {
      final details =
          item.details as MangaOwnedDetails? ?? const MangaOwnedDetails();
      return item.copyWith(
        details: details.copyWith(dustJacketPresent: value == 'true'),
      );
    },
  ),
  TransferableField(
    key: 'obiStripPresent',
    label: 'Obi strip',
    icon: Icons.bookmark_border,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) =>
        ((item.details as MangaOwnedDetails?)?.obiStripPresent == true)
            ? 'true'
            : null,
    write: (item, value) {
      final details =
          item.details as MangaOwnedDetails? ?? const MangaOwnedDetails();
      return item.copyWith(
        details: details.copyWith(obiStripPresent: value == 'true'),
      );
    },
  ),
];

Iterable<String?> _mangaLinkedMetadataValues(MangaMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.originalPublisher,
      metadata.localizedPublisher,
      metadata.variant,
      metadata.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final mangaLibraryFacetModule = TypedLibraryFacetModule<MangaWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: _getFacetValues,
  externalFacetBucketIdsByMode: {
    'manga.genre': MangaFacetIds.genre,
    'manga.demographic': MangaFacetIds.demographic,
  },
);

final mangaKindModule = LibraryKindSpec<MangaWorkspaceDto>(
  presentation: mangaLibraryMediaPresentation,
  physicalMediaFormats: mangaPhysicalMediaFormats,
  trackingProfile: mangaTrackingProfile,
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.manga,
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    title: 'Manga',
    icon: Icons.import_contacts_outlined,
    accent: Color(0xFFFF6F91),
    preferencePrefix: 'manga',
    routeSegments: ['manga'],
    mediaFamily: 'print',
    toolbarActions: [
      ...kDefaultLibraryToolbarActions,
      LibraryToolbarActionId.reassignIndex,
    ],
  ),
  metadata: LibraryMetadataCapability(
    defaultProviderId: 'hardcover',
    usesTreeProviderCandidates: true,
    providers: [
      hardcoverMetadataProvider,
      comicVineMetadataProvider,
      anilistMetadataProvider,
      mangadexMetadataProvider,
    ],
  ),
  hierarchy: const LibraryHierarchyCapability(
    fetchChildrenCallback: _fetchMangaVolumes,
    childrenTitleBuilder: _mangaChildrenTitle,
    supportsMediaReleaseSplit: true,
    contractDiagnosticLabelBuilder: _mangaHierarchyContractDiagnosticLabel,
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<MangaMetadata>(
    _mangaLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _mangaTransferableFields) field.key,
    ],
    kindFields: _mangaTransferableFields,
  ),
  stats: const MangaStatsCapability(),
  add: StandardLibraryAddCapability<MangaAddDraft>(
    kind: CatalogMediaKind.manga,
    initialDraftBuilder: MangaAddDraft.new,
    manualDraftBuilder: MangaAddManualDraft.new,
    ownedPayloadBuilder: (item, common, draft, details) =>
        MangaOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as MangaOwnedDetailsDraft,
      condition: common.condition,
      grade: draft.grade,
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
      advancedFilterDescriptorsBuilder: buildMangaAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildMangaCoreSearchInput,
      providerQueryBuilder: _buildMangaProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _mangaSeriesFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MangaMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _mangaVolumeFilterId,
            exactWeight: 75,
            containsWeight: 36,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MangaMetadata
                  ? [metadata.itemNumber, metadata.volumeNumber]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.issueNumber],
          ),
          LibraryAddSearchRankField(
            id: _mangaPublisherFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MangaMetadata
                  ? [
                      metadata.publisher,
                      metadata.originalPublisher,
                      metadata.localizedPublisher,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _mangaYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is MangaMetadata
                  ? [
                      metadata.originalPublicationDate?.year,
                      metadata.localizedReleaseDate?.year,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildMangaAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMangaLibraryEditDialog,
    mediaEditDialogBuilder: buildMangaMediaLibraryEditDialog,
    presentation: mangaLibraryEditPresentation,
    conditions: MangaVocabularies.condition.builtIns,
    ownedCollectionValueReader: (ownedItem) => ownedItem?.collectionValue,
    vocabularies: StandardKindVocabularyCapability(MangaVocabularies.all),
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    editChrome: const LibraryEditChromeConfig(
      titleUsesItemTitle: true,
      synopsisLabel: 'Plot',
      showsIssueBadge: true,
      showsPhysicalFormatBadge: true,
    ),
    createDraft: createMangaEditDraft,
    ownedDigitalFlagResolver: resolveMangaOwnedDigitalFlag,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        MangaOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue) =>
            MangaOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue, locationId, tags) =>
            MangaOwnedItemUpdatePayload.partial(
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
        MangaOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) =>
        MangaOwnedItemUpdatePayload.partial(
      condition: Patch.set(updated.condition),
      grade: Patch.set(updated.collectionValue),
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
        const MangaOwnedDetailsCodec().draftFromDetails(
          updated.details as MangaOwnedDetails,
        ),
      ),
    ),
    ownedDetailsResetPayloadBuilder: () =>
        MangaOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  ),
);

Iterable<String> _getFacetValues(
    MangaWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
  for (final definition in mangaLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

String _mangaChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchMangaVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final work =
      await api.getMangaWorkDto(itemId).timeout(const Duration(seconds: 60));
  final manga = MangaCoreMapper.fromWorkDto(work);
  final hierarchy = MangaHierarchyMapper.fromChapterRows(
    seriesId: itemId,
    rows: manga.chapters.whereType<Map<Object?, Object?>>().map(
          (chapter) => Map<String, dynamic>.from(chapter),
        ),
  );
  return MangaHierarchyMapper.toLibraryNodes(hierarchy);
}

List<LibraryAddAdvancedFilterField<String>> buildMangaAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _mangaSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(_mangaSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _mangaVolumeFilterId,
        key: const ValueKey('library-add-number-field'),
        label: 'Volume',
        value: req.advancedFilterText(_mangaVolumeFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _mangaPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(_mangaPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _mangaYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_mangaYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildMangaCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalMangaText(context.query),
    series: _optionalMangaText(context.textValueFor(_mangaSeriesFilterId)),
    issueNumber: _optionalMangaText(context.textValueFor(_mangaVolumeFilterId)),
    publisher:
        _optionalMangaText(context.textValueFor(_mangaPublisherFilterId)),
    year: int.tryParse(context.textValueFor(_mangaYearFilterId)),
    barcode: _optionalMangaText(context.identifierCode),
    limit: limit,
  );
}

String _buildMangaProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_mangaSeriesFilterId),
    context.textValueFor(_mangaVolumeFilterId),
    context.textValueFor(_mangaPublisherFilterId),
    context.textValueFor(_mangaYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalMangaText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

final mangaKindWorkspace = TypedLibraryKindWorkspace<MangaWorkspaceDto>(
  fields: mangaLibraryKindSchema.toRegistry(),
  projector: const MangaWorkspaceProjector(),
  hierarchy: mangaKindModule.hierarchy,
);
