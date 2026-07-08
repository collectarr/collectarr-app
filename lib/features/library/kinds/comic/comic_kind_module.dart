import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart'
    as comic_add;
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

final comicKindModule = LibraryKindModule(
  type: comicsLibraryConfig,
  mediaAdapter: comicsMediaAdapter,
  add: LibraryKindAddModule(registerBuilders: comic_add.registerComicAddBuilders),
  providerMapper: const ComicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(loadRows: _loadComicFacetRows),
);

Future<List<Map<String, dynamic>>> _loadComicFacetRows(
  LibraryFacetRequest request,
) async {
  return request.groupMode == LibraryGroupMode.storyArc
      ? request.api.storyArcFacets(request.itemIds)
      : request.api.characterFacets(request.itemIds);
}
