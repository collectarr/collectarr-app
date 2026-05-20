import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';

class ComicsProviderSearchState {
  ComicsProviderSearchState({
    required this.provider,
    required Iterable<ProviderCandidate> results,
    required this.selectedId,
    required this.searched,
    required this.isSearching,
  }) : results = List.unmodifiable(results);

  factory ComicsProviderSearchState.initial(String provider) {
    return ComicsProviderSearchState(
      provider: provider,
      results: const [],
      selectedId: null,
      searched: false,
      isSearching: false,
    );
  }

  final String provider;
  final List<ProviderCandidate> results;
  final String? selectedId;
  final bool searched;
  final bool isSearching;

  ProviderCandidate? get selectedCandidate {
    final id = selectedId;
    if (id == null) {
      return null;
    }
    for (final result in results) {
      if (result.providerItemId == id) {
        return result;
      }
    }
    return null;
  }

  ComicsProviderSearchState startSearch() {
    return ComicsProviderSearchState(
      provider: provider,
      results: const [],
      selectedId: null,
      searched: true,
      isSearching: true,
    );
  }

  ComicsProviderSearchState withResults(List<ProviderCandidate> nextResults) {
    return ComicsProviderSearchState(
      provider: provider,
      results: nextResults,
      selectedId: nextResults.isEmpty ? null : nextResults.first.providerItemId,
      searched: true,
      isSearching: false,
    );
  }

  ComicsProviderSearchState finishSearch() {
    return ComicsProviderSearchState(
      provider: provider,
      results: results,
      selectedId: selectedId,
      searched: searched,
      isSearching: false,
    );
  }

  ComicsProviderSearchState select(String id) {
    return ComicsProviderSearchState(
      provider: provider,
      results: results,
      selectedId: id,
      searched: searched,
      isSearching: isSearching,
    );
  }

  ComicsProviderSearchState clearSelection() {
    return ComicsProviderSearchState(
      provider: provider,
      results: results,
      selectedId: null,
      searched: searched,
      isSearching: isSearching,
    );
  }

  ComicsProviderSearchState clearResults() {
    return ComicsProviderSearchState(
      provider: provider,
      results: const [],
      selectedId: null,
      searched: false,
      isSearching: false,
    );
  }

  ComicsProviderSearchState changeProvider(String nextProvider) {
    if (nextProvider == provider) {
      return this;
    }
    return ComicsProviderSearchState.initial(nextProvider);
  }
}
