import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';

final boardGameKindModule = LibraryKindModule(
  type: boardGamesLibraryConfig,
  mediaAdapter: boardGamesMediaAdapter,
  workspaceDtoFactory: BoardGameWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: boardGamesLibraryGroupModeDefinitions,
    sorts: boardGamesLibrarySortColumnDefinitions,
    defaultVisibleColumnIds:
        boardGamesLibraryDefaultVisibleColumns.map((c) => c.toString().split('.').last).toSet(),
    defaultSortId: 'title',
    defaultGroupId: 'series',
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
