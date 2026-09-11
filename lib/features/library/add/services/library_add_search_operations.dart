import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';

class LibraryAddCoreSearchResult {
  const LibraryAddCoreSearchResult({
    required this.items,
    required this.shouldSearchProvider,
  });

  final List<CatalogSearchCandidate> items;
  final bool shouldSearchProvider;
}

class LibraryAddProviderSearchDebounceDecision {
  const LibraryAddProviderSearchDebounceDecision({
    required this.shouldSkip,
    required this.signature,
    required this.at,
  });

  final bool shouldSkip;
  final String signature;
  final DateTime at;
}

LibraryAddProviderSearchDebounceDecision
    evaluateLibraryAddProviderSearchDebounce({
  required String provider,
  required String query,
  required Duration debounce,
  required DateTime now,
  String? previousSignature,
  DateTime? previousAt,
}) {
  final signature = '$provider|${query.trim().toLowerCase()}';
  final shouldSkip = previousSignature == signature &&
      previousAt != null &&
      now.difference(previousAt) < debounce;
  return LibraryAddProviderSearchDebounceDecision(
    shouldSkip: shouldSkip,
    signature: signature,
    at: now,
  );
}

Future<LibraryAddCoreSearchResult> runLibraryAddCoreSearch({
  required ApiClient api,
  required LibraryKindModule type,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
  required Duration timeout,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  required bool providerSearchAvailable,
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    kind: type.kind,
    catalog: catalog,
    input: input,
  ).timeout(timeout);
  final rankedItems = ranking.rankMetadata(
    [
      for (final item in items)
        CatalogSearchCandidate.fromSnapshot(item.toImportSnapshot()),
    ],
    searchContext,
  );
  return LibraryAddCoreSearchResult(
    items: rankedItems,
    shouldSearchProvider: providerSearchAvailable &&
        ranking.shouldSearchProviderForCoreResults(rankedItems, searchContext),
  );
}

Future<List<CatalogSearchCandidate>> fetchLibraryAddSuggestions({
  required ApiClient api,
  required LibraryKindModule type,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    kind: type.kind,
    catalog: catalog,
    input: input,
  ).timeout(timeout);
  return filterAndRankCatalogItems(
    [
      for (final item in items)
        CatalogSearchCandidate.fromSnapshot(item.toImportSnapshot()),
    ],
    ranking,
    searchContext,
  );
}

Future<LibraryAddCoreSearchResult> runLibraryAddIdentifierLookup({
  required ApiClient api,
  required LibraryKindModule type,
  required CatalogTransportRepository catalog,
  required String identifierCode,
  required Duration timeout,
  required bool providerSearchAvailable,
}) async {
  final results = await lookupAndCacheLibraryBarcodes(
    api: api,
    kind: type.kind,
    catalog: catalog,
    codes: [identifierCode],
  ).timeout(timeout);
  final foundItems = <CatalogSearchCandidate>[
    for (final result in results)
      if (result.item != null)
        CatalogSearchCandidate.fromSnapshot(result.item!.toImportSnapshot()),
  ];
  return LibraryAddCoreSearchResult(
    items: foundItems,
    shouldSearchProvider: foundItems.isEmpty && providerSearchAvailable,
  );
}

Future<List<ProviderCandidate>> runLibraryAddProviderSearch({
  ApiClient? api,
  required LibraryKindModule type,
  required String provider,
  required String query,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  ProviderConnectorRegistry? providerRegistry,
  LibraryAddVideoSearchScope? kindOverride,
}) async {
  final targetKind =
      kindOverride == null ? type.kind : kindOverride.catalogKind;
  final normalizedProvider =
      provider.trim().isEmpty ? null : provider.trim().toLowerCase();
  final effectiveQuery = query.trim();

  List<ProviderCandidate> candidates = [];

  if (providerRegistry != null && effectiveQuery.isNotEmpty) {
    if (normalizedProvider != null && normalizedProvider != 'all') {
      final p = providerRegistry.get(normalizedProvider);
      if (p != null) {
        try {
          candidates = await type.add.search.searchProvider(
            p,
            query: effectiveQuery,
            kind: targetKind,
          );
        } catch (_) {
          candidates = const [];
        }
      }
    } else {
      final providers = providerRegistry.getForKind(targetKind);
      final futures = providers.map((p) async {
        try {
          return await type.add.search.searchProvider(
            p,
            query: effectiveQuery,
            kind: targetKind,
          );
        } catch (_) {
          // A broken provider must NOT destroy the rest of the search!
          return const <ProviderCandidate>[];
        }
      });
      final lists = await Future.wait(futures);
      candidates = lists.expand((l) => l).toList();
    }
  }

  return ranking.rankProvider(candidates, searchContext);
}
