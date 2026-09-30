import '../movie_module_dependencies.dart';
import '../config/movie_kind_configuration.dart';
import 'movie_manual_candidate.dart';

final movieKindAdd = StandardLibraryAddCapability<MovieAddDraft>(
  kind: CatalogMediaKind.movie,
  initialDraftBuilder: MovieAddDraft.new,
  coreCatalogProjectionBuilder: movieCatalogTransportFromCoreItem,
  manualDraftBuilder: MovieAddManualDraft.new,
  manualCandidateBuilder: buildMovieManualCandidate,
  manualProposalBuilder: buildMovieManualProposalData,
  manualCandidateValidationMessage:
      'Enter a title and correct any invalid Catalog Item details.',
  manualPaneBuilder: buildMovieAddManualPane,
  chrome: movieAddChrome,
  headerBuilder: buildMovieAddHeader,
  modeBarBuilder: buildMovieAddModeBar,
  previewPaneBuilder: buildMovieAddPreviewPane,
  searchPaneBuilder: buildMovieAddSearchPane,
  bottomBarPresentation: LibraryAddBottomBarPresentation.segmentedTarget,
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
          ),
        ],
      ),
    ),
    presentation: LibraryAddSearchPresentationCapability(
      controlsBuilder: buildLibraryAddKindFilterRow,
    ),
  ),
  resultPolicy: const LibraryAddResultPolicy(useGridResults: true),
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

String? optionalMovieText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
