import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_shell.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_create_payload.dart';
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
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/add/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/value/movie_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';

const _movieCollectionFilterId = LibraryAddFilterId('movie.collection');
const _movieYearFilterId = LibraryAddFilterId('movie.year');

const _movieAddChrome = LibraryAddChromeConfig(
  videoKindFilterOptions: [
    LibraryAddVideoKindFilterOption(
      kind: 'movie',
      label: 'Movies',
      icon: Icons.movie_outlined,
    ),
    LibraryAddVideoKindFilterOption(
      kind: 'collection',
      label: 'Box Sets',
      icon: Icons.collections_bookmark_outlined,
    ),
  ],
  defaultVideoKindFilters: {'movie'},
);

final _movieTransferableFields = <TransferableField>[
  TransferableField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as MovieOwnedDetails?)?.features,
    write: (item, value) {
      final details =
          item.details as MovieOwnedDetails? ?? const MovieOwnedDetails();
      return item.copyWith(details: details.copyWith(features: value));
    },
  ),
  TransferableField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as MovieOwnedDetails?)?.boxSetName,
    write: (item, value) {
      final details =
          item.details as MovieOwnedDetails? ?? const MovieOwnedDetails();
      return item.copyWith(details: details.copyWith(boxSetName: value));
    },
  ),
  TransferableField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => (item.details as MovieOwnedDetails?)?.packaging,
    write: (item, value) {
      final details =
          item.details as MovieOwnedDetails? ?? const MovieOwnedDetails();
      return item.copyWith(details: details.copyWith(packaging: value));
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

final movieKindModule = LibraryKindSpec<MovieWorkspaceDto, MovieOwnedDetails,
    MovieOwnedDetailsDraft>(
  presentation: moviesLibraryMediaPresentation,
  trackingProfile: movieTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  projector: const MovieWorkspaceProjector(),
  ownedDetailsCodec: const MovieOwnedDetailsCodec(),
  fields: movieLibraryKindSchema.toRegistry(),
  catalogMetadataDecoder: MovieCatalogMetadata.fromJson,
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.movie,
    singularLabel: 'Movie',
    pluralLabel: 'Movies',
    title: 'Movies',
    icon: Icons.movie_outlined,
    accent: Color(0xFF42AA55),
    preferencePrefix: 'movies',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'tmdb',
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
    _movieLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    kindFields: _movieTransferableFields,
  ),
  stats: const MovieStatsCapability(),
  value: const MovieValueCapability(),
  add: StandardLibraryAddCapability<MovieAddDraft>(
    kind: CatalogMediaKind.movie,
    dialogLauncher: showMovieLibraryAddDialog,
    initialDraftBuilder: MovieAddDraft.new,
    manualDraftBuilder: MovieAddManualDraft.new,
    manualPaneBuilder: buildMovieAddManualPane,
    chrome: _movieAddChrome,
    headerBuilder: buildMovieAddHeader,
    modeBarBuilder: buildMovieAddModeBar,
    previewPaneBuilder: buildMovieAddPreviewPane,
    searchPaneBuilder: buildMovieAddSearchPane,
    bottomBarBuilder: buildMovieAddBottomBar,
    ownedPayloadBuilder: (item, common, details) => MovieOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as MovieOwnedDetailsDraft,
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
    existingOwnedPayloadBuilder: MovieOwnedItemCreatePayload.fromOwnedItem,
    search: LibraryAddSearchCapability(
      initialAdvancedFilters: {
        libraryAddVideoKindFilterId: {'movie'},
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
              final metadata = item.kindMetadata;
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
              final metadata = item.kindMetadata;
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
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    createDraft: createMovieEditDraft,
  ),
  providerMapper: const MovieLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMovieCardPresentation,
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

LibraryMetadataSearchInput _buildMovieCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalMovieText(
      buildLibraryAddSearchQuery([
        context.query,
        context.textValueFor(_movieCollectionFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(_movieYearFilterId)),
    barcode: _optionalMovieText(context.barcode),
    limit: limit,
  );
}

String _buildMovieProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_movieCollectionFilterId),
    context.textValueFor(_movieYearFilterId),
    context.barcode,
  ]);
}

String? _optionalMovieText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

LibraryAddVideoResultScope _movieAddResultScope(CatalogItem item) {
  final metadata = item.kindMetadata;
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

String _movieAddGroupTitle(CatalogItem item) {
  final metadata = item.kindMetadata;
  if (metadata is MovieCatalogMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
