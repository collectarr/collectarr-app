part of '../generic_library_page.dart';

/// Dialog launchers for the library page: add, filters, smart lists, sort,
/// reading queue, pick-list editors, column chooser, user folders, transfer,
/// loans, and index reassignment.
class LibraryPageDialogCoordinator {
  LibraryPageDialogCoordinator(this._s);

  final GenericLibraryPageState _s;

  // ---------------------------------------------------------------------------
  // Add / reveal
  // ---------------------------------------------------------------------------

  Future<void> showAddDialogFlow({String? barcode}) async {
    final searchState = _LibraryPageSearchControllerOps.thisState(_s);
    final added = await showLibraryAddDialog(
      context: _s.context,
      type: _s.widget.type,
      accent: _s.widget.accent,
      initialQuery: searchState.query,
      initialBarcode: barcode,
    );
    if (added != null && _s.mounted) {
      _s.ref.invalidate(shelfProvider);
      _revealAddedItems(added.itemIds);
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
          content: Text(
            added.target == LibraryAddTarget.track
                ? '${_s.widget.type.singularLabel} added to tracking'
                : '${_s.widget.type.singularLabel} added',
          ),
        ),
      );
    }
  }

  void _revealAddedItems(List<String> itemIds) {
    if (itemIds.isEmpty) {
      return;
    }
    _s._rebuild(() {
      _s._selectedId = itemIds.first;
      _s._selectedBucket = null;
      _s._selectedLetter = null;
      _s._linkedMetadataFilter = null;
      _s._collectionStatusScope = LibraryCollectionStatusScope.all;
      _s._seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _s._quickView = null;
      _s._filterSelection = LibraryFilterSelection.none;
      _s._activeSmartListId = null;
      _s._activeSmartListName = null;
      _s._scopeHistory = const [];
      _s._searchController.clear();
    });
    _LibraryPageSearchControllerOps.clearSearch(_s);
    _s._syncRouteState();
  }

  // ---------------------------------------------------------------------------
  // Filter / smart lists / sort
  // ---------------------------------------------------------------------------

  Future<void> showFilterDialogFlow(
    LibraryProjection? projection,
  ) async {
    await _LibraryPageLifecycleControllerOps.loadActiveLoanIds(_s);
    if (!_s.mounted) {
      return;
    }
    final customFieldCache = await _s.ref.read(
      libraryCustomFieldCacheProvider(_s.widget.type.workspace.kind.apiValue)
          .future,
    );
    if (!_s.mounted) {
      return;
    }
    final allEntries =
        projection?.allItems.map((i) => i.entry).toList(growable: false) ??
            const [];
    final options = LibraryFilterOptions.fromEntries(
      allEntries,
      adapter: _s._adapter,
      customFieldDefinitions: customFieldCache.definitions,
      customFieldValuesByDefinitionByItem:
          customFieldCache.valuesByDefinitionByItem,
    );
    final result = await showLibraryFilterDialog(
      context: _s.context,
      type: _s.widget.type,
      current: _s._filterSelection,
      options: options,
    );
    if (result != null && _s.mounted) {
      _s._mutateSidebarScope(() {
        _s._filterSelection = result;
        _s._activeSmartListId = null;
        _s._activeSmartListName = null;
      });
    }
  }

  Future<void> showSmartListsFlow(ShelfState? shelfState) async {
    final db = _s.ref.read(localDatabaseProvider);
    final customFieldCache = await _s.ref.read(
      libraryCustomFieldCacheProvider(_s.widget.type.workspace.kind.apiValue)
          .future,
    );
    if (!_s.mounted) {
      return;
    }
    final searchState = _LibraryPageSearchControllerOps.thisState(_s);
    final result = await showSmartListsDialog(
      context: _s.context,
      db: db,
      mediaKind: _s.widget.type.workspace.kind.apiValue,
      currentFilter: _s._filterSelection,
      currentQuickView: _s._quickView,
      currentSortRules: _s._viewState?.sortRules,
      currentSortColumn: _s._viewState?.sortColumn,
      currentSortAscending: _s._viewState?.sortAscending,
      currentSearchQuery:
          searchState.query.isNotEmpty ? searchState.query : null,
      customFieldDefinitions: customFieldCache.definitions,
    );
    if (result != null && _s.mounted) {
      _s._rebuild(() {
        _s._filterSelection = result.filterSelection;
        _s._quickView = result.quickView;
        if (result.searchQuery != null) {
          _s._searchController.text = result.searchQuery!;
          _LibraryPageSearchControllerOps.setQuery(_s, result.searchQuery!);
        } else {
          _s._searchController.clear();
          _LibraryPageSearchControllerOps.clearSearch(_s);
        }
        if (_s._viewState != null) {
          if (result.sortRules != null && result.sortRules!.isNotEmpty) {
            _s._viewState = _s._viewState!.withSortRules(
              result.sortRules!,
              _s._adapter.viewProfile,
            );
          } else if (result.sortColumn != null) {
            _s._viewState = _s._viewState!.copyWith(
              sortColumn: result.sortColumn,
              sortAscending: result.sortAscending ?? true,
            );
          }
        }
      });
      _s._syncRouteState();
    }
  }

  Future<void> showSortDialogFlow() async {
    final viewState = _s._viewState;
    if (viewState == null) {
      return;
    }
    final sortRules = await showLibrarySortDialog(
      context: _s.context,
      type: _s.widget.type,
      currentRules: viewState.sortRules,
      defaultAscendingForColumn: _s._adapter.viewProfile.initialSortAscending,
      availableColumns: _s._scopeAvailableSortColumns,
    );
    if (sortRules != null && _s.mounted) {
      final allowed = _s._scopeAvailableSortColumns.toSet();
      final filteredRules = [
        for (final rule in sortRules)
          if (allowed.contains(rule.column)) rule,
      ];
      if (filteredRules.isEmpty) {
        return;
      }
      _s._updateViewState(
        (state) => state.withSortRules(filteredRules, _s._adapter.viewProfile),
      );
    }
  }

  Future<void> showSortFavoritesManagerFlow() async {
    final result = await showSortFavoritesManagerDialog(
      context: _s.context,
      type: _s.widget.type,
      favorites: _s._sortFavorites,
      initialPinnedIds: _s._pinnedSortFavoriteIds,
      activeSortFavoriteId: _s._activeSortFavorite?.id,
    );
    if (result != null && _s.mounted) {
      _s._rebuild(() => _s._pinnedSortFavoriteIds = result);
      unawaited(_s._viewPrefs.writePinnedSortFavoriteIds(result));
    }
  }

  // ---------------------------------------------------------------------------
  // Reading queue / pick-list editors
  // ---------------------------------------------------------------------------

  Future<void> showReadingQueueFlow() async {
    final db = _s.ref.read(localDatabaseProvider);
    final queueIds = await ReadingQueueRepository(db).getQueue();
    final ownedItems = await _s.ref.read(collectionProvider.future);
    final queuedOwnedItems = ownedItems
        .where((item) => !item.isDeleted && queueIds.contains(item.id))
        .toList(growable: false);
    final catalogItemsById = await CatalogCacheRepository(db).findByIds(
      queuedOwnedItems.map((item) => item.itemId),
    );
    if (!_s.mounted) {
      return;
    }
    await showReadingQueueDialog(
      context: _s.context,
      db: db,
      mediaKind: _s.widget.type.workspace.kind.apiValue,
      ownedItems: queuedOwnedItems,
      catalogItemsById: catalogItemsById,
      onSelectItem: _s._selectItem,
    );
  }

  Future<void> showConditionPickListEditorFlow() async {
    final db = _s.ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: _s.context,
      db: db,
      listName: kConditionPickListName,
      label: 'Condition',
      mediaKind: _s.widget.type.workspace.kind.apiValue,
      builtInValues: _s.widget.type.conditions,
    );
    if (_s.mounted) {
      _s._rebuild(() {});
    }
  }

  Future<void> showGradePickListEditorFlow() async {
    final db = _s.ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: _s.context,
      db: db,
      listName: kGradePickListName,
      label: 'Grade',
      mediaKind: _s.widget.type.workspace.kind.apiValue,
      builtInValues: _s.widget.type.grades,
    );
    if (_s.mounted) {
      _s._rebuild(() {});
    }
  }

  Future<void> showTagPickListEditorFlow() async {
    final db = _s.ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: _s.context,
      db: db,
      listName: kTagPickListName,
      label: 'Tag',
      mediaKind: _s.widget.type.workspace.kind.apiValue,
      builtInValues: const [],
    );
    if (_s.mounted) {
      _s._rebuild(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // Column chooser
  // ---------------------------------------------------------------------------

  Future<void> showColumnChooserFlow() async {
    final viewState = _s._viewState ?? _s._adapter.viewProfile.defaults();
    final selected = await showGenericLibraryColumnChooser(
      context: _s.context,
      type: _s.widget.type,
      adapter: _s._adapter,
      viewState: viewState,
      pinnedFavoriteKeys: _s._pinnedColumnFavoriteKeys,
      onTogglePinnedFavorite: _s._togglePinnedColumnFavorite,
    );
    if (selected != null) {
      _s._updateViewState((state) => state.copyWith(visibleColumns: selected));
    }
    await _s._loadColumnFavoritePresets();
  }

  // ---------------------------------------------------------------------------
  // User folders / transfer field data / index reassignment / loans
  // ---------------------------------------------------------------------------

  Future<void> showUserFoldersFlow() async {
    final db = _s.ref.read(localDatabaseProvider);
    await showUserFoldersDialog(context: _s.context, db: db);
  }

  Future<void> showTransferFieldDataFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null) return;
    final db = _s.ref.read(localDatabaseProvider);
    final customFieldCache = await _s.ref.read(
      libraryCustomFieldCacheProvider(_s.widget.type.workspace.kind.apiValue)
          .future,
    );
    final ownedItems = await _s.ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (item.entry.ownedItemId != null) item.entry.ownedItemId!,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !_s.mounted) return;

    final mutations = _s.ref.read(collectionMutationsProvider);
    final result = await showTransferFieldDataDialog(
      context: _s.context,
      db: db,
      type: _s.widget.type,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldCache.definitions,
    );
    if (result != null && _s.mounted) {
      _s.ref.invalidate(shelfProvider);
      _s.ref.invalidate(
        libraryCustomFieldCacheProvider(
            _s.widget.type.workspace.kind.apiValue),
      );
      ScaffoldMessenger.of(_s.context).showSnackBar(
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
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final db = _s.ref.read(localDatabaseProvider);
    final customFieldCache = await _s.ref.read(
      libraryCustomFieldCacheProvider(_s.widget.type.workspace.kind.apiValue)
          .future,
    );
    final ownedItems = await _s.ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (_s._selection.itemIds.contains(item.entry.id) &&
            item.entry.ownedItemId != null)
          item.entry.ownedItemId!,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !_s.mounted) return;

    final mutations = _s.ref.read(collectionMutationsProvider);
    final result = await showTransferFieldDataDialog(
      context: _s.context,
      db: db,
      type: _s.widget.type,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldCache.definitions,
    );
    if (result != null && _s.mounted) {
      _s.ref.invalidate(shelfProvider);
      _s.ref.invalidate(
        libraryCustomFieldCacheProvider(
            _s.widget.type.workspace.kind.apiValue),
      );
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer complete: ${result.transferred} transferred, '
            '${result.skipped} skipped out of ${result.total}.',
          ),
        ),
      );
    }
  }

  Future<void> showLoanSelectionFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null || _s._selection.itemIds.isEmpty) return;
    final ownedItemIds = <String>{
      for (final item in projection.filteredItems)
        if (_s._selection.itemIds.contains(item.entry.id) &&
            item.entry.ownedItemId != null &&
            !_s._activeLoanOwnedItemIds
                .contains(item.entry.ownedItemId))
          item.entry.ownedItemId!,
    };
    if (ownedItemIds.isEmpty || !_s.mounted) return;

    final draft = await showDialog<_BatchLoanDraft>(
      context: _s.context,
      builder: (context) => _BatchLoanDialog(
        accent: _s.widget.accent,
        itemCount: ownedItemIds.length,
      ),
    );
    if (draft == null || !_s.mounted) return;

    final repo = LoanRepository(_s.ref.read(localDatabaseProvider));
    for (final ownedItemId in ownedItemIds) {
      await repo.create(
        Loan(
          id: const Uuid().v4(),
          ownedItemId: ownedItemId,
          borrowerName: draft.borrowerName,
          lentDate: draft.lentDate,
          dueDate: draft.dueDate,
          notes: draft.notes,
        ),
      );
    }

    _s._rebuild(() => _s._selection = _s._selection.clear());
    await _LibraryPageLifecycleControllerOps.loadActiveLoanIds(_s);
    if (_s.mounted) {
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
          content: Text(
            'Created ${ownedItemIds.length} loan record${ownedItemIds.length == 1 ? '' : 's'}.',
          ),
        ),
      );
    }
  }

  Future<void> reassignIndexFlow(LibraryProjection projection) async {
    final items = projection.filteredItems;
    if (items.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: _s.context,
      builder: (ctx) => AccentAlertDialog(
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
    if (confirmed != true || !_s.mounted) return;

    final mutations = _s.ref.read(collectionMutationsProvider);
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
    _s.ref.invalidate(shelfProvider);
    if (_s.mounted) {
      ScaffoldMessenger.of(_s.context).showSnackBar(
        SnackBar(
          content: Text('Assigned index values to $count items'),
        ),
      );
    }
  }
}

class _BatchLoanDraft {
  const _BatchLoanDraft({
    required this.borrowerName,
    required this.lentDate,
    this.dueDate,
    this.notes,
  });

  final String borrowerName;
  final DateTime lentDate;
  final DateTime? dueDate;
  final String? notes;
}

class _BatchLoanDialog extends StatefulWidget {
  const _BatchLoanDialog({
    required this.accent,
    required this.itemCount,
  });

  final Color accent;
  final int itemCount;

  @override
  State<_BatchLoanDialog> createState() => _BatchLoanDialogState();
}

class _BatchLoanDialogState extends State<_BatchLoanDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _lentDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Loan ${widget.itemCount} items',
          style: TextStyle(color: widget.accent)),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Borrower name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BatchLoanDatePickerField(
                    label: 'Lent date',
                    value: _lentDate,
                    onChanged: (d) => setState(() => _lentDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BatchLoanDatePickerField(
                    label: 'Due date',
                    value: _dueDate,
                    onChanged: (d) => setState(() => _dueDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: widget.accent),
          child: const Text('Loan'),
        ),
      ],
    );
  }

  void _submit() {
    final borrowerName = _nameController.text.trim();
    if (borrowerName.isEmpty) return;
    Navigator.pop(
      context,
      _BatchLoanDraft(
        borrowerName: borrowerName,
        lentDate: _lentDate,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }
}

class _BatchLoanDatePickerField extends StatelessWidget {
  const _BatchLoanDatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
        : 'Select';
    return OutlinedButton(
      onPressed: () async {
        final initialDate = value ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(height: 2),
          Text(display),
        ],
      ),
    );
  }
}
