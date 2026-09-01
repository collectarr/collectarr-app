import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';

class LibraryAddCoreSearchResult {
  const LibraryAddCoreSearchResult({
    required this.items,
    required this.shouldSearchProvider,
  });

  final List<LibraryMetadataItem> items;
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
  required LibraryKindRuntime type,
  required CatalogCacheRepository catalog,
  required LibraryMetadataSearchInput input,
  required Duration timeout,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  required bool providerSearchAvailable,
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    type: type,
    catalog: catalog,
    input: input,
  ).timeout(timeout);
  final rankedItems = ranking.rankMetadata(items, searchContext);
  return LibraryAddCoreSearchResult(
    items: rankedItems,
    shouldSearchProvider: providerSearchAvailable &&
        ranking.shouldSearchProviderForCoreResults(rankedItems, searchContext),
  );
}

Future<List<LibraryMetadataItem>> fetchLibraryAddSuggestions({
  required ApiClient api,
  required LibraryKindRuntime type,
  required CatalogCacheRepository catalog,
  required LibraryMetadataSearchInput input,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    type: type,
    catalog: catalog,
    input: input,
  ).timeout(timeout);
  return filterAndRankLibraryMetadataItems(
    items,
    ranking,
    searchContext,
  );
}

Future<LibraryAddCoreSearchResult> runLibraryAddBarcodeLookup({
  required ApiClient api,
  required LibraryKindRuntime type,
  required CatalogCacheRepository catalog,
  required String barcode,
  required Duration timeout,
  required bool providerSearchAvailable,
}) async {
  final results = await lookupAndCacheLibraryBarcodes(
    api: api,
    type: type,
    catalog: catalog,
    barcodes: [barcode],
  ).timeout(timeout);
  final foundItems = [
    for (final result in results)
      if (result.item != null) result.item!,
  ];
  return LibraryAddCoreSearchResult(
    items: foundItems,
    shouldSearchProvider: foundItems.isEmpty && providerSearchAvailable,
  );
}

Future<List<ProviderCandidate>> runLibraryAddProviderSearch({
  ApiClient? api,
  required LibraryKindRuntime type,
  required String provider,
  required String query,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  ProviderRegistry? providerRegistry,
  String? kindOverride,
}) async {
  final targetKind = kindOverride ?? type.kind.apiValue;
  final normalizedProvider =
      provider.trim().isEmpty ? null : provider.trim().toLowerCase();
  final effectiveQuery = query.trim();

  List<ProviderCandidate> candidates = [];

  if (providerRegistry != null && effectiveQuery.isNotEmpty) {
    if (normalizedProvider != null && normalizedProvider != 'all') {
      final p = providerRegistry.get(normalizedProvider);
      if (p != null) {
        try {
          final results = await p.search(effectiveQuery, kind: targetKind);
          candidates = results
              .map((r) => ProviderCandidate(
                    provider: r.provider,
                    providerItemId: r.providerItemId,
                    title: r.title,
                    kind: r.kind,
                    summary: r.summary,
                    imageUrl: r.imageUrl,
                    series: r.seriesTitle != null
                        ? CatalogSeriesDetailsDto(seriesTitle: r.seriesTitle)
                        : null,
                    issueNumber: r.issueNumber,
                  ))
              .toList();
        } catch (_) {
          candidates = const [];
        }
      }
    } else {
      final providers = providerRegistry.getForKind(targetKind);
      final futures = providers.map((p) async {
        try {
          final results = await p.search(effectiveQuery, kind: targetKind);
          return results
              .map((r) => ProviderCandidate(
                    provider: r.provider,
                    providerItemId: r.providerItemId,
                    title: r.title,
                    kind: r.kind,
                    summary: r.summary,
                    imageUrl: r.imageUrl,
                    series: r.seriesTitle != null
                        ? CatalogSeriesDetailsDto(seriesTitle: r.seriesTitle)
                        : null,
                    issueNumber: r.issueNumber,
                  ))
              .toList();
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
