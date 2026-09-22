import '../tv_module_dependencies.dart';
import '../config/tv_kind_configuration.dart';

final tvKindAdd = StandardLibraryAddCapability<TvAddDraft>(
  kind: CatalogMediaKind.tv,
  initialDraftBuilder: TvAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      tvCatalogTransportFromTypedCandidate(candidate as TvProviderCandidate),
  coreCatalogProjectionBuilder: tvCatalogTransportFromCoreItem,
  manualDraftBuilder: TvAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      TvOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
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
      libraryAddKindFilterId: {tvSearchScope},
    },
    advancedFilterDescriptorsBuilder: buildTvAddAdvancedFilterFields,
    searchInputPredicate: libraryAddHasSearchInput,
    kindSpecificPaneBuilder: buildLibraryAddKindFilterRow,
    providerKindOverridesBuilder: (context) =>
        libraryAddKindOverridesForChrome(tvAddChrome, context),
    coreSearchInputBuilder: buildTvCoreSearchInput,
    providerQueryBuilder: buildTvProviderQuery,
    typedProviderSearchBuilder: searchTvProviderCandidates,
    typedProviderCandidatePreviewLoader: loadTvProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: tvShowFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is TvSeriesMetadata
                ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is TvProviderCandidate
              ? [candidate.series?.seriesTitle]
              : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: tvNetworkFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is TvSeriesMetadata
                ? [
                    metadata.network,
                    metadata.streamingService,
                    ...metadata.productionCompanies,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is TvProviderCandidate
              ? [candidate.publisher, candidate.summary]
              : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: tvYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is TvSeriesMetadata
                ? [
                    metadata.firstAirDate?.year,
                    metadata.lastAirDate?.year,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is TvProviderCandidate
              ? [candidate.series?.volumeStartYear]
              : const <Object?>[],
        ),
      ],
    ),
  ),
  resultPolicy: buildTvAddResultPolicy(
    mediaLabel: 'Series',
    supportsSeasonScope: true,
    coreScopeForItem: tvAddResultScope,
    providerScopeForCandidate: tvAddProviderResultScope,
    coreGroupTitleBuilder: tvAddGroupTitle,
    providerCandidateIsGroup: tvAddProviderCandidateIsGroup,
  ),
  manualPaneBuilder: buildTvAddManualPane,
  chrome: tvAddChrome,
);

String tvChildrenTitle(int count) => 'Seasons ($count)';

Future<List<LibraryHierarchyNode>> fetchTvSeasons({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
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

String buildTvProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(tvShowFilterId),
    context.textValueFor(tvNetworkFilterId),
    context.textValueFor(tvYearFilterId),
    context.identifierCode,
  ]);
}

String? optionalTvText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

TvAddResultScope tvAddResultScope(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is TvSeriesMetadata) {
    if (metadata.seasonNumber != null ||
        metadata.series?.seasonNumber != null) {
      return TvAddResultScope.season;
    }
    if ([
      metadata.itemNumber,
      metadata.physicalFormat,
      metadata.physicalFormatLabel,
      metadata.barcode,
      metadata.variant,
    ].any((value) => value?.trim().isNotEmpty == true)) {
      return TvAddResultScope.release;
    }
  }
  return TvAddResultScope.media;
}

TvAddResultScope tvAddProviderResultScope(
  TvProviderCandidate candidate,
) {
  if (candidate.searchRole == ProviderSearchRole.season) {
    return TvAddResultScope.season;
  }
  if (candidate.searchRole.isCollectibleRelease) {
    return TvAddResultScope.release;
  }
  return TvAddResultScope.media;
}

String tvAddGroupTitle(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is TvSeriesMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.primaryLabel;
  }
  return item.primaryLabel;
}
