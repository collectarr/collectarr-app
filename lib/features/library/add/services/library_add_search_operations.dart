import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';

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

class LibraryAddProviderSearchFailure {
  const LibraryAddProviderSearchFailure({
    required this.source,
    required this.message,
  });

  final String source;
  final String message;
}

class LibraryAddProviderSearchResult {
  const LibraryAddProviderSearchResult({
    required this.candidates,
    required this.failures,
  });

  final List<ProviderSearchCandidate> candidates;
  final List<LibraryAddProviderSearchFailure> failures;
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
  required LibraryKindRegistration type,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
  required Duration timeout,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  required bool providerSearchAvailable,
  CancelToken? cancelToken,
}) async {
  final items = await searchAndCacheLibraryMetadata(
    api: api,
    kind: type.kind,
    catalog: catalog,
    input: input,
    cancelToken: cancelToken,
  ).timeout(timeout);
  final rankedItems = ranking.rankMetadata(
    items,
    searchContext,
  );
  final filteredItems = libraryAddForKind(type.kind)
      .search
      .filterCoreSearchResults(rankedItems, searchContext);
  return LibraryAddCoreSearchResult(
    items: filteredItems,
    shouldSearchProvider: providerSearchAvailable &&
        ranking.shouldSearchProviderForCoreResults(
            filteredItems, searchContext),
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
      .filterCoreSearchResults(ranked, searchContext);
}

Future<LibraryAddCoreSearchResult> runLibraryAddIdentifierLookup({
  required ApiClient api,
  required LibraryKindRegistration type,
  required CatalogTransportRepository catalog,
  required String identifierCode,
  required Duration timeout,
  required bool providerSearchAvailable,
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
    shouldSearchProvider: foundItems.isEmpty && providerSearchAvailable,
  );
}

Future<LibraryAddProviderSearchResult> runLibraryAddProviderSearch({
  ApiClient? api,
  required LibraryKindRegistration type,
  required String provider,
  required String query,
  required LibraryAddSearchRanking ranking,
  required LibraryAddSearchContext searchContext,
  ProviderConnectorRegistry? providerRegistry,
  LibraryAddSearchScope? kindOverride,
  ProviderCancellationToken? cancellationToken,
}) async {
  final targetKind = kindOverride == null ? type.kind : kindOverride.kind;
  final normalizedProvider =
      provider.trim().isEmpty ? null : provider.trim().toLowerCase();
  final effectiveQuery = query.trim();

  List<ProviderSearchCandidate> candidates = [];
  final failures = <LibraryAddProviderSearchFailure>[];

  if (providerRegistry != null && effectiveQuery.isNotEmpty) {
    if (normalizedProvider != null && normalizedProvider != 'all') {
      final p = providerRegistry.get(normalizedProvider);
      if (p != null) {
        try {
          candidates = await libraryAddForKind(type.kind).search.searchProvider(
                p,
                query: effectiveQuery,
                kind: targetKind,
                context: searchContext,
                cancellationToken: cancellationToken,
              );
        } catch (error) {
          if (cancellationToken?.isCancelled == true ||
              error is ProviderCancelledException) {
            rethrow;
          }
          failures.add(
            LibraryAddProviderSearchFailure(
              source: p.descriptor.displayName,
              message: error.toString(),
            ),
          );
        }
      }
    } else {
      final providers = providerRegistry.getForKind(targetKind);
      await Future.wait(providers.map((p) async {
        try {
          candidates
              .addAll(await libraryAddForKind(type.kind).search.searchProvider(
                    p,
                    query: effectiveQuery,
                    kind: targetKind,
                    context: searchContext,
                    cancellationToken: cancellationToken,
                  ));
        } catch (error) {
          if (cancellationToken?.isCancelled == true ||
              error is ProviderCancelledException) {
            rethrow;
          }
          failures.add(
            LibraryAddProviderSearchFailure(
              source: p.descriptor.displayName,
              message: error.toString(),
            ),
          );
        }
      }));
    }
  }

  final ranked = ranking.rankProvider(candidates, searchContext);
  return LibraryAddProviderSearchResult(
    candidates: libraryAddForKind(type.kind)
        .search
        .filterProviderSearchResults(ranked, searchContext),
    failures: failures,
  );
}
