import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_shell.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/release/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/detail/library_video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/add/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/value/movie_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_provider_candidate_projection.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';

const _movieCollectionFilterId = LibraryAddFilterId('movie.collection');
const _movieYearFilterId = LibraryAddFilterId('movie.year');

const _movieAddChrome = LibraryAddChromeConfig(
  videoKindFilterOptions: [
    LibraryAddVideoKindFilterOption(
      scope: LibraryAddVideoSearchScope.movie,
      label: 'Movies',
      icon: Icons.movie_outlined,
    ),
    LibraryAddVideoKindFilterOption(
      scope: LibraryAddVideoSearchScope.collection,
      label: 'Box Sets',
      icon: Icons.collections_bookmark_outlined,
    ),
  ],
  defaultVideoKindFilters: {LibraryAddVideoSearchScope.movie},
);

TransferableField _movieTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(MovieOwnedItem item) read,
  required MovieOwnedItem Function(MovieOwnedItem item, String? value) write,
  LibraryEditScope scope = LibraryEditScope.all,
}) {
  return TransferableField.typed<MovieOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MovieOwnedItem,
    read: read,
    write: write,
  );
}

final _movieUniversalTransferableFields =
    TransferableField.universalForTyped<MovieOwnedItem>(
  decode: (value) => value as MovieOwnedItem,
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

final _movieTransferableFields = <TransferableField>[
  _movieTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  _movieTransferField(
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
  _movieTransferField(
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
  _movieTransferField(
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

final Set<LibraryGroupIdRuntime> _movieMediaGroupModes = Set.unmodifiable({
  MovieGroupIds.director,
  MovieGroupIds.publisher,
  MovieGroupIds.genre,
  MovieGroupIds.releaseYear,
  MovieGroupIds.audienceRating,
  MovieGroupIds.movieOrTvSeries,
  MovieGroupIds.location,
});

final Set<LibraryGroupIdRuntime> _movieEditionGroupModes = Set.unmodifiable({
  MovieGroupIds.format,
  MovieGroupIds.audioTracks,
  MovieGroupIds.editionReleaseDate,
  MovieGroupIds.location,
});

final Set<LibrarySortIdRuntime> _movieMediaSortColumns = Set.unmodifiable({
  MovieSortIds.status,
  MovieSortIds.title,
  MovieSortIds.publisher,
  MovieSortIds.releaseDate,
});

final Set<LibrarySortIdRuntime> _movieEditionSortColumns = Set.unmodifiable({
  MovieSortIds.status,
  MovieSortIds.title,
  MovieSortIds.publisher,
  MovieSortIds.releaseDate,
});

Iterable<String?> _movieLinkedMetadataValues(MovieCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.studio,
      metadata.variant,
      metadata.country,
      metadata.originalLanguage,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

MovieCatalogMetadata? _movieLinkedMetadata(LibraryWorkspaceSource source) {
  final metadata = source.catalogTransport
      ?.mapTransport((transport) => transport)
      .kindMetadata;
  return metadata is MovieCatalogMetadata ? metadata : null;
}

MetadataSearchQuery _movieMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final item = source.catalogTransport;
  return MetadataSearchQuery(
    query: title,
    barcode: item?.mapTransport((transport) => transport).identifierCode,
    publisher: item?.mapTransport((transport) => transport).publisher,
    year: item?.releaseYear,
    limit: 5,
  );
}

const movieLibraryFacetModule = LibraryFacetModule(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
);

MovieOwnedItem _movieTransferOwnedItem(Object value) {
  if (value is MovieOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MovieOwnedItem');
}

final movieKindModule = LibraryKindCapabilityBundle<MovieWorkspaceDto>(
  presentation: moviesLibraryMediaPresentation,
  physicalMediaFormats: moviePhysicalMediaFormats,
  trackingProfile: movieTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.movie,
    singularLabel: 'Movie',
    pluralLabel: 'Movies',
    title: 'Movies',
    icon: Icons.movie_outlined,
    accent: Color(0xFF42AA55),
    preferencePrefix: 'movies',
    routeSegments: ['movies', 'movie'],
    mediaFamily: 'video',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'tmdb',
    catalogMetadataDecoder: MovieCatalogMetadata.fromJson,
    searchQueryBuilder: _movieMetadataSearchQuery,
    providers: [tmdbMetadataProvider],
  ),
  uiPolicy: const LibraryUiPolicy(
    wideDialog: true,
  ),
  hierarchy: LibraryHierarchyCapability(
    browserDelegateBuilder: buildMovieBrowserDelegate,
    supportsMediaReleaseSplit: true,
    mediaScopeGroupIds: _movieMediaGroupModes,
    releaseScopeGroupIds: _movieEditionGroupModes,
    mediaScopeSortIds: _movieMediaSortColumns,
    releaseScopeSortIds: _movieEditionSortColumns,
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildMovieInspectorSections,
    detailPageBuilder: buildLibraryVideoDetailPage,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<MovieCatalogMetadata>(
    _movieLinkedMetadata,
    _movieLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _movieTransferableFields) field.key,
    ],
    kindFields: [
      ..._movieUniversalTransferableFields,
      ..._movieTransferableFields,
    ],
  ),
  stats: const MovieStatsCapability(),
  value: const MovieValueCapability(),
  add: StandardLibraryAddCapability<MovieAddDraft>(
    kind: CatalogMediaKind.movie,
    dialogLauncher: showMovieLibraryAddDialog,
    initialDraftBuilder: MovieAddDraft.new,
    providerCandidateProjectionBuilder:
        movieCatalogTransportFromProviderCandidate,
    coreCatalogProjectionBuilder: movieCatalogTransportFromCoreItem,
    manualDraftBuilder: MovieAddManualDraft.new,
    manualPaneBuilder: buildMovieAddManualPane,
    chrome: _movieAddChrome,
    headerBuilder: buildMovieAddHeader,
    modeBarBuilder: buildMovieAddModeBar,
    previewPaneBuilder: buildMovieAddPreviewPane,
    searchPaneBuilder: buildMovieAddSearchPane,
    bottomBarBuilder: buildMovieAddBottomBar,
    ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
        MovieOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as MovieOwnedDetailsDraft,
      condition: common.condition,
      grade: common.isDigital == true ? null : kindValue ?? draft.grade,
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
      final payload = item.mapTransport((transport) => transport).payload;
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
        libraryAddVideoKindFilterId: {LibraryAddVideoSearchScope.movie},
      },
      advancedFilterDescriptorsBuilder: buildMovieAddAdvancedFilterFields,
      searchInputPredicate: libraryAddVideoHasSearchInput,
      kindSpecificPaneBuilder: buildLibraryAddVideoKindFilterRow,
      providerKindOverridesBuilder: (context) =>
          libraryAddVideoKindOverridesForChrome(_movieAddChrome, context),
      coreSearchInputBuilder: _buildMovieCoreSearchInput,
      providerQueryBuilder: _buildMovieProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _movieCollectionFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata =
                  item.mapTransport((transport) => transport).kindMetadata;
              return metadata is MovieCatalogMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _movieYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata =
                  item.mapTransport((transport) => transport).kindMetadata;
              return metadata is MovieCatalogMetadata
                  ? [metadata.releaseDate?.year]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    resultPolicy: buildLibraryAddVideoResultPolicy(
      mediaLabel: 'Media',
      supportsSeasonScope: false,
      coreScopeForItem: _movieAddResultScope,
      providerScopeForCandidate: _movieAddProviderResultScope,
      coreGroupTitleBuilder: _movieAddGroupTitle,
      providerCandidateIsGroup: libraryAddVideoProviderCandidateIsGroup,
    ),
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMovieLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(MovieVocabularies.all),
    presentation: movieLibraryEditPresentation,
    conditions: MovieVocabularies.condition.builtIns,
    ownedCollectionValueReader: (ownedItem) => ownedItem?.collectionValue,
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    createDraft: createMovieEditDraft,
    ownedDigitalFlagResolver: resolveMovieOwnedDigitalFlag,
    ownedFormatHintResolver: resolveMovieOwnedFormatHint,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        MovieOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue) =>
            MovieOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue, locationId, tags) =>
            MovieOwnedItemUpdatePayload.partial(
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
        MovieOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) {
      final typed = _movieTransferOwnedItem(updated);
      return MovieOwnedItemUpdatePayload.partial(
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
          const MovieOwnedDetailsCodec().draftFromDetails(
            typed.details,
          ),
        ),
      );
    },
    ownedDetailsResetPayloadBuilder: () =>
        MovieOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  ),
);

