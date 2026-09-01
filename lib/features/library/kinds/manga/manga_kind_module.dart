import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/stats/manga_stats_capability.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

const _mangaSeriesFilterId = LibraryAddFilterId('manga.series');
const _mangaVolumeFilterId = LibraryAddFilterId('manga.volume');
const _mangaPublisherFilterId = LibraryAddFilterId('manga.publisher');
const _mangaYearFilterId = LibraryAddFilterId('manga.year');

final _mangaTransferableFields = <TransferableField>[
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.mangaDetails?.signedBy,
    write: (item, value) {
      final details = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(details: details.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.mangaDetails?.gradingCompany,
    write: (item, value) {
      final details = item.mangaDetails ?? const MangaOwnedDetails();
      return item.copyWith(details: details.copyWith(gradingCompany: value));
    },
  ),
  TransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.mangaDetails?.graderNotes,
    write: (item, value) {
      final details = item.mangaDetails ?? const MangaOwnedDetails();
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
        (item.mangaDetails?.dustJacketPresent == true) ? 'true' : null,
    write: (item, value) {
      final details = item.mangaDetails ?? const MangaOwnedDetails();
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
        (item.mangaDetails?.obiStripPresent == true) ? 'true' : null,
    write: (item, value) {
      final details = item.mangaDetails ?? const MangaOwnedDetails();
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

final mangaKindModule = LibraryKindSpec<MangaWorkspaceDto, MangaOwnedDetails>(
  presentation: mangaLibraryMediaPresentation,
  trackingProfile: comicTrackingProfile,
  projector: const MangaWorkspaceProjector(),
  ownedDetailsCodec: const MangaOwnedDetailsCodec(),
  fields: mangaLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<MangaMetadata>(
    MangaMetadata.fromJson,
    _encodeMangaMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.manga,
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    title: 'Manga',
    icon: Icons.import_contacts_outlined,
    accent: Color(0xFFFF6F91),
    preferencePrefix: 'manga',
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
    supportsIndexReassignment: true,
    collectionExportTitleLabel: 'Series',
    mediaReleaseScopeLabel: 'Series',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<MangaMetadata>(
    _mangaLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    kindFields: _mangaTransferableFields,
  ),
  stats: const MangaStatsCapability(),
  add: StandardLibraryAddCapability<MangaAddDraft>(
    kind: CatalogMediaKind.manga,
    initialDraftBuilder: MangaAddDraft.new,
    manualDraftBuilder: MangaAddManualDraft.new,
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
                      item.releaseYear,
                      metadata.originalPublicationDate?.year,
                      metadata.localizedReleaseDate?.year,
                    ]
                  : [item.releaseYear];
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
    vocabularies: StandardKindVocabularyCapability(MangaVocabularies.all),
    editChrome: const LibraryEditChromeConfig(
      titleUsesItemTitle: true,
      synopsisLabel: 'Plot',
      showsIssueBadge: true,
      showsPhysicalFormatBadge: true,
    ),
    mediaFields: const MediaEditFields.print(
      numberLabel: 'Chapter / Vol.',
      publisherLabel: 'Publisher / Studio / Creator',
      releaseDateLabel: 'First published',
    ),
    manualAddUsesTitleAsSeries: true,
    editUsesTitleAsSeries: true,
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Edition / Variant / Format',
      barcodeLabel: 'Barcode / UPC / ISBN',
      variantSeedsPhysicalFormatLabel: true,
    ),
    createDraft: createMangaEditDraft,
  ),
  providerMapper: const MangaLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getFacetValues,
    externalFacetBucketIdsByMode: {
      'manga.genre': MangaFacetIds.genre,
      'manga.demographic': MangaFacetIds.demographic,
    },
  ),
  buildCardPresentation: buildMangaCardPresentation,
);

Iterable<String> _getFacetValues(
    LibraryProjectionRuntime item, LibraryFacetIdRuntime facetId) {
  final kindMetadata = item.source.catalogItem?.kindMetadata;
  final metadata = kindMetadata is MangaMetadata ? kindMetadata : null;
  if (facetId == MangaFacetIds.character) {
    return const [];
  }
  if (facetId == MangaFacetIds.genre) {
    return metadata?.genres ?? const [];
  }
  if (facetId == MangaFacetIds.publisher) {
    final pub = metadata?.publisher;
    return pub != null ? [pub] : const [];
  }
  return const [];
}

Map<String, dynamic> _encodeMangaMetadata(MangaMetadata m) => m.toJson();

String _mangaChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchMangaVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final volumes = await api
      .getItemVolumes(itemId, kind: CatalogMediaKind.manga.apiValue)
      .timeout(const Duration(seconds: 60));
  return [
    for (final volume in volumes)
      LibraryHierarchyNode(
        id: 'volume_${volume.seasonNumber}',
        label: volume.title,
        secondaryLabel:
            volume.episodeCount != null ? '${volume.episodeCount} items' : null,
        level: LibraryHierarchyLevel.container,
        imageUrl: volume.posterUrl,
        totalCount: volume.episodeCount,
        metadata: {
          'number': volume.seasonNumber,
          'airDate': volume.airDate,
        },
      ),
  ];
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

LibraryMetadataSearchInput _buildMangaCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalMangaText(context.query),
    series: _optionalMangaText(context.textValueFor(_mangaSeriesFilterId)),
    issueNumber: _optionalMangaText(context.textValueFor(_mangaVolumeFilterId)),
    publisher:
        _optionalMangaText(context.textValueFor(_mangaPublisherFilterId)),
    year: int.tryParse(context.textValueFor(_mangaYearFilterId)),
    barcode: _optionalMangaText(context.barcode),
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
    context.barcode,
  ]);
}

String? _optionalMangaText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
