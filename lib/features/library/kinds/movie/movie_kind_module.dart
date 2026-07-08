import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart'
    as movie_add;
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final movieKindModule = LibraryKindModule(
  type: moviesLibraryConfig,
  mediaAdapter: collectarrMediaAdapter(moviesLibraryConfig),
  add: LibraryKindAddModule(registerBuilders: movie_add.registerMovieAddBuilders),
  providerMapper: const MovieLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(loadRows: _loadCharacterFacetRows),
);

Future<List<Map<String, dynamic>>> _loadCharacterFacetRows(
  LibraryFacetRequest request,
) {
  return request.api.characterFacets(request.itemIds);
}
