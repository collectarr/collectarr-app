part of '../../page.dart';

extension _PageToolbarBuilder on GenericLibraryPageState {
  Widget _buildToolbar({
    required LibraryProjection? projection,
    required LibraryWorkspaceViewState viewState,
    required ShelfState? shelfState,
  }) {
    final searchState = ref.watch(
      libraryPageSearchStateProvider(_searchStateKey),
    );
    final searchSuggestions = ref.watch(
      libraryToolbarSearchSuggestionsProvider((
        projection: projection,
        query: searchState.query,
      )),
    );
    final showReleaseFolderBack = widget.type.kindUiAdapter.shouldShowReleaseFolderBack(
      widget.type,
      browserMode: _activeBrowserMode,
      releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
    );

    return LibraryToolbar(
      type: widget.type,
      adapter: _adapter,
      browserMode: _activeBrowserMode,
      supportsMediaReleaseSplit: _supportsMediaReleaseSplit,
      includeDesktopSecondaryBand: false,
      searchController: _searchController,
      viewState: viewState,
      counts: projection?.counts ?? const LibraryToolbarCounts(),
      searchTarget: _effectiveSearchTarget,
      searchTargetOptions: _supportsMusicTrackSearch
          ? const <LibrarySearchTarget>[
              LibrarySearchTarget.all,
              LibrarySearchTarget.mediaOnly,
              LibrarySearchTarget.tracksOnly,
            ]
          : const <LibrarySearchTarget>[],
      searchActive:
          searchState.query.isNotEmpty || searchState.pinnedItemId != null,
      searchSuggestions: searchSuggestions,
      selectedBucket: _linkedMetadataFilter?.chipLabel ?? _selectedBucket,
      collectionStatusScope: _collectionStatusScope,
      quickView: _quickView,
      availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
        (projection?.filteredItems ?? const <LibraryProjectionItem>[])
            .map((i) => i.entry.resolvedTitle),
      ),
      selectedLetter: _selectedLetter,
      activeViewPreset: _activeViewPreset,
      pinnedViewPresets: _pinnedViewPresets,
      sortFavorites: _sortFavorites,
      activeSortFavoriteId: _activeSortFavorite?.id,
      pinnedSortFavoriteIds: _pinnedSortFavoriteIds,
      columnFavoritePresets: _columnFavoritePresets,
      activeColumnFavoriteLabel: _activeColumnFavoriteLabel,
      pinnedColumnFavoriteKeys: _pinnedColumnFavoriteKeys,
      canJumpToIssue: _canJumpToIssue(projection),
      hasActiveFilters: _hasActiveFilter,
      activeFilterCount: _filterSelection.activeFilterCount,
      shelfState: shelfState,
      groupMode: _activeSidebarGroupMode,
      folderPreset: _activeFolderPreset,
      availableGroupModes: _scopeAvailableGroupModes,
      pinnedFolderPresets: _pinnedFolderPresets,
      selectionCallbacks: viewState.viewMode == LibraryViewMode.cardFlow
          ? null
          : _selectionCallbacksForProjection(projection),
      selectionEnabled:
          _selection.enabled && viewState.viewMode != LibraryViewMode.cardFlow,
      selectedCount: viewState.viewMode == LibraryViewMode.cardFlow
          ? 0
          : _selection.selectedCount,
      totalSelectableCount: projection?.filteredItems.length ?? 0,
      showReleaseFolderBack: showReleaseFolderBack,
      releaseFolderLabel: _releaseFolderLabelForProjection(projection),
      onAdd: () => showAddDialogFlow(),
      onScan: scanBarcodeFlow,
      onSearchChanged: _onSearchChanged,
      onSearchInputChanged: _onSearchInputChanged,
      onSearchTargetChanged:
          _supportsMusicTrackSearch ? _onSearchTargetChanged : null,
      onClearSearch: _clearSearch,
      onSearchSuggestionSelected: _applySearchSuggestion,
      onEditColumns: showColumnChooserFlow,
      onSortChanged: (column) => _updateViewState(
        (state) => state.withSortColumn(column, _adapter.viewProfile),
      ),
      onEditSort: showSortDialogFlow,
      onSidebarVisibilityChanged: _setGroupingPanelVisibility,
      onViewModeChanged: (mode) =>
          _updateViewState((state) => state.copyWith(viewMode: mode)),
      onBrowserModeChanged: _setBrowserMode,
      onReleaseFolderBack: showReleaseFolderBack ? _closeReleaseFolder : null,
      onDetailsLayoutChanged: (layout) => _updateViewState(
        (state) => state.copyWith(detailsLayout: layout),
      ),
      onDensityPresetChanged: (densityPreset) => _updateViewState(
        (state) => state.copyWith(densityPreset: densityPreset),
      ),
      onCoverSizeChanged: (size) => _updateViewState(
        (state) => state.copyWith(coverSize: size),
      ),
      onClearBucket: _clearToolbarSearchChip,
      onRefreshMetadata: () => showMetadataRefreshFlow(projection),
      onCollectionStatusScopeChanged: _setCollectionStatusScope,
      onQuickViewSelected: (view) =>
          _setQuickView(_quickView == view ? null : view),
      onLetterSelected: _setSelectedLetter,
      onViewPresetSelected: _applyViewPreset,
      onTogglePinnedViewPreset: _togglePinnedViewPreset,
      onSortFavoriteSelected: _applySortFavorite,
      onTogglePinnedSortFavorite: _togglePinnedSortFavorite,
      onManageSortFavorites: showSortFavoritesManagerFlow,
      onColumnFavoriteSelected: _applyColumnFavorite,
      onTogglePinnedColumnFavorite: _togglePinnedColumnFavorite,
      onJumpToIssueSubmitted: projection == null
          ? null
          : (value) => _jumpToIssue(projection, value),
      onClearFilters: _clearFilters,
      onEditFilters: () => showFilterDialogFlow(projection),
      onRandomPick:
          projection == null ? null : () => pickRandomItemFlow(projection),
      onScanCover: () => scanCoverFlow(),
      onDownloadAllCovers:
          shelfState != null ? () => downloadAllCoversFlow(shelfState) : null,
      onSmartLists: () => showSmartListsFlow(shelfState),
      onFolders: showUserFoldersFlow,
      onReadingQueue: showsReadingQueue() ? showReadingQueueFlow : null,
      onEditConditionPickList: widget.type.conditions.isNotEmpty
          ? showConditionPickListEditorFlow
          : null,
      onEditGradePickList:
          widget.type.grades.isNotEmpty ? showGradePickListEditorFlow : null,
      onEditTagPickList: showTagPickListEditorFlow,
      onTransferFieldData:
          projection != null && _hasOwnedItemsInProjection(projection)
              ? () => showTransferFieldDataFlow(projection)
              : null,
      onReassignIndex: projection != null &&
              widget.type.capabilities.supportsIndexReassignment &&
              _hasOwnedItemsInProjection(projection)
          ? () => reassignIndexFlow(projection)
          : null,
      onPrintReport: projection != null && projection.filteredItems.isNotEmpty
          ? () => printReportFlow(projection)
          : null,
      onMissingComics:
          projection != null && widget.type.workspace.kind.apiValue == 'comic'
              ? () => showMissingComicsFlow(projection)
              : null,
      onShareCollection:
          projection != null && projection.filteredItems.isNotEmpty
              ? () => shareCollectionFlow(projection)
              : null,
      onCompareMetadataWithServer: (() {
        if (projection == null ||
            !widget.type.kindUiAdapter.supportsMetadataCompareWithServer(
              widget.type,
            )) {
          return null;
        }
        final selected = selectedProjectionItemFor(projection);
        if (selected == null || !canCompareMetadataWithServerItem(selected)) {
          return null;
        }
        return () => unawaited(
              compareMetadataWithServerFlow(
                projection,
                item: selected,
              ),
            );
      })(),
      onPinnedFolderPresetsChanged: _setPinnedFolderPresets,
      onGroupModeChanged: _setFolderPreset,
    );
  }
}
