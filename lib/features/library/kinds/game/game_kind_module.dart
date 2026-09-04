import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
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
import 'package:collectarr_app/features/library/generic/projection_item.dart';

import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
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

final gameKindModule = LibraryKindSpec<GameWorkspaceDto, GameOwnedDetails>(
  presentation: gamesLibraryMediaPresentation,
  trackingProfile: gameTrackingProfile,
  projector: const GameWorkspaceProjector(),
  ownedDetailsCodec: const GameOwnedDetailsCodec(),
  fields: gameLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<GameCatalogMetadata>(
    GameCatalogMetadata.fromJson,
    _encodeGameMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.game,
    singularLabel: 'Game',
    pluralLabel: 'Games',
    title: 'Games',
    icon: Icons.sports_esports,
    accent: Color(0xFFF64458),
    preferencePrefix: 'games',
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
    presentation: gameLibraryEditPresentation,
    createDraft: createGameEditDraft,
  ),
  providerMapper: const GameLibraryKindProviderMapper(),
  facets: LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getGameFacetValues,
    definitions: gameLibraryFacetDefinitions,
    externalFacetBucketIdsByMode: {
      'game.genre': GameFacetIds.genre,
      'game.region': GameFacetIds.region,
    },
  ),
  buildCardPresentation: buildGameCardPresentation,
);

Map<String, dynamic> _encodeGameMetadata(GameCatalogMetadata m) => m.toJson();

Iterable<String> _getGameFacetValues(
  LibraryProjectionRuntime item,
  LibraryFacetIdRuntime facetId,
) {
  final dto = item.dto;
  if (dto is! GameWorkspaceDto) {
    return const [];
  }
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