List<LibraryAddAdvancedFilterField<String>> buildMovieAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _movieCollectionFilterId,
        key: const ValueKey('library-add-collection-field'),
        label: 'Collection',
        value: req.advancedFilterText(_movieCollectionFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _movieYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_movieYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildMovieCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalMovieText(
      buildLibraryAddSearchQuery([
        context.query,
        context.textValueFor(_movieCollectionFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(_movieYearFilterId)),
    barcode: _optionalMovieText(context.identifierCode),
    limit: limit,
  );
}

String _buildMovieProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_movieCollectionFilterId),
    context.textValueFor(_movieYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalMovieText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

LibraryAddVideoResultScope _movieAddResultScope(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is MovieCatalogMetadata &&
      [
        metadata.editionTitle,
        metadata.itemNumber,
        metadata.physicalFormat,
        metadata.physicalFormatLabel,
        metadata.barcode,
        metadata.variant,
      ].any((value) => value?.trim().isNotEmpty == true)) {
    return LibraryAddVideoResultScope.release;
  }
  return LibraryAddVideoResultScope.media;
}

LibraryAddVideoResultScope _movieAddProviderResultScope(
  ProviderCandidate candidate,
) {
  final candidateType = candidate.candidateType?.trim().toLowerCase();
  if (candidateType == 'release' ||
      candidateType == 'edition' ||
      candidate.issueNumber?.trim().isNotEmpty == true ||
      candidate.isVariant) {
    return LibraryAddVideoResultScope.release;
  }
  return LibraryAddVideoResultScope.media;
}

String _movieAddGroupTitle(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is MovieCatalogMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  fields: movieLibraryKindSchema.toRegistry(),
  projector: const MovieWorkspaceProjector(),
  hierarchy: movieKindModule.hierarchy,
);
