part of '../../page.dart';

abstract final class _LibraryPageSearchControllerOps {
  static LibraryPageSearchState state(GenericLibraryPageState state) {
    return state.ref.read(
      libraryPageSearchStateProvider(state._searchStateKey),
    );
  }

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

  static void setTarget(
    GenericLibraryPageState state,
    LibrarySearchTarget target,
  ) {
    state.ref
        .read(libraryPageSearchStateProvider(state._searchStateKey))
        .setTarget(target);
  }

  static void setRouteSearchState(
    GenericLibraryPageState state,
    LibraryRouteState routeState,
  ) {
    final routeQuery = routeState.searchQuery?.trim() ?? '';
    final controller =
        state.ref.read(libraryPageSearchStateProvider(state._searchStateKey));
    controller.setQuery(routeQuery);
    if (!state._supportsMusicTrackSearch) {
      controller.setTarget(LibrarySearchTarget.all);
    }
  }

  static LibraryPageSearchState thisState(GenericLibraryPageState state) {
    return state.ref.read(
      libraryPageSearchStateProvider(state._searchStateKey),
    );
  }
}
