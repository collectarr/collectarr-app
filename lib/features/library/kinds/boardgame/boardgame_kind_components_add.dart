part of 'boardgame_kind_components.dart';

final boardGameKindAdd = StandardLibraryAddCapability<BoardgameAddDraft>(
  kind: CatalogMediaKind.boardgame,
  initialDraftBuilder: BoardgameAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      boardGameCatalogTransportFromTypedCandidate(
    candidate as BoardGameProviderCandidate,
  ),
  coreCatalogProjectionBuilder: boardGameCatalogTransportFromCoreItem,
  manualDraftBuilder: BoardgameAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      BoardgameOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as BoardgameOwnedDetailsDraft,
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
    advancedFilterDescriptorsBuilder: buildBoardGameAddAdvancedFilterFields,
    coreSearchInputBuilder: _buildBoardGameCoreSearchInput,
    providerQueryBuilder: _buildBoardGameProviderQuery,
    typedProviderSearchBuilder: searchBoardGameProviderCandidates,
    typedProviderCandidatePreviewLoader: loadBoardGameProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: _boardGameDesignerFilterId,
          exactWeight: 110,
          containsWeight: 44,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BoardGameMetadata
                ? [...metadata.designers, ...metadata.artists]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is BoardGameProviderCandidate
                  ? [candidate.summary]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: _boardGamePublisherFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BoardGameMetadata
                ? [...metadata.publishers, metadata.publisher]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is BoardGameProviderCandidate
                  ? [candidate.publisher]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: _boardGameYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BoardGameMetadata
                ? [metadata.yearPublished]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is BoardGameProviderCandidate
                  ? [candidate.series?.volumeStartYear]
                  : const <Object?>[],
        ),
      ],
    ),
  ),
  manualPaneBuilder: buildBoardgameAddManualPane,
);

final boardGameKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildBoardGameLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildBoardGameReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildBoardGameMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(BoardGameVocabularies.all),
  presentation: boardGamesLibraryEditPresentation,
  conditions: BoardGameVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    BoardGameOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createBoardGameEditDraft,
  ownedDigitalFlagResolver: resolveBoardGameOwnedDigitalFlag,
  ownedFormatHintResolver: resolveBoardGameOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      BoardgameOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      BoardgameOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          BoardgameOwnedItemUpdatePayload.partial(
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
      BoardgameOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = _boardGameTransferOwnedItem(updated);
    return BoardgameOwnedItemUpdatePayload.partial(
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
        const BoardgameOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      BoardgameOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

final boardGameKindStats = const BoardGameStatsCapability();

Iterable<String> _getBoardGameFacetValues(
  BoardGameWorkspaceDto dto,
  LibraryFacetIdRuntime facetId,
) {
  for (final definition in boardgameLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

List<LibraryAddAdvancedFilterField<String>>
    buildBoardGameAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
        [
          LibraryAddAdvancedFilterField<String>(
            id: _boardGameDesignerFilterId,
            key: const ValueKey('library-add-designer-field'),
            label: 'Designer',
            value: req.advancedFilterText(_boardGameDesignerFilterId),
            parse: (text) => text.trim(),
          ),
          LibraryAddAdvancedFilterField<String>(
            id: _boardGamePublisherFilterId,
            key: const ValueKey('library-add-publisher-field'),
            label: 'Publisher',
            value: req.advancedFilterText(_boardGamePublisherFilterId),
            parse: (text) => text.trim(),
          ),
          LibraryAddAdvancedFilterField<String>(
            id: _boardGameYearFilterId,
            key: const ValueKey('library-add-year-field'),
            label: 'Year',
            value: req.advancedFilterText(_boardGameYearFilterId),
            parse: (text) => text.trim(),
            width: 120,
          ),
        ];

MetadataSearchQuery _buildBoardGameCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalBoardGameText(context.query),
    publisher: _optionalBoardGameText(
        context.textValueFor(_boardGamePublisherFilterId)),
    year: int.tryParse(context.textValueFor(_boardGameYearFilterId)),
    barcode: _optionalBoardGameText(context.identifierCode),
    limit: limit,
  );
}

String _buildBoardGameProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_boardGameDesignerFilterId),
    context.textValueFor(_boardGamePublisherFilterId),
    context.textValueFor(_boardGameYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalBoardGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
