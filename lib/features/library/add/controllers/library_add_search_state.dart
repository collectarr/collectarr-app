import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryAddSearchState {
  LibraryAddSearchState({
    this.query = '',
    this.identifierCode = '',
    this.isSearching = false,
    this.isScanningCover = false,
    this.showAdvancedSearch = false,
    this.results = const [],
    Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters = const {},
    this.suggestions = const [],
    this.showSuggestions = false,
    this.error,
    this.coreSearchGeneration = 0,
    this.coverScanPrefill,
  }) : advancedFilters = Map.unmodifiable(advancedFilters);

  factory LibraryAddSearchState.initial({
    Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters = const {},
  }) =>
      LibraryAddSearchState(
        advancedFilters: advancedFilters,
      );

  final String query;
  final String identifierCode;
  final bool isSearching;
  final bool isScanningCover;
  final bool showAdvancedSearch;
  final List<CatalogSearchCandidate> results;
  final Map<LibraryAddFilterId, LibraryAddFilterValue> advancedFilters;
  final List<CatalogSearchCandidate> suggestions;
  final bool showSuggestions;
  final String? error;
  final int coreSearchGeneration;
  final LibraryCoverScanResult? coverScanPrefill;

  bool get isBusy => isSearching || isScanningCover;

  LibraryAddSearchState copyWith({
    String? query,
    String? identifierCode,
    bool? isSearching,
    bool? isScanningCover,
    bool? showAdvancedSearch,
    List<CatalogSearchCandidate>? results,
    Map<LibraryAddFilterId, LibraryAddFilterValue>? advancedFilters,
    List<CatalogSearchCandidate>? suggestions,
    bool? showSuggestions,
    String? error,
    bool clearError = false,
    int? coreSearchGeneration,
    LibraryCoverScanResult? coverScanPrefill,
    bool clearCoverScanPrefill = false,
  }) {
    return LibraryAddSearchState(
      query: query ?? this.query,
      identifierCode: identifierCode ?? this.identifierCode,
      isSearching: isSearching ?? this.isSearching,
      isScanningCover: isScanningCover ?? this.isScanningCover,
      showAdvancedSearch: showAdvancedSearch ?? this.showAdvancedSearch,
      results: results ?? this.results,
      advancedFilters: advancedFilters ?? this.advancedFilters,
      suggestions: suggestions ?? this.suggestions,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      error: clearError ? null : (error ?? this.error),
      coreSearchGeneration: coreSearchGeneration ?? this.coreSearchGeneration,
      coverScanPrefill: clearCoverScanPrefill
          ? null
          : (coverScanPrefill ?? this.coverScanPrefill),
    );
  }
}
