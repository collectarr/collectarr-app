import 'dart:async';

import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

class LibraryAddSearchController {
  LibraryAddSearchController({
    required this.selectedProvider,
    Map<LibraryAddFilterId, Object?> initialAdvancedFilters = const {},
  }) : _advancedFilters = Map.from(initialAdvancedFilters);

  final queryController = TextEditingController();
  final barcodeController = TextEditingController();

  List<CatalogItem> results = const [];
  List<ProviderCandidate> providerResults = const [];
  String? error;
  String selectedProvider;
  bool searchedProvider = false;
  bool isSearching = false;
  bool isSearchingProvider = false;
  bool showAdvancedSearch = false;
  bool isScanningCover = false;
  DateTime? lastProviderSearchAt;
  String? lastProviderSearchSignature;
  int coreSearchGeneration = 0;
  int providerSearchGeneration = 0;
  Timer? autocompleteTimer;
  List<CatalogItem> suggestions = const [];
  bool showSuggestions = false;
  final Map<LibraryAddFilterId, Object?> _advancedFilters;

  Map<LibraryAddFilterId, Object?> get advancedFilters =>
      Map.unmodifiable(_advancedFilters);

  bool get isBusy => isSearching || isSearchingProvider;

  void setInitialInput({
    String? query,
    String? barcode,
  }) {
    queryController.text = query?.trim() ?? '';
    barcodeController.text = barcode?.trim() ?? '';
  }

  void updateAdvancedFilter(LibraryAddFilterId id, Object? value) {
    if (value == null) {
      _advancedFilters.remove(id);
    } else {
      _advancedFilters[id] = value;
    }
  }

  void clearSuggestions() {
    suggestions = const [];
    showSuggestions = false;
  }

  void dismissSuggestions() {
    showSuggestions = false;
  }

  void dispose() {
    autocompleteTimer?.cancel();
    queryController.dispose();
    barcodeController.dispose();
  }
}

@immutable
class LibraryAddSearchState {
  LibraryAddSearchState({
    this.query = '',
    this.barcode = '',
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
  final String barcode;
  final bool isSearching;
  final bool isSearchingProvider;
  final bool searchedProvider;
  final bool isScanningCover;
  final bool showAdvancedSearch;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final String selectedProvider;
  final Map<LibraryAddFilterId, Object?> advancedFilters;
  final List<CatalogItem> suggestions;
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
    String? barcode,
    bool? isSearching,
    bool? isSearchingProvider,
    bool? searchedProvider,
    bool? isScanningCover,
    bool? showAdvancedSearch,
    List<CatalogItem>? results,
    List<ProviderCandidate>? providerResults,
    String? selectedProvider,
    Map<LibraryAddFilterId, Object?>? advancedFilters,
    List<CatalogItem>? suggestions,
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
      barcode: barcode ?? this.barcode,
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
