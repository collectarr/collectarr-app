import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/stats/boardgame_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_profile.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

const _boardGameDesignerFilterId = LibraryAddFilterId('boardgame.designer');
const _boardGamePublisherFilterId = LibraryAddFilterId('boardgame.publisher');
const _boardGameYearFilterId = LibraryAddFilterId('boardgame.year');

TransferableField _boardGameTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(BoardGameOwnedItem item) read,
  required BoardGameOwnedItem Function(
    BoardGameOwnedItem item,
    String? value,
  ) write,
  LibraryEditScope scope = LibraryEditScope.all,
}) {
  return TransferableField.typed<BoardGameOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as BoardGameOwnedItem,
    read: read,
    write: write,
  );
}

final _boardgameUniversalTransferableFields =
    TransferableField.universalForTyped<BoardGameOwnedItem>(
  decode: (value) => value as BoardGameOwnedItem,
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

final _boardgameTransferableFields = <TransferableField>[
  _boardGameTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  _boardGameTransferField(
    key: 'isSleeved',
    label: 'Sleeved',
    icon: Icons.shield_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => item.details.isSleeved ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
          details: item.details.copyWith(isSleeved: value == 'true'));
    },
  ),
  _boardGameTransferField(
    key: 'hasCustomInsert',
    label: 'Custom insert',
    icon: Icons.grid_view_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => item.details.hasCustomInsert ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(hasCustomInsert: value == 'true'),
      );
    },
  ),
];

Iterable<String?> _boardGameLinkedMetadataValues(
  BoardGameMetadata metadata,
) =>
    [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      ...metadata.publishers,
      metadata.variant,
      ...metadata.languages,
      ...metadata.categories,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
    ];

final boardGameLibraryFacetModule =
    TypedLibraryFacetModule<BoardGameWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: _getBoardGameFacetValues,
);

BoardGameOwnedItem _boardGameTransferOwnedItem(Object value) {
  if (value is BoardGameOwnedItem) return value;
  if (value is OwnedItem) {
    return BoardGameOwnedItem.fromJson(
      Map<String, dynamic>.from(value.toJson()),
    );
  }
  throw ArgumentError.value(value, 'updated', 'Expected BoardGameOwnedItem');
}

final boardGameKindModule = LibraryKindSpec<BoardGameWorkspaceDto>(
  presentation: boardGamesLibraryMediaPresentation,
  physicalMediaFormats: boardGamePhysicalMediaFormats,
  trackingProfile: boardGameTrackingProfile,
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.boardgame,
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    title: 'Board Games',
    icon: Icons.casino_outlined,
    accent: Color(0xFFE0A52B),
    preferencePrefix: 'boardgames',
    routeSegments: ['board-games', 'boardgames', 'boardgame'],
    mediaFamily: 'game',
    normalizeCatalogLabels: true,
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'bgg',
    providers: [bggMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
    supportsMediaReleaseSplit: false,
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildBoardGameInspectorSections,
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<BoardGameMetadata>(
    _boardGameLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _boardgameTransferableFields) field.key,
    ],
    kindFields: [
      ..._boardgameUniversalTransferableFields,
      ..._boardgameTransferableFields,
    ],
  ),
  add: StandardLibraryAddCapability<BoardgameAddDraft>(
    kind: CatalogMediaKind.boardgame,
    initialDraftBuilder: BoardgameAddDraft.new,
    manualDraftBuilder: BoardgameAddManualDraft.new,
    ownedPayloadBuilder: (item, common, draft, details) =>
        BoardgameOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as BoardgameOwnedDetailsDraft,
      condition: common.condition,
      grade: common.collectionValue ?? draft.grade,
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
    search: LibraryAddSearchCapability(
      advancedFilterDescriptorsBuilder: buildBoardGameAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildBoardGameCoreSearchInput,
      providerQueryBuilder: _buildBoardGameProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _boardGameDesignerFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BoardGameMetadata
                  ? [...metadata.designers, ...metadata.artists]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.summary],
          ),
          LibraryAddSearchRankField(
            id: _boardGamePublisherFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BoardGameMetadata
                  ? [...metadata.publishers, metadata.publisher]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _boardGameYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BoardGameMetadata
                  ? [metadata.yearPublished]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildBoardgameAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildBoardGameLibraryEditDialog,
    mediaEditDialogBuilder: buildBoardGameMediaLibraryEditDialog,
    releaseEditDialogBuilder: buildBoardGameReleaseLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(BoardGameVocabularies.all),
    presentation: boardGamesLibraryEditPresentation,
    conditions: BoardGameVocabularies.condition.builtIns,
    ownedCollectionValueReader: (ownedItem) => ownedItem?.collectionValue,
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    createDraft: createBoardGameEditDraft,
    ownedDigitalFlagResolver: resolveBoardGameOwnedDigitalFlag,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        BoardgameOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue) =>
            BoardgameOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue, locationId, tags) =>
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
      ownedItemId,
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
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) {
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
  ),
  stats: const BoardGameStatsCapability(),
);

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

final boardGameKindWorkspace = TypedLibraryKindWorkspace<BoardGameWorkspaceDto>(
  fields: boardgameLibraryKindSchema.toRegistry(),
  projector: const BoardGameWorkspaceProjector(),
  hierarchy: boardGameKindModule.hierarchy,
);
