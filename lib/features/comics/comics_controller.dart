import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final comicsSearchProvider =
    FutureProvider.family<List<CatalogItem>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return const [];
  }
  final api = ref.watch(apiClientProvider);
  final results = await api.search(query, kind: 'comic');
  final items = results.map(CatalogItem.fromJson).toList();
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
