import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final mangaKindModule = LibraryKindModule(
  type: mangaLibraryConfig,
  mediaAdapter: mangaMediaAdapter,
  facets: const LibraryFacetModule(loadRows: _loadCharacterFacetRows),
);

Future<List<Map<String, dynamic>>> _loadCharacterFacetRows(
  LibraryFacetRequest request,
) {
  return request.api.characterFacets(request.itemIds);
}
