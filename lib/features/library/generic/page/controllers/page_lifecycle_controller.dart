part of '../generic_library_page.dart';

abstract final class _LibraryPageLifecycleControllerOps {
  static void initState(GenericLibraryPageState state) {
    state._kindBrowserDelegate =
        libraryHierarchyForKind(state.widget.type.kind).buildBrowserDelegate();
    state._shelfSubscription = state.ref.listenManual<AsyncValue<ShelfState>>(
      shelfProvider,
      (_, next) {
        final shelfState = next.asData?.value;
        if (shelfState != null) {
          state._maybeEnsureFacetBucketsLoaded(
            shelfState,
            state._activeGroupMode,
          );
        }
      },
    );
    unawaited(state._warmViewStateCachesOnce());
    state._session.preferences.viewState = state._viewProfile.defaults();

    // Hydrate & persist Riverpod state
    state.ref.read(libraryWorkspaceHydrationProvider(state.workspaceKey));
    state.ref.listenManual<void>(
      libraryWorkspacePersistenceProvider(state.workspaceKey),
      (_, __) {},
    );

    state._primeCachedViewPreferences();
    state._applyRouteStateFromUri(state.widget.routeUri);
    unawaited(state._loadViewState());
    unawaited(state._loadViewPreferences());
    unawaited(state._loadColumnFavoritePresets());
    unawaited(state._loadActiveLoanIds());
  }

