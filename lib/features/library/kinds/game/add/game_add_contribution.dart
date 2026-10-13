import '../game_module_dependencies.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import '../config/game_kind_configuration.dart';
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
    condition: common.condition,
    grade: kindValue ?? draft.grade,
    purchaseDate: common.purchaseDate,
    pricePaidCents: common.pricePaidCents,
    currency: common.currency,
    personalNotes: common.personalNotes,
    tags: common.tags,
    locationId: common.locationId,
    purchaseStore: common.purchaseStore,
    ownerLabel: common.ownerLabel,
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
    input: LibraryAddSearchInputCapability(
      advancedFilterDescriptorsBuilder: buildGameAddAdvancedFilterFields,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: _buildGameCoreSearchInput,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: gamePlatformFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                (transport) => GameCatalogMetadata.fromJson(transport.kindData),
              );
              return metadata.platforms;
            },
          ),
          LibraryAddSearchRankField(
            id: gameYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                (transport) => GameCatalogMetadata.fromJson(transport.kindData),
              );
              return [
                item.gameCatalogFields.releaseYear,
                metadata.releaseDate?.year,
              ];
            },
          ),
        ],
      ),
    ),
  ),
  manualPaneBuilder: buildGameAddManualPane,
);

List<LibraryAddAdvancedFilterField<String>> buildGameAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: gamePlatformFilterId,
        key: const ValueKey('library-add-platform-field'),
        label: 'Platform',
        value: req.advancedFilterText(gamePlatformFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: gameYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(gameYearFilterId),
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
        context.textValueFor(gamePlatformFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(gameYearFilterId)),
    barcode: _optionalGameText(context.identifierCode),
    limit: limit,
  );
}

String? _optionalGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
