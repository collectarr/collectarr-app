part of '../../page.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _PageSidebarHooks on GenericLibraryPageState {
  LibraryGroupMode? get _activeSidebarGroupMode {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    if (!viewState.isSidebarVisible) {
      return null;
    }
    if (_scopeAvailableGroupModes.contains(_groupMode)) {
      return _groupMode;
    }
    final fallback = _scopeAvailableGroupModes;
    if (fallback.isNotEmpty) {
      return fallback.first;
    }
    return libraryDefaultGroupMode(widget.type);
  }

  LibraryGroupMode get _projectionGroupMode {
    return _activeBrowserMode == LibraryWorkspaceBrowserMode.releases &&
            !_isScopedMediaReleaseSplit
        ? LibraryGroupMode.title
        : (_activeSidebarGroupMode ?? LibraryGroupMode.title);
  }

  LibraryGroupMode get _activeGroupMode => _projectionGroupMode;

  void _sanitizeScopeDependentState() {
    final allowedModes = _scopeAvailableGroupModes.toSet();
    final allowedSort = _scopeAvailableSortColumns.toSet();
    _groupMode = _groupMode != null && allowedModes.contains(_groupMode)
        ? _groupMode
        : (allowedModes.isNotEmpty ? allowedModes.first : null);
    _folderPreset = sanitizeLibraryFolderPreset(
      _folderPreset,
      allowedModes: allowedModes,
    );
    _pinnedFolderPresets = [
      for (final preset in _pinnedFolderPresets)
        if (sanitizeLibraryFolderPreset(preset, allowedModes: allowedModes)
            case final sanitized?)
          sanitized,
    ];
    final viewState = _viewState;
    if (viewState != null) {
      final filteredRules = [
        for (final rule in viewState.sortRules)
          if (allowedSort.contains(rule.column)) rule,
      ];
      final defaults = _adapter.viewProfile.defaults().sortRules;
      final fallbackRules = [
        for (final rule in defaults)
          if (allowedSort.contains(rule.column)) rule,
      ];
      _viewState = viewState.copyWith(
        sortRules: filteredRules.isNotEmpty ? filteredRules : fallbackRules,
      );
    }
  }

  LibraryWorkspaceBrowserMode get _activeBrowserMode {
    if (!_supportsMediaReleaseSplit) {
      return LibraryWorkspaceBrowserMode.media;
    }
    if (_releaseFolderTitleItemId != null) {
      return LibraryWorkspaceBrowserMode.releases;
    }
    return (_viewState ?? _adapter.viewProfile.defaults()).browserMode;
  }

  void _setBrowserMode(LibraryWorkspaceBrowserMode mode) {
    _updateViewState((state) => state.copyWith(browserMode: mode));
    setState(() {
      _selectedBucket = null;
      _selectedLetter = null;
      if (mode != LibraryWorkspaceBrowserMode.releases) {
        _releaseFolderTitleItemId = null;
      }
      _sanitizeScopeDependentState();
    });
  }

  void _openReleaseFolder(LibraryProjectionItem item) {
    final titleId = item.entry.titleItemId ?? item.entry.id;
    setState(() {
      _releaseFolderTitleItemId = titleId;
      _selectedBucket = null;
      _selectedLetter = null;
      _selectedId = item.entry.id;
    });
    _syncRouteState();
  }

  void _closeReleaseFolder() {
    setState(() => _releaseFolderTitleItemId = null);
  }

  String? _releaseFolderLabelForProjection(LibraryProjection? projection) {
    final titleId = _releaseFolderTitleItemId;
    if (titleId == null || projection == null) {
      return null;
    }
    for (final item in projection.allItems) {
      if ((item.entry.titleItemId ?? item.entry.id) == titleId) {
        return item.entry.resolvedTitle;
      }
    }
    return null;
  }

  String? _releasePositionLabelForProjection(LibraryProjection projection) {
    if (_releaseFolderTitleItemId == null) {
      return null;
    }
    final items = projection.filteredItems;
    if (items.isEmpty) {
      return null;
    }
    final selectedIndex = items.indexWhere((item) => item.entry.id == _selectedId);
    final index = selectedIndex < 0 ? 0 : selectedIndex;
    return 'Release ${index + 1}/${items.length}';
  }

  LibraryFolderPreset get _activeFolderPreset =>
      sanitizeLibraryFolderPreset(
        _folderPreset,
        allowedModes: _scopeAvailableGroupModes,
      ) ??
      LibraryFolderPreset.single(_activeGroupMode);

  bool get _hasActiveFilter =>
      _appliedSearchQuery.trim().isNotEmpty ||
      _linkedMetadataFilter != null ||
      _selectedBucket != null ||
      _selectedLetter != null ||
      _collectionStatusScope != LibraryCollectionStatusScope.all ||
      _quickView != null ||
      _activeSmartListId != null ||
      _releaseFolderTitleItemId != null ||
      _filterSelection.hasActiveFilters;

  void _setGroupMode(LibraryGroupMode mode) {
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
    setState(() {
      _folderPreset = sanitized;
      _groupMode = sanitized.primaryMode;
      if (_groupMode != LibraryGroupMode.series) {
        _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      }
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _scopeHistory = const [];
    });
    _syncRouteState();
    final shelfState = ref.read(shelfProvider).asData?.value;
    if (shelfState != null) {
      _maybeEnsureFacetBucketsLoaded(shelfState, sanitized.primaryMode);
    }
    unawaited(_viewPrefs.writeFolderPreset(sanitized));
    unawaited(_viewPrefs.writeGroupMode(sanitized.primaryMode));
  }

  LibraryRouteState _buildRouteState() {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    final allowedSortColumns = _scopeAvailableSortColumns.toSet();
    final scopedSortRules = [
      for (final rule in viewState.sortRules)
        if (allowedSortColumns.contains(rule.column)) rule,
    ];
    return LibraryRouteState(
      kind: widget.type.workspace.kind.apiValue,
      searchQuery: _trimmedQuery(_appliedSearchQuery),
      groupMode: viewState.isSidebarVisible ? _activeGroupMode : null,
      folderPreset: viewState.isSidebarVisible ? _activeFolderPreset : null,
      selectedBucket: _selectedBucket,
      linkedMetadataValue: _linkedMetadataFilter?.value,
      selectedLetter: _selectedLetter,
      collectionStatusScope: _collectionStatusScope,
      seriesCompletionScope: _activeGroupMode == LibraryGroupMode.series
          ? _seriesCompletionScope
          : LibrarySeriesCompletionScope.all,
      quickView: _quickView,
      filterSelection: _filterSelection,
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
      kind: widget.type.workspace.kind.apiValue,
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
    final currentViewState = _viewState ?? _adapter.viewProfile.defaults();
    final allowedSortColumns = _scopeAvailableSortColumns.toSet();
    final routeSortRules = [
      for (final rule in (routeState.sortRules ?? currentViewState.sortRules))
        if (allowedSortColumns.contains(rule.column)) rule,
    ];
    _viewState = currentViewState.copyWith(
      isSidebarVisible:
          routeState.isSidebarVisible ?? currentViewState.isSidebarVisible,
      sortRules: routeSortRules,
    );
    final sidebarVisible = _viewState!.isSidebarVisible;
    final routeFolderPreset = sanitizeLibraryFolderPreset(
      routeState.folderPreset,
      allowedModes: _scopeAvailableGroupModes,
    );
    _groupMode = sidebarVisible
        ? routeFolderPreset?.primaryMode ??
            routeState.groupMode ??
            (_scopeAvailableGroupModes.isNotEmpty
                ? _scopeAvailableGroupModes.first
                : libraryDefaultGroupMode(widget.type))
        : null;
    _folderPreset = !sidebarVisible
        ? null
        : routeFolderPreset ??
            (_groupMode == null
                ? null
                : LibraryFolderPreset.single(_groupMode!));
    _selectedBucket = routeState.selectedBucket;
    _selectedLetter = routeState.selectedLetter;
    _linkedMetadataFilter = routeState.linkedMetadataValue == null
        ? null
        : LibraryLinkedMetadataFilter(value: routeState.linkedMetadataValue!);
    _collectionStatusScope = routeState.collectionStatusScope;
    _seriesCompletionScope = routeState.seriesCompletionScope;
    _quickView = routeState.quickView;
    _sanitizeScopeDependentState();
    _filterSelection = routeState.filterSelection;
    _activeSmartListId = null;
    _activeSmartListName = null;
    _scopeHistory = const [];
    final routeQuery = routeState.searchQuery ?? '';
    _searchController.value = _searchController.value.copyWith(
      text: routeQuery,
      selection: TextSelection.collapsed(offset: routeQuery.length),
      composing: TextRange.empty,
    );
    _appliedSearchQuery = routeQuery;
    _searchPinnedItemId = null;
    final shelfState = ref.read(shelfProvider).asData?.value;
    if (shelfState != null) {
      _maybeEnsureFacetBucketsLoaded(shelfState, _activeGroupMode);
    }
  }

  String? _trimmedQuery(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
