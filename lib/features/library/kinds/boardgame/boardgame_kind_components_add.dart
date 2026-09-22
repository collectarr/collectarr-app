import 'boardgame_module_dependencies.dart';
import 'boardgame_kind_components_support.dart';

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
    coreSearchInputBuilder: buildBoardGameCoreSearchInput,
    providerQueryBuilder: buildBoardGameProviderQuery,
    typedProviderSearchBuilder: searchBoardGameProviderCandidates,
    typedProviderCandidatePreviewLoader: loadBoardGameProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: boardGameDesignerFilterId,
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
          id: boardGamePublisherFilterId,
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
          id: boardGameYearFilterId,
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

final boardGameKindStats = const BoardGameStatsCapability();

Iterable<String> getBoardGameFacetValues(
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
            id: boardGameDesignerFilterId,
            key: const ValueKey('library-add-designer-field'),
            label: 'Designer',
            value: req.advancedFilterText(boardGameDesignerFilterId),
            parse: (text) => text.trim(),
          ),
          LibraryAddAdvancedFilterField<String>(
            id: boardGamePublisherFilterId,
            key: const ValueKey('library-add-publisher-field'),
            label: 'Publisher',
            value: req.advancedFilterText(boardGamePublisherFilterId),
            parse: (text) => text.trim(),
          ),
          LibraryAddAdvancedFilterField<String>(
            id: boardGameYearFilterId,
            key: const ValueKey('library-add-year-field'),
            label: 'Year',
            value: req.advancedFilterText(boardGameYearFilterId),
            parse: (text) => text.trim(),
            width: 120,
          ),
        ];

MetadataSearchQuery buildBoardGameCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalBoardGameText(context.query),
    publisher:
        optionalBoardGameText(context.textValueFor(boardGamePublisherFilterId)),
    year: int.tryParse(context.textValueFor(boardGameYearFilterId)),
    barcode: optionalBoardGameText(context.identifierCode),
    limit: limit,
  );
}

String buildBoardGameProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(boardGameDesignerFilterId),
    context.textValueFor(boardGamePublisherFilterId),
    context.textValueFor(boardGameYearFilterId),
    context.identifierCode,
  ]);
}

String? optionalBoardGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
