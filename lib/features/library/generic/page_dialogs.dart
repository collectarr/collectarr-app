part of 'page.dart';

/// Dialog launchers for the library page: filters, smart lists, sort, reading
/// queue, pick-list editors, column chooser, metadata refresh, share, print.
extension _LibraryPageDialogs on _LibraryPageState {
  Future<void> showFilterDialogFlow(
    LibraryProjection? projection,
  ) async {
    await _loadActiveLoanIds();
    if (!mounted) {
      return;
    }
    final allEntries =
        projection?.allItems.map((i) => i.entry).toList(growable: false) ??
            const [];
    final options = LibraryFilterOptions.fromEntries(
      allEntries,
      adapter: _adapter,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
    );
    final result = await showLibraryFilterDialog(
      context: context,
      type: widget.type,
      current: _filterSelection,
      options: options,
    );
    if (result != null && mounted) {
      _mutateSidebarScope(() {
        _filterSelection = result;
        _activeSmartListId = null;
        _activeSmartListName = null;
      });
    }
  }

  Future<void> showSmartListsFlow(ShelfState? shelfState) async {
    final db = ref.read(localDatabaseProvider);
    final result = await showSmartListsDialog(
      context: context,
      db: db,
      mediaKind: widget.type.workspace.kind.apiValue,
      currentFilter: _filterSelection,
      currentQuickView: _quickView,
      currentSortRules: _viewState?.sortRules,
      currentSortColumn: _viewState?.sortColumn,
      currentSortAscending: _viewState?.sortAscending,
      currentSearchQuery:
          _searchController.text.isNotEmpty ? _searchController.text : null,
      customFieldDefinitions: customFieldDefinitions,
    );
    if (result != null && mounted) {
      _rebuild(() {
        _filterSelection = result.filterSelection;
        _quickView = result.quickView;
        if (result.searchQuery != null) {
          _searchController.text = result.searchQuery!;
        } else {
          _searchController.clear();
        }
        if (_viewState != null) {
          if (result.sortRules != null && result.sortRules!.isNotEmpty) {
            _viewState = _viewState!.withSortRules(
              result.sortRules!,
              _adapter.viewProfile,
            );
          } else if (result.sortColumn != null) {
            _viewState = _viewState!.copyWith(
              sortColumn: result.sortColumn,
              sortAscending: result.sortAscending ?? true,
            );
          }
        }
      });
    }
  }

  Future<void> showSortDialogFlow() async {
    final viewState = _viewState;
    if (viewState == null) {
      return;
    }
    final sortRules = await showLibrarySortDialog(
      context: context,
      type: widget.type,
      currentRules: viewState.sortRules,
      defaultAscendingForColumn: _adapter.viewProfile.initialSortAscending,
    );
    if (sortRules != null && mounted) {
      _updateViewState(
        (state) => state.withSortRules(sortRules, _adapter.viewProfile),
      );
    }
  }

  Future<void> showSortFavoritesManagerFlow() async {
    final result = await showSortFavoritesManagerDialog(
      context: context,
      type: widget.type,
      favorites: _sortFavorites,
      initialPinnedIds: _pinnedSortFavoriteIds,
      activeSortFavoriteId: _activeSortFavorite?.id,
    );
    if (result != null && mounted) {
      _rebuild(() => _pinnedSortFavoriteIds = result);
      unawaited(_viewPrefs.writePinnedSortFavoriteIds(result));
    }
  }

  Future<void> showReadingQueueFlow() async {
    final db = ref.read(localDatabaseProvider);
    final queueIds = await ReadingQueueRepository(db).getQueue();
    final ownedItems = await ref.read(collectionProvider.future);
    final queuedOwnedItems = ownedItems
        .where((item) => !item.isDeleted && queueIds.contains(item.id))
        .toList(growable: false);
    final catalogItemsById = await CatalogCacheRepository(db).findByIds(
      queuedOwnedItems.map((item) => item.itemId),
    );
    if (!mounted) {
      return;
    }
    await showReadingQueueDialog(
      context: context,
      db: db,
      mediaKind: widget.type.workspace.kind.apiValue,
      ownedItems: queuedOwnedItems,
      catalogItemsById: catalogItemsById,
      onSelectItem: _selectItem,
    );
  }

