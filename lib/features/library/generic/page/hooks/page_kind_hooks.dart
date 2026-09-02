part of '../generic_library_page.dart';

// ignore_for_file: invalid_use_of_protected_member, unused_element

extension _PageKindHooks on GenericLibraryPageState {
  LibraryWorkspaceViewProfile get _viewProfile => widget.type.viewProfile;

  LibrarySearchTarget get _effectiveSearchTarget =>
      widget.type.searchTargetOptions.isEmpty
          ? LibrarySearchTarget.all
          : _searchControllerOps.state.target;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.kind);

  bool get _supportsMediaReleaseSplit {
    return widget.type.hierarchy.supportsMediaReleaseSplit;
  }

  bool showsReadingQueue() {
    return widget.type.toolbarActionAvailability
        .allows(LibraryToolbarActionId.readingQueue);
  }

  bool get _isScopedMediaReleaseSplit {
    return _supportsMediaReleaseSplit &&
        widget.type.hierarchy.scopesOptionsByBrowserMode;
  }

  LibraryWorkspaceBrowserMode get _activeBrowserMode {
    return widget.type.hierarchy.browserModeForViewState(
      _viewState ?? _viewProfile.defaults(),
      releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
    );
  }

  bool _shouldOpenReleaseFolder(LibraryProjectionItem item) {
    return widget.type.hierarchy.shouldOpenReleaseFolderOnOpen(
      browserMode: _activeBrowserMode,
      browseScope: item.node.scope,
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
    final titleId = item.node.titleItemId;
    setState(() {
      _kindBrowserDelegate.openReleaseFolder(titleId);
      _selectedBucket = null;
      _selectedLetter = null;
      _selectedId = item.node.id;
    });
    _syncRouteState();
  }

  void _closeReleaseFolder() {
    setState(_kindBrowserDelegate.closeReleaseFolder);
  }

  String? _releaseFolderLabelForProjection(LibraryProjection? projection) {
    final titleId = activeReleaseFolderTitleItemId;
    if (titleId == null || projection == null) {
      return null;
    }
    for (final item in projection.allItems) {
      if (item.node.titleItemId == titleId) {
        return item.dto.title;
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
    final selectedIndex =
        items.indexWhere((item) => item.node.id == _selectedId);
    final index = selectedIndex < 0 ? 0 : selectedIndex;
    return 'Release ${index + 1}/${items.length}';
  }

  List<String> get _scopeAvailableGroupModes {
    return [
      for (final groupId
          in widget.type.availableGroupIdsForBrowserMode(_activeBrowserMode))
        groupId.value,
    ];
  }

  List<String> get _scopeAvailableSortColumns {
    return [
      for (final sortId
          in widget.type.availableSortIdsForBrowserMode(_activeBrowserMode))
        sortId.value,
    ];
  }
}
