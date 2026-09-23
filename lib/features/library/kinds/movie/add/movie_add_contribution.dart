import '../movie_module_dependencies.dart';
import '../config/movie_kind_configuration.dart';

final movieKindAdd = StandardLibraryAddCapability<MovieAddDraft>(
  kind: CatalogMediaKind.movie,
  dialogLauncher: showMovieLibraryAddDialog,
  initialDraftBuilder: MovieAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      movieCatalogTransportFromTypedCandidate(
    candidate as MovieProviderCandidate,
  ),
  coreCatalogProjectionBuilder: movieCatalogTransportFromCoreItem,
  manualDraftBuilder: MovieAddManualDraft.new,
  manualPaneBuilder: buildMovieAddManualPane,
  chrome: movieAddChrome,
  headerBuilder: buildMovieAddHeader,
  modeBarBuilder: buildMovieAddModeBar,
  previewPaneBuilder: buildMovieAddPreviewPane,
  searchPaneBuilder: buildMovieAddSearchPane,
  bottomBarBuilder: buildMovieAddBottomBar,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MovieOwnedItemCreatePayload(
    catalogRef: item.reference,
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
    final payload =
        item.kindCapability.mapTransport((transport) => transport).payload;
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
    input: LibraryAddSearchInputCapability(
      initialAdvancedFilters: {
        libraryAddKindFilterId:
            LibraryAddSearchScopesFilterValue({movieSearchScope}),
      },
      advancedFilterDescriptorsBuilder: buildMovieAddAdvancedFilterFields,
      searchInputPredicate: libraryAddHasSearchInput,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: buildMovieCoreSearchInput,
    ),
    provider: LibraryAddProviderSearchCapability(
      queryBuilder: buildMovieProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: movieCollectionFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata = item.kindCapability
                  .mapTransport((transport) => transport)
                  .kindMetadata;
              return metadata is MovieCatalogMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
            typedProviderValues: (candidate) =>
                candidate is MovieProviderCandidate
                    ? [candidate.series?.seriesTitle]
                    : const <Object?>[],
          ),
          LibraryAddSearchRankField(
            id: movieYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindCapability
                  .mapTransport((transport) => transport)
                  .kindMetadata;
              return metadata is MovieCatalogMetadata
                  ? [metadata.releaseDate?.year]
                  : const <Object?>[];
            },
            typedProviderValues: (candidate) =>
                candidate is MovieProviderCandidate
                    ? [candidate.series?.volumeStartYear]
                    : const <Object?>[],
          ),
        ],
      ),
      strategy:
          LibraryAddTypedProviderSearchStrategy(searchMovieProviderCandidates),
      candidatePreviewLoader: loadMovieProviderCandidatePreview,
      kindOverridesBuilder: (context) =>
          libraryAddKindOverridesForChrome(movieAddChrome, context),
    ),
    presentation: LibraryAddSearchPresentationCapability(
      controlsBuilder: buildLibraryAddKindFilterRow,
    ),
  ),
  resultPolicy: buildMovieAddResultPolicy(
    mediaLabel: 'Media',
    supportsSeasonScope: false,
    coreScopeForItem: movieAddResultScope,
    providerScopeForCandidate: movieAddProviderResultScope,
    coreGroupTitleBuilder: movieAddGroupTitle,
    providerCandidateIsGroup: movieAddProviderCandidateIsGroup,
  ),
);

List<LibraryAddAdvancedFilterField<String>> buildMovieAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: movieCollectionFilterId,
        key: const ValueKey('library-add-collection-field'),
        label: 'Collection',
        value: req.advancedFilterText(movieCollectionFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: movieYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(movieYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildMovieCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalMovieText(
      buildLibraryAddSearchQuery([
        context.query,
        context.textValueFor(movieCollectionFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(movieYearFilterId)),
    barcode: optionalMovieText(context.identifierCode),
    limit: limit,
  );
}

String buildMovieProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(movieCollectionFilterId),
    context.textValueFor(movieYearFilterId),
    context.identifierCode,
  ]);
}

String? optionalMovieText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

MovieAddResultScope movieAddResultScope(CatalogSearchCandidate item) {
  final metadata =
      item.kindCapability.mapTransport((transport) => transport).kindMetadata;
  if (metadata is MovieCatalogMetadata &&
      [
        metadata.editionTitle,
        metadata.itemNumber,
        metadata.physicalFormat,
        metadata.physicalFormatLabel,
        metadata.barcode,
        metadata.variant,
      ].any((value) => value?.trim().isNotEmpty == true)) {
    return MovieAddResultScope.release;
  }
  return MovieAddResultScope.media;
}

MovieAddResultScope movieAddProviderResultScope(
  MovieProviderCandidate candidate,
) {
  if (candidate.searchRole.isCollectibleRelease) {
    return MovieAddResultScope.release;
  }
  return MovieAddResultScope.media;
}

String movieAddGroupTitle(CatalogSearchCandidate item) {
  final metadata =
      item.kindCapability.mapTransport((transport) => transport).kindMetadata;
  if (metadata is MovieCatalogMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.summary.primaryLabel;
  }
  return item.summary.primaryLabel;
}
