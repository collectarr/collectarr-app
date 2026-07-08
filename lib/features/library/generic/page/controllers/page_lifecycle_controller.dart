part of '../generic_library_page.dart';

abstract final class _LibraryPageLifecycleControllerOps {
  static void initState(GenericLibraryPageState state) {
    state._kindBrowserDelegate =
        state.widget.type.kindBrowserDelegateBuilder?.call() ??
            LibraryNoopBrowserDelegate();
    state._shelfSubscription = state.ref.listenManual<AsyncValue<ShelfState>>(
      shelfProvider,
      (_, next) {
        final shelfState = next.asData?.value;
        if (shelfState != null) {
          state._maybeEnsureFacetBucketsLoaded(
              shelfState, state._activeGroupMode);
        }
      },
    );
    unawaited(state._warmViewStateCachesOnce());
    state._viewState = state._adapter.viewProfile.defaults();
    state._primeCachedViewPreferences();
    state._applyRouteStateFromUri(state.widget.routeUri);
    unawaited(state._loadViewState());
    unawaited(state._loadViewPreferences());
    unawaited(state._loadColumnFavoritePresets());
    unawaited(state._loadActiveLoanIds());
  }

  static Future<void> loadViewPreferences(GenericLibraryPageState state) async {
    try {
      final loadToken = ++state._viewPreferenceLoadToken;
      final expectedKind = state.widget.type.workspace.kind;
      final quickViewFuture = state._viewPrefs.readQuickView();
      final folderPresetFuture = state._viewPrefs.readFolderPreset(
        allowedModes: state._scopeAvailableGroupModes,
      );
      final pinnedPresetsFuture = state._viewPrefs.readPinnedFolderPresets(
        allowedModes: state._scopeAvailableGroupModes,
      );
      final pinnedViewPresetsFuture = state._viewPrefs.readPinnedViewPresets(
        fallback: libraryDefaultPinnedViewPresetsForType(state.widget.type),
      );
      final pinnedSortFavoriteIdsFuture =
          state._viewPrefs.readPinnedSortFavoriteIds(
        fallback: libraryDefaultPinnedSortFavoriteIdsForType(state.widget.type),
      );
      final pinnedColumnFavoriteKeysFuture =
          state._viewPrefs.readPinnedColumnFavoriteKeys(
        fallback: libraryDefaultPinnedColumnFavoriteKeysForType(
          state.widget.type,
        ),
      );

      final (
        quickView,
        folderPreset,
        pinnedPresets,
        pinnedViewPresets,
        pinnedSortFavoriteIds,
        pinnedColumnFavoriteKeys,
      ) = await (
        quickViewFuture,
        folderPresetFuture,
        pinnedPresetsFuture,
        pinnedViewPresetsFuture,
        pinnedSortFavoriteIdsFuture,
        pinnedColumnFavoriteKeysFuture,
      ).wait;
      if (!state.mounted ||
          loadToken != state._viewPreferenceLoadToken ||
          state.widget.type.workspace.kind != expectedKind) {
        return;
      }

      final nextGroupMode = folderPreset?.primaryMode;
      final effectiveFolderPreset = folderPreset ??
          (nextGroupMode == null
              ? null
              : LibraryFolderPreset.single(nextGroupMode));
      final groupPresentationOverride = effectiveFolderPreset == null
          ? null
          : await state._viewPrefs.readGroupPresentationOverride(
              effectiveFolderPreset,
            );
      final collapsedGroupBuckets = effectiveFolderPreset == null
          ? const <String>{}
          : await state._viewPrefs.readCollapsedGroupBuckets(
              effectiveFolderPreset,
            );
      final preferencesChanged = state._quickView !=
              sanitizeLibraryQuickViewForType(quickView, state.widget.type) ||
          state._folderPreset != folderPreset ||
          state._groupMode != nextGroupMode ||
          state._groupPresentationOverride != groupPresentationOverride ||
          !setEquals(state._collapsedGroupBuckets, collapsedGroupBuckets) ||
          !listEquals(state._pinnedFolderPresets, pinnedPresets) ||
          !setEquals(state._pinnedViewPresets, pinnedViewPresets) ||
          !setEquals(state._pinnedSortFavoriteIds, pinnedSortFavoriteIds) ||
          !setEquals(state._pinnedColumnFavoriteKeys, pinnedColumnFavoriteKeys);

      if (!preferencesChanged) {
        unawaited(state._loadFolderTreePreferencesForActivePreset());
        return;
      }

      state._mutateState(() {
        state._quickView = sanitizeLibraryQuickViewForType(
          quickView,
          state.widget.type,
        );
        state._folderPreset = folderPreset;
        state._groupMode = nextGroupMode;
        state._groupPresentationOverride = groupPresentationOverride;
        state._collapsedGroupBuckets = collapsedGroupBuckets;
        state._pinnedFolderPresets = pinnedPresets;
        state._pinnedViewPresets = pinnedViewPresets;
        state._pinnedSortFavoriteIds = pinnedSortFavoriteIds;
        state._pinnedColumnFavoriteKeys = pinnedColumnFavoriteKeys;
        state._applyRouteStateFromUri(state.widget.routeUri);
      });
      unawaited(state._loadFolderTreePreferencesForActivePreset());
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load view preferences.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void primeCachedViewPreferences(GenericLibraryPageState state) {
    final allowedGroupModes = state._scopeAvailableGroupModes.toSet();
    state._quickView = sanitizeLibraryQuickViewForType(
      state._viewPrefs.cachedQuickView,
      state.widget.type,
    );
    state._folderPreset = sanitizeLibraryFolderPreset(
          state._viewPrefs.cachedFolderPreset,
          allowedModes: allowedGroupModes,
        );
    state._groupMode = state._folderPreset?.primaryMode;
    state._folderDisplayMode = LibraryFolderDisplayMode.drilldown;
    state._folderTreeExpandedNodeIds = const <String>{};
    state._folderTreeSelectedNodeId = null;
    state._groupPresentationOverride = null;
    state._collapsedGroupBuckets = const <String>{};
    state._pinnedFolderPresets = state._viewPrefs.cachedPinnedFolderPresets
        .map(
          (preset) => sanitizeLibraryFolderPreset(
            preset,
            allowedModes: allowedGroupModes,
          ),
        )
        .whereType<LibraryFolderPreset>()
        .toList(growable: false);
    state._pinnedViewPresets =
        state._viewPrefs.cachedPinnedViewPresets.isNotEmpty
            ? state._viewPrefs.cachedPinnedViewPresets
            : libraryDefaultPinnedViewPresetsForType(state.widget.type);
    state._pinnedSortFavoriteIds =
        state._viewPrefs.cachedPinnedSortFavoriteIds.isNotEmpty
            ? state._viewPrefs.cachedPinnedSortFavoriteIds
            : libraryDefaultPinnedSortFavoriteIdsForType(state.widget.type);
    state._pinnedColumnFavoriteKeys =
        state._viewPrefs.cachedPinnedColumnFavoriteKeys.isNotEmpty
            ? state._viewPrefs.cachedPinnedColumnFavoriteKeys
            : libraryDefaultPinnedColumnFavoriteKeysForType(state.widget.type);
  }

  static void didUpdateWidget(
    GenericLibraryPageState state,
    GenericLibraryPage oldWidget,
  ) {
    if (oldWidget.type.workspace.kind != state.widget.type.workspace.kind) {
      state._selectedId = null;
      state._selectedBucket = null;
      state._selectedLetter = null;
      state._linkedMetadataFilter = null;
      state._selection = LibrarySelectionState.empty();
      state._filterSelection = LibraryFilterSelection.none;
      state._collectionStatusScope = LibraryCollectionStatusScope.all;
      state._seriesCompletionScope = LibrarySeriesCompletionScope.all;
      state._activeSmartListId = null;
      state._activeSmartListName = null;
      state._pinnedViewPresets = const {};
      state._pinnedSortFavoriteIds = const {};
      state._pinnedColumnFavoriteKeys = const {};
      state._savedColumnFavoritePresets = const [];
      state._scopeHistory = const [];
      state._folderDisplayMode = LibraryFolderDisplayMode.drilldown;
      state._folderTreeExpandedNodeIds = const <String>{};
      state._folderTreeSelectedNodeId = null;
      state._groupPresentationOverride = null;
      state._collapsedGroupBuckets = const <String>{};
      state._selectionAnchorId = null;
      state._kindBrowserDelegate.closeReleaseFolder();
      state.ref
          .read(
            libraryFacetControllerProvider(
              oldWidget.type.workspace.kind.apiValue,
            ).notifier,
          )
          .clearAll();
      state.ref
          .read(
            libraryFacetControllerProvider(
              state.widget.type.workspace.kind.apiValue,
            ).notifier,
          )
          .clearAll();
      state._lastFacetEnsureSignature = null;
      state._lastFacetEnsureMode = null;
      state._searchController.clear();
      state._searchControllerOps.clearSearch();
      state._primeCachedViewPreferences();
      // Start from the next kind's own cached defaults/chrome to avoid
      // a one-frame layout jump (e.g. right -> bottom details panel).
      state._viewState = state._adapter.viewProfile.defaults();
      unawaited(state._loadViewState());
      unawaited(state._loadViewPreferences());
      unawaited(state._loadColumnFavoritePresets());
      unawaited(state._loadActiveLoanIds());
    } else if (oldWidget.routeUri.toString() !=
        state.widget.routeUri.toString()) {
      state._applyRouteStateFromUri(state.widget.routeUri);
    }
  }

  static Future<void> loadActiveLoanIds(GenericLibraryPageState state) async {
    try {
      final loadToken = ++state._activeLoanIdsLoadToken;
      final expectedKind = state.widget.type.workspace.kind;
      final db = state.ref.read(localDatabaseProvider);
      final repo = LoanRepository(db);
      final activeLoans = await repo.getActiveLoans();
      final next = <String>{
        for (final loan in activeLoans) loan.ownedItemId,
      };
      if (!state.mounted ||
          loadToken != state._activeLoanIdsLoadToken ||
          state.widget.type.workspace.kind != expectedKind) {
        return;
      }
      state._mutateState(() => state._activeLoanOwnedItemIds = next);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load active loan IDs.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void dispose(GenericLibraryPageState state) {
    state._viewStateSaveDebounce?.cancel();
    state._selectionHydrationDebounce?.cancel();
    state._shelfSubscription?.close();
    state._searchController.dispose();
  }
}
