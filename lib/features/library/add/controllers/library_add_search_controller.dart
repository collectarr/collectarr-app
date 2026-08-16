import 'dart:async';

import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';

class LibraryAddSearchController {
  LibraryAddSearchController({
    required this.selectedProvider,
    Iterable<String> initialVideoKindFilters = const [],
  }) : videoKindFilters = <String>{...initialVideoKindFilters};

  final queryController = TextEditingController();
  final barcodeController = TextEditingController();
  final searchSeriesController = TextEditingController();
  final searchNumberController = TextEditingController();
  final searchPublisherController = TextEditingController();
  final searchYearController = TextEditingController();

  List<LibraryMetadataItem> results = const [];
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
  List<LibraryMetadataItem> suggestions = const [];
  bool showSuggestions = false;
  final Set<String> videoKindFilters;

  bool get isBusy => isSearching || isSearchingProvider;

  void setInitialInput({
    String? query,
    String? barcode,
  }) {
    queryController.text = query?.trim() ?? '';
    barcodeController.text = barcode?.trim() ?? '';
  }

  LibraryAddLocalRerankHints buildLocalRerankHints() {
    return LibraryAddLocalRerankHints(
      query: queryController.text,
      series: searchSeriesController.text,
      issueNumber: searchNumberController.text,
      publisher: searchPublisherController.text,
      year: int.tryParse(searchYearController.text.trim()),
    );
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
    searchSeriesController.dispose();
    searchNumberController.dispose();
    searchPublisherController.dispose();
    searchYearController.dispose();
  }
}

@immutable
class LibraryAddSearchState {
  const LibraryAddSearchState({
    this.query = '',
    this.barcode = '',
    this.series = '',
    this.number = '',
    this.publisher = '',
    this.year = '',
    this.isSearching = false,
    this.isSearchingProvider = false,
    this.searchedProvider = false,
    this.isScanningCover = false,
    this.showAdvancedSearch = false,
    this.results = const [],
    this.providerResults = const [],
    this.selectedProvider = '',
    this.videoKindFilters = const {},
    this.suggestions = const [],
    this.showSuggestions = false,
    this.error,
    this.coreSearchGeneration = 0,
    this.providerSearchGeneration = 0,
    this.lastProviderSearchAt,
    this.lastProviderSearchSignature,
    this.coverScanPrefill,
  });

  factory LibraryAddSearchState.initial({
    String selectedProvider = '',
    Set<String> videoKindFilters = const {},
  }) =>
      LibraryAddSearchState(
        selectedProvider: selectedProvider,
        videoKindFilters: videoKindFilters,
      );

  final String query;
  final String barcode;
  final String series;
  final String number;
  final String publisher;
  final String year;
  final bool isSearching;
  final bool isSearchingProvider;
  final bool searchedProvider;
  final bool isScanningCover;
  final bool showAdvancedSearch;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final String selectedProvider;
  final Set<String> videoKindFilters;
  final List<LibraryMetadataItem> suggestions;
  final bool showSuggestions;
  final String? error;
  final int coreSearchGeneration;
  final int providerSearchGeneration;
  final DateTime? lastProviderSearchAt;
  final String? lastProviderSearchSignature;
  final LibraryCoverScanResult? coverScanPrefill;

  bool get isBusy => isSearching || isSearchingProvider || isScanningCover;

  LibraryAddLocalRerankHints buildLocalRerankHints() {
    return LibraryAddLocalRerankHints(
      query: query,
      series: series,
      issueNumber: number,
      publisher: publisher,
      year: int.tryParse(year.trim()),
    );
  }

  LibraryAddSearchState copyWith({
    String? query,
    String? barcode,
    String? series,
    String? number,
    String? publisher,
    String? year,
    bool? isSearching,
    bool? isSearchingProvider,
    bool? searchedProvider,
    bool? isScanningCover,
    bool? showAdvancedSearch,
    List<LibraryMetadataItem>? results,
    List<ProviderCandidate>? providerResults,
    String? selectedProvider,
    Set<String>? videoKindFilters,
    List<LibraryMetadataItem>? suggestions,
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
      series: series ?? this.series,
      number: number ?? this.number,
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
      isSearching: isSearching ?? this.isSearching,
      isSearchingProvider: isSearchingProvider ?? this.isSearchingProvider,
      searchedProvider: searchedProvider ?? this.searchedProvider,
      isScanningCover: isScanningCover ?? this.isScanningCover,
      showAdvancedSearch: showAdvancedSearch ?? this.showAdvancedSearch,
      results: results ?? this.results,
      providerResults: providerResults ?? this.providerResults,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      videoKindFilters: videoKindFilters ?? this.videoKindFilters,
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
