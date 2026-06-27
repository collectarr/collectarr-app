part of '../../page.dart';

abstract final class _LibraryScopeControllerOps {
  static List<String> sidebarBreadcrumbs(GenericLibraryPageState state) {
    return buildLibrarySidebarBreadcrumbs(
      rootLabel: 'All ${state.widget.type.pluralLabel}',
      history: state._scopeHistory,
      current: captureSidebarScope(state),
      labelForScope: (scope) => sidebarScopeLabel(state, scope),
    );
  }

  static List<LibraryBucketScopeFilter> sidebarBucketScopeFilters(
    GenericLibraryPageState state,
  ) {
    return [
      for (final snapshot in state._scopeHistory)
        if (snapshot.selectedBucket != null)
          LibraryBucketScopeFilter(
            groupMode: snapshot.groupMode,
            bucket: snapshot.selectedBucket!,
          ),
    ];
  }

  static List<String> sidebarAncestorScopeLabels(
      GenericLibraryPageState state) {
    return [
      for (final snapshot in state._scopeHistory)
        if (snapshot.selectedBucket != null) sidebarScopeLabel(state, snapshot),
    ];
  }

  static void navigateSidebarToAncestorScope(
    GenericLibraryPageState state,
    int index,
  ) {
    final bucketIndexes = <int>[
      for (var historyIndex = 0;
          historyIndex < state._scopeHistory.length;
          historyIndex += 1)
        if (state._scopeHistory[historyIndex].selectedBucket != null)
          historyIndex,
    ];
    if (index < 0 || index >= bucketIndexes.length) {
      return;
    }
    navigateSidebarToBreadcrumb(state, bucketIndexes[index] + 1);
  }

  static void setSelectedBucket(GenericLibraryPageState state, String? bucket) {
    final currentMode = state._activeGroupMode;
    final childMode = bucket == null
        ? null
        : state._activeFolderPreset.nextModeAfter(currentMode);
    final canDrilldown = childMode != null && childMode != currentMode;
    if (canDrilldown) {
      final previous = captureSidebarScope(state);
      final drilldownSource = LibrarySidebarScopeSnapshot(
        groupMode: previous.groupMode,
        selectedBucket: bucket,
        selectedLetter: null,
        linkedMetadataFilter: null,
        collectionStatusScope: previous.collectionStatusScope,
        quickView: previous.quickView,
        filterSelection: previous.filterSelection,
        activeSmartListId: null,
        activeSmartListName: null,
        searchQuery: previous.searchQuery,
      );
      final next = LibrarySidebarScopeSnapshot(
        groupMode: childMode,
        collectionStatusScope: previous.collectionStatusScope,
        quickView: previous.quickView,
        filterSelection: previous.filterSelection,
        searchQuery: previous.searchQuery,
      );
      state._mutateState(() {
        state._scopeHistory = updateLibrarySidebarScopeHistory(
          history: state._scopeHistory,
          previous: drilldownSource,
          next: next,
        );
        state._groupMode = childMode;
        state._selectedBucket = null;
        state._selectedLetter = null;
        state._linkedMetadataFilter = null;
        state._activeSmartListId = null;
        state._activeSmartListName = null;
      });
      state._syncRouteState();
      return;
    }
    mutateSidebarScope(state, () {
      state._selectedBucket = bucket;
      state._selectedLetter = null;
      state._linkedMetadataFilter = null;
      state._activeSmartListId = null;
      state._activeSmartListName = null;
    });
  }

  static void setSelectedLetter(GenericLibraryPageState state, String? letter) {
    mutateSidebarScope(state, () {
      state._selectedLetter = letter;
      state._selectedBucket = null;
      state._linkedMetadataFilter = null;
      state._activeSmartListId = null;
      state._activeSmartListName = null;
    });
  }

