part of '../generic_library_page.dart';

abstract final class _LibraryScopeControllerOps {
  static List<String> sidebarBreadcrumbs(GenericLibraryPageState state) {
    return buildLibrarySidebarBreadcrumbs(
      rootLabel: 'All ${state.widget.type.identity.pluralLabel}',
      history: state._session.preferences.scopeHistory,
      current: captureSidebarScope(state),
      labelForScope: (scope) => sidebarScopeLabel(state, scope),
    );
  }

  static List<LibraryBucketScopeFilter> sidebarBucketScopeFilters(
    GenericLibraryPageState state,
  ) {
    final registration = state.widget.type;
    final fields = libraryKindWorkspaceForKind(registration.kind).fields;
    return [
      for (final snapshot in state._session.preferences.scopeHistory)
        if (snapshot.selectedBucket != null)
          LibraryBucketScopeFilter(
            groupId: fields.decodeGroupId(snapshot.groupMode),
            bucket: snapshot.selectedBucket!,
          ),
    ];
  }

  static List<String> sidebarAncestorScopeLabels(
      GenericLibraryPageState state) {
    return [
      for (final snapshot in state._session.preferences.scopeHistory)
        if (snapshot.selectedBucket != null) sidebarScopeLabel(state, snapshot),
    ];
  }

  static void navigateSidebarToAncestorScope(
    GenericLibraryPageState state,
    int index,
  ) {
    final bucketIndexes = <int>[
      for (var historyIndex = 0;
          historyIndex < state._session.preferences.scopeHistory.length;
          historyIndex += 1)
        if (state._session.preferences.scopeHistory[historyIndex]
                .selectedBucket !=
            null)
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
    final canDrilldown = libraryAllowsGroupDrilldown(
      currentMode: currentMode,
      childMode: childMode,
    );
    if (canDrilldown) {
      final resolvedChildMode = childMode!;
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
        groupMode: resolvedChildMode,
        collectionStatusScope: previous.collectionStatusScope,
        quickView: previous.quickView,
        filterSelection: previous.filterSelection,
        searchQuery: previous.searchQuery,
      );
      state._mutateState(() {
        state._session.preferences.scopeHistory =
            updateLibrarySidebarScopeHistory(
          history: state._session.preferences.scopeHistory,
          previous: drilldownSource,
          next: next,
        );
        state._session.preferences.groupMode = resolvedChildMode;
        state._session.facets.selectedBucket = null;
        state._session.facets.selectedLetter = null;
        state._session.facets.linkedMetadataFilter = null;
        state._session.preferences.activeSmartListId = null;
        state._session.preferences.activeSmartListName = null;
      });
      state._syncRouteState();
      return;
    }
    mutateSidebarScope(state, () {
      state._session.facets.selectedBucket = bucket;
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
    });
  }

  static void setSelectedLetter(GenericLibraryPageState state, String? letter) {
    mutateSidebarScope(state, () {
      state._session.facets.selectedLetter = letter;
      state._session.facets.selectedBucket = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
    });
  }

  static void toggleLinkedMetadataFilter(
    GenericLibraryPageState state,
    String value,
  ) {
    mutateSidebarScope(state, () {
      state._session.facets.linkedMetadataFilter =
          state._session.facets.linkedMetadataFilter?.value == value
              ? null
              : LibraryLinkedMetadataFilter(value: value);
      state._session.facets.selectedBucket = null;
      state._session.facets.selectedLetter = null;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
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
      state._session.preferences.scopeHistory =
          updateLibrarySidebarScopeHistory(
        history: state._session.preferences.scopeHistory,
        previous: previous,
        next: next,
      );
    });
    state._syncRouteState();
  }

  static LibrarySidebarScopeSnapshot captureSidebarScope(
    GenericLibraryPageState state,
  ) {
    final searchState = state._searchControllerOps.state;
    return LibrarySidebarScopeSnapshot(
      groupMode: state._activeGroupMode,
      selectedBucket: state._session.facets.selectedBucket,
      selectedLetter: state._session.facets.selectedLetter,
      linkedMetadataFilter: state._session.facets.linkedMetadataFilter,
      collectionStatusScope: state._session.facets.collectionStatusScope,
      bucketCompletionScope: state._session.facets.bucketCompletionScope,
      quickView: state._session.facets.quickView,
      filterSelection: state._session.selection.filterSelection,
      activeSmartListId: state._session.preferences.activeSmartListId,
      activeSmartListName: state._session.preferences.activeSmartListName,
      searchQuery: searchState.query.trim(),
    );
  }

