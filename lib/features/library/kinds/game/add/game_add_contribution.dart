import '../game_module_dependencies.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import '../config/game_kind_configuration.dart';

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
          id: gamePlatformFilterId,
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
          id: gameYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is GameCatalogMetadata
                ? [
                    item.gameCatalogFields.releaseYear,
                    metadata.releaseDate?.year
                  ]
                : [item.gameCatalogFields.releaseYear];
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

String _buildGameProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(gamePlatformFilterId),
    context.textValueFor(gameYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
