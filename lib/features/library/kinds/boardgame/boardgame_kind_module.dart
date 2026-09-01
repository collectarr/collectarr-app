import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';

const _boardGameDesignerFilterId = LibraryAddFilterId('boardgame.designer');
const _boardGamePublisherFilterId = LibraryAddFilterId('boardgame.publisher');
const _boardGameYearFilterId = LibraryAddFilterId('boardgame.year');

final boardGameKindModule =
    LibraryKindSpec<BoardGameWorkspaceDto, BoardgameOwnedDetails>(
  type: boardGamesLibraryConfig,
  projector: const BoardGameWorkspaceProjector(),
  ownedDetailsCodec: const BoardgameOwnedDetailsCodec(),
  fields: boardgameLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<BoardGameMetadata>(
    BoardGameMetadata.fromJson,
    _encodeBoardGameMetadata,
  ),
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
    contentHierarchy: LibraryContentHierarchy.flat,
    supportsMediaReleaseSplit: false,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  transfer: LibraryTransferCapability(
    kindFields: boardgameTransferableFields,
  ),
  add: StandardLibraryAddCapability<BoardgameAddDraft>(
    kind: CatalogMediaKind.boardgame,
    initialDraftBuilder: BoardgameAddDraft.new,
    manualDraftBuilder: BoardgameAddManualDraft.new,
    search: LibraryAddSearchCapability(
      advancedFilterFieldsBuilder: buildBoardGameAddAdvancedFilterFields,
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
                  ? [item.releaseYear, metadata.yearPublished]
                  : [item.releaseYear];
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
    vocabularies: StandardKindVocabularyCapability(BoardGameVocabularies.all),
    presentation: boardGamesLibraryEditPresentation,
    mediaFields: const MediaEditFields(
      numberLabel: 'Edition',
      publisherLabel: 'Publisher / Designer',
      releaseDateLabel: 'Release date',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Expansion / Edition',
      barcodeLabel: 'Barcode',
    ),
    createDraft: createBoardGameEditDraft,
  ),
  providerMapper: const BoardGameLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);

Map<String, dynamic> _encodeBoardGameMetadata(BoardGameMetadata m) =>
    m.toJson();

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
