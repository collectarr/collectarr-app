import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final comicsSearchProvider =
    FutureProvider.family<List<CatalogItem>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return const [];
  }
  final api = ref.watch(apiClientProvider);
  final libraryType = ref.watch(
    resolvedLibraryTypeProvider(comicsLibraryConfig),
  );
  final items = await searchLibraryMetadata(
    api,
    libraryType,
    query: query,
  );
  await CatalogCacheRepository(ref.watch(localDatabaseProvider))
      .upsertAll(items);
  return items;
});

final comicDetailProvider =
    FutureProvider.family<ComicDetail, String>((ref, itemId) async {
  final api = ref.watch(apiClientProvider);
  final result = await api.getComic(itemId);
  return ComicDetail.fromJson(result);
});
