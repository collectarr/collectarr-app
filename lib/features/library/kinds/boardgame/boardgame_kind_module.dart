import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
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
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/stats/boardgame_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_profile.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

const _boardGameDesignerFilterId = LibraryAddFilterId('boardgame.designer');
const _boardGamePublisherFilterId = LibraryAddFilterId('boardgame.publisher');
const _boardGameYearFilterId = LibraryAddFilterId('boardgame.year');

final _boardgameTransferableFields = <TransferableField>[
  TransferableField(
    key: 'isSleeved',
    label: 'Sleeved',
    icon: Icons.shield_outlined,
    type: TransferableFieldType.boolean,
    read: (item) =>
        ((item.details as BoardgameOwnedDetails?)?.isSleeved == true)
            ? 'true'
            : null,
    write: (item, value) {
      final details = item.details as BoardgameOwnedDetails? ??
          const BoardgameOwnedDetails();
      return item.copyWith(
          details: details.copyWith(isSleeved: value == 'true'));
    },
  ),
  TransferableField(
    key: 'hasCustomInsert',
    label: 'Custom insert',
    icon: Icons.grid_view_outlined,
    type: TransferableFieldType.boolean,
    read: (item) =>
        ((item.details as BoardgameOwnedDetails?)?.hasCustomInsert == true)
            ? 'true'
            : null,
    write: (item, value) {
      final details = item.details as BoardgameOwnedDetails? ??
          const BoardgameOwnedDetails();
      return item.copyWith(
        details: details.copyWith(hasCustomInsert: value == 'true'),
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

final boardGameKindModule =
    LibraryKindSpec<BoardGameWorkspaceDto, BoardgameOwnedDetails>(
  presentation: boardGamesLibraryMediaPresentation,
  trackingProfile: boardGameTrackingProfile,
  projector: const BoardGameWorkspaceProjector(),
  ownedDetailsCodec: const BoardgameOwnedDetailsCodec(),
  fields: boardgameLibraryKindSchema.toRegistry(),
  catalogMetadataDecoder: BoardGameMetadata.fromJson,
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.boardgame,
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    title: 'Board Games',
    icon: Icons.casino_outlined,
    accent: Color(0xFFE0A52B),
    preferencePrefix: 'boardgames',
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
    kindFields: _boardgameTransferableFields,
  ),
  add: StandardLibraryAddCapability<BoardgameAddDraft>(
    kind: CatalogMediaKind.boardgame,
    initialDraftBuilder: BoardgameAddDraft.new,
    manualDraftBuilder: BoardgameAddManualDraft.new,
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
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    createDraft: createBoardGameEditDraft,
  ),
  providerMapper: const BoardGameLibraryKindProviderMapper(),
  stats: const BoardGameStatsCapability(),
  facets: LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getBoardGameFacetValues,
    definitions: boardgameLibraryFacetDefinitions,
  ),
);

Iterable<String> _getBoardGameFacetValues(
  LibraryProjectionRuntime item,
  LibraryFacetIdRuntime facetId,
) {
  final dto = item.dto;
  if (dto is! BoardGameWorkspaceDto) {
    return const [];
  }
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

LibraryMetadataSearchInput _buildBoardGameCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalBoardGameText(context.query),
    publisher: _optionalBoardGameText(
        context.textValueFor(_boardGamePublisherFilterId)),
    year: int.tryParse(context.textValueFor(_boardGameYearFilterId)),
    barcode: _optionalBoardGameText(context.barcode),
    limit: limit,
  );
}

String _buildBoardGameProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_boardGameDesignerFilterId),
    context.textValueFor(_boardGamePublisherFilterId),
    context.textValueFor(_boardGameYearFilterId),
    context.barcode,
  ]);
}

String? _optionalBoardGameText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
