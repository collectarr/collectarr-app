import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
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

import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_facet_definitions.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';

import 'package:collectarr_app/features/library/kinds/game/stats/game_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';

const _gamePlatformFilterId = LibraryAddFilterId('game.platform');
const _gameYearFilterId = LibraryAddFilterId('game.year');

Iterable<String?> _gameLinkedMetadataValues(GameCatalogMetadata metadata) => [
      metadata.series,
      metadata.country,
      metadata.releaseRegion,
      metadata.publishers.firstOrNull,
      ...metadata.publishers,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final gameLibraryFacetModule = TypedLibraryFacetModule<GameWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: _getGameFacetValues,
  externalFacetBucketIdsByMode: {
    'game.genre': GameFacetIds.genre,
    'game.region': GameFacetIds.region,
  },
);

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
    _gameLinkedMetadataValues,
  ),
  transfer: const LibraryTransferCapability(),
  stats: const GameStatsCapability(),
  add: StandardLibraryAddCapability<GameAddDraft>(
    kind: CatalogMediaKind.game,
    initialDraftBuilder: GameAddDraft.new,
    manualDraftBuilder: GameAddManualDraft.new,
    ownedPayloadBuilder: (item, common, details) => GameOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as GameOwnedDetailsDraft,
      condition: common.condition,
      grade: common.grade,
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
    existingOwnedPayloadBuilder: GameOwnedItemCreatePayload.fromOwnedItem,
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
              final metadata = item.kindMetadata;
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
              final metadata = item.kindMetadata;
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
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    presentation: gameLibraryEditPresentation,
    createDraft: createGameEditDraft,
    ownedDigitalFlagResolver: resolveGameOwnedDigitalFlag,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        GameOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionGradeUpdatePayloadBuilder: (ownedItemId, condition, grade) =>
        GameOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(grade),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, grade, locationId, tags) =>
            GameOwnedItemUpdatePayload.partial(
      condition:
          condition == null ? const Patch.unchanged() : Patch.set(condition),
      grade: grade == null ? const Patch.unchanged() : Patch.set(grade),
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
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) =>
        GameOwnedItemUpdatePayload.partial(
      condition: Patch.set(updated.condition),
      grade: Patch.set(updated.grade),
      personalNotes: Patch.set(updated.personalNotes),
      locationId: Patch.set(updated.locationId),
      tags: Patch.set(updated.tags),
      currency: Patch.set(updated.currency),
      soldTo: Patch.set(updated.soldTo),
      purchaseStore: Patch.set(updated.purchaseStore),
      pricePaidCents: Patch.set(updated.pricePaidCents),
      sellPriceCents: Patch.set(updated.sellPriceCents),
      quantity: Patch.set(updated.quantity),
      indexNumber: Patch.set(updated.indexNumber),
      purchaseDate: Patch.set(updated.purchaseDate),
      soldAt: Patch.set(updated.soldAt),
      details: Patch.set(
        const GameOwnedDetailsCodec().draftFromDetails(
          updated.details as GameOwnedDetails,
        ),
      ),
    ),
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

LibraryMetadataSearchInput _buildGameCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalGameText(
      buildLibraryAddSearchQuery([
        context.query,
        context.textValueFor(_gamePlatformFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(_gameYearFilterId)),
    barcode: _optionalGameText(context.barcode),
    limit: limit,
  );
}

String _buildGameProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_gamePlatformFilterId),
    context.textValueFor(_gameYearFilterId),
    context.barcode,
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
