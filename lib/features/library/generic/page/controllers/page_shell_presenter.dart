part of '../generic_library_page.dart';

abstract final class LibraryPageShellPresenter {
  static Widget build(
    GenericLibraryPageState state,
    BuildContext context,
  ) {
    final shelf = state.ref.watch(shelfProvider);
    final wishlistValue = state.ref.watch(wishlistProvider);
    final switchSnapshot = state.widget.switchLayoutSnapshot;
    final baseViewState =
        state._session.preferences.viewState ?? state._viewProfile.defaults();
    final viewState = switchSnapshot == null
        ? baseViewState
        : baseViewState.withLayoutSnapshot(switchSnapshot);
    final shelfState = shelf.asData?.value;
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
                        allOwnedCopies: [
                          for (final item in (projection ??
                                  state._projectionForShelf(
                                    stateValue,
                                    viewState,
                                  ))
                              .allItems)
                            if (item.source.ownedSummary case final owned?)
                              owned,
                        ],
                        allWishlistItems: allWishlistItems,
                      ),
                      error: (error, _) => AppErrorCard(
                        message: error.toString(),
                      ),
                      loading: () => const SkeletonGrid(),
                    ),
                  ),
                  LibraryCollectionTabBar(
                    mediaKind: state.widget.type.kind.apiValue,
                    activeSmartListId:
                        state._session.preferences.activeSmartListId,
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
    required List<OwnedItemSummary> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final registration = state.widget.type;
    final activeScope = projection.allItems.isNotEmpty
        ? projection.allItems.first.node.scope
        : libraryBrowserNavigationPolicy.entityScopeForBrowserMode(
            viewState.browserMode,
          );
    final activeFields = libraryKindWorkspaceForKind(registration.kind)
        .fieldsForScope(activeScope);
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
        (item) => item.node.id == state._session.selection.selectedId,
      );
      if (!hasSelection) {
        final firstReleaseId = projection.filteredItems.first.node.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.mounted ||
              state._session.selection.selectedId == firstReleaseId) {
            return;
          }
          state._activateItem(firstReleaseId);
        });
      }
    }
    // Switching Work/Release scope invalidates the previous node id. Keep the
    // inspector attached to the active entity scope instead of leaving it on
    // the previous Work projection while the browser shows Releases.
    if (state._session.selection.selectedId != null &&
        projection.filteredItems.isNotEmpty &&
        !projection.filteredItems.any(
          (item) => item.node.id == state._session.selection.selectedId,
        )) {
      final firstVisibleId = projection.filteredItems.first.node.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!state.mounted ||
            state._session.selection.selectedId == firstVisibleId) {
          return;
        }
        state._activateItem(firstVisibleId);
      });
    }
    final searchState = state._searchControllerOps.state;
    final trimmedSearchQuery = searchState.query.trim();
    final bucketStatusSummary =
        state._bucketStatusSummaryForProjection(projection);
    if (kDebugMode &&
        kIsWeb &&
        state._session.selection.selectedId == null &&
        state._session.selection.value.itemIds.isEmpty &&
        projection.filteredItems.isNotEmpty) {
      final firstVisibleId = projection.filteredItems.first.node.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!state.mounted ||
            state._session.selection.selectedId != null ||
            state._session.selection.value.itemIds.isNotEmpty) {
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
    final canUseBucketCompletionScope = libraryGroupModeSupportsCompletion(
      state.widget.type,
      state._activeGroupMode,
    );
    final effectiveBucketCompletionScope = canUseBucketCompletionScope
        ? state._session.facets.bucketCompletionScope
        : LibraryBucketCompletionScope.all;
    return LibraryBody(
      type: state.widget.type,
      projection: projection,
      viewState: viewState,
      selectedId: state._session.selection.selectedId,
      selectedAnchorId: state._session.selection.anchorId,
      selectedBucket: state._session.facets.selectedBucket,
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
      selectionEnabled: state._session.selection.value.enabled &&
          viewState.viewMode != LibraryViewMode.cardFlow,
      selectedItemIds: state._session.selection.value.itemIds,
      onApplySelection: state._applySelection,
      onActivateItem: state._activateItem,
      onToggleSelectionItem: state._toggleSelectionItem,
      onOpenItem: (item) {
        final isMediaTitle = item.node.scope == LibraryEntityScope.work;
        if (state._shouldOpenReleaseFolder(item) && isMediaTitle) {
          state._openReleaseFolder(item);
          return;
        }
        state._editCoordinator.showDetailPage(item);
      },
      onBoxSelectionChanged: (ids) => state._rebuild(() {
        state._session.selection.value =
            state._session.selection.value.replace(ids);
        if (ids.isEmpty) {
          state._session.selection.anchorId = null;
        } else {
          state._session.selection.anchorId ??= ids.first;
          state._session.selection.selectedId =
              ids.contains(state._session.selection.selectedId)
                  ? state._session.selection.selectedId
                  : ids.first;
        }
      }),
      onBucketChanged: state._setSelectedBucket,
      collapsedGroupBuckets: state._session.preferences.collapsedGroupBuckets,
      onGroupBucketCollapsedToggled: state._toggleCollapsedGroupBucket,
      onSetCollapsedGroupBuckets: state._setCollapsedGroupBuckets,
      onGroupModeChanged: state._setGroupMode,
      onSortChanged: (column) => state._updateViewState(
        (stateValue) => stateValue.withSortColumn(
          activeFields.decodeSortId(column),
          state._viewProfile,
        ),
      ),
      onColumnWidthChanged: (column, width) => state._updateViewState(
        (stateValue) => stateValue.withColumnWidth(
          activeFields.decodeColumnId(column),
          width,
          state._viewProfile,
        ),
      ),
      onColumnReordered: (column, beforeColumn) => state._updateViewState(
        (stateValue) => stateValue.withReorderedColumn(
          column: activeFields.decodeColumnId(column),
          beforeColumn: beforeColumn == null
              ? null
              : activeFields.decodeColumnId(beforeColumn),
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
      onSidebarNavigateBack: state._session.preferences.scopeHistory.isEmpty
          ? null
          : state._navigateSidebarBack,
      onSidebarNavigateToBreadcrumb: state._navigateSidebarToBreadcrumb,
      onSidebarNavigateToAncestorScope: state._navigateSidebarToAncestorScope,
      searchQuery: trimmedSearchQuery.isEmpty ? null : trimmedSearchQuery,
      searchTarget: state._effectiveSearchTarget,
      activeSmartListName: state._session.preferences.activeSmartListName,
      quickView: state._session.facets.quickView,
      collectionStatusScope: state._session.facets.collectionStatusScope,
      bucketCompletionScope: effectiveBucketCompletionScope,
      collectionStatusScopeLabel: state._session.facets.collectionStatusScope ==
              LibraryCollectionStatusScope.all
          ? null
          : state._session.facets.collectionStatusScope.label,
      linkedMetadataFilterLabel:
          state._session.facets.linkedMetadataFilter?.chipLabel,
      sidebarSelectedLetter: state._session.facets.selectedLetter,
      bucketStatusSummary: bucketStatusSummary,
      filterSelection: state._session.selection.filterSelection,
      preferToolbarAlphabet: true,
      onCollectionStatusScopeChanged: state._toggleCollectionStatusScope,
      onBucketCompletionScopeChanged:
          canUseBucketCompletionScope ? state._setBucketCompletionScope : null,
      onFilterByValue: state._toggleLinkedMetadataFilter,
      selectedLetter: state._session.facets.selectedLetter,
      availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
        projection.filteredItems.map((i) => i.dto.primaryLabel),
      ),
      onLetterSelected: state._setSelectedLetter,
      db: state.ref.read(localDatabaseProvider),
      folderPreset: state._activeFolderPreset,
      pinnedFolderPresets: state._session.preferences.pinnedFolderPresets,
      onManageBuckets: state.supportsBucketManagement(activeProjectionGroupMode)
          ? () => unawaited(state._showBucketManagerFlow(projection))
          : null,
      onPinnedFolderPresetsChanged: state._setPinnedFolderPresets,
      folderDisplayMode: state._session.preferences.folderDisplayMode,
      folderTreeExpandedNodeIds:
          state._session.preferences.folderTreeExpandedNodeIds,
      folderTreeSelectedNodeId:
          state._session.preferences.folderTreeSelectedNodeId,
      onFolderDisplayModeChanged: state._setFolderDisplayMode,
      onFolderTreeNodeSelected: state._selectFolderTreePath,
      onFolderTreeNodeExpandedToggled: state._toggleFolderTreeNodeExpanded,
      inspectorContextLabel: releasePositionLabel,
      desktopToolbarBand: LibraryDesktopSecondaryToolbar(
        type: state.widget.type,
        viewState: viewState,
        counts: projection.counts,
        onEditColumns: state._dialogCoordinator.showColumnChooserFlow,
        columnFavoritePresets: state._columnFavoritePresets,
        activeColumnFavoriteLabel: state._activeColumnFavoriteLabel,
        onColumnFavoriteSelected: state._applyColumnFavorite,
        pinnedColumnFavoriteKeys:
            state._session.preferences.pinnedColumnFavoriteKeys,
        onEditSort: state._dialogCoordinator.showSortDialogFlow,
        onSidebarVisibilityChanged: state._setGroupingPanelVisibility,
        onViewModeChanged: (mode) => state._updateViewState(
          (stateValue) => stateValue.copyWith(viewMode: mode),
        ),
        browserMode: state._activeBrowserMode,
        onBrowserModeChanged: state._setBrowserMode,
        showReleaseFolderBack:
            libraryBrowserNavigationPolicy.shouldShowReleaseFolderBack(
          browserMode: state._activeBrowserMode,
          releaseFolderWorkId: state.activeReleaseFolderTitleItemId,
        ),
        releaseFolderLabel: state._releaseFolderLabelForProjection(projection),
        onReleaseFolderBack:
            libraryBrowserNavigationPolicy.shouldShowReleaseFolderBack(
          browserMode: state._activeBrowserMode,
          releaseFolderWorkId: state.activeReleaseFolderTitleItemId,
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
        selectedBucket: state._session.facets.linkedMetadataFilter?.chipLabel ??
            state._session.facets.selectedBucket,
        onClearBucket: state._clearToolbarSearchChip,
        quickView: state._session.facets.quickView,
        activeSortFavoriteId: state._activeSortFavorite?.id,
        sortFavorites: state._sortFavorites,
        onSortFavoriteSelected: state._applySortFavorite,
        pinnedSortFavoriteIds: state._session.preferences.pinnedSortFavoriteIds,
        onTogglePinnedSortFavorite: state._togglePinnedSortFavorite,
        onManageSortFavorites:
            state._dialogCoordinator.showSortFavoritesManagerFlow,
        hasActiveFilters: state._hasActiveFilter,
        onQuickViewSelected: (view) => state._setQuickView(
            state._session.facets.quickView == view ? null : view),
        onClearFilters: state._clearFilters,
        onEditFilters: () =>
            state._dialogCoordinator.showFilterDialogFlow(projection),
        activeFilterCount:
            state._session.selection.filterSelection.activeFilterCount,
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
        onReadingQueue: state.widget.type.toolbarActionAvailability
                .allows(LibraryToolbarActionId.readingQueue)
            ? state._dialogCoordinator.showReadingQueueFlow
            : null,
        onEditConditionPickList:
            libraryEditPresentationForKind(state.widget.type.kind)
                    .hasConditionPickList
                ? state._dialogCoordinator.showConditionPickListEditorFlow
                : null,
        onEditGradePickList:
            libraryEditPresentationForKind(state.widget.type.kind)
                    .hasCollectionValuePickList
                ? state._dialogCoordinator.showGradePickListEditorFlow
                : null,
        onEditTagPickList: state._dialogCoordinator.showTagPickListEditorFlow,
        onTransferFieldData: state._hasOwnedItemsInProjection(projection)
            ? () =>
                state._dialogCoordinator.showTransferFieldDataFlow(projection)
            : null,
        onReassignIndex: state.widget.type.toolbarActionAvailability
                    .allows(LibraryToolbarActionId.reassignIndex) &&
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
          if (!libraryMetadataForKind(state.widget.type.kind)
              .supportsServerCompare) {
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
        pinnedFolderPresets: state._session.preferences.pinnedFolderPresets,
        onPinnedFolderPresetsChanged: state._setPinnedFolderPresets,
        onGroupModeChanged: state._setFolderPreset,
        groupPresentation: state._activeGroupPresentation,
        onGroupPresentationChanged: state._setGroupPresentation,
        selectionCallbacks: viewState.viewMode == LibraryViewMode.cardFlow
            ? null
            : selectionCallbacksForProjection(state, projection),
        selectedCount: viewState.viewMode == LibraryViewMode.cardFlow
            ? 0
            : state._session.selection.value.selectedCount,
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
            state._session.selection.value =
                state._session.selection.value.clear();
            state._session.selection.anchorId = null;
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
