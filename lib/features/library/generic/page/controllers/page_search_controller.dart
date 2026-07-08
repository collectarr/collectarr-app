import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/page_search_state.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPageSearchController {
  LibraryPageSearchController({
    required this.ref,
    required this.searchStateKey,
    required this.searchController,
    required this.supportsTrackSearch,
    required this.clearActiveSmartLists,
    required this.syncRouteState,
  });

  final WidgetRef ref;
  final String searchStateKey;
  final TextEditingController searchController;
  final bool supportsTrackSearch;
  final VoidCallback clearActiveSmartLists;
  final VoidCallback syncRouteState;

  LibraryPageSearchState get state => ref.read(
        libraryPageSearchStateProvider(searchStateKey),
      );

  void onSearchChanged(String value) {
    final trimmed = value.trim();
    final searchState = ref.watch(
      libraryPageSearchStateProvider(searchStateKey),
    );
    if (searchState.query == trimmed && searchState.pinnedItemId == null) {
      return;
    }
    state.setQuery(trimmed);
    clearActiveSmartLists();
    syncRouteState();
  }

  void onSearchInputChanged(String value) {
    onSearchChanged(value);
  }

  void clearSearch() {
    searchController.clear();
    state.clearSearch();
    clearActiveSmartLists();
    syncRouteState();
  }

  void applySearchSuggestion(LibraryToolbarSearchSuggestion suggestion) {
    searchController.value = searchController.value.copyWith(
      text: suggestion.title,
      selection: TextSelection.collapsed(offset: suggestion.title.length),
      composing: TextRange.empty,
    );
    state.applySuggestion(title: suggestion.title, id: suggestion.id);
    clearActiveSmartLists();
    syncRouteState();
  }

  void onSearchTargetChanged(LibrarySearchTarget target) {
    final searchState = state;
    if (!supportsTrackSearch || searchState.target == target) {
      return;
    }
    searchState.setTarget(target);
    clearActiveSmartLists();
    syncRouteState();
  }
}
