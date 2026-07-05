part of '../../page.dart';

abstract final class _LibraryPageShellPresenter {
  static Widget build(
    GenericLibraryPageState state,
    BuildContext context,
  ) {
    final shelf = state.ref.watch(shelfProvider);
    final ownedCopiesValue = state.ref.watch(collectionProvider);
    final wishlistValue = state.ref.watch(wishlistProvider);
    final viewState = state._viewState ?? state._adapter.viewProfile.defaults();
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
                onPressed: () => state.showAddDialogFlow(),
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
                  state._buildToolbar(
                    projection: projection,
                    viewState: viewState,
                    shelfState: shelfState,
                  ),
                  Expanded(
                    child: shelf.when(
                      data: (stateValue) =>
                          _LibraryPageShellPresenter._buildBody(
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
    final searchState = _LibraryPageSearchControllerOps.thisState(state);
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
    final activeFacetLoadKey = state._facetLoadKey(
      activeProjectionGroupMode,
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
      groupLoading: state._isFacetLoadInFlight(activeFacetLoadKey),
      accent: state.widget.accent,
      hasActiveFilter: state._hasActiveFilter,
      onAdd: () => state.showAddDialogFlow(),
      onClearFilters: state._clearFilters,
      onEditFilters: () => state.showFilterDialogFlow(projection),
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
        state.showDetailPage(item);
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
      onAddOwned: (item) => state.runCollectionAction(
        (actions) => actions.addOwned(item),
      ),
      onRemoveOwned: state.confirmAndRemoveOwned,
      onAddWishlist: (item) => state.runCollectionAction(
        (actions) => actions.addWishlist(item),
      ),
      onRemoveWishlist: (item) => state.runCollectionAction(
        (actions) => actions.removeWishlist(item),
      ),
      onEditItem: (item, ownedItem) =>
          unawaited(state.showEditDialog(item, ownedItem)),
      workspaceOverride: workspaceOverride,
      onItemContextMenu: (item, position) =>
          state.handleItemContextMenu(projection, item, position),
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
      onManageBuckets: state.supportsBucketManagement(activeProjectionGroupMode)
          ? () => unawaited(state._showBucketManagerFlow(projection))
          : null,
      onPinnedFolderPresetsChanged: state._setPinnedFolderPresets,
      inspectorContextLabel: releasePositionLabel,
      desktopToolbarBand: LibraryDesktopSecondaryToolbar(
        type: state.widget.type,
        viewState: viewState,
        adapter: state._adapter,
        counts: projection.counts,
        onEditColumns: state.showColumnChooserFlow,
        columnFavoritePresets: state._columnFavoritePresets,
        activeColumnFavoriteLabel: state._activeColumnFavoriteLabel,
        onColumnFavoriteSelected: state._applyColumnFavorite,
        pinnedColumnFavoriteKeys: state._pinnedColumnFavoriteKeys,
        onEditSort: state.showSortDialogFlow,
        onSidebarVisibilityChanged: state._setGroupingPanelVisibility,
        onViewModeChanged: (mode) => state._updateViewState(
          (stateValue) => stateValue.copyWith(viewMode: mode),
        ),
        browserMode: state._activeBrowserMode,
        supportsMediaReleaseSplit: state._supportsMediaReleaseSplit,
        onBrowserModeChanged: state._setBrowserMode,
        showReleaseFolderBack: state.widget.type.shouldShowReleaseFolderBack(
          browserMode: state._activeBrowserMode,
          releaseFolderTitleItemId: state.activeReleaseFolderTitleItemId,
        ),
        releaseFolderLabel: state._releaseFolderLabelForProjection(projection),
        onReleaseFolderBack: state.widget.type.shouldShowReleaseFolderBack(
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
        onManageSortFavorites: state.showSortFavoritesManagerFlow,
        hasActiveFilters: state._hasActiveFilter,
        onQuickViewSelected: (view) =>
            state._setQuickView(state._quickView == view ? null : view),
        onClearFilters: state._clearFilters,
        onEditFilters: () => state.showFilterDialogFlow(projection),
        activeFilterCount: state._filterSelection.activeFilterCount,
        onRandomPick: projection.filteredItems.isNotEmpty
            ? () => state.pickRandomItemFlow(projection)
            : null,
        onDownloadAllCovers: () => state.downloadAllCoversFlow(shelfState),
        shelfState: shelfState,
        onSmartLists: () => state.showSmartListsFlow(shelfState),
        onFolders: state.showUserFoldersFlow,
        onReadingQueue: state.widget.type.supportsReadingQueue
            ? state.showReadingQueueFlow
            : null,
        onEditConditionPickList: state.widget.type.hasConditionPickList
            ? state.showConditionPickListEditorFlow
            : null,
        onEditGradePickList: state.widget.type.hasGradePickList
            ? state.showGradePickListEditorFlow
            : null,
        onEditTagPickList: state.showTagPickListEditorFlow,
        onTransferFieldData: state._hasOwnedItemsInProjection(projection)
            ? () => state.showTransferFieldDataFlow(projection)
            : null,
        onReassignIndex: state.widget.type.supportsIndexReassignment &&
                state._hasOwnedItemsInProjection(projection)
            ? () => state.reassignIndexFlow(projection)
            : null,
        onPrintReport: projection.filteredItems.isNotEmpty
            ? () => state.printReportFlow(projection)
            : null,
        onShareCollection: projection.filteredItems.isNotEmpty
            ? () => state.shareCollectionFlow(projection)
            : null,
        onCompareMetadataWithServer: (() {
          if (!state.widget.type.supportsMetadataCompareWithServer) {
            return null;
          }
          final selected = state.selectedProjectionItemFor(projection);
          if (selected == null ||
              !state.canCompareMetadataWithServerItem(selected)) {
            return null;
          }
          return () => unawaited(
                state.compareMetadataWithServerFlow(
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
            : _selectionCallbacksForProjection(state, projection),
        selectedCount: viewState.viewMode == LibraryViewMode.cardFlow
            ? 0
            : state._selection.selectedCount,
        totalSelectableCount: projection.filteredItems.length,
      ),
    );
  }

  static LibrarySelectionCallbacks _selectionCallbacksForProjection(
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
          ? () => state.bulkEditFlow(projection)
          : null,
      onPrintToPdf: state._hasSelectedItemsInSelection(projection)
          ? () => state.printSelectedReportFlow(projection)
          : null,
      onExportCsvTxt: state._hasSelectedItemsInSelection(projection)
          ? () => state.shareSelectedCollectionFlow(projection)
          : null,
      onBulkDuplicate: state._hasOwnedItemsInSelection(projection)
          ? () => state.bulkDuplicateFlow(projection)
          : null,
      onBulkLoan: state._hasLoanableOwnedItemsInSelection(projection)
          ? () => state.showLoanSelectionFlow(projection)
          : null,
      onTransferFieldData: state._hasOwnedItemsInSelection(projection)
          ? () => state.showTransferFieldDataForSelectionFlow(projection)
          : null,
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToOwned:
          state._hasMoveToOwnedEligibleItemsInSelection(projection)
              ? () => state.bulkMoveToOwnedFlow(projection)
              : null,
      onBulkMoveToWishlist:
          state._hasMoveToWishlistEligibleItemsInSelection(projection)
              ? () => state.bulkMoveToWishlistFlow(projection)
              : null,
      onBulkRemove: state._hasRemovableItemsInSelection(projection)
          ? () => state.bulkRemoveFlow(projection)
          : null,
      onBulkRefreshMetadata: state._hasSelectedItemsInSelection(projection)
          ? () => state.bulkRefreshMetadataFlow(projection)
          : null,
    );
  }
}
