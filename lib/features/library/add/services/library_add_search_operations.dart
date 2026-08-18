import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';

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

String buildLibraryAddProviderQuery(Iterable<String> parts) {
  final seen = <String>{};
  return parts.map((part) => part.trim()).where((part) {
    if (part.isEmpty) {
      return false;
    }
    return seen.add(part.toLowerCase());
  }).join(' ');
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
  required LibraryTypeConfig type,
  required CatalogCacheRepository catalog,
  required LibraryMetadataSearchInput input,
  required Duration timeout,
  required LibraryAddLocalRerankHints rerankHints,
  required bool providerSearchAvailable,
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    type: type,
    catalog: catalog,
    input: input,
  ).timeout(timeout);
  final rankedItems = rerankLibraryMetadataItems(items, rerankHints);
  return LibraryAddCoreSearchResult(
    items: rankedItems,
    shouldSearchProvider: providerSearchAvailable &&
        shouldSearchProviderForCoreResults(rankedItems, rerankHints),
  );
}

Future<List<LibraryMetadataItem>> fetchLibraryAddSuggestions({
  required ApiClient api,
  required LibraryTypeConfig type,
  required CatalogCacheRepository catalog,
  required String query,
  required int limit,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    type: type,
    catalog: catalog,
    input: LibraryMetadataSearchInput(
      query: query,
      limit: limit,
    ),
  ).timeout(timeout);
  return filterAndRerankLibraryMetadataItems(
    items,
    LibraryAddLocalRerankHints(query: query),
  );
}

Future<LibraryAddCoreSearchResult> runLibraryAddBarcodeLookup({
  required ApiClient api,
  required LibraryTypeConfig type,
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
  required LibraryTypeConfig type,
  required String provider,
  required String query,
  required LibraryAddLocalRerankHints rerankHints,
  ProviderRegistry? providerRegistry,
  String? series,
  String? issueNumber,
  int? year,
  String? kindOverride,
}) async {
  final targetKind = kindOverride ?? type.workspace.kind.apiValue;
  final normalizedProvider =
      provider.trim().isEmpty ? null : provider.trim().toLowerCase();

  List<ProviderCandidate> candidates = [];

  if (providerRegistry != null) {
    if (normalizedProvider != null && normalizedProvider != 'all') {
      final p = providerRegistry.get(normalizedProvider);
      if (p != null) {
        try {
          final results = await p.search(query, kind: targetKind);
          candidates = results
              .map((r) => ProviderCandidate(
                    provider: r.provider,
                    providerItemId: r.providerItemId,
                    title: r.title,
                    kind: r.kind,
                    summary: r.summary,
                    imageUrl: r.imageUrl,
                    series: r.seriesTitle != null
                        ? CatalogSeriesDetails(seriesTitle: r.seriesTitle)
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
          final results = await p.search(query, kind: targetKind);
          return results
              .map((r) => ProviderCandidate(
                    provider: r.provider,
                    providerItemId: r.providerItemId,
                    title: r.title,
                    kind: r.kind,
                    summary: r.summary,
                    imageUrl: r.imageUrl,
                    series: r.seriesTitle != null
                        ? CatalogSeriesDetails(seriesTitle: r.seriesTitle)
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

  // Fallback to Core provider search if registry produced no results and api is present
  if (candidates.isEmpty && api != null) {
    try {
      final rawResults = await searchLibraryProviderCandidates(
        api,
        type,
        provider: normalizedProvider,
        query: query,
        series: series,
        issueNumber: issueNumber,
        year: year,
        kindOverride: kindOverride,
      );
      candidates = rawResults;
    } catch (error) {
      if (_isMissingBearerTokenError(error) && normalizedProvider != null) {
        try {
          final fallbackResults = await searchLibraryProviderCandidates(
            api,
            type,
            provider: null,
            query: query,
            series: series,
            issueNumber: issueNumber,
            year: year,
            kindOverride: kindOverride,
          );
          candidates = fallbackResults;
        } catch (_) {
          candidates = const [];
        }
      }
    }
  }

  return rerankProviderCandidates(candidates, rerankHints);
}

bool _isMissingBearerTokenError(Object error) {
  if (error is! DioException) {
    return false;
  }
  if (error.response?.statusCode != 401) {
    return false;
  }
  final data = error.response?.data;
  if (data is! Map) {
    return false;
  }
  final code = data['code']?.toString().trim();
  return code == 'missing_bearer_token';
}
