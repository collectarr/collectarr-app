part of '../generic_library_page.dart';

extension _PageSidebarHooks on GenericLibraryPageState {
  String? get _activeSidebarGroupMode {
    final viewState = _session.preferences.viewState ?? _viewProfile.defaults();
    if (!viewState.isSidebarVisible) {
      return null;
    }
    if (_scopeAvailableGroupModes.contains(_session.preferences.groupMode)) {
      return _session.preferences.groupMode;
    }
    final fallback = _scopeAvailableGroupModes;
    if (fallback.isNotEmpty) {
      return fallback.first;
    }
    return libraryDefaultGroupMode(widget.type);
  }

  String get _projectionGroupMode {
    return _activeSidebarGroupMode ?? LibraryStandardGroupIds.title.value;
  }

  String get _activeGroupMode => _projectionGroupMode;

  void _sanitizeScopeDependentState() {
    final allowedModes = _scopeAvailableGroupModes.toSet();
    final allowedSort = _scopeAvailableSortColumns.toSet();
    _session.preferences.groupMode = _session.preferences.groupMode != null &&
            allowedModes.contains(_session.preferences.groupMode)
        ? _session.preferences.groupMode
        : (allowedModes.isNotEmpty ? allowedModes.first : null);
    _session.preferences.folderPreset = sanitizeLibraryFolderPreset(
      _session.preferences.folderPreset,
      allowedModes: allowedModes,
    );
    _session.preferences.pinnedFolderPresets = [
      for (final preset in _session.preferences.pinnedFolderPresets)
        if (sanitizeLibraryFolderPreset(preset, allowedModes: allowedModes)
            case final sanitized?)
          sanitized,
    ];
    final viewState = _session.preferences.viewState;
    if (viewState != null) {
      final filteredRules = [
        for (final rule in viewState.sortRules)
          if (allowedSort.contains(rule.sortId.value)) rule,
      ];
      final defaults = _viewProfile.defaults().sortRules;
      final fallbackRules = [
        for (final rule in defaults)
          if (allowedSort.contains(rule.sortId.value)) rule,
      ];
      _session.preferences.viewState = viewState.copyWith(
        sortRules: filteredRules.isNotEmpty ? filteredRules : fallbackRules,
      );
    }
  }

  LibraryFolderPreset get _activeFolderPreset =>
      sanitizeLibraryFolderPreset(
        _session.preferences.folderPreset,
        allowedModes: _scopeAvailableGroupModes,
      ) ??
      LibraryFolderPreset.single(_activeGroupMode);

  LibraryGroupPresentation get _activeGroupPresentation {
    return _session.preferences.groupPresentationOverride ??
        genericGroupPresentationForMode(_activeGroupMode, widget.type);
  }

  bool get _hasActiveFilter =>
      _searchControllerOps.state.query.trim().isNotEmpty ||
      _session.facets.linkedMetadataFilter != null ||
      _session.facets.selectedBucket != null ||
      _session.facets.selectedLetter != null ||
      _session.facets.collectionStatusScope !=
          LibraryCollectionStatusScope.all ||
      _session.facets.quickView != null ||
      _session.preferences.activeSmartListId != null ||
      activeReleaseFolderTitleItemId != null ||
      _session.selection.filterSelection.hasActiveFilters;

  void _setGroupMode(String mode) {
    _setFolderPreset(LibraryFolderPreset.single(mode));
  }

  void _setFolderPreset(LibraryFolderPreset preset) {
    final sanitized = sanitizeLibraryFolderPreset(
      preset,
      allowedModes: _scopeAvailableGroupModes,
    );
    if (sanitized == null) {
      return;
    }
    _mutateState(() {
      _session.preferences.folderPreset = sanitized;
      _session.preferences.groupMode = sanitized.primaryMode;
      if (_session.preferences.groupMode == null ||
          !libraryGroupModeSupportsCompletion(
              widget.type, _session.preferences.groupMode!)) {
        _session.facets.bucketCompletionScope =
            LibraryBucketCompletionScope.all;
      }
      _session.facets.selectedBucket = null;
      _session.facets.selectedLetter = null;
      _session.facets.linkedMetadataFilter = null;
      _session.preferences.activeSmartListId = null;
      _session.preferences.activeSmartListName = null;
      _session.preferences.scopeHistory = const [];
    });
    _syncRouteState();
    final shelfState = _pageRef.read(shelfProvider).asData?.value;
    if (shelfState != null) {
      _maybeEnsureFacetBucketsLoaded(shelfState, sanitized.primaryMode);
    }
    unawaited(_viewPrefs.writeFolderPreset(sanitized));
    unawaited(_loadFolderTreePreferencesForActivePreset());
  }

  void _setGroupPresentation(LibraryGroupPresentation presentation) {
    final preset = _activeFolderPreset;
    if (_session.preferences.groupPresentationOverride == presentation) {
      return;
    }
    _mutateState(() {
      _session.preferences.groupPresentationOverride = presentation;
    });
    unawaited(_viewPrefs.writeGroupPresentationOverride(preset, presentation));
  }

  void _toggleCollapsedGroupBucket(String bucket) {
    final preset = _activeFolderPreset;
    final next = Set<String>.from(_session.preferences.collapsedGroupBuckets);
    if (!next.add(bucket)) {
      next.remove(bucket);
    }
    _mutateState(() {
      _session.preferences.collapsedGroupBuckets = next;
    });
    unawaited(_viewPrefs.writeCollapsedGroupBuckets(preset, next));
  }

