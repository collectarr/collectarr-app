import 'search_controls.dart';
import '../game_hardware_module_dependencies.dart';

final gameHardwareKindAdd = StandardLibraryAddCapability<GameHardwareAddDraft>(
    kind: CatalogMediaKind.gameHardware,
    initialDraftBuilder: GameHardwareAddDraft.new,
    coreCatalogProjectionBuilder: gameHardwareCatalogTransportFromCoreItem,
    manualDraftBuilder: GameHardwareAddManualDraft.new,
    manualCandidateBuilder: buildGameHardwareManualCandidate,
    manualProposalBuilder: buildGameHardwareManualProposalData,
    manualPaneBuilder: buildGameHardwareAddManualPane,
    chrome: const LibraryAddChromeConfig(supportsTracking: false),
    search: LibraryAddSearchCapability(
        input: LibraryAddSearchInputCapability(
            initialAdvancedFilters: gameHardwareInitialSearchFilters,
            searchInputPredicate: gameHardwareHasSearchInput),
        core: LibraryAddCoreSearchCapability(
            ranking: buildLibraryAddSearchRanking(fields: const []),
            inputBuilder: gameHardwareCoreSearchInput),
        presentation: LibraryAddSearchPresentationCapability(
            queryTrailingBuilder: buildGameHardwareAddPlatformControl,
            controlsBuilder: buildGameHardwareAddTypeControls)),
    entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
        GameHardwareLibraryEntryCreatePayload(
            details: details as GameHardwareEntryDetailsDraft,
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
