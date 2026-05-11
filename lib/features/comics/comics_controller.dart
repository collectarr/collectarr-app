import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final comicsSearchProvider =
    FutureProvider.family<List<CatalogItem>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return const [];
  }
  final api = ref.watch(apiClientProvider);
  final results = await api.search(query, kind: 'comic');
  return results.map(CatalogItem.fromJson).toList();
});
