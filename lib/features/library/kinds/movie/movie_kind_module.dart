import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_shell.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/library_add_video_result_policy.dart';

import 'package:collectarr_app/features/library/kinds/movie/stats/movie_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';

const _movieCollectionFilterId = LibraryAddFilterId('movie.collection');
const _movieYearFilterId = LibraryAddFilterId('movie.year');

final movieKindModule = LibraryKindSpec<MovieWorkspaceDto, MovieOwnedDetails>(
  type: moviesLibraryConfig,
  projector: const MovieWorkspaceProjector(),
  ownedDetailsCodec: const MovieOwnedDetailsCodec(),
  fields: movieLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<MovieCatalogMetadata>(
    MovieCatalogMetadata.fromJson,
    _encodeMovieMetadata,
  ),
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
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.flat,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildMovieInspectorSections,
    detailPageBuilder: buildVideoLibraryDetailPage,
  ),
  transfer: LibraryTransferCapability(
    kindFields: movieTransferableFields,
  ),
  stats: const MovieStatsCapability(),
  add: StandardLibraryAddCapability<MovieAddDraft>(
    kind: CatalogMediaKind.movie,
    initialDraftBuilder: MovieAddDraft.new,
    manualDraftBuilder: MovieAddManualDraft.new,
    manualPaneBuilder: buildMovieAddManualPane,
    headerBuilder: buildMovieAddHeader,
    modeBarBuilder: buildMovieAddModeBar,
    previewPaneBuilder: buildMovieAddPreviewPane,
    searchPaneBuilder: buildMovieAddSearchPane,
    bottomBarBuilder: buildMovieAddBottomBar,
    search: LibraryAddSearchCapability(
      initialAdvancedFilters:
          buildLibraryAddVideoInitialFilters(moviesLibraryConfig),
      advancedFilterDescriptorsBuilder: buildMovieAddAdvancedFilterFields,
      searchInputPredicate: libraryAddVideoHasSearchInput,
      kindSpecificPaneBuilder: buildLibraryAddVideoKindFilterRow,
      providerKindOverridesBuilder: (context) =>
          libraryAddVideoKindOverrides(moviesLibraryConfig, context),
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
                  ? [item.releaseYear, metadata.releaseDate?.year]
                  : [item.releaseYear];
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
    mediaFields: const MediaEditFields(
      numberLabel: 'Edition no.',
      publisherLabel: 'Studio',
      releaseDateLabel: 'Release Date',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Format / Edition',
      barcodeLabel: 'UPC / Barcode',
    ),
    createDraft: createMovieEditDraft,
  ),
  providerMapper: const MovieLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMovieCardPresentation,
);

Map<String, dynamic> _encodeMovieMetadata(MovieCatalogMetadata m) => m.toJson();

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

LibraryAddVideoResultScope _movieAddResultScope(LibraryMetadataItem item) {
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

String _movieAddGroupTitle(LibraryMetadataItem item) {
  final metadata = item.kindMetadata;
  if (metadata is MovieCatalogMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
