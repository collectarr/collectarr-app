part of '../generic_library_page.dart';

// ignore_for_file: invalid_use_of_protected_member, unused_element

extension _PageKindHooks on GenericLibraryPageState {
  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      collectarrMediaAdapter(widget.type);

  bool get _supportsMusicTrackSearch =>
      widget.type.kindUiAdapter.supportsMusicTrackSearch(widget.type);

  LibrarySearchTarget get _effectiveSearchTarget => _supportsMusicTrackSearch
      ? _searchControllerOps.state.target
      : LibrarySearchTarget.all;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.workspace.kind);

  bool get _supportsMediaReleaseSplit {
    return widget.type.supportsMediaReleaseSplit;
  }

  bool showsReadingQueue() {
    return widget.type.kindUiAdapter.showsReadingQueue(widget.type);
  }

  bool get _isScopedMediaReleaseSplit {
    return _supportsMediaReleaseSplit &&
        widget.type.capabilities.scopesOptionsByBrowserMode;
  }

  LibraryWorkspaceBrowserMode get _activeBrowserMode {
    return widget.type.kindUiAdapter.browserModeForViewState(
      widget.type,
      _viewState ?? _adapter.viewProfile.defaults(),
      releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
    );
  }

  bool _shouldOpenReleaseFolder(LibraryProjectionItem item) {
    return widget.type.kindUiAdapter.shouldOpenReleaseFolderOnOpen(
      widget.type,
      browserMode: _activeBrowserMode,
      browseScope: item.entry.browseScope,
    );
  }

  void _setBrowserMode(LibraryWorkspaceBrowserMode mode) {
    _updateViewState((state) => state.copyWith(browserMode: mode));
    setState(() {
      _selectedBucket = null;
      _selectedLetter = null;
      if (mode != LibraryWorkspaceBrowserMode.releases) {
        _kindBrowserDelegate.closeReleaseFolder();
      }
      _sanitizeScopeDependentState();
    });
  }

  void _openReleaseFolder(LibraryProjectionItem item) {
    final titleId = item.entry.titleItemId ?? item.entry.id;
    setState(() {
      _kindBrowserDelegate.openReleaseFolder(titleId);
      _selectedBucket = null;
      _selectedLetter = null;
      _selectedId = item.entry.id;
    });
    _syncRouteState();
  }

  void _closeReleaseFolder() {
    setState(_kindBrowserDelegate.closeReleaseFolder);
  }

  String? _releaseFolderLabelForProjection(LibraryProjection? projection) {
    return widget.type.kindUiAdapter.releaseFolderLabelForProjection(
      widget.type,
      projection,
      releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
    );
  }

  String? _releasePositionLabelForProjection(LibraryProjection projection) {
    if (activeReleaseFolderTitleItemId == null) {
      return null;
    }
    final items = projection.filteredItems;
    if (items.isEmpty) {
      return null;
    }
    final selectedIndex =
        items.indexWhere((item) => item.entry.id == _selectedId);
    final index = selectedIndex < 0 ? 0 : selectedIndex;
    return 'Release ${index + 1}/${items.length}';
  }

  List<LibraryGroupMode> get _scopeAvailableGroupModes {
    return widget.type.availableGroupModesForBrowserMode(_activeBrowserMode);
  }

  List<LibrarySortColumn> get _scopeAvailableSortColumns {
    return widget.type.availableSortColumnsForBrowserMode(_activeBrowserMode);
  }
}