  void _setCollapsedGroupBuckets(Set<String> buckets) {
    final preset = _activeFolderPreset;
    final next = Set<String>.unmodifiable(buckets);
    if (setEquals(next, _session.preferences.collapsedGroupBuckets)) {
      return;
    }
    _mutateState(() {
      _session.preferences.collapsedGroupBuckets = next;
    });
    unawaited(_viewPrefs.writeCollapsedGroupBuckets(preset, next));
  }

  LibraryRouteState _buildRouteState() {
    final viewState = _session.preferences.viewState ?? _viewProfile.defaults();
    final allowedSortColumns = _scopeAvailableSortColumns.toSet();
    final scopedSortRules = [
      for (final rule in viewState.sortRules)
        if (allowedSortColumns.contains(rule.sortId.value))
          LibrarySortRule(
            column: rule.sortId.value,
            ascending: rule.ascending,
          ),
    ];
    final searchState = _searchControllerOps.state;
    return LibraryRouteState(
      kind: widget.type.kind.apiValue,
      searchQuery: _trimmedQuery(searchState.query),
      groupMode: viewState.isSidebarVisible ? _activeGroupMode : null,
      folderPreset: viewState.isSidebarVisible ? _activeFolderPreset : null,
      selectedBucket: _session.facets.selectedBucket,
      linkedMetadataValue: _session.facets.linkedMetadataFilter?.value,
      selectedLetter: _session.facets.selectedLetter,
      collectionStatusScope: _session.facets.collectionStatusScope,
      bucketCompletionScope:
          libraryGroupModeSupportsCompletion(widget.type, _activeGroupMode)
              ? _session.facets.bucketCompletionScope
              : LibraryBucketCompletionScope.all,
      quickView: _session.facets.quickView,
      filterSelection: _session.selection.filterSelection,
      sortRules: scopedSortRules,
      isSidebarVisible: viewState.isSidebarVisible,
    );
  }

  void _syncRouteState() {
    if (!mounted) {
      return;
    }
    if (GoRouter.maybeOf(context) == null) {
      return;
    }
    final nextUri = _buildRouteState().toUri(
      widget.routeUri,
      type: widget.type,
    );
    if (nextUri.toString() == widget.routeUri.toString()) {
      return;
    }
    context.replace(nextUri.toString());
  }

  void _applyRouteStateFromUri(Uri uri) {
    final routeState =
        LibraryRouteState.fromUri(uri).filteredForType(widget.type);
    if (!routeState.hasExplicitViewState) {
      return;
    }
    final currentViewState =
        _session.preferences.viewState ?? _viewProfile.defaults();
    final allowedSortColumns = _scopeAvailableSortColumns.toSet();
    final currentSortRules = [
      for (final rule in currentViewState.sortRules)
        LibrarySortRule(
          column: rule.sortId.value,
          ascending: rule.ascending,
        ),
    ];
    final routeSortRules = [
      for (final rule in _viewProfile.decodeSortRules(
        routeState.sortRules ?? currentSortRules,
      ))
        if (allowedSortColumns.contains(rule.sortId.value)) rule,
    ];
    _session.preferences.viewState = currentViewState.copyWith(
      isSidebarVisible:
          routeState.isSidebarVisible ?? currentViewState.isSidebarVisible,
      sortRules: routeSortRules,
    );
    final sidebarVisible = _session.preferences.viewState!.isSidebarVisible;
    final routeFolderPreset = sanitizeLibraryFolderPreset(
      routeState.folderPreset,
      allowedModes: _scopeAvailableGroupModes,
    );
    _session.preferences.groupMode = sidebarVisible
        ? routeFolderPreset?.primaryMode ??
            routeState.groupMode ??
            (_scopeAvailableGroupModes.isNotEmpty
                ? _scopeAvailableGroupModes.first
                : libraryDefaultGroupMode(widget.type))
        : null;
    _session.preferences.folderPreset = !sidebarVisible
        ? null
        : routeFolderPreset ??
            (_session.preferences.groupMode == null
                ? null
                : LibraryFolderPreset.single(_session.preferences.groupMode!));
    _session.facets.selectedBucket = routeState.selectedBucket;
    _session.facets.selectedLetter = routeState.selectedLetter;
    _session.facets.linkedMetadataFilter = routeState.linkedMetadataValue ==
            null
        ? null
        : LibraryLinkedMetadataFilter(value: routeState.linkedMetadataValue!);
    _session.facets.collectionStatusScope = routeState.collectionStatusScope;
    _session.facets.bucketCompletionScope = routeState.bucketCompletionScope;
    _session.facets.quickView = routeState.quickView;
    _sanitizeScopeDependentState();
    _session.selection.filterSelection = routeState.filterSelection;
    _session.preferences.activeSmartListId = null;
    _session.preferences.activeSmartListName = null;
    _session.preferences.scopeHistory = const [];
    final routeQuery = routeState.searchQuery ?? '';
    _searchController.value = _searchController.value.copyWith(
      text: routeQuery,
      selection: TextSelection.collapsed(offset: routeQuery.length),
      composing: TextRange.empty,
    );
    _searchControllerOps.state.setQuery(routeQuery);
    final shelfState = _pageRef.read(shelfProvider).asData?.value;
    if (shelfState != null) {
      _maybeEnsureFacetBucketsLoaded(shelfState, _activeGroupMode);
    }
  }

  String? _trimmedQuery(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
