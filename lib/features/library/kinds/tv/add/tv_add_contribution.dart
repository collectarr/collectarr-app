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
  entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      TvLibraryEntryCreatePayload(
    details: details as TvEntryDetailsDraft,
    condition: common.condition,
    grade: kindValue ?? draft.grade,
    purchaseDate: common.purchaseDate,
    pricePaidCents: common.pricePaidCents,
    currency: common.currency,
    personalNotes: common.personalNotes,
    tags: common.tags,
    locationId: common.locationId,
    purchaseStore: common.purchaseStore,
    ownerLabel: common.ownerLabel,
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
              final metadata = item.kindCapability.mapTransport(
                  (transport) => TvSeriesMetadata.fromJson(transport.kindData));
              return [metadata.seriesTitle];
            },
          ),
          LibraryAddSearchRankField(
            id: tvNetworkFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                  (transport) => TvSeriesMetadata.fromJson(transport.kindData));
              return [
                metadata.publisher,
                metadata.network,
                metadata.streamingService,
                ...metadata.productionCompanies,
              ];
            },
          ),
          LibraryAddSearchRankField(
            id: tvYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                  (transport) => TvSeriesMetadata.fromJson(transport.kindData));
              return [
                metadata.firstAirDate?.year,
                metadata.lastAirDate?.year,
                metadata.releaseDate?.year,
              ];
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
  final item = await api
      .getCatalogItemJson(kind: CatalogMediaKind.tv, id: itemId)
      .timeout(const Duration(seconds: 60));
  final series = TvCoreMapper.fromCatalogItemJson(item);
  return TvHierarchyMapper.toLibraryNodes(series.seasons);
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
