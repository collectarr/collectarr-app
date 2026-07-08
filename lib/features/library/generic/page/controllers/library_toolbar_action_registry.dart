part of '../generic_library_page.dart';

class LibraryToolbarActionRegistry {
  const LibraryToolbarActionRegistry();

  LibraryToolbarActions build({
    required GenericLibraryPageState state,
    required LibraryProjection? projection,
    required LibraryWorkspaceViewState viewState,
    required ShelfState? shelfState,
  }) {
    final showReleaseFolderBack =
        state.widget.type.kindUiAdapter.shouldShowReleaseFolderBack(
      state.widget.type,
      browserMode: state._activeBrowserMode,
      releaseFolderTitleItemId: state.activeReleaseFolderTitleItemId,
    );

    final declaredActions = state.widget.type.workspace.toolbarActions.toSet();
    final kindCapabilities = state.widget.type.capabilities.toolbarCapabilities;

    bool enabled(LibraryToolbarActionId id) => declaredActions.contains(id);

    return LibraryToolbarActions(
      onAdd: enabled(LibraryToolbarActionId.add)
          ? () => state._dialogCoordinator.showAddDialogFlow()
          : () {},
      onScan: enabled(LibraryToolbarActionId.scan)
          ? state._collectionActionCoordinator.scanBarcodeFlow
          : () {},
      onSearchChanged: state._onSearchChanged,
      onSearchInputChanged: state._onSearchInputChanged,
      onSearchTargetChanged: state._supportsMusicTrackSearch
          ? state._onSearchTargetChanged
          : null,
      onClearSearch: state._clearSearch,
      onSearchSuggestionSelected: state._applySearchSuggestion,
      onEditColumns: enabled(LibraryToolbarActionId.editColumns)
          ? state._dialogCoordinator.showColumnChooserFlow
          : () {},
      onSortChanged: (column) => state._updateViewState(
        (next) => next.withSortColumn(column, state._adapter.viewProfile),
      ),
      onEditSort: state._dialogCoordinator.showSortDialogFlow,
      onSidebarVisibilityChanged: state._setGroupingPanelVisibility,
      onViewModeChanged: (mode) =>
          state._updateViewState((next) => next.copyWith(viewMode: mode)),
      onBrowserModeChanged: state._setBrowserMode,
      onReleaseFolderBack:
          showReleaseFolderBack ? state._closeReleaseFolder : null,
      onDetailsLayoutChanged: (layout) => state._updateViewState(
        (next) => next.copyWith(detailsLayout: layout),
      ),
      onDensityPresetChanged: (densityPreset) => state._updateViewState(
        (next) => next.copyWith(densityPreset: densityPreset),
      ),
      onCoverSizeChanged: (size) => state._updateViewState(
        (next) => next.copyWith(coverSize: size),
      ),
      onClearBucket: state._clearToolbarSearchChip,
      onRefreshMetadata: () =>
          state._metadataCoordinator.showMetadataRefreshFlow(projection),
      onCollectionStatusScopeChanged: state._setCollectionStatusScope,
      onQuickViewSelected: (view) =>
          state._setQuickView(state._quickView == view ? null : view),
      onLetterSelected: state._setSelectedLetter,
      onViewPresetSelected: state._applyViewPreset,
      onTogglePinnedViewPreset: state._togglePinnedViewPreset,
      onSortFavoriteSelected: state._applySortFavorite,
      onTogglePinnedSortFavorite: state._togglePinnedSortFavorite,
      onManageSortFavorites: state._dialogCoordinator.showSortFavoritesManagerFlow,
      onColumnFavoriteSelected: state._applyColumnFavorite,
      onTogglePinnedColumnFavorite: state._togglePinnedColumnFavorite,
      onJumpToIssueSubmitted: projection == null
          ? null
          : (value) => state._jumpToIssue(projection, value),
      onClearFilters: state._clearFilters,
      onEditFilters:
          projection == null ? null : () => state._dialogCoordinator.showFilterDialogFlow(projection),
      onRandomPick: projection == null
          ? null
          : () =>
              state._collectionActionCoordinator.pickRandomItemFlow(projection),
      onScanCover: kindCapabilities.canScanCover
          ? () => state._coverCoordinator.scanCoverFlow()
          : null,
      onDownloadAllCovers: kindCapabilities.canDownloadAllCovers && shelfState != null
          ? () => state._coverCoordinator.downloadAllCoversFlow(shelfState)
          : null,
      onSmartLists: shelfState == null
          ? null
          : () => state._dialogCoordinator.showSmartListsFlow(shelfState),
      onFolders: state._dialogCoordinator.showUserFoldersFlow,
      onReadingQueue: kindCapabilities.canReadingQueue
          ? state._dialogCoordinator.showReadingQueueFlow
          : null,
      onEditConditionPickList: state.widget.type.hasConditionPickList
          ? state._dialogCoordinator.showConditionPickListEditorFlow
          : null,
      onEditGradePickList: state.widget.type.hasGradePickList
          ? state._dialogCoordinator.showGradePickListEditorFlow
          : null,
      onEditTagPickList: state._dialogCoordinator.showTagPickListEditorFlow,
      onTransferFieldData: projection != null &&
              state._hasOwnedItemsInProjection(projection)
          ? () => state._dialogCoordinator.showTransferFieldDataFlow(projection)
          : null,
      onReassignIndex: projection != null &&
              kindCapabilities.canReassignIndex &&
              state._hasOwnedItemsInProjection(projection)
          ? () => state._dialogCoordinator.reassignIndexFlow(projection)
          : null,
      onPrintReport:
          projection != null && projection.filteredItems.isNotEmpty
              ? () => state._reportCoordinator.printReportFlow(projection)
              : null,
      onMissingComics: projection != null &&
              kindCapabilities.canMissingComicsReport &&
              state.widget.type.kindUiAdapter.supportsMissingComicsReport(
                state.widget.type,
              )
          ? () => state._reportCoordinator.showMissingComicsFlow(projection)
          : null,
      onShareCollection:
          projection != null && projection.filteredItems.isNotEmpty
              ? () => state._sharingCoordinator.shareCollectionFlow(projection)
              : null,
      onCompareMetadataWithServer: (() {
        if (projection == null ||
            !kindCapabilities.canCompareMetadataWithServer ||
            !state.widget.type.kindUiAdapter.supportsMetadataCompareWithServer(
              state.widget.type,
            )) {
          return null;
        }
        final selected =
            state._collectionActionCoordinator.selectedProjectionItemFor(
          projection,
        );
        if (selected == null ||
            !state._collectionActionCoordinator
                .canCompareMetadataWithServerItem(selected)) {
          return null;
        }
        return () => unawaited(
              state._metadataCoordinator.compareMetadataWithServerFlow(
                projection,
                item: selected,
              ),
            );
      })(),
      onPinnedFolderPresetsChanged: state._setPinnedFolderPresets,
      onGroupModeChanged: state._setFolderPreset,
      onGroupPresentationChanged: state._setGroupPresentationOverride,
    );
  }
}
