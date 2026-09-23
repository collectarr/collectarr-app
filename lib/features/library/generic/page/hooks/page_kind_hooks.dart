part of '../generic_library_page.dart';

extension _PageKindHooks on GenericLibraryPageState {
  LibraryWorkspaceViewProfile get _viewProfile =>
      libraryViewProfileForKind(widget.type.kind);

  LibrarySearchTarget get _effectiveSearchTarget =>
      librarySearchTargetOptionsForKind(widget.type.kind).isEmpty
          ? LibrarySearchTarget.all
          : _searchControllerOps.state.target;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.kind);

  LibraryWorkspaceBrowserMode get _activeBrowserMode {
    return libraryBrowserNavigationPolicy.browserModeForViewState(
      _session.preferences.viewState ?? _viewProfile.defaults(),
      releaseFolderWorkId: activeReleaseFolderTitleItemId,
    );
  }

  bool _shouldOpenReleaseFolder(LibraryProjectionItem item) {
    return libraryBrowserNavigationPolicy.shouldOpenReleaseFolderOnOpen(
      browserMode: _activeBrowserMode,
      browseScope: item.node.scope,
    );
  }

  void _setBrowserMode(LibraryWorkspaceBrowserMode mode) {
    _updateViewState((state) => state.copyWith(browserMode: mode));
    _mutateState(() {
      _session.facets.selectedBucket = null;
      _session.facets.selectedLetter = null;
      if (mode != LibraryWorkspaceBrowserMode.release) {
        _kindBrowserDelegate.closeReleaseFolder();
      }
      _sanitizeScopeDependentState();
    });
  }

  void _openReleaseFolder(LibraryProjectionItem item) {
    final titleId = item.node.workId;
    _mutateState(() {
      _kindBrowserDelegate.openReleaseFolder(titleId);
      _session.facets.selectedBucket = null;
      _session.facets.selectedLetter = null;
      _session.selection.selectedId = item.node.id;
    });
    _syncRouteState();
  }

  void _closeReleaseFolder() {
    _mutateState(_kindBrowserDelegate.closeReleaseFolder);
  }

  String? _releaseFolderLabelForProjection(LibraryProjection? projection) {
    final titleId = activeReleaseFolderTitleItemId;
    if (titleId == null || projection == null) {
      return null;
    }
    for (final item in projection.allItems) {
      if (item.node.workId == titleId) {
        return item.dto.primaryLabel;
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
    final selectedIndex = items
        .indexWhere((item) => item.node.id == _session.selection.selectedId);
    final index = selectedIndex < 0 ? 0 : selectedIndex;
    return 'Release ${index + 1}/${items.length}';
  }

  List<String> get _scopeAvailableGroupModes {
    return [
      for (final groupId in libraryKindWorkspaceForKind(widget.type.kind)
          .availableGroupIdsForScope(
        libraryBrowserNavigationPolicy.entityScopeForBrowserMode(
          _activeBrowserMode,
        ),
      ))
        groupId.value,
    ];
  }

  List<String> get _scopeAvailableSortColumns {
    return [
      for (final sortId in libraryKindWorkspaceForKind(widget.type.kind)
          .availableSortIdsForScope(
        libraryBrowserNavigationPolicy.entityScopeForBrowserMode(
          _activeBrowserMode,
        ),
      ))
        sortId.value,
    ];
  }
}
