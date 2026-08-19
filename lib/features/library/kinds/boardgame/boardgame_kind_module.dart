import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';

import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';

final boardGameKindModule =
    LibraryKindSpec<BoardGameWorkspaceDto, BoardgameOwnedDetails>(
  type: boardGamesLibraryConfig,
  mediaAdapter: boardGamesMediaAdapter,
  projector: const BoardGameWorkspaceProjector(),
  ownedDetailsCodec: const BoardgameOwnedDetailsCodec(),
  fields: boardgameLibraryKindSchema.toRegistry(),
  add: const StandardLibraryAddCapability<BoardGameAddDraft>(
    kind: CatalogMediaKind.boardgame,
    initialDraftBuilder: BoardGameAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    boardGamesLibraryConfig,
    createDraft: createGenericEditDraft,
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
