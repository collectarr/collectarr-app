part of 'game_kind_components.dart';

final gameKindAdd = StandardLibraryAddCapability<GameAddDraft>(
  kind: CatalogMediaKind.game,
  initialDraftBuilder: GameAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      gameCatalogTransportFromTypedCandidate(
          candidate as GameProviderCandidate),
  coreCatalogProjectionBuilder: gameCatalogTransportFromCoreItem,
  manualDraftBuilder: GameAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      GameOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as GameOwnedDetailsDraft,
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
    advancedFilterDescriptorsBuilder: buildGameAddAdvancedFilterFields,
    coreSearchInputBuilder: _buildGameCoreSearchInput,
    providerQueryBuilder: _buildGameProviderQuery,
    typedProviderSearchBuilder: searchGameProviderCandidates,
    typedProviderCandidatePreviewLoader: loadGameProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: _gamePlatformFilterId,
          exactWeight: 110,
          containsWeight: 44,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is GameCatalogMetadata
                ? [metadata.platform, ...metadata.platforms]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is GameProviderCandidate
              ? [candidate.summary]
              : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: _gameYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is GameCatalogMetadata
                ? [item.releaseYear, metadata.releaseDate?.year]
                : [item.releaseYear];
          },
          typedProviderValues: (candidate) => candidate is GameProviderCandidate
              ? [candidate.series?.volumeStartYear]
              : const <Object?>[],
        ),
      ],
    ),
  ),
  manualPaneBuilder: buildGameAddManualPane,
);

final gameKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildGameLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildGameReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildGameMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(GameVocabularies.all),
  conditions: GameVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    GameOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  presentation: gameLibraryEditPresentation,
  createSession: createGameEditDraft,
  ownedDigitalFlagResolver: resolveGameOwnedDigitalFlag,
  ownedFormatHintResolver: resolveGameOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      GameOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      GameOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          GameOwnedItemUpdatePayload.partial(
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
      GameOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = _gameTransferOwnedItem(updated);
    return GameOwnedItemUpdatePayload.partial(
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
        const GameOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      GameOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

Iterable<String> _getGameFacetValues(
  GameWorkspaceDto dto,
  LibraryFacetIdRuntime facetId,
) {
  for (final definition in gameLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

List<LibraryAddAdvancedFilterField<String>> buildGameAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _gamePlatformFilterId,
        key: const ValueKey('library-add-platform-field'),
        label: 'Platform',
        value: req.advancedFilterText(_gamePlatformFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _gameYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_gameYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildGameCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalGameText(
      buildLibraryAddSearchQuery([
        context.query,
        context.textValueFor(_gamePlatformFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(_gameYearFilterId)),
    barcode: _optionalGameText(context.identifierCode),
    limit: limit,
  );
}

String _buildGameProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_gamePlatformFilterId),
    context.textValueFor(_gameYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
