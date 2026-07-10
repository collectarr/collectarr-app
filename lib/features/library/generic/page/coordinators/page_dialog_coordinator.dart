import 'dart:async';

import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/generic/column_chooser.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/dialogs/batch_loan_dialog.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_enums.dart';
import 'package:collectarr_app/features/library/generic/reading_queue_dialog.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/transfer_field_data_dialog.dart';
import 'package:collectarr_app/features/library/generic/user_folders_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Dialog launchers for the library page: add, filters, smart lists, sort,
/// reading queue, pick-list editors, column chooser, user folders, transfer,
/// loans, and index reassignment.
class LibraryPageDialogCoordinator {
  LibraryPageDialogCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  // ---------------------------------------------------------------------------
  // Add / reveal
  // ---------------------------------------------------------------------------

  Future<void> showAddDialogFlow({String? barcode}) async {
    final context = _page.context;
    final added = await showLibraryAddDialog(
      context: context,
      type: _page.type,
      accent: _page.accent,
      initialQuery: _page.searchQuery,
      initialBarcode: barcode,
    );
    if (added != null && _page.mounted && context.mounted) {
      _page.invalidateShelf();
      _revealAddedItems(added.itemIds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added.target == LibraryAddTarget.track
                ? '${_page.type.singularLabel} added to tracking'
                : '${_page.type.singularLabel} added',
          ),
        ),
      );
    }
  }

  void _revealAddedItems(List<String> itemIds) {
    if (itemIds.isEmpty) {
      return;
    }
    _page.rebuild(() {
      _page.selectedId = itemIds.first;
      _page.selectedBucket = null;
      _page.selectedLetter = null;
      _page.linkedMetadataFilter = null;
      _page.collectionStatusScope = LibraryCollectionStatusScope.all;
      _page.seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _page.quickView = null;
      _page.filterSelection = LibraryFilterSelection.none;
      _page.activeSmartListId = null;
      _page.activeSmartListName = null;
      _page.scopeHistory = const [];
    });
    _page.clearSearchQuery();
    _page.syncRouteState();
  }

  // ---------------------------------------------------------------------------
  // Filter / smart lists / sort
  // ---------------------------------------------------------------------------

  Future<void> showFilterDialogFlow(
    LibraryProjection? projection,
  ) async {
    final context = _page.context;
    await _page.loadActiveLoanIds();
    if (!_page.mounted) {
      return;
    }
    final customFieldCache = await _page.ref.read(
      libraryCustomFieldCacheProvider(_page.type.workspace.kind.apiValue)
          .future,
    );
    if (!_page.mounted) {
      return;
    }
    final allEntries =
        projection?.allItems.map((i) => i.entry).toList(growable: false) ??
            const [];
    final options = LibraryFilterOptions.fromEntries(
      allEntries,
      adapter: _page.adapter,
      customFieldDefinitions: customFieldCache.definitions,
      customFieldValuesByDefinitionByItem:
          customFieldCache.valuesByDefinitionByItem,
    );
    if (!context.mounted) {
      return;
    }
    final result = await showLibraryFilterDialog(
      context: context,
      type: _page.type,
      current: _page.filterSelection,
      options: options,
    );
    if (result != null && _page.mounted && context.mounted) {
      _page.mutateSidebarScope(() {
        _page.filterSelection = result;
        _page.activeSmartListId = null;
        _page.activeSmartListName = null;
      });
    }
  }

  Future<void> showSmartListsFlow(ShelfState? ignoredShelfState) async {
    final context = _page.context;
    final db = _page.ref.read(localDatabaseProvider);
    final customFieldCache = await _page.ref.read(
      libraryCustomFieldCacheProvider(_page.type.workspace.kind.apiValue)
          .future,
    );
    if (!_page.mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final result = await showSmartListsDialog(
      context: context,
      db: db,
      mediaKind: _page.type.workspace.kind.apiValue,
      currentFilter: _page.filterSelection,
      currentQuickView: _page.quickView,
      currentSortRules: _page.viewState?.sortRules,
      currentSortColumn: _page.viewState?.sortColumn as LibrarySortColumn?,
      currentSortAscending: _page.viewState?.sortAscending,
      currentSearchQuery:
          _page.searchQuery.isNotEmpty ? _page.searchQuery : null,
      customFieldDefinitions: customFieldCache.definitions,
    );
    if (result != null && _page.mounted && context.mounted) {
      _page.rebuild(() {
        _page.filterSelection = result.filterSelection;
        _page.quickView = result.quickView;
        if (result.searchQuery != null) {
          _page.setSearchQuery(result.searchQuery!);
        } else {
          _page.clearSearchQuery();
        }
        final viewState = _page.viewState;
        if (viewState != null) {
          if (result.sortRules != null && result.sortRules!.isNotEmpty) {
            _page.viewState = viewState.withSortRules(
              result.sortRules!,
              _page.adapter.viewProfile,
            );
          } else if (result.sortColumn != null) {
            _page.viewState = viewState.copyWith(
              sortColumn: result.sortColumn,
              sortAscending: result.sortAscending ?? true,
            );
          }
        }
      });
      _page.syncRouteState();
    }
  }

  Future<void> showSortDialogFlow() async {
    final viewState = _page.viewState;
    if (viewState == null) {
      return;
    }
    final sortRules = await showLibrarySortDialog(
      context: _page.context,
      type: _page.type,
      currentRules: viewState.sortRules,
      defaultAscendingForColumn: _page.adapter.viewProfile.initialSortAscending,
      availableColumns: _page.scopeAvailableSortColumns,
    );
    if (sortRules != null && _page.mounted) {
      final allowed = _page.scopeAvailableSortColumns.toSet();
      final filteredRules = [
        for (final rule in sortRules)
          if (allowed.contains(rule.column)) rule,
      ];
      if (filteredRules.isEmpty) {
        return;
      }
      _page.updateViewState(
        (state) =>
            state.withSortRules(filteredRules, _page.adapter.viewProfile),
      );
    }
  }

  Future<void> showSortFavoritesManagerFlow() async {
    final result = await showSortFavoritesManagerDialog(
      context: _page.context,
      type: _page.type,
      favorites: _page.sortFavorites,
      initialPinnedIds: _page.pinnedSortFavoriteIds,
      activeSortFavoriteId: _page.activeSortFavorite?.id,
    );
    if (result != null && _page.mounted) {
      _page.rebuild(() => _page.pinnedSortFavoriteIds = result);
      unawaited(_page.viewPrefs.writePinnedSortFavoriteIds(result));
    }
  }

  // ---------------------------------------------------------------------------
  // Reading queue / pick-list editors
  // ---------------------------------------------------------------------------

  Future<void> showReadingQueueFlow() async {
    final context = _page.context;
    final db = _page.ref.read(localDatabaseProvider);
    final queueIds = await ReadingQueueRepository(db).getQueue();
    final ownedItems = await _page.ref.read(collectionProvider.future);
    final queuedOwnedItems = ownedItems
        .where((item) => !item.isDeleted && queueIds.contains(item.id))
        .toList(growable: false);
    final catalogItemsById = await CatalogCacheRepository(db).findByIds(
      queuedOwnedItems.map((item) => item.itemId),
    );
    if (!_page.mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await showReadingQueueDialog(
      context: context,
      db: db,
      mediaKind: _page.type.workspace.kind.apiValue,
      ownedItems: queuedOwnedItems,
      catalogItemsById: catalogItemsById,
      onSelectItem: _page.selectItem,
    );
  }

  Future<void> showConditionPickListEditorFlow() async {
    final db = _page.ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: _page.context,
      db: db,
      listName: kConditionPickListName,
      label: 'Condition',
      mediaKind: _page.type.workspace.kind.apiValue,
      builtInValues: _page.type.conditions,
    );
    if (_page.mounted) {
      _page.rebuild(() {});
    }
  }

  Future<void> showGradePickListEditorFlow() async {
    final db = _page.ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: _page.context,
      db: db,
      listName: kGradePickListName,
      label: 'Grade',
      mediaKind: _page.type.workspace.kind.apiValue,
      builtInValues: _page.type.grades,
    );
    if (_page.mounted) {
      _page.rebuild(() {});
    }
  }

  Future<void> showTagPickListEditorFlow() async {
    final db = _page.ref.read(localDatabaseProvider);
    await showPickListEditorDialog(
      context: _page.context,
      db: db,
      listName: kTagPickListName,
      label: 'Tag',
      mediaKind: _page.type.workspace.kind.apiValue,
      builtInValues: const [],
    );
    if (_page.mounted) {
      _page.rebuild(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // Column chooser
  // ---------------------------------------------------------------------------

  Future<void> showColumnChooserFlow() async {
    final viewState = _page.viewState ?? _page.adapter.viewProfile.defaults();
    final selected = await showGenericLibraryColumnChooser(
      context: _page.context,
      type: _page.type,
      adapter: _page.adapter,
      viewState: viewState,
      pinnedFavoriteKeys: _page.pinnedColumnFavoriteKeys,
      onTogglePinnedFavorite: _page.togglePinnedColumnFavorite,
    );
    if (selected != null) {
      _page
          .updateViewState((state) => state.copyWith(visibleColumns: selected));
    }
    await _page.loadColumnFavoritePresets();
  }

  // ---------------------------------------------------------------------------
  // User folders / transfer field data / index reassignment / loans
  // ---------------------------------------------------------------------------

  Future<void> showUserFoldersFlow() async {
    final db = _page.ref.read(localDatabaseProvider);
    await showUserFoldersDialog(context: _page.context, db: db);
  }

  Future<void> showTransferFieldDataFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null) return;
    final context = _page.context;
    final db = _page.ref.read(localDatabaseProvider);
    final customFieldCache = await _page.ref.read(
      libraryCustomFieldCacheProvider(_page.type.workspace.kind.apiValue)
          .future,
    );
    final ownedItems = await _page.ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (item.entry.ownedItemId != null) item.entry.ownedItemId!,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !_page.mounted) return;

    final mutations = _page.ref.read(collectionMutationsProvider);
    if (!context.mounted) {
      return;
    }
    final result = await showTransferFieldDataDialog(
      context: context,
      db: db,
      type: _page.type,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldCache.definitions,
    );
    if (result != null && _page.mounted && context.mounted) {
      _page.invalidateShelf();
      _page.ref.invalidate(
        libraryCustomFieldCacheProvider(_page.type.workspace.kind.apiValue),
      );
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
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final context = _page.context;
    final db = _page.ref.read(localDatabaseProvider);
    final customFieldCache = await _page.ref.read(
      libraryCustomFieldCacheProvider(_page.type.workspace.kind.apiValue)
          .future,
    );
    final ownedItems = await _page.ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.entry.id) &&
            item.entry.ownedItemId != null)
          item.entry.ownedItemId!,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !_page.mounted) return;

    final mutations = _page.ref.read(collectionMutationsProvider);
    if (!context.mounted) {
      return;
    }
    final result = await showTransferFieldDataDialog(
      context: context,
      db: db,
      type: _page.type,
      items: items,
      mutations: mutations,
      customFieldDefinitions: customFieldCache.definitions,
    );
    if (result != null && _page.mounted && context.mounted) {
      _page.invalidateShelf();
      _page.ref.invalidate(
        libraryCustomFieldCacheProvider(_page.type.workspace.kind.apiValue),
      );
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

  Future<void> showLoanSelectionFlow(
    LibraryProjection? projection,
  ) async {
    if (projection == null || _page.selection.itemIds.isEmpty) return;
    final context = _page.context;
    final ownedItemIds = <String>{
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.entry.id) &&
            item.entry.ownedItemId != null &&
            !_page.activeLoanOwnedItemIds.contains(item.entry.ownedItemId))
          item.entry.ownedItemId!,
    };
    if (ownedItemIds.isEmpty || !_page.mounted) return;

    final draft = await showDialog<BatchLoanDraft>(
      context: context,
      builder: (context) => BatchLoanDialog(
        accent: _page.accent,
        itemCount: ownedItemIds.length,
      ),
    );
    if (draft == null || !_page.mounted || !context.mounted) return;

    final repo = LoanRepository(_page.ref.read(localDatabaseProvider));
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

    _page.rebuild(_page.clearSelection);
    await _page.loadActiveLoanIds();
    if (_page.mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Created ${ownedItemIds.length} loan record${ownedItemIds.length == 1 ? '' : 's'}.',
          ),
        ),
      );
    }
  }

  Future<void> reassignIndexFlow(LibraryProjection projection) async {
    final context = _page.context;
    final items = projection.filteredItems;
    if (items.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
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
    if (confirmed != true || !_page.mounted || !context.mounted) return;

    final mutations = _page.ref.read(collectionMutationsProvider);
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
    _page.invalidateShelf();
    if (_page.mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assigned index values to $count items'),
        ),
      );
    }
  }
}