  static void toggleLinkedMetadataFilter(
    GenericLibraryPageState state,
    String value,
  ) {
    mutateSidebarScope(state, () {
      state._linkedMetadataFilter = state._linkedMetadataFilter?.value == value
          ? null
          : LibraryLinkedMetadataFilter(value: value);
      state._selectedBucket = null;
      state._selectedLetter = null;
      state._activeSmartListId = null;
      state._activeSmartListName = null;
    });
  }

  static void mutateSidebarScope(
    GenericLibraryPageState state,
    VoidCallback mutate,
  ) {
    final previous = captureSidebarScope(state);
    mutate();
    final next = captureSidebarScope(state);
    if (next == previous) {
      return;
    }
    state._mutateState(() {
      state._scopeHistory = updateLibrarySidebarScopeHistory(
        history: state._scopeHistory,
        previous: previous,
        next: next,
      );
    });
    state._syncRouteState();
  }

  static LibrarySidebarScopeSnapshot captureSidebarScope(
    GenericLibraryPageState state,
  ) {
    return LibrarySidebarScopeSnapshot(
      groupMode: state._activeGroupMode,
      selectedBucket: state._selectedBucket,
      selectedLetter: state._selectedLetter,
      linkedMetadataFilter: state._linkedMetadataFilter,
      collectionStatusScope: state._collectionStatusScope,
      seriesCompletionScope: state._seriesCompletionScope,
      quickView: state._quickView,
      filterSelection: state._filterSelection,
      activeSmartListId: state._activeSmartListId,
      activeSmartListName: state._activeSmartListName,
      searchQuery: state._appliedSearchQuery.trim(),
    );
  }

  static void applySidebarScopeSnapshot(
    GenericLibraryPageState state,
    LibrarySidebarScopeSnapshot snapshot,
  ) {
    state._groupMode = snapshot.groupMode;
    state._selectedBucket = snapshot.selectedBucket;
    state._selectedLetter = snapshot.selectedLetter;
    state._linkedMetadataFilter = snapshot.linkedMetadataFilter;
    state._collectionStatusScope = snapshot.collectionStatusScope;
    state._seriesCompletionScope = snapshot.seriesCompletionScope;
    state._quickView = snapshot.quickView;
    state._filterSelection = snapshot.filterSelection;
    state._activeSmartListId = snapshot.activeSmartListId;
    state._activeSmartListName = snapshot.activeSmartListName;
    state._searchController.value = state._searchController.value.copyWith(
      text: snapshot.searchQuery,
      selection: TextSelection.collapsed(offset: snapshot.searchQuery.length),
      composing: TextRange.empty,
    );
    state._appliedSearchQuery = snapshot.searchQuery;
    state._searchPinnedItemId = null;
  }

  static void navigateSidebarBack(GenericLibraryPageState state) {
    final navigation = popLibrarySidebarScopeHistory(state._scopeHistory);
    if (navigation == null) {
      return;
    }
    state._mutateState(() {
      state._scopeHistory = navigation.history;
      applySidebarScopeSnapshot(state, navigation.target);
    });
    state._syncRouteState();
  }

  static void navigateSidebarToBreadcrumb(
    GenericLibraryPageState state,
    int index,
  ) {
    final navigation = navigateLibrarySidebarScopeHistoryToBreadcrumb(
      history: state._scopeHistory,
      index: index,
      rootScope: LibrarySidebarScopeSnapshot(groupMode: state._activeGroupMode),
    );
    if (navigation == null) {
      return;
    }
    state._mutateState(() {
      state._scopeHistory = navigation.history;
      applySidebarScopeSnapshot(state, navigation.target);
    });
    state._syncRouteState();
  }

