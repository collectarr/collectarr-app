import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/library_add_video_kind_filters.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

const _animeSeriesFilterId = LibraryAddFilterId('anime.series');
const _animeStudioFilterId = LibraryAddFilterId('anime.studio');
const _animeYearFilterId = LibraryAddFilterId('anime.year');

final animeKindModule = LibraryKindSpec<AnimeWorkspaceDto, AnimeOwnedDetails>(
  type: animeLibraryConfig,
  projector: const AnimeWorkspaceProjector(),
  ownedDetailsCodec: const AnimeOwnedDetailsCodec(),
  fields: animeLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<AnimeMetadata>(
    AnimeMetadata.fromJson,
    _encodeAnimeMetadata,
  ),
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
    providers: [anilistMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.seasons,
    childrenTitleBuilder: _animeChildrenTitle,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  transfer: LibraryTransferCapability(
    kindFields: animeTransferableFields,
  ),
  add: StandardLibraryAddCapability<AnimeAddDraft>(
    kind: CatalogMediaKind.anime,
    initialDraftBuilder: AnimeAddDraft.new,
    manualDraftBuilder: AnimeAddManualDraft.new,
    search: LibraryAddSearchCapability(
      initialAdvancedFilters:
          buildLibraryAddVideoInitialFilters(animeLibraryConfig),
      advancedFilterDescriptorsBuilder: buildAnimeAddAdvancedFilterFields,
      searchInputPredicate: libraryAddVideoHasSearchInput,
      kindSpecificPaneBuilder: buildLibraryAddVideoKindFilterRow,
      providerKindOverridesBuilder: (context) =>
          libraryAddVideoKindOverrides(animeLibraryConfig, context),
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
                  ? [item.releaseYear, metadata.seasonYear]
                  : [item.releaseYear];
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
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildAnimeLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
    mediaFields: const MediaEditFields(
      numberLabel: 'Edition no.',
      publisherLabel: 'Studio',
      releaseDateLabel: 'First aired',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Format / Edition',
      barcodeLabel: 'UPC / Barcode',
    ),
    createDraft: createAnimeEditDraft,
  ),
  providerMapper: const AnimeLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildAnimeCardPresentation,
);

String _animeChildrenTitle(int count) => 'Seasons ($count)';

Map<String, dynamic> _encodeAnimeMetadata(AnimeMetadata m) => m.toJson();

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

LibraryAddVideoResultScope _animeAddResultScope(LibraryMetadataItem item) {
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

String _animeAddGroupTitle(LibraryMetadataItem item) {
  final metadata = item.kindMetadata;
  if (metadata is AnimeMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
