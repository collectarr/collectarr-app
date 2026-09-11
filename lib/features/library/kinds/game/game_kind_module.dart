import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/game/inspector_panel.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_facet_definitions.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';

import 'package:collectarr_app/features/library/kinds/game/stats/game_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_provider_candidate_projection.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';

const _gamePlatformFilterId = LibraryAddFilterId('game.platform');
const _gameYearFilterId = LibraryAddFilterId('game.year');

TransferableField _gameTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(GameOwnedItem item) read,
  required GameOwnedItem Function(GameOwnedItem item, String? value) write,
  LibraryEditScope scope = LibraryEditScope.all,
}) {
  return TransferableField.typed<GameOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as GameOwnedItem,
    read: read,
    write: write,
  );
}

final _gameUniversalTransferableFields =
    TransferableField.universalForTyped<GameOwnedItem>(
  decode: (value) => value as GameOwnedItem,
  readCondition: (item) => item.condition,
  writeCondition: (item, value) => item.copyWith(condition: value),
  readPersonalNotes: (item) => item.personalNotes,
  writePersonalNotes: (item, value) => item.copyWith(personalNotes: value),
  readLocationId: (item) => item.locationId,
  writeLocationId: (item, value) => item.copyWith(locationId: value),
  readTags: (item) => item.tags,
  writeTags: (item, value) => item.copyWith(tags: value),
  readCurrency: (item) => item.currency,
  writeCurrency: (item, value) => item.copyWith(currency: value),
  readSoldTo: (item) => item.soldTo,
  writeSoldTo: (item, value) => item.copyWith(soldTo: value),
  readPurchaseStore: (item) => item.purchaseStore,
  writePurchaseStore: (item, value) => item.copyWith(purchaseStore: value),
  readPricePaidCents: (item) => item.pricePaidCents?.toString(),
  writePricePaidCents: (item, value) => item.copyWith(
    pricePaidCents: value == null ? null : int.tryParse(value),
  ),
  readSellPriceCents: (item) => item.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
    sellPriceCents: value == null ? null : int.tryParse(value),
  ),
  readQuantity: (item) => item.quantity.toString(),
  writeQuantity: (item, value) => item.copyWith(
    quantity: value == null ? 1 : int.tryParse(value) ?? 1,
  ),
  readIndexNumber: (item) => item.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
    indexNumber: value == null ? null : int.tryParse(value),
  ),
  readPurchaseDate: (item) => item.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
    purchaseDate: value == null ? null : DateTime.tryParse(value),
  ),
  readSoldAt: (item) => item.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
    soldAt: value == null ? null : DateTime.tryParse(value),
  ),
);

final _gameTransferableFields = <TransferableField>[
  _gameTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
];

Iterable<String?> _gameLinkedMetadataValues(GameCatalogMetadata metadata) => [
      metadata.series,
      metadata.country,
      metadata.releaseRegion,
      metadata.publishers.firstOrNull,
      ...metadata.publishers,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

GameCatalogMetadata? _gameLinkedMetadata(LibraryWorkspaceSource source) {
  final metadata = source.catalogTransport?.toTransportItem().kindMetadata;
  return metadata is GameCatalogMetadata ? metadata : null;
}

MetadataSearchQuery _gameMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final item = source.catalogTransport;
  return MetadataSearchQuery(
    query: title,
    barcode: item?.toTransportItem().identifierCode,
    publisher: item?.toTransportItem().publisher,
    year: item?.releaseYear,
    limit: 5,
  );
}

final gameLibraryFacetModule = TypedLibraryFacetModule<GameWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: _getGameFacetValues,
  externalFacetBucketIdsByMode: {
    'game.genre': GameFacetIds.genre,
    'game.region': GameFacetIds.region,
  },
);

GameOwnedItem _gameTransferOwnedItem(Object value) {
  if (value is GameOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected GameOwnedItem');
}

final gameKindModule = LibraryKindSpec<GameWorkspaceDto>(
  presentation: gamesLibraryMediaPresentation,
  physicalMediaFormats: gamePhysicalMediaFormats,
  trackingProfile: gameTrackingProfile,
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.game,
    singularLabel: 'Game',
    pluralLabel: 'Games',
    title: 'Games',
    icon: Icons.sports_esports,
    accent: Color(0xFFF64458),
    preferencePrefix: 'games',
    routeSegments: ['games', 'game'],
    mediaFamily: 'game',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'igdb',
    searchQueryBuilder: _gameMetadataSearchQuery,
    providers: [igdbMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
    supportsMediaReleaseSplit: true,
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildGameInspectorSections,
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<GameCatalogMetadata>(
    _gameLinkedMetadata,
    _gameLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _gameTransferableFields) field.key,
    ],
    kindFields: [
      ..._gameUniversalTransferableFields,
      ..._gameTransferableFields,
    ],
  ),
  stats: const GameStatsCapability(),
  add: StandardLibraryAddCapability<GameAddDraft>(
    kind: CatalogMediaKind.game,
    initialDraftBuilder: GameAddDraft.new,
    providerCandidateProjectionBuilder:
        gameCatalogTransportFromProviderCandidate,
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
      final payload = item.toTransportItem().payload;
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
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _gamePlatformFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata = item.toTransportItem().kindMetadata;
              return metadata is GameCatalogMetadata
                  ? [metadata.platform, ...metadata.platforms]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.summary],
          ),
          LibraryAddSearchRankField(
            id: _gameYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.toTransportItem().kindMetadata;
              return metadata is GameCatalogMetadata
                  ? [item.releaseYear, metadata.releaseDate?.year]
                  : [item.releaseYear];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildGameAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildGameLibraryEditDialog,
    mediaEditDialogBuilder: buildGameMediaLibraryEditDialog,
    releaseEditDialogBuilder: buildGameReleaseLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(GameVocabularies.all),
    conditions: GameVocabularies.condition.builtIns,
    ownedCollectionValueReader: (ownedItem) => ownedItem?.collectionValue,
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    presentation: gameLibraryEditPresentation,
    createDraft: createGameEditDraft,
    ownedDigitalFlagResolver: resolveGameOwnedDigitalFlag,
    ownedFormatHintResolver: resolveGameOwnedFormatHint,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        GameOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue) =>
            GameOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue, locationId, tags) =>
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
      ownedItemId,
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
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) {
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
  ),
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

final gameKindWorkspace = TypedLibraryKindWorkspace<GameWorkspaceDto>(
  fields: gameLibraryKindSchema.toRegistry(),
  projector: const GameWorkspaceProjector(),
  hierarchy: gameKindModule.hierarchy,
);
