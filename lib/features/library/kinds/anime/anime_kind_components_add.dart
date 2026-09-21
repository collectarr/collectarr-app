part of 'anime_kind_components.dart';

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
    catalogRef: item.catalogRef,
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
      libraryAddKindFilterId: {_animeSearchScope},
    },
    advancedFilterDescriptorsBuilder: buildAnimeAddAdvancedFilterFields,
    searchInputPredicate: libraryAddHasSearchInput,
    kindSpecificPaneBuilder: buildLibraryAddKindFilterRow,
    providerKindOverridesBuilder: (context) =>
        libraryAddKindOverridesForChrome(_animeAddChrome, context),
    coreSearchInputBuilder: _buildAnimeCoreSearchInput,
    providerQueryBuilder: _buildAnimeProviderQuery,
    typedProviderSearchBuilder: searchAnimeProviderCandidates,
    typedProviderCandidatePreviewLoader: loadAnimeProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: _animeSeriesFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
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
          id: _animeStudioFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
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
          id: _animeYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
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
    coreScopeForItem: _animeAddResultScope,
    providerScopeForCandidate: _animeAddProviderResultScope,
    coreGroupTitleBuilder: _animeAddGroupTitle,
    providerCandidateIsGroup: animeAddProviderCandidateIsGroup,
  ),
  manualPaneBuilder: buildAnimeAddManualPane,
  chrome: _animeAddChrome,
);

final animeKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildAnimeLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildAnimeReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildAnimeMediaLibraryEditDialog,
    ),
  ]),
  presentation: animeLibraryEditPresentation,
  conditions: AnimeVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) =>
      ownedItem?.map<String>(anime: (item) => item.grade),
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
  createSession: createAnimeEditDraft,
  ownedDigitalFlagResolver: resolveAnimeOwnedDigitalFlag,
  ownedFormatHintResolver: resolveAnimeOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      AnimeOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      AnimeOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          AnimeOwnedItemUpdatePayload.partial(
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
      AnimeOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = _animeTransferOwnedItem(updated);
    return AnimeOwnedItemUpdatePayload.partial(
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
        const AnimeOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      AnimeOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

String _animeChildrenTitle(int count) => 'Episodes ($count)';

Future<List<LibraryHierarchyNode>> _fetchAnimeEpisodes({
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

MetadataSearchQuery _buildAnimeCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalAnimeText(context.query),
    series: _optionalAnimeText(context.textValueFor(_animeSeriesFilterId)),
    publisher: _optionalAnimeText(context.textValueFor(_animeStudioFilterId)),
    year: int.tryParse(context.textValueFor(_animeYearFilterId)),
    barcode: _optionalAnimeText(context.identifierCode),
    limit: limit,
  );
}

String _buildAnimeProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_animeSeriesFilterId),
    context.textValueFor(_animeStudioFilterId),
    context.textValueFor(_animeYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalAnimeText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

AnimeAddResultScope _animeAddResultScope(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
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

AnimeAddResultScope _animeAddProviderResultScope(
  AnimeProviderCandidate candidate,
) {
  if (candidate.searchRole == ProviderSearchRole.season) {
    return AnimeAddResultScope.season;
  }
  if (candidate.searchRole.isReleaseLike) {
    return AnimeAddResultScope.release;
  }
  return AnimeAddResultScope.media;
}

String _animeAddGroupTitle(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is AnimeMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}

