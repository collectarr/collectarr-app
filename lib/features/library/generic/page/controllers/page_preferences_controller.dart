part of '../generic_library_page.dart';

abstract final class LibraryPagePreferencesControllerOps {
  static Future<void> loadColumnFavoritePresets(
    GenericLibraryPageState state,
  ) async {
    try {
      final loadToken = ++state._session.preferences.columnFavoritesLoadToken;
      final expectedKind = state.widget.type.kind;
      final presets = await LibraryColumnPresetStore(
        state.widget.type,
        scope: state._activeBrowserMode == LibraryWorkspaceBrowserMode.release
            ? LibraryEntityScope.release
            : LibraryEntityScope.work,
      ).read();
      if (!state.mounted ||
          loadToken != state._session.preferences.columnFavoritesLoadToken ||
          state.widget.type.kind != expectedKind) {
        return;
      }
      state._mutateState(() =>
          state._session.preferences.savedColumnFavoritePresets = presets);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load column favorites.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void setPinnedFolderPresets(
    GenericLibraryPageState state,
    List<LibraryFolderPreset> presets,
  ) {
    final updated = <LibraryFolderPreset>[];
    for (final preset in presets) {
      final sanitized = sanitizeLibraryFolderPreset(
        preset,
        allowedModes: state._scopeAvailableGroupModes,
      );
      if (sanitized != null && !updated.contains(sanitized)) {
        updated.add(sanitized);
      }
    }
    state._mutateState(
        () => state._session.preferences.pinnedFolderPresets = updated);
    unawaited(state._viewPrefs.writePinnedFolderPresets(updated));
  }

  static Future<void> loadFolderTreePreferencesForActivePreset(
    GenericLibraryPageState state,
  ) async {
    final preset = state._activeFolderPreset;
    try {
      final loadToken =
          ++state._session.preferences.folderTreePreferenceLoadToken;
      final expectedKind = state.widget.type.kind;
      final displayModeFuture = state._viewPrefs.readFolderDisplayMode(preset);
      final expandedNodeIdsFuture =
          state._viewPrefs.readFolderTreeExpandedNodeIds(preset);
      final selectedNodeIdFuture =
          state._viewPrefs.readFolderTreeSelectedNodeId(preset);
      final groupPresentationFuture =
          state._viewPrefs.readGroupPresentationOverride(preset);
      final collapsedGroupBucketsFuture =
          state._viewPrefs.readCollapsedGroupBuckets(preset);
      final (displayMode, expandedNodeIds, selectedNodeId) = await (
        displayModeFuture,
        expandedNodeIdsFuture,
        selectedNodeIdFuture
      ).wait;
      final groupPresentationOverride = await groupPresentationFuture;
      final collapsedGroupBuckets = await collapsedGroupBucketsFuture;
      if (!state.mounted ||
          loadToken !=
              state._session.preferences.folderTreePreferenceLoadToken ||
          state.widget.type.kind != expectedKind) {
        return;
      }
      state._mutateState(() {
        state._session.preferences.folderDisplayMode =
            displayMode ?? LibraryFolderDisplayMode.drilldown;
        state._session.preferences.folderTreeExpandedNodeIds = expandedNodeIds;
        state._session.preferences.folderTreeSelectedNodeId = selectedNodeId;
        state._session.preferences.groupPresentationOverride =
            groupPresentationOverride;
        state._session.preferences.collapsedGroupBuckets =
            collapsedGroupBuckets;
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load folder tree preferences.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void setFolderDisplayMode(
    GenericLibraryPageState state,
    LibraryFolderDisplayMode mode,
  ) {
    final preset = state._activeFolderPreset;
    state._mutateState(() {
      state._session.preferences.folderDisplayMode = mode;
      if (mode == LibraryFolderDisplayMode.drilldown) {
        state._session.preferences.folderTreeExpandedNodeIds = const <String>{};
        state._session.preferences.folderTreeSelectedNodeId = null;
      }
    });
    unawaited(state._viewPrefs.writeFolderDisplayMode(preset, mode));
    if (mode == LibraryFolderDisplayMode.drilldown) {
      unawaited(
          state._viewPrefs.writeFolderTreeExpandedNodeIds(preset, const {}));
      unawaited(state._viewPrefs.writeFolderTreeSelectedNodeId(preset, null));
    }
  }

  static void toggleFolderTreeNodeExpanded(
    GenericLibraryPageState state,
    String nodeId,
  ) {
    final preset = state._activeFolderPreset;
    final next =
        Set<String>.from(state._session.preferences.folderTreeExpandedNodeIds);
    if (!next.add(nodeId)) {
      next.remove(nodeId);
    }
    state._mutateState(() {
      state._session.preferences.folderTreeExpandedNodeIds = next;
    });
    unawaited(state._viewPrefs.writeFolderTreeExpandedNodeIds(preset, next));
  }

  static void selectFolderTreePath(
    GenericLibraryPageState state,
    List<LibraryFolderTreeNode> path,
  ) {
    if (path.isEmpty) {
      return;
    }
    final preset = state._activeFolderPreset;
    final leaf = path.last;
    final expanded =
        Set<String>.from(state._session.preferences.folderTreeExpandedNodeIds);
    for (final node in path) {
      expanded.add(node.id);
    }
    state._mutateState(() {
      state._session.preferences.folderTreeExpandedNodeIds = expanded;
      state._session.preferences.folderTreeSelectedNodeId = leaf.id;
    });
    unawaited(
        state._viewPrefs.writeFolderTreeExpandedNodeIds(preset, expanded));
    unawaited(state._viewPrefs.writeFolderTreeSelectedNodeId(preset, leaf.id));
    final bucketPath = [
      for (final node in path)
        if (node.bucketValue != null) node.bucketValue!,
    ];
    if (bucketPath.isEmpty) {
      state._setSelectedBucket(null);
      return;
    }
    state._mutateState(() {
      state._session.facets.selectedBucket = null;
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
      state._session.preferences.scopeHistory = const [];
      state._session.preferences.groupMode = preset.primaryMode;
    });
    for (final bucket in bucketPath) {
      state._setSelectedBucket(bucket);
    }
  }

  static void applyViewPreset(
    GenericLibraryPageState state,
    LibraryWorkspacePreset preset,
  ) {
    state._updateViewState((viewState) => viewState.withPreset(
          preset,
          state._viewProfile,
        ));
  }

  static void togglePinnedViewPreset(
    GenericLibraryPageState state,
    LibraryWorkspacePreset preset,
  ) {
    final next = Set<LibraryWorkspacePreset>.from(
        state._session.preferences.pinnedViewPresets);
    if (!next.add(preset)) {
      next.remove(preset);
    }
    state._mutateState(
        () => state._session.preferences.pinnedViewPresets = next);
    unawaited(state._viewPrefs.writePinnedViewPresets(next));
  }

  static void applySortFavorite(
    GenericLibraryPageState state,
    LibrarySortFavorite favorite,
  ) {
    state._updateViewState(
      (viewState) => viewState.withSortRules(
        state._viewProfile.decodeSortRules(favorite.rules),
        state._viewProfile,
      ),
    );
  }

  static void togglePinnedSortFavorite(
    GenericLibraryPageState state,
    LibrarySortFavorite favorite,
  ) {
    final next =
        Set<String>.from(state._session.preferences.pinnedSortFavoriteIds);
    if (!next.add(favorite.id)) {
      next.remove(favorite.id);
    }
    state._mutateState(
        () => state._session.preferences.pinnedSortFavoriteIds = next);
    unawaited(state._viewPrefs.writePinnedSortFavoriteIds(next));
  }

  static void applyColumnFavorite(
    GenericLibraryPageState state,
    LibraryTableColumnPreset preset,
  ) {
    state._updateViewState((viewState) => viewState.copyWith(
          visibleColumnIds: state._viewProfile.decodeColumnIds(preset.columns),
        ));
  }

  static void togglePinnedColumnFavorite(
    GenericLibraryPageState state,
    LibraryTableColumnPreset preset,
  ) {
    final key = libraryColumnFavoriteKey(preset);
    final next =
        Set<String>.from(state._session.preferences.pinnedColumnFavoriteKeys);
    if (!next.add(key)) {
      next.remove(key);
    }
    state._mutateState(
        () => state._session.preferences.pinnedColumnFavoriteKeys = next);
    unawaited(state._viewPrefs.writePinnedColumnFavoriteKeys(next));
  }

  static String? activeColumnFavoriteLabel(GenericLibraryPageState state) {
    final viewState =
        state._session.preferences.viewState ?? state._viewProfile.defaults();
    for (final preset in state._columnFavoritePresets) {
      if (setEquals(state._viewProfile.decodeColumnIds(preset.columns),
          viewState.visibleColumnIds)) {
        return preset.label;
      }
    }
    return null;
  }

  static LibrarySortFavorite? activeSortFavorite(
      GenericLibraryPageState state) {
    final viewState =
        state._session.preferences.viewState ?? state._viewProfile.defaults();
    for (final favorite in state._sortFavorites) {
      final currentRules = [
        for (final rule in viewState.sortRules)
          LibrarySortRule(
            column: rule.sortId.value,
            ascending: rule.ascending,
          ),
      ];
      if (state._sameSortRules(favorite.rules, currentRules)) {
        return favorite;
      }
    }
    return null;
  }

  static LibraryWorkspacePreset? activeViewPreset(
    GenericLibraryPageState state,
  ) {
    final viewState =
        state._session.preferences.viewState ?? state._viewProfile.defaults();
    for (final preset in LibraryWorkspacePreset.values) {
      final config = state._viewProfile.presetConfig(preset);
      if (viewState.viewMode == config.viewMode &&
          viewState.detailsLayout == config.detailsLayout &&
          viewState.coverSize == config.coverSize &&
          setEquals(viewState.visibleColumnIds, config.visibleColumns)) {
        return preset;
      }
    }
    return null;
  }
}
