import '../tv_module_dependencies.dart';
import '../config/tv_kind_configuration.dart';
import 'tv_manual_candidate.dart';

final tvKindAdd = StandardLibraryAddCapability<TvAddDraft>(
  kind: CatalogMediaKind.tv,
  initialDraftBuilder: TvAddDraft.new,
  coreCatalogProjectionBuilder: tvCatalogTransportFromCoreItem,
  manualDraftBuilder: TvAddManualDraft.new,
  manualCandidateBuilder: buildTvManualCandidate,
  manualProposalBuilder: buildTvManualProposalData,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      TvOwnedItemCreatePayload(
    catalogRef: item.reference,
    details: details as TvOwnedDetailsDraft,
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
            LibraryAddSearchScopesFilterValue({tvSearchScope}),
      },
      advancedFilterDescriptorsBuilder: buildTvAddAdvancedFilterFields,
      searchInputPredicate: libraryAddHasSearchInput,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: buildTvCoreSearchInput,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: tvShowFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindCapability
                  .mapTransport((transport) => transport)
                  .kindMetadata;
              return metadata is TvSeriesMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
          ),
          LibraryAddSearchRankField(
            id: tvNetworkFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindCapability
                  .mapTransport((transport) => transport)
                  .kindMetadata;
              return metadata is TvSeriesMetadata
                  ? [
                      metadata.network,
                      metadata.streamingService,
                      ...metadata.productionCompanies,
                    ]
                  : const <Object?>[];
            },
          ),
          LibraryAddSearchRankField(
            id: tvYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindCapability
                  .mapTransport((transport) => transport)
                  .kindMetadata;
              return metadata is TvSeriesMetadata
                  ? [
                      metadata.firstAirDate?.year,
                      metadata.lastAirDate?.year,
                    ]
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
  manualPaneBuilder: buildTvAddManualPane,
  chrome: tvAddChrome,
);

String tvChildrenTitle(int count) => 'Seasons ($count)';

Future<List<LibraryHierarchyNode>> fetchTvSeasons({
  required ApiClient api,
  required String itemId,
}) async {
  final seasons = await api
      .getTvSeriesSeasonsDto(itemId)
      .timeout(const Duration(seconds: 60));
  final typedSeasons = [
    for (final season in seasons) TvCoreMapper.fromSeasonDto(season),
  ];
  return TvHierarchyMapper.toLibraryNodes(typedSeasons);
}

List<LibraryAddAdvancedFilterField<String>> buildTvAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: tvShowFilterId,
        key: const ValueKey('library-add-show-field'),
        label: 'Show / Series',
        value: req.advancedFilterText(tvShowFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: tvNetworkFilterId,
        key: const ValueKey('library-add-network-field'),
        label: 'Network',
        value: req.advancedFilterText(tvNetworkFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: tvYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(tvYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildTvCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalTvText(context.query),
    series: optionalTvText(context.textValueFor(tvShowFilterId)),
    publisher: optionalTvText(context.textValueFor(tvNetworkFilterId)),
    year: int.tryParse(context.textValueFor(tvYearFilterId)),
    barcode: optionalTvText(context.identifierCode),
    limit: limit,
  );
}

String? optionalTvText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