  static Future<void> loadViewPreferences(GenericLibraryPageState state) async {
    try {
      final loadToken = ++state._session.preferences.viewPreferenceLoadToken;
      final expectedKind = state.widget.type.kind;
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
          loadToken != state._session.preferences.viewPreferenceLoadToken ||
          state.widget.type.kind != expectedKind) {
        return;
      }

      final validPinnedSortFavoriteIds = sanitizeLibraryPinnedSortFavoriteIds(
        state.widget.type,
        pinnedSortFavoriteIds,
      );
      final validPinnedColumnFavoriteKeys =
          sanitizeLibraryPinnedColumnFavoriteKeys(
        state.widget.type,
        pinnedColumnFavoriteKeys,
      );
      if (!setEquals(validPinnedSortFavoriteIds, pinnedSortFavoriteIds)) {
        unawaited(
          state._viewPrefs.writePinnedSortFavoriteIds(
            validPinnedSortFavoriteIds,
          ),
        );
      }
      if (!setEquals(validPinnedColumnFavoriteKeys, pinnedColumnFavoriteKeys)) {
        unawaited(
          state._viewPrefs.writePinnedColumnFavoriteKeys(
            validPinnedColumnFavoriteKeys,
          ),
        );
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
      final preferencesChanged = state._session.facets.quickView !=
              sanitizeLibraryQuickViewForType(quickView, state.widget.type) ||
          state._session.preferences.folderPreset != folderPreset ||
          state._session.preferences.groupMode != nextGroupMode ||
          state._session.preferences.groupPresentationOverride !=
              groupPresentationOverride ||
          !setEquals(state._session.preferences.collapsedGroupBuckets,
              collapsedGroupBuckets) ||
          !listEquals(
              state._session.preferences.pinnedFolderPresets, pinnedPresets) ||
          !setEquals(state._session.preferences.pinnedViewPresets,
              pinnedViewPresets) ||
          !setEquals(state._session.preferences.pinnedSortFavoriteIds,
              validPinnedSortFavoriteIds) ||
          !setEquals(state._session.preferences.pinnedColumnFavoriteKeys,
              validPinnedColumnFavoriteKeys);

      if (!preferencesChanged) {
        unawaited(state._loadFolderTreePreferencesForActivePreset());
        return;
      }

      state._mutateState(() {
        state._session.facets.quickView = sanitizeLibraryQuickViewForType(
          quickView,
          state.widget.type,
        );
        state._session.preferences.folderPreset = folderPreset;
        state._session.preferences.groupMode = nextGroupMode;
        state._session.preferences.groupPresentationOverride =
            groupPresentationOverride;
        state._session.preferences.collapsedGroupBuckets =
            collapsedGroupBuckets;
        state._session.preferences.pinnedFolderPresets = pinnedPresets;
        state._session.preferences.pinnedViewPresets = pinnedViewPresets;
        state._session.preferences.pinnedSortFavoriteIds =
            validPinnedSortFavoriteIds;
        state._session.preferences.pinnedColumnFavoriteKeys =
            validPinnedColumnFavoriteKeys;
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
    state._session.facets.quickView = sanitizeLibraryQuickViewForType(
      state._viewPrefs.cachedQuickView,
      state.widget.type,
    );
    state._session.preferences.folderPreset = sanitizeLibraryFolderPreset(
      state._viewPrefs.cachedFolderPreset,
      allowedModes: allowedGroupModes,
    );
    state._session.preferences.groupMode =
        state._session.preferences.folderPreset?.primaryMode;
    state._session.preferences.folderDisplayMode =
        LibraryFolderDisplayMode.drilldown;
    state._session.preferences.folderTreeExpandedNodeIds = const <String>{};
    state._session.preferences.folderTreeSelectedNodeId = null;
    state._session.preferences.groupPresentationOverride = null;
    state._session.preferences.collapsedGroupBuckets = const <String>{};
    state._session.preferences.pinnedFolderPresets =
        state._viewPrefs.cachedPinnedFolderPresets
            .map(
              (preset) => sanitizeLibraryFolderPreset(
                preset,
                allowedModes: allowedGroupModes,
              ),
            )
            .whereType<LibraryFolderPreset>()
            .toList(growable: false);
    state._session.preferences.pinnedViewPresets =
        state._viewPrefs.cachedPinnedViewPresets.isNotEmpty
            ? state._viewPrefs.cachedPinnedViewPresets
            : libraryDefaultPinnedViewPresetsForType(state.widget.type);
    state._session.preferences.pinnedSortFavoriteIds =
        sanitizeLibraryPinnedSortFavoriteIds(
      state.widget.type,
      state._viewPrefs.cachedPinnedSortFavoriteIds.isNotEmpty
          ? state._viewPrefs.cachedPinnedSortFavoriteIds
          : libraryDefaultPinnedSortFavoriteIdsForType(state.widget.type),
    );
    state._session.preferences.pinnedColumnFavoriteKeys =
        sanitizeLibraryPinnedColumnFavoriteKeys(
      state.widget.type,
      state._viewPrefs.cachedPinnedColumnFavoriteKeys.isNotEmpty
          ? state._viewPrefs.cachedPinnedColumnFavoriteKeys
          : libraryDefaultPinnedColumnFavoriteKeysForType(state.widget.type),
    );
  }

  static void didUpdateWidget(
    GenericLibraryPageState state,
    GenericLibraryPage oldWidget,
  ) {
    if (oldWidget.type.kind != state.widget.type.kind) {
      state._session.selection.selectedId = null;
      state._session.facets.selectedBucket = null;
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.selection.value = LibrarySelectionState.empty();
      state._session.selection.filterSelection = LibraryFilterSelection.none;
      state._session.facets.collectionStatusScope =
          LibraryCollectionStatusScope.all;
      state._session.facets.bucketCompletionScope =
          LibraryBucketCompletionScope.all;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
      state._session.preferences.pinnedViewPresets = const {};
      state._session.preferences.pinnedSortFavoriteIds = const {};
      state._session.preferences.pinnedColumnFavoriteKeys = const {};
      state._session.preferences.savedColumnFavoritePresets = const [];
      state._session.preferences.scopeHistory = const [];
      state._session.preferences.folderDisplayMode =
          LibraryFolderDisplayMode.drilldown;
      state._session.preferences.folderTreeExpandedNodeIds = const <String>{};
      state._session.preferences.folderTreeSelectedNodeId = null;
      state._session.preferences.groupPresentationOverride = null;
      state._session.preferences.collapsedGroupBuckets = const <String>{};
      state._session.selection.anchorId = null;
      state._kindBrowserDelegate.closeReleaseFolder();
      state.ref
          .read(
            libraryFacetControllerProvider(
              oldWidget.type.kind.apiValue,
            ).notifier,
          )
          .clearAll();
      state.ref
          .read(
            libraryFacetControllerProvider(
              state.widget.type.kind.apiValue,
            ).notifier,
          )
          .clearAll();
      state._session.facets.lastEnsureSignature = null;
      state._session.facets.lastEnsureFacetId = null;
      state._searchController.clear();
      state._searchControllerOps.clearSearch();
      state._primeCachedViewPreferences();
      // Start from the next kind's own cached defaults/chrome to avoid
      // a one-frame layout jump (e.g. right -> bottom details panel).
      state._session.preferences.viewState = state._viewProfile.defaults();
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
      final expectedKind = state.widget.type.kind;
      final db = state.ref.read(localDatabaseProvider);
      final repo = LoanRepository(db);
      final activeLoans = await repo.getActiveLoans();
      final next = <OwnedItemRef>{
        for (final loan in activeLoans) loan.ownedRef,
      };
      if (!state.mounted ||
          loadToken != state._activeLoanIdsLoadToken ||
          state.widget.type.kind != expectedKind) {
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
    state._filtersSubscription?.close();
    state._viewConfigSubscription?.close();
    state._session.preferences.viewStateSaveDebounce?.cancel();
    state._session.selection.hydrationDebounce?.cancel();
    state._shelfSubscription?.close();
    state._searchController.dispose();
  }
}
