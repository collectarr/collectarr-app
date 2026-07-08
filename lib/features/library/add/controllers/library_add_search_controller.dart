import 'dart:async';

import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
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
