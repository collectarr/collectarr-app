import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:dio/dio.dart';

class LibraryAddCoreSearchResult {
  const LibraryAddCoreSearchResult({
    required this.items,
    required this.rawItemCount,
    this.nextOffset,
    this.hasMore = false,
  });

  final List<CatalogSearchCandidate> items;
  final int rawItemCount;
  final int? nextOffset;
  final bool hasMore;
}

Future<LibraryAddCoreSearchResult> runLibraryAddCoreSearch({
  required ApiClient api,
  required LibraryKindRegistration type,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
  required Duration timeout,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  CancelToken? cancelToken,
}) async {
  final page = await searchAndCacheLibraryMetadataPage(
    api: api,
    kind: type.kind,
    catalog: catalog,
    input: input,
    cancelToken: cancelToken,
  ).timeout(timeout);
  final rankedItems = ranking.rankMetadata(
    page.items,
    searchContext,
  );
  final filteredItems = libraryAddForKind(type.kind)
      .search
      .core
      .filterResults(rankedItems, searchContext);
  return LibraryAddCoreSearchResult(
    items: filteredItems,
    rawItemCount: page.items.length,
    nextOffset: page.nextOffset,
    hasMore: page.hasMore,
  );
}

Future<List<CatalogSearchCandidate>> fetchLibraryAddSuggestions({
  required ApiClient api,
  required LibraryKindRegistration type,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  CancelToken? cancelToken,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    kind: type.kind,
    catalog: catalog,
    input: input,
    cancelToken: cancelToken,
  ).timeout(timeout);
  final ranked = filterAndRankCatalogItems(
    items,
    ranking,
    searchContext,
  );
  return libraryAddForKind(type.kind)
      .search
      .core
      .filterResults(ranked, searchContext);
}

Future<LibraryAddCoreSearchResult> runLibraryAddIdentifierLookup({
  required ApiClient api,
  required LibraryKindRegistration type,
  required CatalogTransportRepository catalog,
  required String identifierCode,
  required Duration timeout,
  CancelToken? cancelToken,
}) async {
  final results = await lookupAndCacheLibraryBarcodes(
    api: api,
    kind: type.kind,
    catalog: catalog,
    codes: [identifierCode],
    cancelToken: cancelToken,
  ).timeout(timeout);
  final foundItems = <CatalogSearchCandidate>[
    for (final result in results)
      if (result.item != null) result.item!,
  ];
  return LibraryAddCoreSearchResult(
    items: foundItems,
    rawItemCount: foundItems.length,
  );
}
