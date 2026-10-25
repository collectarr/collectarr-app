import 'package:collectarr_app/ui/app_icons.dart';
import '../game_module_dependencies.dart';
import 'game_add_preview.dart';
import 'game_add_result_grouping.dart';
import 'game_add_search_controls.dart';
import 'game_manual_candidate.dart';

final gameKindAdd = StandardLibraryAddCapability<GameAddDraft>(
  kind: CatalogMediaKind.game,
  initialDraftBuilder: GameAddDraft.new,
  coreCatalogProjectionBuilder: gameCatalogTransportFromCoreItem,
  manualDraftBuilder: GameAddManualDraft.new,
  manualCandidateBuilder: buildGameManualCandidate,
  manualProposalBuilder: buildGameManualProposalData,
  entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      GameLibraryEntryCreatePayload(
    details: details as GameEntryDetailsDraft,
    condition:
        (common.condition?.trim().isEmpty ?? true) ? null : common.condition,
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
    isDigital: common.isDigital,
    quantity: draft.quantity,
    indexNumber: draft.indexNumber,
    rating: draft.rating,
    marketValueCents: draft.marketValueCents,
    purchaseDateParts: draft.purchaseDateParts,
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
    input: const LibraryAddSearchInputCapability(
      codeSearchTab: LibraryAddCodeSearchTab(
        label: 'Platform',
        hintText: 'Filter games...',
        icon: AppIcons.viewList,
      ),
      searchInputPredicate: _gameAddHasSearchInput,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: _buildGameCoreSearchInput,
      resultFilter: (items, context) => [
        for (final item in items)
          if (gameAddCandidateMatchesPlatform(item, context)) item,
      ],
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: gameAddPlatformFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) => item.kindCapability
                .mapTransport(
                  (transport) =>
                      GameCatalogMetadata.fromJson(transport.kindData),
                )
                .platforms,
          ),
        ],
      ),
    ),
    presentation: LibraryAddSearchPresentationCapability(
      queryTrailingBuilder: buildGameAddPlatformControl,
    ),
  ),
  manualPaneBuilder: buildGameAddManualPane,
  previewPaneBuilder: buildGameAddPreview,
  chrome: const LibraryAddChromeConfig(confirmSheetSize: Size(730, 369)),
  resultPolicy: LibraryAddResultPolicy(grouping: gameAddResultGrouping),
);

bool _gameAddHasSearchInput(LibraryAddSearchContext context) =>
    context.query.trim().isNotEmpty ||
    context.identifierCode.trim().isNotEmpty ||
    context.codeQuery.trim().isNotEmpty;

MetadataSearchQuery _buildGameCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalGameText(
      buildLibraryAddSearchQuery([context.query, context.codeQuery]),
    ),
    barcode: _optionalGameText(context.identifierCode),
    limit: limit,
  );
}

String? _optionalGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
