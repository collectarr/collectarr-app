import '../game_toy_module_dependencies.dart';

final gameToyKindAdd = StandardLibraryAddCapability<GameToyAddDraft>(
    kind: CatalogMediaKind.gameToy,
    initialDraftBuilder: GameToyAddDraft.new,
    coreCatalogProjectionBuilder: gameToyCatalogTransportFromCoreItem,
    manualDraftBuilder: GameToyAddManualDraft.new,
    manualCandidateBuilder: buildGameToyManualCandidate,
    manualProposalBuilder: buildGameToyManualProposalData,
    manualPaneBuilder: buildGameToyAddManualPane,
    chrome: const LibraryAddChromeConfig(supportsTracking: false),
    search: LibraryAddSearchCapability(
        input: const LibraryAddSearchInputCapability(),
        core: LibraryAddCoreSearchCapability(
            ranking: buildLibraryAddSearchRanking(fields: const []),
            inputBuilder: (context, {required limit}) => MetadataSearchQuery(
                query:
                    context.query.trim().isEmpty ? null : context.query.trim(),
                barcode: context.identifierCode.trim().isEmpty
                    ? null
                    : context.identifierCode.trim(),
                limit: limit))),
    entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
        GameToyLibraryEntryCreatePayload(
            details: details as GameToyEntryDetailsDraft,
            condition: common.condition,
            grade: kindValue ?? draft.grade,
            purchaseDate: common.purchaseDate,
            pricePaidCents: common.pricePaidCents,
            currency: common.currency,
            personalNotes: common.personalNotes,
            tags: common.tags ?? const [],
            locationId: common.locationId,
            purchaseStore: common.purchaseStore,
            ownerLabel: common.ownerLabel,
            collectionStatus: common.collectionStatus,
            isDigital: false,
            quantity: draft.quantity,
            indexNumber: draft.indexNumber,
            rating: draft.rating,
            marketValueCents: draft.marketValueCents,
            purchaseDateParts: draft.purchaseDateParts));