  static void clearFilters(GenericLibraryPageState state) {
    state._mutateState(() {
      state._selectedBucket = null;
      state._selectedLetter = null;
      state._linkedMetadataFilter = null;
      state._collectionStatusScope = LibraryCollectionStatusScope.all;
      state._seriesCompletionScope = LibrarySeriesCompletionScope.all;
      state._quickView = null;
      state._filterSelection = LibraryFilterSelection.none;
      state._activeSmartListId = null;
      state._activeSmartListName = null;
      state._scopeHistory = const [];
      state._searchController.clear();
      state._appliedSearchQuery = '';
      state._searchPinnedItemId = null;
      state._selectionAnchorId = null;
    });
    state._syncRouteState();
  }

  static void applySmartList(
      GenericLibraryPageState state, SmartList smartList) {
    state._mutateState(() {
      state._activeSmartListId = smartList.id;
      state._activeSmartListName = smartList.name;
      state._filterSelection = smartList.filterSelection;
      state._quickView = smartList.quickView;
      if (smartList.searchQuery != null) {
        state._searchController.text = smartList.searchQuery!;
        state._appliedSearchQuery = smartList.searchQuery!.trim();
      } else {
        state._searchController.clear();
        state._appliedSearchQuery = '';
      }
      state._searchPinnedItemId = null;
      if (state._viewState != null) {
        if (smartList.sortRules != null && smartList.sortRules!.isNotEmpty) {
          state._viewState = state._viewState!.withSortRules(
            smartList.sortRules!,
            state._adapter.viewProfile,
          );
        } else if (smartList.sortColumn != null) {
          state._viewState = state._viewState!.copyWith(
            sortColumn: smartList.sortColumn,
            sortAscending: smartList.sortAscending ?? true,
          );
        }
      }
      state._selectedBucket = null;
      state._selectedLetter = null;
      state._linkedMetadataFilter = null;
      state._collectionStatusScope = LibraryCollectionStatusScope.all;
      state._seriesCompletionScope = LibrarySeriesCompletionScope.all;
      state._scopeHistory = const [];
    });
    state._syncRouteState();
  }

  static void clearSmartList(GenericLibraryPageState state) {
    state._mutateState(() {
      state._activeSmartListId = null;
      state._activeSmartListName = null;
      state._filterSelection = LibraryFilterSelection.none;
      state._quickView = null;
      state._collectionStatusScope = LibraryCollectionStatusScope.all;
      state._seriesCompletionScope = LibrarySeriesCompletionScope.all;
      state._searchController.clear();
      state._appliedSearchQuery = '';
      state._searchPinnedItemId = null;
      state._selectedBucket = null;
      state._selectedLetter = null;
      state._linkedMetadataFilter = null;
      state._scopeHistory = const [];
    });
    state._syncRouteState();
  }

  static String sidebarScopeLabel(
    GenericLibraryPageState state,
    LibrarySidebarScopeSnapshot snapshot,
  ) {
    if (snapshot.selectedBucket != null) {
      return '${genericGroupModeLabel(snapshot.groupMode, state.widget.type)}: ${snapshot.selectedBucket}';
    }
    if (snapshot.linkedMetadataFilter != null) {
      return snapshot.linkedMetadataFilter!.chipLabel;
    }
    if (snapshot.collectionStatusScope != LibraryCollectionStatusScope.all) {
      return snapshot.collectionStatusScope.label;
    }
    if (snapshot.seriesCompletionScope != LibrarySeriesCompletionScope.all) {
      return snapshot.seriesCompletionScope.label;
    }
    if (snapshot.selectedLetter != null) {
      return 'Letter ${snapshot.selectedLetter}';
    }
    if (snapshot.activeSmartListName != null &&
        snapshot.activeSmartListName!.trim().isNotEmpty) {
      return snapshot.activeSmartListName!;
    }
    if (snapshot.quickView != null) {
      return snapshot.quickView!.label;
    }
    if (snapshot.filterSelection.hasActiveFilters) {
      return '${snapshot.filterSelection.activeFilterCount} filters';
    }
    if (snapshot.searchQuery.trim().isNotEmpty) {
      return 'Search';
    }
    return 'All ${state.widget.type.pluralLabel}';
  }
}
