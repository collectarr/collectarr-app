part of '../generic_library_page.dart';

/// Toolbar controller: builds search suggestions and the toolbar widget.
class LibraryPageToolbarController {
  LibraryPageToolbarController(this._s);

  final GenericLibraryPageState _s;

  static List<LibraryToolbarSearchSuggestion> buildSearchSuggestions(
    LibraryProjection projection,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const <LibraryToolbarSearchSuggestion>[];
    }
    final ranked = <(int, LibraryToolbarSearchSuggestion)>[];
    for (final item in projection.allItems) {
      final entry = item.entry;
      final title = entry.resolvedTitle.trim().isEmpty
          ? entry.title.trim()
          : entry.resolvedTitle.trim();
      if (title.isEmpty) {
        continue;
      }
      final normalizedTitle = title.toLowerCase();
      final itemNumber = entry.itemNumber?.trim();
      final publisher = entry.publisher?.trim();
      final subtitleParts = <String>[
        if (itemNumber != null && itemNumber.isNotEmpty) '#$itemNumber',
        if (publisher != null && publisher.isNotEmpty) publisher,
      ];
      final subtitle = subtitleParts.isEmpty ? null : subtitleParts.join(' • ');
      var score = 0;
      if (normalizedTitle.startsWith(normalizedQuery)) {
        score = 3;
      } else if (normalizedTitle.contains(normalizedQuery)) {
        score = 2;
      } else if ((itemNumber?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (publisher?.toLowerCase().contains(normalizedQuery) ?? false)) {
        score = 1;
      }
      if (score == 0) {
        continue;
      }
      ranked.add((
        score,
        LibraryToolbarSearchSuggestion(
          id: entry.id,
          title: title,
          subtitle: subtitle,
        ),
      ));
    }
    ranked.sort((left, right) {
      final byScore = right.$1.compareTo(left.$1);
      if (byScore != 0) {
        return byScore;
      }
      return left.$2.title
          .toLowerCase()
          .compareTo(right.$2.title.toLowerCase());
    });
    return ranked.map((value) => value.$2).take(8).toList(growable: false);
  }

