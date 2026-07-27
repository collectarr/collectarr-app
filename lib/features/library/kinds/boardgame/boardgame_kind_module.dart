import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';

import 'package:collectarr_app/features/library/config/owned_details_codec.dart';

final boardGameKindModule = LibraryKindSpec<BoardGameWorkspaceDto, GenericOwnedDetails>(
  type: boardGamesLibraryConfig,
  mediaAdapter: boardGamesMediaAdapter,
  workspaceDtoFactory: BoardGameWorkspaceDto.fromEntry,
  ownedDetailsCodec: const GenericOwnedDetailsCodec(),
  fields: AnyLibraryFieldRegistry(
    groups: boardGamesLibraryGroupDefinitions,
    sorts: boardGamesLibrarySortDefinitions,
    columns: boardGamesLibraryColumnDefinitions,
    defaultVisibleColumnIds: boardGamesLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
