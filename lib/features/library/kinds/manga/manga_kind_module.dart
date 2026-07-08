import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final mangaKindModule = LibraryKindModule(
  type: mangaLibraryConfig,
  mediaAdapter: mangaMediaAdapter,
  workspaceDtoFactory: MangaWorkspaceDto.fromEntry,
  facets: const LibraryFacetModule(loadRows: _loadCharacterFacetRows),
);

Future<List<Map<String, dynamic>>> _loadCharacterFacetRows(
  LibraryFacetRequest request,
) {
  return request.api.characterFacets(request.itemIds);
}
