part of '../generic_library_page.dart';

abstract final class LibraryPageSelectionControllerOps {
  static void selectItem(GenericLibraryPageState state, String id) {
    state._mutateState(() {
      state._selectedId = id;
      if (state._kindBrowserDelegate.hasItemDrilldown &&
          state._kindBrowserDelegate.drilldownRootItemId != id) {
        state._kindBrowserDelegate.closeItemDrilldown();
      }
    });
    state._selectionHydrationDebounce?.cancel();
    state._selectionHydrationDebounce = Timer(
      const Duration(milliseconds: 250),
      () {
        if (!state.mounted || state._selectedId != id) {
          return;
        }
        unawaited(state._hydrateSelectedItem(id));
      },
    );
  }

  static void activateItem(GenericLibraryPageState state, String id) {
    if (state._selection.enabled) {
      state._mutateState(() {
        state._selection = state._selection.clear();
      });
    }
    state._selectionAnchorId = id;
    selectItem(state, id);
  }

  static void toggleSelectionItem(GenericLibraryPageState state, String id) {
    state._mutateState(() {
      state._selection = state._selection.toggle(id);
      state._selectedId = id;
      state._selectionAnchorId = id;
    });
  }

  static void applySelection(
    GenericLibraryPageState state,
    Set<String> ids,
    String focusedId,
  ) {
    state._mutateState(() {
      state._selection = state._selection.replace(ids);
      state._selectedId = focusedId;
      state._selectionAnchorId ??= focusedId;
    });
  }

  static void selectAllVisible(
    GenericLibraryPageState state,
    LibraryProjection projection,
  ) {
    if (isTextInputFocused(state)) {
      return;
    }
    final visibleIds = visibleSelectionItemIds(state, projection);
    if (visibleIds.isEmpty) {
      return;
    }
    applySelection(state, visibleIds, state._selectedId ?? visibleIds.first);
  }

  static void removeVisibleSelection(
    GenericLibraryPageState state,
    LibraryProjection projection,
  ) {
    if (isTextInputFocused(state) || state._selection.itemIds.isEmpty) {
      return;
    }
    unawaited(state._collectionActionCoordinator.bulkRemoveFlow(projection));
  }

  static Set<String> visibleSelectionItemIds(
    GenericLibraryPageState state,
    LibraryProjection projection,
  ) {
    final visibleItems = state._selectedLetter == null
        ? projection.filteredItems
        : projection.filteredItems
            .where(
              (item) => LibraryAlphaJumpBar.matchesLetter(
                item.entry.resolvedTitle,
                state._selectedLetter!,
              ),
            )
            .toList(growable: false);
    return visibleItems.map((item) => item.entry.id).toSet();
  }

  static bool isTextInputFocused(GenericLibraryPageState state) {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) {
      return false;
    }
    return focusedContext.widget is EditableText;
  }
}
