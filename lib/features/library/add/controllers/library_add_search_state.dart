import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryAddSearchState {
  LibraryAddSearchState({
    this.query = '',
    this.identifierCode = '',
    this.isSearching = false,
    this.isSearchingProvider = false,
    this.searchedProvider = false,
    this.isScanningCover = false,
    this.showAdvancedSearch = false,
    this.results = const [],
    this.providerResults = const [],
    this.selectedProvider = '',
    Map<LibraryAddFilterId, Object?> advancedFilters = const {},
    this.suggestions = const [],
    this.showSuggestions = false,
    this.error,
    this.coreSearchGeneration = 0,
    this.providerSearchGeneration = 0,
    this.lastProviderSearchAt,
    this.lastProviderSearchSignature,
    this.coverScanPrefill,
  }) : advancedFilters = Map.unmodifiable(advancedFilters);

  factory LibraryAddSearchState.initial({
    String selectedProvider = '',
    Map<LibraryAddFilterId, Object?> advancedFilters = const {},
  }) =>
      LibraryAddSearchState(
        selectedProvider: selectedProvider,
        advancedFilters: advancedFilters,
      );

  final String query;
  final String identifierCode;
  final bool isSearching;
  final bool isSearchingProvider;
  final bool searchedProvider;
  final bool isScanningCover;
  final bool showAdvancedSearch;
  final List<CatalogSearchCandidate> results;
  final List<ProviderSearchCandidate> providerResults;
  final String selectedProvider;
  final Map<LibraryAddFilterId, Object?> advancedFilters;
  final List<CatalogSearchCandidate> suggestions;
  final bool showSuggestions;
  final String? error;
  final int coreSearchGeneration;
  final int providerSearchGeneration;
  final DateTime? lastProviderSearchAt;
  final String? lastProviderSearchSignature;
  final LibraryCoverScanResult? coverScanPrefill;

  bool get isBusy => isSearching || isSearchingProvider || isScanningCover;

  LibraryAddSearchState copyWith({
    String? query,
    String? identifierCode,
    bool? isSearching,
    bool? isSearchingProvider,
    bool? searchedProvider,
    bool? isScanningCover,
    bool? showAdvancedSearch,
    List<CatalogSearchCandidate>? results,
    List<ProviderSearchCandidate>? providerResults,
    String? selectedProvider,
    Map<LibraryAddFilterId, Object?>? advancedFilters,
    List<CatalogSearchCandidate>? suggestions,
    bool? showSuggestions,
    String? error,
    bool clearError = false,
    int? coreSearchGeneration,
    int? providerSearchGeneration,
    DateTime? lastProviderSearchAt,
    String? lastProviderSearchSignature,
    LibraryCoverScanResult? coverScanPrefill,
    bool clearCoverScanPrefill = false,
  }) {
    return LibraryAddSearchState(
      query: query ?? this.query,
      identifierCode: identifierCode ?? this.identifierCode,
      isSearching: isSearching ?? this.isSearching,
      isSearchingProvider: isSearchingProvider ?? this.isSearchingProvider,
      searchedProvider: searchedProvider ?? this.searchedProvider,
      isScanningCover: isScanningCover ?? this.isScanningCover,
      showAdvancedSearch: showAdvancedSearch ?? this.showAdvancedSearch,
      results: results ?? this.results,
      providerResults: providerResults ?? this.providerResults,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      advancedFilters: advancedFilters ?? this.advancedFilters,
      suggestions: suggestions ?? this.suggestions,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      error: clearError ? null : (error ?? this.error),
      coreSearchGeneration: coreSearchGeneration ?? this.coreSearchGeneration,
      providerSearchGeneration:
          providerSearchGeneration ?? this.providerSearchGeneration,
      lastProviderSearchAt: lastProviderSearchAt ?? this.lastProviderSearchAt,
      lastProviderSearchSignature:
          lastProviderSearchSignature ?? this.lastProviderSearchSignature,
      coverScanPrefill: clearCoverScanPrefill
          ? null
          : (coverScanPrefill ?? this.coverScanPrefill),
    );
  }
}
