import '../anime_module_dependencies.dart';
import '../config/anime_kind_configuration.dart';

final animeKindAdd = StandardLibraryAddCapability<AnimeAddDraft>(
  kind: CatalogMediaKind.anime,
  initialDraftBuilder: AnimeAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      animeCatalogTransportFromTypedCandidate(
          candidate as AnimeProviderCandidate),
  coreCatalogProjectionBuilder: animeCatalogTransportFromCoreItem,
  manualDraftBuilder: AnimeAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      AnimeOwnedItemCreatePayload(
    catalogRef: item.reference,
    details: details as AnimeOwnedDetailsDraft,
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
    initialAdvancedFilters: {
      libraryAddKindFilterId:
          LibraryAddSearchScopesFilterValue({animeSearchScope}),
    },
    advancedFilterDescriptorsBuilder: buildAnimeAddAdvancedFilterFields,
    searchInputPredicate: libraryAddHasSearchInput,
    kindSpecificPaneBuilder: buildLibraryAddKindFilterRow,
    providerKindOverridesBuilder: (context) =>
        libraryAddKindOverridesForChrome(animeAddChrome, context),
    coreSearchInputBuilder: buildAnimeCoreSearchInput,
    providerQueryBuilder: buildAnimeProviderQuery,
    typedProviderSearchBuilder: searchAnimeProviderCandidates,
    typedProviderCandidatePreviewLoader: loadAnimeProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: animeSeriesFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final metadata = item.kindCapability
                .mapTransport((transport) => transport)
                .kindMetadata;
            return metadata is AnimeMetadata
                ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is AnimeProviderCandidate
                  ? [candidate.series?.seriesTitle]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: animeStudioFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata = item.kindCapability
                .mapTransport((transport) => transport)
                .kindMetadata;
            return metadata is AnimeMetadata
                ? [...metadata.studios, ...metadata.producers]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is AnimeProviderCandidate
                  ? [candidate.publisher, candidate.summary]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: animeYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata = item.kindCapability
                .mapTransport((transport) => transport)
                .kindMetadata;
            return metadata is AnimeMetadata
                ? [metadata.seasonYear, metadata.startDate?.year]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is AnimeProviderCandidate
                  ? [candidate.series?.volumeStartYear]
                  : const <Object?>[],
        ),
      ],
    ),
  ),
  resultPolicy: buildAnimeAddResultPolicy(
    mediaLabel: 'Series',
    supportsSeasonScope: true,
    coreScopeForItem: animeAddResultScope,
    providerScopeForCandidate: animeAddProviderResultScope,
    coreGroupTitleBuilder: animeAddGroupTitle,
    providerCandidateIsGroup: animeAddProviderCandidateIsGroup,
  ),
  manualPaneBuilder: buildAnimeAddManualPane,
  chrome: animeAddChrome,
);

String animeChildrenTitle(int count) => 'Episodes ($count)';

Future<List<LibraryHierarchyNode>> fetchAnimeEpisodes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final dto =
      await api.getAnimeSeriesDto(itemId).timeout(const Duration(seconds: 60));
  return AnimeHierarchyMapper.toLibraryNodes(
    AnimeCoreMapper.fromSeriesDto(dto),
  );
}

List<LibraryAddAdvancedFilterField<String>> buildAnimeAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: animeSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(animeSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: animeStudioFilterId,
        key: const ValueKey('library-add-studio-field'),
        label: 'Studio',
        value: req.advancedFilterText(animeStudioFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: animeYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(animeYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildAnimeCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalAnimeText(context.query),
    series: optionalAnimeText(context.textValueFor(animeSeriesFilterId)),
    publisher: optionalAnimeText(context.textValueFor(animeStudioFilterId)),
    year: int.tryParse(context.textValueFor(animeYearFilterId)),
    barcode: optionalAnimeText(context.identifierCode),
    limit: limit,
  );
}

String buildAnimeProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(animeSeriesFilterId),
    context.textValueFor(animeStudioFilterId),
    context.textValueFor(animeYearFilterId),
    context.identifierCode,
  ]);
}

String? optionalAnimeText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

AnimeAddResultScope animeAddResultScope(CatalogSearchCandidate item) {
  final metadata =
      item.kindCapability.mapTransport((transport) => transport).kindMetadata;
  if (metadata is AnimeMetadata) {
    if (metadata.series?.seasonNumber != null) {
      return AnimeAddResultScope.season;
    }
    if ([
      metadata.itemNumber,
      metadata.editionTitle,
      metadata.physicalFormat,
      metadata.physicalFormatLabel,
      metadata.barcode,
      metadata.variant,
    ].any((value) => value?.trim().isNotEmpty == true)) {
      return AnimeAddResultScope.release;
    }
  }
  return AnimeAddResultScope.media;
}

AnimeAddResultScope animeAddProviderResultScope(
  AnimeProviderCandidate candidate,
) {
  if (candidate.searchRole == ProviderSearchRole.season) {
    return AnimeAddResultScope.season;
  }
  if (candidate.searchRole.isCollectibleRelease) {
    return AnimeAddResultScope.release;
  }
  return AnimeAddResultScope.media;
}

String animeAddGroupTitle(CatalogSearchCandidate item) {
  final metadata =
      item.kindCapability.mapTransport((transport) => transport).kindMetadata;
  if (metadata is AnimeMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.summary.primaryLabel;
  }
  return item.summary.primaryLabel;
}
