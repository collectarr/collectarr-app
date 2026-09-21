part of 'tv_kind_components.dart';

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
      libraryAddKindFilterId: {_tvSearchScope},
    },
    advancedFilterDescriptorsBuilder: buildTvAddAdvancedFilterFields,
    searchInputPredicate: libraryAddHasSearchInput,
    kindSpecificPaneBuilder: buildLibraryAddKindFilterRow,
    providerKindOverridesBuilder: (context) =>
        libraryAddKindOverridesForChrome(_tvAddChrome, context),
    coreSearchInputBuilder: _buildTvCoreSearchInput,
    providerQueryBuilder: _buildTvProviderQuery,
    typedProviderSearchBuilder: searchTvProviderCandidates,
    typedProviderCandidatePreviewLoader: loadTvProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: _tvShowFilterId,
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
          id: _tvNetworkFilterId,
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
          id: _tvYearFilterId,
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
    coreScopeForItem: _tvAddResultScope,
    providerScopeForCandidate: _tvAddProviderResultScope,
    coreGroupTitleBuilder: _tvAddGroupTitle,
    providerCandidateIsGroup: tvAddProviderCandidateIsGroup,
  ),
  manualPaneBuilder: buildTvAddManualPane,
  chrome: _tvAddChrome,
);

final tvKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildTvLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildTvReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildTvMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(TvVocabularies.all),
  presentation: tvLibraryEditPresentation,
  conditions: TvVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    TvOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createTvEditDraft,
  ownedDigitalFlagResolver: resolveTvOwnedDigitalFlag,
  ownedFormatHintResolver: resolveTvOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      TvOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      TvOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          TvOwnedItemUpdatePayload.partial(
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
    _,
    purchaseDate,
    pricePaidCents,
    currency,
    personalNotes,
    purchaseStore,
    locationChanged,
    locationId,
  ) =>
      TvOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = _tvTransferOwnedItem(updated);
    return TvOwnedItemUpdatePayload.partial(
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
        const TvOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      TvOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

String _tvChildrenTitle(int count) => 'Seasons ($count)';

Future<List<LibraryHierarchyNode>> _fetchTvSeasons({
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
        id: _tvShowFilterId,
        key: const ValueKey('library-add-show-field'),
        label: 'Show / Series',
        value: req.advancedFilterText(_tvShowFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _tvNetworkFilterId,
        key: const ValueKey('library-add-network-field'),
        label: 'Network',
        value: req.advancedFilterText(_tvNetworkFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _tvYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_tvYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildTvCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalTvText(context.query),
    series: _optionalTvText(context.textValueFor(_tvShowFilterId)),
    publisher: _optionalTvText(context.textValueFor(_tvNetworkFilterId)),
    year: int.tryParse(context.textValueFor(_tvYearFilterId)),
    barcode: _optionalTvText(context.identifierCode),
    limit: limit,
  );
}

String _buildTvProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_tvShowFilterId),
    context.textValueFor(_tvNetworkFilterId),
    context.textValueFor(_tvYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalTvText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

TvAddResultScope _tvAddResultScope(CatalogSearchCandidate item) {
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

TvAddResultScope _tvAddProviderResultScope(
  TvProviderCandidate candidate,
) {
  if (candidate.searchRole == ProviderSearchRole.season) {
    return TvAddResultScope.season;
  }
  if (candidate.searchRole.isReleaseLike) {
    return TvAddResultScope.release;
  }
  return TvAddResultScope.media;
}

String _tvAddGroupTitle(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is TvSeriesMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