  static void applySidebarScopeSnapshot(
    GenericLibraryPageState state,
    LibrarySidebarScopeSnapshot snapshot,
  ) {
    state._session.preferences.groupMode = snapshot.groupMode;
    state._session.facets.selectedBucket = snapshot.selectedBucket;
    state._session.facets.selectedLetter = snapshot.selectedLetter;
    state._session.facets.linkedMetadataFilter = snapshot.linkedMetadataFilter;
    state._session.facets.collectionStatusScope =
        snapshot.collectionStatusScope;
    state._session.facets.bucketCompletionScope =
        snapshot.bucketCompletionScope;
    state._session.facets.quickView = snapshot.quickView;
    state._session.selection.filterSelection = snapshot.filterSelection;
    state._session.preferences.activeSmartListId = snapshot.activeSmartListId;
    state._session.preferences.activeSmartListName =
        snapshot.activeSmartListName;
    state._searchController.value = state._searchController.value.copyWith(
      text: snapshot.searchQuery,
      selection: TextSelection.collapsed(offset: snapshot.searchQuery.length),
      composing: TextRange.empty,
    );
    state._searchControllerOps.state.setQuery(snapshot.searchQuery);
  }

  static void navigateSidebarBack(GenericLibraryPageState state) {
    final navigation =
        popLibrarySidebarScopeHistory(state._session.preferences.scopeHistory);
    if (navigation == null) {
      return;
    }
    state._mutateState(() {
      state._session.preferences.scopeHistory = navigation.history;
      applySidebarScopeSnapshot(state, navigation.target);
    });
    state._syncRouteState();
  }

  static void navigateSidebarToBreadcrumb(
    GenericLibraryPageState state,
    int index,
  ) {
    final navigation = navigateLibrarySidebarScopeHistoryToBreadcrumb(
      history: state._session.preferences.scopeHistory,
      index: index,
      rootScope: LibrarySidebarScopeSnapshot(groupMode: state._activeGroupMode),
    );
    if (navigation == null) {
      return;
    }
    state._mutateState(() {
      state._session.preferences.scopeHistory = navigation.history;
      applySidebarScopeSnapshot(state, navigation.target);
    });
    state._syncRouteState();
  }

  static void clearFilters(GenericLibraryPageState state) {
    state._mutateState(() {
      state._session.facets.selectedBucket = null;
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.facets.collectionStatusScope =
          LibraryCollectionStatusScope.all;
      state._session.facets.bucketCompletionScope =
          LibraryBucketCompletionScope.all;
      state._session.facets.quickView = null;
      state._session.selection.filterSelection = LibraryFilterSelection.none;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
      state._session.preferences.scopeHistory = const [];
      state._searchController.clear();
      state._session.selection.anchorId = null;
    });
    state._searchControllerOps.clearSearch();
    state._syncRouteState();
  }

  static void applySmartList(
      GenericLibraryPageState state, SmartList smartList) {
    state._mutateState(() {
      state._session.preferences.activeSmartListId = smartList.id;
      state._session.preferences.activeSmartListName = smartList.name;
      state._session.selection.filterSelection = smartList.filterSelection;
      state._session.facets.quickView = smartList.quickView;
      if (smartList.searchQuery != null) {
        state._searchController.text = smartList.searchQuery!;
        state._searchControllerOps.state.setQuery(smartList.searchQuery!);
      } else {
        state._searchController.clear();
        state._searchControllerOps.clearSearch();
      }
      if (state._session.preferences.viewState != null) {
        if (smartList.sortRules != null && smartList.sortRules!.isNotEmpty) {
          state._session.preferences.viewState =
              state._session.preferences.viewState!.withSortRules(
            state._viewProfile.decodeSortRules(
              smartList.sortRules!,
              scope: smartList.entityScope ?? state.activeEntityScope,
            ),
            state._viewProfile,
          );
        } else if (smartList.sortColumn != null) {
          final registration = state.widget.type;
          state._session.preferences.viewState =
              state._session.preferences.viewState!.copyWith(
            sortId: libraryKindWorkspaceForKind(registration.kind)
                .fieldsForScope(
                  smartList.entityScope ?? state.activeEntityScope,
                )
                .decodeSortId(smartList.sortColumn!),
            sortAscending: smartList.sortAscending ?? true,
          );
        }
      }
      state._session.facets.selectedBucket = null;
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.facets.collectionStatusScope =
          LibraryCollectionStatusScope.all;
      state._session.facets.bucketCompletionScope =
          LibraryBucketCompletionScope.all;
      state._session.preferences.scopeHistory = const [];
    });
    state._syncRouteState();
  }

  static void clearSmartList(GenericLibraryPageState state) {
    state._mutateState(() {
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
      state._session.selection.filterSelection = LibraryFilterSelection.none;
      state._session.facets.quickView = null;
      state._session.facets.collectionStatusScope =
          LibraryCollectionStatusScope.all;
      state._session.facets.bucketCompletionScope =
          LibraryBucketCompletionScope.all;
      state._searchController.clear();
      state._session.facets.selectedBucket = null;
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.preferences.scopeHistory = const [];
    });
    state._searchControllerOps.clearSearch();
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
    if (snapshot.bucketCompletionScope != LibraryBucketCompletionScope.all) {
      return snapshot.bucketCompletionScope.label;
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
    return 'All ${state.widget.type.identity.pluralLabel}';
  }
}
