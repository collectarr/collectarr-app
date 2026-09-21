part of 'manga_kind_components.dart';

final mangaKindAdd = StandardLibraryAddCapability<MangaAddDraft>(
  kind: CatalogMediaKind.manga,
  initialDraftBuilder: MangaAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      mangaCatalogTransportFromTypedCandidate(
    candidate as MangaProviderCandidate,
  ),
  coreCatalogProjectionBuilder: mangaCatalogTransportFromCoreItem,
  manualDraftBuilder: MangaAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MangaOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as MangaOwnedDetailsDraft,
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
    advancedFilterDescriptorsBuilder: buildMangaAddAdvancedFilterFields,
    coreSearchInputBuilder: _buildMangaCoreSearchInput,
    providerQueryBuilder: _buildMangaProviderQuery,
    typedProviderSearchBuilder: searchMangaProviderCandidates,
    typedProviderCandidatePreviewLoader: loadMangaProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: _mangaSeriesFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.series?.seriesTitle]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: _mangaVolumeFilterId,
          exactWeight: 75,
          containsWeight: 36,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [metadata.itemNumber, metadata.volumeNumber]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.issueNumber]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: _mangaPublisherFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [
                    metadata.publisher,
                    metadata.originalPublisher,
                    metadata.localizedPublisher,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.publisher]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: _mangaYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [
                    metadata.originalPublicationDate?.year,
                    metadata.localizedReleaseDate?.year,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.series?.volumeStartYear]
                  : const <Object?>[],
        ),
      ],
    ),
  ),
  manualPaneBuilder: buildMangaAddManualPane,
);

final mangaKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildMangaLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildMangaReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildMangaMediaLibraryEditDialog,
    ),
  ]),
  presentation: mangaLibraryEditPresentation,
  conditions: MangaVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    MangaOwnedItem item => item.grade,
    _ => null,
  },
  vocabularies: StandardKindVocabularyCapability(MangaVocabularies.all),
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  editChrome: const LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  createSession: createMangaEditDraft,
  ownedDigitalFlagResolver: resolveMangaOwnedDigitalFlag,
  ownedFormatHintResolver: resolveMangaOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MangaOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MangaOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MangaOwnedItemUpdatePayload.partial(
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
      MangaOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = _mangaTransferOwnedItem(updated);
    return MangaOwnedItemUpdatePayload.partial(
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
        const MangaOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      MangaOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

Iterable<String> _getFacetValues(
    MangaWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
  for (final definition in mangaLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

String _mangaChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchMangaVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final work =
      await api.getMangaWorkDto(itemId).timeout(const Duration(seconds: 60));
  final manga = MangaCoreMapper.fromWorkDto(work);
  final hierarchy = MangaHierarchyMapper.fromChapterRows(
    seriesId: itemId,
    rows: manga.chapters.whereType<Map<Object?, Object?>>().map(
          (chapter) => Map<String, dynamic>.from(chapter),
        ),
  );
  return MangaHierarchyMapper.toLibraryNodes(hierarchy);
}

List<LibraryAddAdvancedFilterField<String>> buildMangaAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _mangaSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(_mangaSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _mangaVolumeFilterId,
        key: const ValueKey('library-add-number-field'),
        label: 'Volume',
        value: req.advancedFilterText(_mangaVolumeFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _mangaPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(_mangaPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _mangaYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_mangaYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildMangaCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalMangaText(context.query),
    series: _optionalMangaText(context.textValueFor(_mangaSeriesFilterId)),
    issueNumber: _optionalMangaText(context.textValueFor(_mangaVolumeFilterId)),
    publisher:
        _optionalMangaText(context.textValueFor(_mangaPublisherFilterId)),
    year: int.tryParse(context.textValueFor(_mangaYearFilterId)),
    barcode: _optionalMangaText(context.identifierCode),
    limit: limit,
  );
}

String _buildMangaProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_mangaSeriesFilterId),
    context.textValueFor(_mangaVolumeFilterId),
    context.textValueFor(_mangaPublisherFilterId),
    context.textValueFor(_mangaYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalMangaText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
