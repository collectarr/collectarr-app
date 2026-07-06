part of '../generic_library_page.dart';

abstract final class _LibraryViewStateControllerOps {
  static Future<void> loadViewState(GenericLibraryPageState state) async {
    try {
      final token = ++state._viewStateLoadToken;
      final expectedKind = state.widget.type.workspace.kind;
      final loaded = await state._adapter.viewProfile.load();
      if (state.mounted &&
          token == state._viewStateLoadToken &&
          state.widget.type.workspace.kind == expectedKind) {
        if (viewStateEquals(state, state._viewState, loaded)) {
          return;
        }
        state._mutateState(() {
          state._viewState = loaded;
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

  static Future<void> warmViewStateCachesOnce(GenericLibraryPageState state) async {
    if (GenericLibraryPageState._viewStateCacheWarmupStarted) {
      return;
    }
    GenericLibraryPageState._viewStateCacheWarmupStarted = true;
    for (final adapter in collectarrMediaAdapters.adapters) {
      try {
        await adapter.viewProfile.load();
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
    final previous = state._viewState;
    if (previous == null) {
      return;
    }
    final next = update(previous);
    if (viewStateEquals(state, previous, next)) {
      return;
    }
    state._mutateState(() {
      state._viewState = next;
    });
    state._syncRouteState();
    scheduleViewStateSave(state, next);
  }

  static void scheduleViewStateSave(
    GenericLibraryPageState state,
    LibraryWorkspaceViewState persistedState,
  ) {
    state._viewStateSaveDebounce?.cancel();
    state._viewStateSaveDebounce = Timer(const Duration(milliseconds: 120), () {
      unawaited(state._adapter.viewProfile.save(persistedState));
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
    final current = state._viewState;
    if (current == null || current.isSidebarVisible == isVisible) {
      return;
    }
    updateViewChrome(
      state,
      (current) => current.copyWith(isSidebarVisible: isVisible),
    );
  }
}
