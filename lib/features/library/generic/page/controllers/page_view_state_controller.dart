part of '../generic_library_page.dart';

abstract final class _LibraryViewStateControllerOps {
  static Future<void> loadViewState(GenericLibraryPageState state) async {
    try {
      final token = ++state._session.preferences.viewStateLoadToken;
      final expectedKind = state.widget.type.kind;
      final loaded = await state._viewProfile.load();
      if (state.mounted &&
          token == state._session.preferences.viewStateLoadToken &&
          state.widget.type.kind == expectedKind) {
        if (viewStateEquals(
            state, state._session.preferences.viewState, loaded)) {
          return;
        }
        state._mutateState(() {
          state._session.preferences.viewState = loaded;
          state._applyRouteStateFromUri(state.widget.routeUri);
        });
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load view state.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> warmViewStateCachesOnce(
      GenericLibraryPageState state) async {
    if (GenericLibraryPageState._viewStateCacheWarmupStarted) {
      return;
    }
    GenericLibraryPageState._viewStateCacheWarmupStarted = true;
    for (final registration in collectarrKindRegistrationsList) {
      try {
        await libraryViewProfileForKind(registration.kind).load();
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_page',
          message: 'Failed to warm library view-state cache.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  static bool viewStateEquals(
    GenericLibraryPageState state,
    LibraryWorkspaceViewState? left,
    LibraryWorkspaceViewState right,
  ) {
    if (left == null) {
      return false;
    }
    return left == right;
  }

  static void updateViewState(
    GenericLibraryPageState state,
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState state) update,
  ) {
    final previous = state._session.preferences.viewState;
    if (previous == null) {
      return;
    }
    final next = update(previous);
    if (viewStateEquals(state, previous, next)) {
      return;
    }
    state._mutateState(() {
      state._session.preferences.viewState = next;
    });
    state._syncRouteState();
    scheduleViewStateSave(state, next);
  }

  static void scheduleViewStateSave(
    GenericLibraryPageState state,
    LibraryWorkspaceViewState persistedState,
  ) {
    state._session.preferences.viewStateSaveDebounce?.cancel();
    state._session.preferences.viewStateSaveDebounce =
        Timer(const Duration(milliseconds: 120), () {
      unawaited(state._viewProfile.save(persistedState));
    });
  }

  static void updateViewChrome(
    GenericLibraryPageState state,
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState state) update,
  ) {
    updateViewState(state, update);
  }

  static void setGroupingPanelVisibility(
    GenericLibraryPageState state,
    bool isVisible,
  ) {
    final current = state._session.preferences.viewState;
    if (current == null || current.isSidebarVisible == isVisible) {
      return;
    }
    updateViewChrome(
      state,
      (current) => current.copyWith(isSidebarVisible: isVisible),
    );
  }
}
