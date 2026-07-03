part of '../../page.dart';

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
