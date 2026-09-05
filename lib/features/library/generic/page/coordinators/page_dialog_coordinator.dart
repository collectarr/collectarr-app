import 'dart:async';

import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
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
import 'package:collectarr_app/features/library/generic/reading_queue_dialog.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
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
                ? '${_page.type.identity.singularLabel} added to tracking'
                : '${_page.type.identity.singularLabel} added',
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
      _page.bucketCompletionScope = LibraryBucketCompletionScope.all;
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
      libraryCustomFieldCacheProvider(_page.type.kind.apiValue).future,
    );
    if (!_page.mounted) {
      return;
    }
    final allEntries = projection?.allItems ?? const [];
    final options = LibraryFilterOptions.fromEntries(
      allEntries,
      filterDefinitions: _page.type.presentation.filterDefinitions,
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
      libraryCustomFieldCacheProvider(_page.type.kind.apiValue).future,
    );
    if (!_page.mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final runtime = _page.type;
    final currentSortRules = _page.viewState?.sortRules
        .map(
          (rule) => LibrarySortRule(
            column: rule.sortId.value,
            ascending: rule.ascending,
          ),
        )
        .toList();
    final result = await showSmartListsDialog(
      context: context,
      db: db,
      mediaKind: _page.type.kind.apiValue,
      currentFilter: _page.filterSelection,
      currentQuickView: _page.quickView,
      currentSortRules: currentSortRules,
      currentSortColumn: _page.viewState?.sortId.value,
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
              _page.viewProfile.decodeSortRules(result.sortRules!),
              _page.viewProfile,
            );
          } else if (result.sortColumn != null) {
            _page.viewState = viewState.copyWith(
              sortId: runtime.fields.decodeSortId(result.sortColumn!),
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
    final runtime = _page.type;
    final sortRules = await showLibrarySortDialog(
      context: _page.context,
      type: _page.type,
      currentRules: [
        for (final rule in viewState.sortRules)
          LibrarySortRule(
            column: rule.sortId.value,
            ascending: rule.ascending,
          ),
      ],
      defaultAscendingForColumn: (column) =>
          _page.viewProfile.initialSortAscending(
        runtime.fields.decodeSortId(column),
      ),
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
        (state) => state.withSortRules(
          _page.viewProfile.decodeSortRules(filteredRules),
          _page.viewProfile,
        ),
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
    final legacyCatalogItemsById = await LibraryCatalogRepository(db).findByIds(
      queuedOwnedItems.map((item) => item.itemId),
    );
    final catalogItemsById = {
      for (final entry in legacyCatalogItemsById.entries)
        entry.key: typedCatalogItemFromCatalogItem(entry.value),
    };
    if (!_page.mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await showReadingQueueDialog(
      context: context,
      db: db,
      mediaKind: _page.type.kind.apiValue,
      ownedItems: queuedOwnedItems,
      catalogItemsById: catalogItemsById,
      onSelectItem: _page.selectItem,
    );
  }

  Future<void> showConditionPickListEditorFlow() async {
    final db = _page.ref.read(localDatabaseProvider);
    final editCapability = _page.type.edit;
    final definition =
        editCapability.vocabularies?.definitionForSuffix('condition');
    await showPickListEditorDialog(
      context: _page.context,
      db: db,
      listName: definition?.key ?? UniversalVocabularies.condition.key,
      label: 'Condition',
      mediaKind: _page.type.kind.apiValue,
      builtInValues:
          definition?.builtIns.map((value) => value.toString()).toList() ??
              editCapability.conditions,
    );
    if (_page.mounted) {
      _page.rebuild(() {});
    }
  }

  Future<void> showGradePickListEditorFlow() async {
    final db = _page.ref.read(localDatabaseProvider);
    final editCapability = _page.type.edit;
    final definition =
        editCapability.vocabularies?.definitionForSuffix('grade');
    await showPickListEditorDialog(
      context: _page.context,
      db: db,
      listName: definition?.key ?? UniversalVocabularies.grade.key,
      label: 'Grade',
      mediaKind: _page.type.kind.apiValue,
      builtInValues:
          definition?.builtIns.map((value) => value.toString()).toList() ??
              editCapability.grades,
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
      listName: UniversalVocabularies.tags.key,
      label: 'Tag',
      mediaKind: _page.type.kind.apiValue,
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
    final viewState = _page.viewState ?? _page.viewProfile.defaults();
    final selected = await showGenericLibraryColumnChooser(
      context: _page.context,
      type: _page.type,
      viewState: viewState,
      pinnedFavoriteKeys: _page.pinnedColumnFavoriteKeys,
      onTogglePinnedFavorite: _page.togglePinnedColumnFavorite,
    );
    if (selected != null) {
      _page.updateViewState(
        (state) => state.copyWith(
          visibleColumnIds: _page.viewProfile.decodeColumnIds(selected),
        ),
      );
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
      libraryCustomFieldCacheProvider(_page.type.kind.apiValue).future,
    );
    final ownedItems = await _page.ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (item.source.ownedItem?.id != null) item.source.ownedItem!.id,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !_page.mounted) return;

    final mutations = _page.ref.read(ownedItemMutationsProvider);
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
      _page.ref.invalidate(shelfProvider);
      _page.ref.invalidate(
        libraryCustomFieldCacheProvider(_page.type.kind.apiValue),
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
      libraryCustomFieldCacheProvider(_page.type.kind.apiValue).future,
    );
    final ownedItems = await _page.ref.read(collectionProvider.future);
    final visibleIds = <String>{
      for (final item in projection.filteredItems)
        if (_page.selection.itemIds.contains(item.node.id) &&
            item.source.ownedItem?.id != null)
          item.source.ownedItem!.id,
    };
    final items = ownedItems
        .where((o) => !o.isDeleted && visibleIds.contains(o.id))
        .toList(growable: false);
    if (items.isEmpty || !_page.mounted) return;

    final mutations = _page.ref.read(ownedItemMutationsProvider);
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
      _page.ref.invalidate(shelfProvider);
      _page.ref.invalidate(
        libraryCustomFieldCacheProvider(_page.type.kind.apiValue),
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
    final ownedItemsById = <String, OwnedItem>{};
    for (final item in projection.filteredItems) {
      final ownedItem = item.source.ownedItem;
      if (_page.selection.itemIds.contains(item.node.id) &&
          ownedItem != null &&
          !_page.activeLoanOwnedItemIds.contains(ownedItem.id)) {
        ownedItemsById[ownedItem.id] = ownedItem;
      }
    }
    final ownedItems = ownedItemsById.values.toList(growable: false);
    if (ownedItems.isEmpty || !_page.mounted) return;

    final draft = await showDialog<BatchLoanDraft>(
      context: context,
      builder: (context) => BatchLoanDialog(
        accent: _page.accent,
        itemCount: ownedItems.length,
      ),
    );
    if (draft == null || !_page.mounted || !context.mounted) return;

    final repo = LoanRepository(_page.ref.read(localDatabaseProvider));
    for (final ownedItem in ownedItems) {
      await repo.create(
        Loan(
          id: const Uuid().v4(),
          ownedRef: OwnedItemRef(
            kind: ownedItem.catalogRef.mediaKind,
            id: OwnedItemId(ownedItem.id),
          ),
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
            'Created ${ownedItems.length} loan record${ownedItems.length == 1 ? '' : 's'}.',
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

    final coordinator = _page.ref.read(collectionCommandCoordinatorProvider);
    var count = 0;
    for (var i = 0; i < items.length; i++) {
      final ownedItem = items[i].source.ownedItem;
      if (ownedItem == null) continue;
      await coordinator.updateOwnedItem(
        UpdateOwnedItemCommand(
          ownedItemId: ownedItem.id,
          indexNumber: Patch.set(i + 1),
        ),
      );
      count++;
    }
    _page.ref.invalidate(shelfProvider);
    if (_page.mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assigned index values to $count items'),
        ),
      );
    }
  }
}
