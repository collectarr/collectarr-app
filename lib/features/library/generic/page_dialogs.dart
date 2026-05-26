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
    final allEntries = projection?.allItems
            .map((i) => i.entry)
            .toList(growable: false) ??
        const [];
    final options = LibraryFilterOptions.fromEntries(
      allEntries,
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
      _rebuild(() => _filterSelection = result);
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
      currentSearchQuery: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
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
      currentRules: viewState.sortRules,
    );
    if (sortRules != null && mounted) {
      _updateViewState(
        (state) => state.withSortRules(sortRules, _adapter.viewProfile),
      );
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
    );
    if (selected != null) {
      _updateViewState((state) => state.copyWith(visibleColumns: selected));
    }
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

  Future<void> showUserFoldersFlow() async {
    final db = ref.read(localDatabaseProvider);
    await showUserFoldersDialog(context: context, db: db);
  }
}
