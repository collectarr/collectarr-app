part of '../../page.dart';

// ignore_for_file: invalid_use_of_protected_member, unused_element

extension _PageKindHooks on GenericLibraryPageState {
  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  bool get _supportsMusicTrackSearch =>
      widget.type.workspace.kind == CatalogMediaKind.music;

  LibrarySearchTarget get _effectiveSearchTarget =>
      _supportsMusicTrackSearch ? _searchTarget : LibrarySearchTarget.all;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.workspace.kind);

  bool get _supportsMediaReleaseSplit {
    return widget.type.capabilities.supportsMediaReleaseSplit;
  }

  bool get _isScopedMediaReleaseSplit {
    return _supportsMediaReleaseSplit &&
        widget.type.capabilities.scopesOptionsByBrowserMode;
  }

  LibraryWorkspaceBrowserMode get _activeBrowserMode {
    if (!_supportsMediaReleaseSplit) {
      return LibraryWorkspaceBrowserMode.media;
    }
    if (activeReleaseFolderTitleItemId != null) {
      return LibraryWorkspaceBrowserMode.releases;
    }
    return (_viewState ?? _adapter.viewProfile.defaults()).browserMode;
  }

  bool get _isReleaseFolderOpen => activeReleaseFolderTitleItemId != null;

  bool get _shouldShowReleaseFolderBack => _isReleaseFolderOpen;

  bool get _shouldOpenReleaseFolderForMediaTitle {
    return _supportsMediaReleaseSplit &&
        _activeBrowserMode == LibraryWorkspaceBrowserMode.media;
  }

  bool _shouldOpenReleaseFolder(LibraryProjectionItem item) {
    return _shouldOpenReleaseFolderForMediaTitle &&
        item.entry.browseScope == LibraryBrowserScope.title;
  }

  void _setBrowserMode(LibraryWorkspaceBrowserMode mode) {
    _updateViewState((state) => state.copyWith(browserMode: mode));
    setState(() {
      _selectedBucket = null;
      _selectedLetter = null;
      if (mode != LibraryWorkspaceBrowserMode.releases) {
        setActiveReleaseFolderTitleItemId(null);
      }
      _sanitizeScopeDependentState();
    });
  }

  void _openReleaseFolder(LibraryProjectionItem item) {
    final titleId = item.entry.titleItemId ?? item.entry.id;
    setState(() {
      setActiveReleaseFolderTitleItemId(titleId);
      _selectedBucket = null;
      _selectedLetter = null;
      _selectedId = item.entry.id;
    });
    _syncRouteState();
  }

  void _closeReleaseFolder() {
    setState(() => setActiveReleaseFolderTitleItemId(null));
  }

  String? _releaseFolderLabelForProjection(LibraryProjection? projection) {
    final titleId = activeReleaseFolderTitleItemId;
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
    if (activeReleaseFolderTitleItemId == null) {
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

  List<LibraryGroupMode> get _scopeAvailableGroupModes {
    final allowed = widget.type.availableGroupModes;
    if (!_isScopedMediaReleaseSplit) {
      return allowed;
    }
    final scoped = _activeBrowserMode == LibraryWorkspaceBrowserMode.releases
        ? widget.type.capabilities.releaseScopeGroupModes
        : widget.type.capabilities.mediaScopeGroupModes;
    if (scoped == null) {
      return allowed;
    }
    return [
      for (final mode in allowed)
        if (scoped.contains(mode)) mode,
    ];
  }

  List<LibrarySortColumn> get _scopeAvailableSortColumns {
    final allowed = widget.type.availableSortColumns;
    if (!_isScopedMediaReleaseSplit) {
      return allowed;
    }
    final scoped = _activeBrowserMode == LibraryWorkspaceBrowserMode.releases
        ? widget.type.capabilities.releaseScopeSortColumns
        : widget.type.capabilities.mediaScopeSortColumns;
    if (scoped == null) {
      return allowed;
    }
    return [
      for (final column in allowed)
        if (scoped.contains(column)) column,
    ];
  }

}
