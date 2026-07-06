part of '../library_page.dart';

abstract final class _LibraryPageSearchControllerOps {
  static void setQuery(GenericLibraryPageState state, String query) {
    state.ref
        .read(libraryPageSearchStateProvider(state._searchStateKey))
        .setQuery(query);
  }

  static void applySuggestion(
    GenericLibraryPageState state,
    LibraryToolbarSearchSuggestion suggestion,
  ) {
    state.ref
        .read(libraryPageSearchStateProvider(state._searchStateKey))
        .applySuggestion(title: suggestion.title, id: suggestion.id);
  }

  static void clearSearch(GenericLibraryPageState state) {
    state.ref
        .read(libraryPageSearchStateProvider(state._searchStateKey))
        .clearSearch();
  }

  static LibraryPageSearchState thisState(GenericLibraryPageState state) {
    return state.ref.read(
      libraryPageSearchStateProvider(state._searchStateKey),
    );
  }
}

extension _LibraryPageSearchStateHandlers on GenericLibraryPageState {
  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    final searchState = ref.watch(
      libraryPageSearchStateProvider(_searchStateKey),
    );
    if (searchState.query == trimmed && searchState.pinnedItemId == null) {
      return;
    }
    _LibraryPageSearchControllerOps.setQuery(this, trimmed);
    _mutateState(() {
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }

  void _onSearchInputChanged(String value) {
    _onSearchChanged(value);
  }

  void _clearSearch() {
    _searchController.clear();
    _LibraryPageSearchControllerOps.clearSearch(this);
    _mutateState(() {
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }

  void _applySearchSuggestion(LibraryToolbarSearchSuggestion suggestion) {
    _searchController.value = _searchController.value.copyWith(
      text: suggestion.title,
      selection: TextSelection.collapsed(offset: suggestion.title.length),
      composing: TextRange.empty,
    );
    _LibraryPageSearchControllerOps.applySuggestion(this, suggestion);
    _mutateState(() {
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }

  void _onSearchTargetChanged(LibrarySearchTarget target) {
    final searchState = _LibraryPageSearchControllerOps.thisState(this);
    if (!_supportsMusicTrackSearch || searchState.target == target) {
      return;
    }
    searchState.setTarget(target);
    _mutateState(() {
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }
}