  Future<void> showConditionPickListEditorFlow() async {
    final db = ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: context,
      db: db,
      listName: kConditionPickListName,
      label: 'Condition',
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInValues: widget.type.conditions,
    );
    if (mounted) {
      _rebuild(() {});
    }
  }

  Future<void> showGradePickListEditorFlow() async {
    final db = ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: context,
      db: db,
      listName: kGradePickListName,
      label: 'Grade',
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInValues: widget.type.grades,
    );
    if (mounted) {
      _rebuild(() {});
    }
  }

  Future<void> showTagPickListEditorFlow() async {
    final db = ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: context,
      db: db,
      listName: kTagPickListName,
      label: 'Tag',
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInValues: const [],
    );
    if (mounted) {
      _rebuild(() {});
    }
  }

  Future<void> showColumnChooserFlow() async {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    final selected = await showGenericLibraryColumnChooser(
      context: context,
      type: widget.type,
      adapter: _adapter,
      viewState: viewState,
      pinnedFavoriteKeys: _pinnedColumnFavoriteKeys,
      onTogglePinnedFavorite: _togglePinnedColumnFavorite,
    );
    if (selected != null) {
      _updateViewState((state) => state.copyWith(visibleColumns: selected));
    }
    await _loadColumnFavoritePresets();
  }

  Future<void> showMetadataRefreshFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Library data is still loading')),
      );
      return;
    }
    final result = await showGenericLibraryMetadataRefreshDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      projection: projection,
    );
    if (result == null || !mounted) {
      return;
    }
    ref.invalidate(shelfProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Metadata refresh finished: ${result.matched}/${result.targets} matched, ${result.cached} cached, ${result.failed} failed.',
        ),
      ),
    );
  }

  void printReportFlow(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    printCollectionReport(
      context: context,
      title: widget.type.workspace.title,
      items: items,
    );
  }

  void shareCollectionFlow(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    showCollectionShareDialog(
      context: context,
      title: widget.type.workspace.title,
      items: items,
    );
  }

  void printSelectedReportFlow(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (items.isEmpty) return;
    printCollectionReport(
      context: context,
      title: widget.type.workspace.title,
      items: items,
    );
  }

  void shareSelectedCollectionFlow(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final items = [
      for (final item in projection.filteredItems)
        if (_selection.itemIds.contains(item.entry.id)) item.entry,
    ];
    if (items.isEmpty) return;
    showCollectionShareDialog(
      context: context,
      title: widget.type.workspace.title,
      items: items,
    );
  }

  Future<void> showUserFoldersFlow() async {
    final db = ref.read(localDatabaseProvider);
    await showUserFoldersDialog(context: context, db: db);
  }

  Future<void> showTransferFieldDataFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null) return;
    final db = ref.read(localDatabaseProvider);
    final ownedItems = await ref.read(collectionProvider.future);
    // Intersect with currently visible items.
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (item.entry.ownedItemId != null) item.entry.ownedItemId!,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !mounted) return;

    final mutations = ref.read(collectionMutationsProvider);
    final result = await showTransferFieldDataDialog(
      context: context,
      db: db,
      type: widget.type,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldDefinitions,
    );
    if (result != null && mounted) {
      ref.invalidate(shelfProvider);
      loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer complete: ${result.transferred} transferred, '
            '${result.skipped} skipped out of ${result.total}.',
          ),
        ),
      );
    }
  }

  Future<void> showTransferFieldDataForSelectionFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final db = ref.read(localDatabaseProvider);
    final ownedItems = await ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (_selection.itemIds.contains(item.entry.id) &&
            item.entry.ownedItemId != null)
          item.entry.ownedItemId!,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !mounted) return;

    final mutations = ref.read(collectionMutationsProvider);
    final result = await showTransferFieldDataDialog(
      context: context,
      db: db,
      type: widget.type,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldDefinitions,
    );
    if (result != null && mounted) {
      ref.invalidate(shelfProvider);
      loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer complete: ${result.transferred} transferred, '
            '${result.skipped} skipped out of ${result.total}.',
          ),
        ),
      );
    }
  }

  Future<void> reassignIndexFlow(LibraryProjection projection) async {
    final items = projection.filteredItems;
    if (items.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-assign index values'),
        content: Text(
          'Assign sequential index numbers (1–${items.length}) '
          'to ${items.length} item${items.length == 1 ? '' : 's'} '
          'in their current display order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Re-assign'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final mutations = ref.read(collectionMutationsProvider);
    var count = 0;
    for (var i = 0; i < items.length; i++) {
      final ownedItem = items[i].source.ownedItem;
      if (ownedItem == null) continue;
      await mutations.updateItem(
        ownedItem,
        indexNumber: i + 1,
        notify: i == items.length - 1,
      );
      count++;
    }
    ref.invalidate(shelfProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assigned index values to $count items'),
        ),
      );
    }
  }
}
