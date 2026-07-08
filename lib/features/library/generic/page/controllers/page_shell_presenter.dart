part of '../generic_library_page.dart';

abstract final class LibraryPageShellPresenter {
  static Widget build(
    GenericLibraryPageState state,
    BuildContext context,
  ) {
    final shelf = state.ref.watch(shelfProvider);
    final ownedCopiesValue = state.ref.watch(collectionProvider);
    final wishlistValue = state.ref.watch(wishlistProvider);
    final switchSnapshot = state.widget.switchLayoutSnapshot;
    final baseViewState =
        state._viewState ?? state._adapter.viewProfile.defaults();
    final viewState = switchSnapshot == null
        ? baseViewState
        : baseViewState.withLayoutSnapshot(switchSnapshot);
    final shelfState = shelf.asData?.value;
    final allOwnedCopies = state._activeOwnedCopies(ownedCopiesValue);
    final allWishlistItems = state._activeWishlistItems(wishlistValue);
    final projection = shelfState == null
        ? null
        : state._projectionForShelf(
            shelfState,
            viewState,
          );
    final useFab =
        state.ref.watch(uiPreferencesProvider.select((p) => p.fabAddButton));

    return LibraryKeyboardShortcuts(
      onSelectAll:
          projection == null ? null : () => state._selectAllVisible(projection),
      onDelete: projection == null
          ? null
          : () => state._removeVisibleSelection(projection),
      onNextItem: projection == null
          ? null
          : () => state._navigateKeyboardSelection(projection, 1),
      onPreviousItem: projection == null
          ? null
          : () => state._navigateKeyboardSelection(projection, -1),
      onEscape: state._handleKeyboardEscape,
      child: Scaffold(
        backgroundColor: appPalette(context).canvas,
        floatingActionButton: useFab
            ? FloatingActionButton(
                onPressed: () => state._dialogCoordinator.showAddDialogFlow(),
                backgroundColor: state.widget.accent,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  state.widget.topBar,
                  state._toolbarController.buildToolbar(
                    context: context,
                    projection: projection,
                    viewState: viewState,
                    shelfState: shelfState,
                  ),
                  Expanded(
                    child: shelf.when(
                      data: (stateValue) =>
                          LibraryPageShellPresenter._buildBody(
                        state,
                        projection ??
                            state._projectionForShelf(stateValue, viewState),
                        viewState,
                        shelfState: stateValue,
                        allOwnedCopies: allOwnedCopies,
                        allWishlistItems: allWishlistItems,
                      ),
                      error: (error, _) => AppErrorCard(
                        message: error.toString(),
                      ),
                      loading: () => const SkeletonGrid(),
                    ),
                  ),
                  LibraryCollectionTabBar(
                    mediaKind: state.widget.type.workspace.kind.apiValue,
                    activeSmartListId: state._activeSmartListId,
                    onSmartListSelected: state._applySmartList,
                    onAllSelected: state._clearSmartList,
                  ),
                ],
              ),
              if (state._isScanningCover)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: appPalette(context).panel.withValues(alpha: 0.48),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBody(
    GenericLibraryPageState state,
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required ShelfState shelfState,
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final workspaceOverride = state.buildWorkspaceOverride(
      projection,
      viewState,
      allOwnedCopies: allOwnedCopies,
      allWishlistItems: allWishlistItems,
    );
    final releasePositionLabel =
        state._releasePositionLabelForProjection(projection);
    if (state.activeReleaseFolderTitleItemId != null &&
        projection.filteredItems.isNotEmpty) {
      final hasSelection = projection.filteredItems.any(
        (item) => item.entry.id == state._selectedId,
      );
      if (!hasSelection) {
        final firstReleaseId = projection.filteredItems.first.entry.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.mounted || state._selectedId == firstReleaseId) {
            return;
          }
          state._activateItem(firstReleaseId);
        });
      }
    }
    final searchState = state._searchControllerOps.state;
    final trimmedSearchQuery = searchState.query.trim();
    final seriesStatusSummary =
        state._seriesStatusSummaryForProjection(projection);
    if (kDebugMode &&
        kIsWeb &&
        state._selectedId == null &&
        state._selection.itemIds.isEmpty &&
        projection.filteredItems.isNotEmpty) {
      final firstVisibleId = projection.filteredItems.first.entry.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!state.mounted ||
            state._selectedId != null ||
            state._selection.itemIds.isNotEmpty) {
          return;
        }
        state._activateItem(firstVisibleId);
      });
    }
    final activeProjectionGroupMode = state._projectionGroupMode;
    final activeFacetId = state._facetIdForMode(activeProjectionGroupMode);
    final activeFacetLoadKey = activeFacetId == null
        ? null
        : state._facetLoadKey(
            activeFacetId,
            state._genericShelfSignature(shelfState),
          );
    final canUseSeriesCompletionScope =
        state._activeGroupMode == LibraryGroupMode.series;
    final effectiveSeriesCompletionScope = canUseSeriesCompletionScope
        ? state._seriesCompletionScope
        : LibrarySeriesCompletionScope.all;
    return LibraryBody(
      type: state.widget.type,
      adapter: state._adapter,
      projection: projection,
      viewState: viewState,
      selectedId: state._selectedId,
      selectedAnchorId: state._selectionAnchorId,
      selectedBucket: state._selectedBucket,
      groupMode: activeProjectionGroupMode,
      groupPresentation: state._activeGroupPresentation,
      groupLoading: activeFacetLoadKey != null &&
          state._isFacetLoadInFlight(activeFacetLoadKey),
      accent: state.widget.accent,
      hasActiveFilter: state._hasActiveFilter,
      onAdd: () => state._dialogCoordinator.showAddDialogFlow(),
      onClearFilters: state._clearFilters,
      onEditFilters: () =>
          state._dialogCoordinator.showFilterDialogFlow(projection),
      selectionEnabled: state._selection.enabled &&
          viewState.viewMode != LibraryViewMode.cardFlow,
      selectedItemIds: state._selection.itemIds,
      onApplySelection: state._applySelection,
      onActivateItem: state._activateItem,
      onToggleSelectionItem: state._toggleSelectionItem,
      onOpenItem: (item) {
        final isMediaTitle =
            item.entry.browseScope == LibraryBrowserScope.title;
        if (state._shouldOpenReleaseFolder(item) && isMediaTitle) {
          state._openReleaseFolder(item);
          return;
        }
        state._editCoordinator.showDetailPage(item);
      },
      onBoxSelectionChanged: (ids) => state._rebuild(() {
        state._selection = state._selection.replace(ids);
        if (ids.isEmpty) {
          state._selectionAnchorId = null;
        } else {
          state._selectionAnchorId ??= ids.first;
          state._selectedId =
              ids.contains(state._selectedId) ? state._selectedId : ids.first;
        }
      }),
      onBucketChanged: state._setSelectedBucket,
      collapsedGroupBuckets: state._collapsedGroupBuckets,
      onGroupBucketCollapsedToggled: state._toggleCollapsedGroupBucket,
      onSetCollapsedGroupBuckets: state._setCollapsedGroupBuckets,
      onGroupModeChanged: state._setGroupMode,
      onSortChanged: (column) => state._updateViewState(
        (stateValue) =>
            stateValue.withSortColumn(column, state._adapter.viewProfile),
      ),
      onColumnWidthChanged: (column, width) => state._updateViewState(
        (stateValue) => stateValue.withColumnWidth(
          column,
          width,
          state._adapter.viewProfile,
        ),
      ),
      onColumnReordered: (column, beforeColumn) => state._updateViewState(
        (stateValue) => stateValue.withReorderedColumn(
          column: column,
          beforeColumn: beforeColumn,
        ),
      ),
      onCoverSizeChanged: (size) => state._updateViewState(
        (stateValue) => stateValue.copyWith(coverSize: size),
      ),
      onSidebarWidthChanged: (width) => state._updateViewChrome(
        (stateValue) => stateValue.copyWith(sidebarWidth: width),
      ),
      onSidebarVisibilityChanged: state._setGroupingPanelVisibility,
      onDetailsLayoutChanged: (layout) => state._updateViewState(
        (stateValue) => stateValue.copyWith(detailsLayout: layout),
      ),
      onDetailsWidthChanged: (width) => state._updateViewChrome(
        (stateValue) => stateValue.copyWith(detailsWidth: width),
      ),
      onDetailsHeightChanged: (height) => state._updateViewChrome(
        (stateValue) => stateValue.copyWith(detailsHeight: height),
      ),
      onLayoutSnapshotChanged: (snapshot) {
        state.ref.read(libraryLayoutSnapshotProvider.notifier).update(snapshot);
      },
      onAddOwned: (item) =>
          state._collectionActionCoordinator.runCollectionAction(
        (actions) => actions.addOwned(item),
      ),
      onRemoveOwned: state._collectionActionCoordinator.confirmAndRemoveOwned,
      onAddWishlist: (item) =>
          state._collectionActionCoordinator.runCollectionAction(
        (actions) => actions.addWishlist(item),
      ),
      onRemoveWishlist: (item) =>
          state._collectionActionCoordinator.runCollectionAction(
        (actions) => actions.removeWishlist(item),
      ),
      onEditItem: (item, ownedItem) =>
          unawaited(state._editCoordinator.showEditDialog(item, ownedItem)),
      workspaceOverride: workspaceOverride,
      onItemContextMenu: (item, position) => state._collectionActionCoordinator
          .handleItemContextMenu(projection, item, position),
      sidebarBreadcrumbs: state._sidebarBreadcrumbs,
      sidebarAncestorScopeLabels: state._sidebarAncestorScopeLabels,
      onSidebarNavigateBack:
          state._scopeHistory.isEmpty ? null : state._navigateSidebarBack,
      onSidebarNavigateToBreadcrumb: state._navigateSidebarToBreadcrumb,
      onSidebarNavigateToAncestorScope: state._navigateSidebarToAncestorScope,
      searchQuery: trimmedSearchQuery.isEmpty ? null : trimmedSearchQuery,
      searchTarget: state._effectiveSearchTarget,
      activeSmartListName: state._activeSmartListName,
      quickView: state._quickView,
      collectionStatusScope: state._collectionStatusScope,
      seriesCompletionScope: effectiveSeriesCompletionScope,
      collectionStatusScopeLabel:
          state._collectionStatusScope == LibraryCollectionStatusScope.all
              ? null
              : state._collectionStatusScope.label,
      linkedMetadataFilterLabel: state._linkedMetadataFilter?.chipLabel,
      sidebarSelectedLetter: state._selectedLetter,
      seriesStatusSummary: seriesStatusSummary,
      filterSelection: state._filterSelection,
      preferToolbarAlphabet: true,
      onCollectionStatusScopeChanged: state._toggleCollectionStatusScope,
      onSeriesCompletionScopeChanged:
          canUseSeriesCompletionScope ? state._setSeriesCompletionScope : null,
      onFilterByValue: state._toggleLinkedMetadataFilter,
      selectedLetter: state._selectedLetter,
      availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
        projection.filteredItems.map((i) => i.entry.resolvedTitle),
      ),
      onLetterSelected: state._setSelectedLetter,
      db: state.ref.read(localDatabaseProvider),
      folderPreset: state._activeFolderPreset,
      pinnedFolderPresets: state._pinnedFolderPresets,
      onManageBuckets: state.widget.type.kindUiAdapter.supportsBucketManagement(
              state.widget.type, activeProjectionGroupMode)
          ? () => unawaited(state._showBucketManagerFlow(projection))
          : null,
      onPinnedFolderPresetsChanged: state._setPinnedFolderPresets,
      folderDisplayMode: state._folderDisplayMode,
      folderTreeExpandedNodeIds: state._folderTreeExpandedNodeIds,
      folderTreeSelectedNodeId: state._folderTreeSelectedNodeId,
      onFolderDisplayModeChanged: state._setFolderDisplayMode,
      onFolderTreeNodeSelected: state._selectFolderTreePath,
      onFolderTreeNodeExpandedToggled: state._toggleFolderTreeNodeExpanded,
      inspectorContextLabel: releasePositionLabel,
      desktopToolbarBand: LibraryDesktopSecondaryToolbar(
        type: state.widget.type,
        viewState: viewState,
        adapter: state._adapter,
        counts: projection.counts,
        onEditColumns: state._dialogCoordinator.showColumnChooserFlow,
        columnFavoritePresets: state._columnFavoritePresets,
        activeColumnFavoriteLabel: state._activeColumnFavoriteLabel,
        onColumnFavoriteSelected: state._applyColumnFavorite,
        pinnedColumnFavoriteKeys: state._pinnedColumnFavoriteKeys,
        onEditSort: state._dialogCoordinator.showSortDialogFlow,
        onSidebarVisibilityChanged: state._setGroupingPanelVisibility,
        onViewModeChanged: (mode) => state._updateViewState(
          (stateValue) => stateValue.copyWith(viewMode: mode),
        ),
        browserMode: state._activeBrowserMode,
        supportsMediaReleaseSplit: state._supportsMediaReleaseSplit,
        onBrowserModeChanged: state._setBrowserMode,
        showReleaseFolderBack:
            state.widget.type.kindUiAdapter.shouldShowReleaseFolderBack(
          state.widget.type,
          browserMode: state._activeBrowserMode,
          releaseFolderTitleItemId: state.activeReleaseFolderTitleItemId,
        ),
        releaseFolderLabel:
            state.widget.type.kindUiAdapter.releaseFolderLabelForProjection(
          state.widget.type,
          projection,
          releaseFolderTitleItemId: state.activeReleaseFolderTitleItemId,
        ),
        onReleaseFolderBack:
            state.widget.type.kindUiAdapter.shouldShowReleaseFolderBack(
          state.widget.type,
          browserMode: state._activeBrowserMode,
          releaseFolderTitleItemId: state.activeReleaseFolderTitleItemId,
        )
                ? state._closeReleaseFolder
                : null,
        onDetailsLayoutChanged: (layout) => state._updateViewState(
          (stateValue) => stateValue.copyWith(detailsLayout: layout),
        ),
        onDensityPresetChanged: (densityPreset) => state._updateViewState(
          (stateValue) => stateValue.copyWith(densityPreset: densityPreset),
        ),
        onCoverSizeChanged: (size) => state._updateViewState(
          (stateValue) => stateValue.copyWith(coverSize: size),
        ),
        selectedBucket:
            state._linkedMetadataFilter?.chipLabel ?? state._selectedBucket,
        onClearBucket: state._clearToolbarSearchChip,
        quickView: state._quickView,
        activeSortFavoriteId: state._activeSortFavorite?.id,
        sortFavorites: state._sortFavorites,
        onSortFavoriteSelected: state._applySortFavorite,
        pinnedSortFavoriteIds: state._pinnedSortFavoriteIds,
        onTogglePinnedSortFavorite: state._togglePinnedSortFavorite,
        onManageSortFavorites:
            state._dialogCoordinator.showSortFavoritesManagerFlow,
        hasActiveFilters: state._hasActiveFilter,
        onQuickViewSelected: (view) =>
            state._setQuickView(state._quickView == view ? null : view),
        onClearFilters: state._clearFilters,
        onEditFilters: () =>
            state._dialogCoordinator.showFilterDialogFlow(projection),
        activeFilterCount: state._filterSelection.activeFilterCount,
        onRandomPick: projection.filteredItems.isNotEmpty
            ? () => state._collectionActionCoordinator
                .pickRandomItemFlow(projection)
            : null,
        onDownloadAllCovers: () =>
            state._coverCoordinator.downloadAllCoversFlow(shelfState),
        shelfState: shelfState,
        onSmartLists: () =>
            state._dialogCoordinator.showSmartListsFlow(shelfState),
        onFolders: state._dialogCoordinator.showUserFoldersFlow,
        onReadingQueue: state.widget.type.supportsReadingQueue
            ? state._dialogCoordinator.showReadingQueueFlow
            : null,
        onEditConditionPickList: state.widget.type.hasConditionPickList
            ? state._dialogCoordinator.showConditionPickListEditorFlow
            : null,
        onEditGradePickList: state.widget.type.hasGradePickList
            ? state._dialogCoordinator.showGradePickListEditorFlow
            : null,
        onEditTagPickList: state._dialogCoordinator.showTagPickListEditorFlow,
        onTransferFieldData: state._hasOwnedItemsInProjection(projection)
            ? () =>
                state._dialogCoordinator.showTransferFieldDataFlow(projection)
            : null,
        onReassignIndex: state.widget.type.supportsIndexReassignment &&
                state._hasOwnedItemsInProjection(projection)
            ? () => state._dialogCoordinator.reassignIndexFlow(projection)
            : null,
        onPrintReport: projection.filteredItems.isNotEmpty
            ? () => state._reportCoordinator.printReportFlow(projection)
            : null,
        onShareCollection: projection.filteredItems.isNotEmpty
            ? () => state._sharingCoordinator.shareCollectionFlow(projection)
            : null,
        onCompareMetadataWithServer: (() {
          if (!state.widget.type.supportsMetadataCompareWithServer) {
            return null;
          }
          final selected = state._collectionActionCoordinator
              .selectedProjectionItemFor(projection);
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
        groupMode: state._activeSidebarGroupMode,
        folderPreset: state._activeFolderPreset,
        availableGroupModes: state._scopeAvailableGroupModes,
        pinnedFolderPresets: state._pinnedFolderPresets,
        onPinnedFolderPresetsChanged: state._setPinnedFolderPresets,
        onGroupModeChanged: state._setFolderPreset,
        selectionCallbacks: viewState.viewMode == LibraryViewMode.cardFlow
            ? null
            : selectionCallbacksForProjection(state, projection),
        selectedCount: viewState.viewMode == LibraryViewMode.cardFlow
            ? 0
            : state._selection.selectedCount,
        totalSelectableCount: projection.filteredItems.length,
      ),
    );
  }

  static LibrarySelectionCallbacks selectionCallbacksForProjection(
    GenericLibraryPageState state,
    LibraryProjection? projection,
  ) {
    return (
      onClearSelection: () => state._rebuild(() {
            state._selection = state._selection.clear();
            state._selectionAnchorId = null;
          }),
      onSelectAll: () {
        if (projection != null) {
          state._selectAllVisible(projection);
        }
      },
      onBulkEdit: state._hasOwnedItemsInSelection(projection)
          ? () => state._collectionActionCoordinator.bulkEditFlow(projection)
          : null,
      onPrintToPdf: state._hasSelectedItemsInSelection(projection)
          ? () => state._reportCoordinator.printSelectedReportFlow(projection)
          : null,
      onExportCsvTxt: state._hasSelectedItemsInSelection(projection)
          ? () =>
              state._sharingCoordinator.shareSelectedCollectionFlow(projection)
          : null,
      onBulkDuplicate: state._hasOwnedItemsInSelection(projection)
          ? () =>
              state._collectionActionCoordinator.bulkDuplicateFlow(projection)
          : null,
      onBulkLoan: state._hasLoanableOwnedItemsInSelection(projection)
          ? () => state._dialogCoordinator.showLoanSelectionFlow(projection)
          : null,
      onTransferFieldData: state._hasOwnedItemsInSelection(projection)
          ? () => state._dialogCoordinator
              .showTransferFieldDataForSelectionFlow(projection)
          : null,
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToOwned: state
              ._hasMoveToOwnedEligibleItemsInSelection(projection)
          ? () =>
              state._collectionActionCoordinator.bulkMoveToOwnedFlow(projection)
          : null,
      onBulkMoveToWishlist:
          state._hasMoveToWishlistEligibleItemsInSelection(projection)
              ? () => state._collectionActionCoordinator
                  .bulkMoveToWishlistFlow(projection)
              : null,
      onBulkRemove: state._hasRemovableItemsInSelection(projection)
          ? () => state._collectionActionCoordinator.bulkRemoveFlow(projection)
          : null,
      onBulkRefreshMetadata: state._hasSelectedItemsInSelection(projection)
          ? () => state._metadataCoordinator.bulkRefreshMetadataFlow(projection)
          : null,
    );
  }
}
