part of '../../page.dart';

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
