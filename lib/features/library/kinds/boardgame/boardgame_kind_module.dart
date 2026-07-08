import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final boardGameKindModule = LibraryKindModule(
  type: boardGamesLibraryConfig,
  mediaAdapter: boardGamesMediaAdapter,
  workspaceDtoFactory: BoardGameWorkspaceDto.fromEntry,
  facets: const LibraryFacetModule(loadRows: _loadCharacterFacetRows),
);

Future<List<Map<String, dynamic>>> _loadCharacterFacetRows(
  LibraryFacetRequest request,
) {
  return request.api.characterFacets(request.itemIds);
}
