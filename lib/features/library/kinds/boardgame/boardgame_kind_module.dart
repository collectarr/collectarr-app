import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final boardGameKindModule =
    LibraryKindSpec<BoardGameWorkspaceDto, BoardgameOwnedDetails>(
  type: boardGamesLibraryConfig,
  mediaAdapter: boardGamesMediaAdapter,
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
    supportsSeriesSubgroups: true,
    supportsMediaReleaseSplit: false,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  transfer: const LibraryTransferCapability(),
  add: const StandardLibraryAddCapability<BoardGameAddDraft>(
    kind: CatalogMediaKind.boardgame,
    initialDraftBuilder: BoardGameAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    boardGamesLibraryConfig,
    createDraft: createBoardGameEditDraft,
  ),
  providerMapper: const BoardGameLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);

Map<String, dynamic> _encodeBoardGameMetadata(BoardGameMetadata m) =>
    m.toJson();