  Widget buildToolbar({
    required LibraryProjection? projection,
    required LibraryWorkspaceViewState viewState,
    required ShelfState? shelfState,
  }) {
    final searchState = _s.ref.watch(
      libraryPageSearchStateProvider(_s._searchStateKey),
    );
    final searchSuggestions = _s.ref.watch(
      libraryToolbarSearchSuggestionsProvider((
        projection: projection,
        query: searchState.query,
      )),
    );
    final showReleaseFolderBack =
        _s.widget.type.kindUiAdapter.shouldShowReleaseFolderBack(
      _s.widget.type,
      browserMode: _s._activeBrowserMode,
      releaseFolderTitleItemId: _s.activeReleaseFolderTitleItemId,
    );

    final presentation = LibraryToolbarPresentation(
      config: LibraryToolbarConfig(
        type: _s.widget.type,
        adapter: _s._adapter,
        browserMode: _s._activeBrowserMode,
        supportsMediaReleaseSplit: _s._supportsMediaReleaseSplit,
        includeDesktopSecondaryBand: false,
      ),
      state: LibraryToolbarState(
        searchController: _s._searchController,
        viewState: viewState,
        counts: projection?.counts ?? const LibraryToolbarCounts(),
        searchTarget: _s._effectiveSearchTarget,
        searchTargetOptions: _s._supportsMusicTrackSearch
            ? const <LibrarySearchTarget>[
                LibrarySearchTarget.all,
                LibrarySearchTarget.mediaOnly,
                LibrarySearchTarget.tracksOnly,
              ]
            : const <LibrarySearchTarget>[],
        searchActive:
            searchState.query.isNotEmpty || searchState.pinnedItemId != null,
        searchSuggestions: searchSuggestions,
        selectedBucket:
            _s._linkedMetadataFilter?.chipLabel ?? _s._selectedBucket,
        collectionStatusScope: _s._collectionStatusScope,
        quickView: _s._quickView,
        availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
          (projection?.filteredItems ?? const <LibraryProjectionItem>[])
              .map((i) => i.entry.resolvedTitle),
        ),
        selectedLetter: _s._selectedLetter,
        activeViewPreset: _s._activeViewPreset,
        pinnedViewPresets: _s._pinnedViewPresets,
        sortFavorites: _s._sortFavorites,
        activeSortFavoriteId: _s._activeSortFavorite?.id,
        pinnedSortFavoriteIds: _s._pinnedSortFavoriteIds,
        columnFavoritePresets: _s._columnFavoritePresets,
        activeColumnFavoriteLabel: _s._activeColumnFavoriteLabel,
        pinnedColumnFavoriteKeys: _s._pinnedColumnFavoriteKeys,
        canJumpToIssue: _s._canJumpToIssue(projection),
        hasActiveFilters: _s._hasActiveFilter,
        activeFilterCount: _s._filterSelection.activeFilterCount,
        shelfState: shelfState,
        groupMode: _s._activeSidebarGroupMode,
        folderPreset: _s._activeFolderPreset,
        groupPresentation: _s._activeGroupPresentation,
        availableGroupModes: _s._scopeAvailableGroupModes,
        pinnedFolderPresets: _s._pinnedFolderPresets,
        selectionCallbacks: viewState.viewMode == LibraryViewMode.cardFlow
            ? null
            : _s._selectionCallbacksForProjection(projection),
        selectionEnabled: _s._selection.enabled &&
            viewState.viewMode != LibraryViewMode.cardFlow,
        selectedCount: viewState.viewMode == LibraryViewMode.cardFlow
            ? 0
            : _s._selection.selectedCount,
        totalSelectableCount: projection?.filteredItems.length ?? 0,
        showReleaseFolderBack: showReleaseFolderBack,
        releaseFolderLabel:
            _s.widget.type.kindUiAdapter.releaseFolderLabelForProjection(
          _s.widget.type,
          projection,
          releaseFolderTitleItemId: _s.activeReleaseFolderTitleItemId,
        ),
      ),
      actions: LibraryToolbarActions(
        onAdd: () => _s._dialogCoordinator.showAddDialogFlow(),
        onScan: _s._collectionActionCoordinator.scanBarcodeFlow,
        onSearchChanged: _s._onSearchChanged,
        onSearchInputChanged: _s._onSearchInputChanged,
        onSearchTargetChanged:
            _s._supportsMusicTrackSearch ? _s._onSearchTargetChanged : null,
        onClearSearch: _s._clearSearch,
        onSearchSuggestionSelected: _s._applySearchSuggestion,
        onEditColumns: _s._dialogCoordinator.showColumnChooserFlow,
        onSortChanged: (column) => _s._updateViewState(
          (state) => state.withSortColumn(column, _s._adapter.viewProfile),
        ),
        onEditSort: _s._dialogCoordinator.showSortDialogFlow,
        onSidebarVisibilityChanged: _s._setGroupingPanelVisibility,
        onViewModeChanged: (mode) =>
            _s._updateViewState((state) => state.copyWith(viewMode: mode)),
        onBrowserModeChanged: _s._setBrowserMode,
        onReleaseFolderBack:
            showReleaseFolderBack ? _s._closeReleaseFolder : null,
        onDetailsLayoutChanged: (layout) => _s._updateViewState(
          (state) => state.copyWith(detailsLayout: layout),
        ),
        onDensityPresetChanged: (densityPreset) => _s._updateViewState(
          (state) => state.copyWith(densityPreset: densityPreset),
        ),
        onCoverSizeChanged: (size) => _s._updateViewState(
          (state) => state.copyWith(coverSize: size),
        ),
        onClearBucket: _s._clearToolbarSearchChip,
        onRefreshMetadata: () =>
            _s._metadataCoordinator.showMetadataRefreshFlow(projection),
        onCollectionStatusScopeChanged: _s._setCollectionStatusScope,
        onQuickViewSelected: (view) =>
            _s._setQuickView(_s._quickView == view ? null : view),
        onLetterSelected: _s._setSelectedLetter,
        onViewPresetSelected: _s._applyViewPreset,
        onTogglePinnedViewPreset: _s._togglePinnedViewPreset,
        onSortFavoriteSelected: _s._applySortFavorite,
        onTogglePinnedSortFavorite: _s._togglePinnedSortFavorite,
        onManageSortFavorites:
            _s._dialogCoordinator.showSortFavoritesManagerFlow,
        onColumnFavoriteSelected: _s._applyColumnFavorite,
        onTogglePinnedColumnFavorite: _s._togglePinnedColumnFavorite,
        onJumpToIssueSubmitted: projection == null
            ? null
            : (value) => _s._jumpToIssue(projection, value),
        onClearFilters: _s._clearFilters,
        onEditFilters: () =>
            _s._dialogCoordinator.showFilterDialogFlow(projection),
        onRandomPick: projection == null
            ? null
            : () =>
                _s._collectionActionCoordinator.pickRandomItemFlow(projection),
        onScanCover: () => _s._coverCoordinator.scanCoverFlow(),
        onDownloadAllCovers: shelfState != null
            ? () => _s._coverCoordinator.downloadAllCoversFlow(shelfState)
            : null,
        onSmartLists: () =>
            _s._dialogCoordinator.showSmartListsFlow(shelfState),
        onFolders: _s._dialogCoordinator.showUserFoldersFlow,
        onReadingQueue: _s.showsReadingQueue()
            ? _s._dialogCoordinator.showReadingQueueFlow
            : null,
        onEditConditionPickList: _s.widget.type.hasConditionPickList
            ? _s._dialogCoordinator.showConditionPickListEditorFlow
            : null,
        onEditGradePickList: _s.widget.type.hasGradePickList
            ? _s._dialogCoordinator.showGradePickListEditorFlow
            : null,
        onEditTagPickList: _s._dialogCoordinator.showTagPickListEditorFlow,
        onTransferFieldData: projection != null &&
                _s._hasOwnedItemsInProjection(projection)
            ? () =>
                _s._dialogCoordinator.showTransferFieldDataFlow(projection)
            : null,
        onReassignIndex: projection != null &&
                _s.widget.type.capabilities.supportsIndexReassignment &&
                _s._hasOwnedItemsInProjection(projection)
            ? () => _s._dialogCoordinator.reassignIndexFlow(projection)
            : null,
        onPrintReport:
            projection != null && projection.filteredItems.isNotEmpty
                ? () => _s._reportCoordinator.printReportFlow(projection)
                : null,
        onMissingComics: projection != null &&
                _s.widget.type.kindUiAdapter.supportsMissingComicsReport(
                  _s.widget.type,
                )
            ? () => _s._reportCoordinator.showMissingComicsFlow(projection)
            : null,
        onShareCollection:
            projection != null && projection.filteredItems.isNotEmpty
                ? () => _s._sharingCoordinator.shareCollectionFlow(projection)
                : null,
        onCompareMetadataWithServer: (() {
          if (projection == null ||
              !_s.widget.type.kindUiAdapter.supportsMetadataCompareWithServer(
                _s.widget.type,
              )) {
            return null;
          }
          final selected =
              _s._collectionActionCoordinator.selectedProjectionItemFor(
            projection,
          );
          if (selected == null ||
              !_s._collectionActionCoordinator
                  .canCompareMetadataWithServerItem(selected)) {
            return null;
          }
          return () => unawaited(
                _s._metadataCoordinator.compareMetadataWithServerFlow(
                  projection,
                  item: selected,
                ),
              );
        })(),
        onPinnedFolderPresetsChanged: _s._setPinnedFolderPresets,
        onGroupModeChanged: _s._setFolderPreset,
        onGroupPresentationChanged: _s._setGroupPresentationOverride,
      ),
    );

    return buildLibraryToolbar(presentation);
  }
}

typedef LibraryToolbarSearchSuggestionsInput = ({
  LibraryProjection? projection,
  String query,
});

final libraryToolbarSearchSuggestionsProvider = Provider.autoDispose
    .family<List<LibraryToolbarSearchSuggestion>,
        LibraryToolbarSearchSuggestionsInput>((ref, input) {
  final projection = input.projection;
  if (projection == null) {
    return const <LibraryToolbarSearchSuggestion>[];
  }
  return LibraryPageToolbarController.buildSearchSuggestions(
    projection,
    input.query,
  );
});