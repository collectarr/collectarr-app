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
        searchTargetOptions: _s._supportsTrackSearch
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
        canJumpToIssue: _s._canJumpToSelectedEntry(projection),
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
        showReleaseFolderBack:
            _s._kindBrowserDelegate.hasReleaseFolderTitleItemId &&
                _s.widget.type.kindUiAdapter.shouldShowReleaseFolderBack(
                  _s.widget.type,
                  browserMode: _s._activeBrowserMode,
                  releaseFolderTitleItemId: _s.activeReleaseFolderTitleItemId,
                ),
        releaseFolderLabel:
            _s.widget.type.kindUiAdapter.releaseFolderLabelForProjection(
          _s.widget.type,
          projection,
          releaseFolderTitleItemId: _s.activeReleaseFolderTitleItemId,
        ),
      ),
      actions: const LibraryToolbarActionRegistry().build(
        context: LibraryPageToolbarActionContext(
          search: LibraryToolbarSearchContext(
            supportsTrackSearch: _s._supportsTrackSearch,
            onSearchChanged: _s._onSearchChanged,
            onSearchInputChanged: _s._onSearchInputChanged,
            onSearchTargetChanged:
                _s._supportsTrackSearch ? _s._onSearchTargetChanged : null,
            onClearSearch: _s._clearSearch,
            onSearchSuggestionSelected: _s._applySearchSuggestion,
          ),
          view: LibraryToolbarViewContext(
            type: _s.widget.type,
            activeBrowserMode: _s._activeBrowserMode,
            activeReleaseFolderTitleItemId: _s.activeReleaseFolderTitleItemId,
            adapter: _s._adapter,
            onShowAddDialogFlow: _s._dialogCoordinator.showAddDialogFlow,
            onShowColumnChooserFlow:
                _s._dialogCoordinator.showColumnChooserFlow,
            onShowSortDialogFlow: _s._dialogCoordinator.showSortDialogFlow,
            onSetGroupingPanelVisibility: _s._setGroupingPanelVisibility,
            onUpdateViewState: _s._updateViewState,
            onSetBrowserMode: _s._setBrowserMode,
            onCloseReleaseFolder: _s._closeReleaseFolder,
            onClearToolbarSearchChip: _s._clearToolbarSearchChip,
            onQuickViewSelected: (value) => _s._setQuickView(
              _s._quickView == value ? null : value,
            ),
            onSetSelectedLetter: _s._setSelectedLetter,
            onApplyViewPreset: _s._applyViewPreset,
            onTogglePinnedViewPreset: _s._togglePinnedViewPreset,
            onApplySortFavorite: _s._applySortFavorite,
            onTogglePinnedSortFavorite: _s._togglePinnedSortFavorite,
            onShowSortFavoritesManagerFlow:
                _s._dialogCoordinator.showSortFavoritesManagerFlow,
            onApplyColumnFavorite: _s._applyColumnFavorite,
            onTogglePinnedColumnFavorite: _s._togglePinnedColumnFavorite,
          ),
          grouping: LibraryToolbarGroupingContext(
            onClearFilters: _s._clearFilters,
            onEditFilters: (value) =>
                _s._dialogCoordinator.showFilterDialogFlow(value),
            onRandomPick: (value) {
              if (value == null) return;
              _s._collectionActionCoordinator.pickRandomItemFlow(value);
            },
            onSmartLists: (value) =>
                _s._dialogCoordinator.showSmartListsFlow(value),
            onShowUserFoldersFlow: _s._dialogCoordinator.showUserFoldersFlow,
            onShowReadingQueueFlow: _s._dialogCoordinator.showReadingQueueFlow,
          ),
          metadata: LibraryToolbarMetadataContext(
            onRefreshMetadata: (value) =>
                _s._metadataCoordinator.showMetadataRefreshFlow(value),
            onSetCollectionStatusScope: _s._setCollectionStatusScope,
            onJumpToIssueSubmitted: (proj, value) => _s._jumpToIssue(
              proj,
              value,
            ),
            selectedProjectionItemFor:
                _s._collectionActionCoordinator.selectedProjectionItemFor,
            canCompareMetadataWithServerItem: _s
                ._collectionActionCoordinator.canCompareMetadataWithServerItem,
          ),
          collectionActions: LibraryToolbarCollectionActionsContext(
            onTransferFieldData: (value) =>
                _s._dialogCoordinator.showTransferFieldDataFlow(value),
            onReassignIndex: (value) {
              if (value == null) return;
              _s._dialogCoordinator.reassignIndexFlow(value);
            },
            onPrintReport: (value) {
              if (value == null) return;
              _s._reportCoordinator.printReportFlow(value);
            },
            onMissingComics: (value) {
              if (value == null) return;
              _s._reportCoordinator.showMissingComicsFlow(value);
            },
            onShareCollection: (value) {
              if (value == null) return;
              _s._sharingCoordinator.shareCollectionFlow(value);
            },
            onCompareMetadataWithServer: (projectionValue,
                    {LibraryProjectionItem? item}) =>
                _s._metadataCoordinator.compareMetadataWithServerFlow(
              projectionValue,
              item: item,
            ),
          ),
          adminActions: LibraryToolbarAdminActionsContext(
            onScanCover: _s._coverCoordinator.scanCoverFlow,
            onDownloadAllCovers: _s._coverCoordinator.downloadAllCoversFlow,
            onShowConditionPickListEditorFlow:
                _s.widget.type.hasConditionPickList
                    ? _s._dialogCoordinator.showConditionPickListEditorFlow
                    : null,
            onShowGradePickListEditorFlow: _s.widget.type.hasGradePickList
                ? _s._dialogCoordinator.showGradePickListEditorFlow
                : null,
            onShowTagPickListEditorFlow:
                _s._dialogCoordinator.showTagPickListEditorFlow,
          ),
        ),
        projection: projection,
        viewState: viewState,
        shelfState: shelfState,
      ),
    );

    return buildLibraryToolbar(presentation);
  }
}

typedef LibraryToolbarSearchSuggestionsInput = ({
  LibraryProjection? projection,
  String query,
});

final libraryToolbarSearchSuggestionsProvider = Provider.autoDispose.family<
    List<LibraryToolbarSearchSuggestion>,
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
