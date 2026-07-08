import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LibraryViewStateUpdater = LibraryWorkspaceViewState Function(
  LibraryWorkspaceViewState state,
);

typedef LibraryPageRebuild = void Function([VoidCallback? fn]);

typedef LibraryPageEditDialogLauncher = Future<void> Function(
  LibraryProjectionItem item,
  OwnedItem? ownedItemOverride,
);

typedef LibraryPageCompareMetadataWithServer = Future<void> Function(
  LibraryProjection projection, {
  LibraryProjectionItem? item,
});

typedef LibraryPageAddDialogLauncher = Future<void> Function({
  String? barcode,
});

typedef LibraryPageSelectedProjectionItemResolver = LibraryProjectionItem?
    Function(LibraryProjection projection);

typedef LibraryPageCanCompareMetadataWithServer = bool Function(
  LibraryProjectionItem item,
);

class LibraryPageCoordinatorContext {
  LibraryPageCoordinatorContext({
    required this.context,
    required this.ref,
    required LibraryTypeConfig Function() getType,
    required Color Function() getAccent,
    required bool Function() getMounted,
    required LibraryMediaAdapter Function() getAdapter,
    required LibraryViewPreferenceStore Function() getViewPrefs,
    required String Function() getSearchQuery,
    required void Function(String? query) setSearchQuery,
    required LibraryWorkspaceViewState? Function() getViewState,
    required void Function(LibraryWorkspaceViewState? value) setViewState,
    required LibrarySelectionState Function() getSelection,
    required void Function(LibrarySelectionState value) setSelection,
    required String? Function() getSelectedId,
    required void Function(String? value) setSelectedId,
    required String? Function() getSelectionAnchorId,
    required void Function(String? value) setSelectionAnchorId,
    required String? Function() getSelectedBucket,
    required void Function(String? value) setSelectedBucket,
    required String? Function() getSelectedLetter,
    required void Function(String? value) setSelectedLetter,
    required LibraryLinkedMetadataFilter? Function() getLinkedMetadataFilter,
    required void Function(LibraryLinkedMetadataFilter? value)
        setLinkedMetadataFilter,
    required LibraryCollectionStatusScope Function() getCollectionStatusScope,
    required void Function(LibraryCollectionStatusScope value)
        setCollectionStatusScope,
    required LibrarySeriesCompletionScope Function() getSeriesCompletionScope,
    required void Function(LibrarySeriesCompletionScope value)
        setSeriesCompletionScope,
    required LibraryQuickView? Function() getQuickView,
    required void Function(LibraryQuickView? value) setQuickView,
    required LibraryFilterSelection Function() getFilterSelection,
    required void Function(LibraryFilterSelection value) setFilterSelection,
    required String? Function() getActiveSmartListId,
    required void Function(String? value) setActiveSmartListId,
    required String? Function() getActiveSmartListName,
    required void Function(String? value) setActiveSmartListName,
    required List<LibrarySidebarScopeSnapshot> Function() getScopeHistory,
    required void Function(List<LibrarySidebarScopeSnapshot> value)
        setScopeHistory,
    required Set<String> Function() getActiveLoanOwnedItemIds,
    required Set<String> Function() getPinnedSortFavoriteIds,
    required void Function(Set<String> value) setPinnedSortFavoriteIds,
    required Set<String> Function() getPinnedColumnFavoriteKeys,
    required List<LibrarySortFavorite> Function() getSortFavorites,
    required LibrarySortFavorite? Function() getActiveSortFavorite,
    required List<LibrarySortColumn> Function() getScopeAvailableSortColumns,
    required bool Function() getIsScanningCover,
    required void Function(bool value) setIsScanningCover,
    required Future<void> Function() loadColumnFavoritePresets,
    required Future<void> Function() loadActiveLoanIds,
    required void Function(LibraryTableColumnPreset preset)
        togglePinnedColumnFavorite,
    required LibraryPageRebuild rebuild,
    required void Function(VoidCallback mutate) mutateSidebarScope,
    required void Function(LibraryViewStateUpdater update) updateViewState,
    required void Function(String id) selectItem,
    required void Function() syncRouteState,
    required LibraryBulkActions Function() bulkActions,
    required Future<bool> Function(
      BuildContext context, {
      required int count,
      String itemLabel,
    }) confirmBulkRemove,
    required Future<bool> Function(
      BuildContext context, {
      required String title,
      required String itemLabel,
    }) confirmSingleRemove,
    required Future<LibraryBulkEditSelection?> Function(
      BuildContext context, {
      required LibraryTypeConfig type,
      required int selectedCount,
    }) showBulkEditDialog,
  })  : _getType = getType,
        _getAccent = getAccent,
        _getMounted = getMounted,
        _getAdapter = getAdapter,
        _getViewPrefs = getViewPrefs,
        _getSearchQuery = getSearchQuery,
        _setSearchQuery = setSearchQuery,
        _getViewState = getViewState,
        _setViewState = setViewState,
        _getSelection = getSelection,
        _setSelection = setSelection,
        _getSelectedId = getSelectedId,
        _setSelectedId = setSelectedId,
        _getSelectionAnchorId = getSelectionAnchorId,
        _setSelectionAnchorId = setSelectionAnchorId,
        _getSelectedBucket = getSelectedBucket,
        _setSelectedBucket = setSelectedBucket,
        _getSelectedLetter = getSelectedLetter,
        _setSelectedLetter = setSelectedLetter,
        _getLinkedMetadataFilter = getLinkedMetadataFilter,
        _setLinkedMetadataFilter = setLinkedMetadataFilter,
        _getCollectionStatusScope = getCollectionStatusScope,
        _setCollectionStatusScope = setCollectionStatusScope,
        _getSeriesCompletionScope = getSeriesCompletionScope,
        _setSeriesCompletionScope = setSeriesCompletionScope,
        _getQuickView = getQuickView,
        _setQuickView = setQuickView,
        _getFilterSelection = getFilterSelection,
        _setFilterSelection = setFilterSelection,
        _getActiveSmartListId = getActiveSmartListId,
        _setActiveSmartListId = setActiveSmartListId,
        _getActiveSmartListName = getActiveSmartListName,
        _setActiveSmartListName = setActiveSmartListName,
        _getScopeHistory = getScopeHistory,
        _setScopeHistory = setScopeHistory,
        _getActiveLoanOwnedItemIds = getActiveLoanOwnedItemIds,
        _getPinnedSortFavoriteIds = getPinnedSortFavoriteIds,
        _setPinnedSortFavoriteIds = setPinnedSortFavoriteIds,
        _getPinnedColumnFavoriteKeys = getPinnedColumnFavoriteKeys,
        _getSortFavorites = getSortFavorites,
        _getActiveSortFavorite = getActiveSortFavorite,
        _getScopeAvailableSortColumns = getScopeAvailableSortColumns,
        _getIsScanningCover = getIsScanningCover,
        _setIsScanningCover = setIsScanningCover,
        _loadColumnFavoritePresets = loadColumnFavoritePresets,
        _loadActiveLoanIds = loadActiveLoanIds,
        _togglePinnedColumnFavorite = togglePinnedColumnFavorite,
        _rebuild = rebuild,
        _mutateSidebarScope = mutateSidebarScope,
        _updateViewState = updateViewState,
        _selectItem = selectItem,
        _syncRouteState = syncRouteState,
        _bulkActions = bulkActions,
        _confirmBulkRemove = confirmBulkRemove,
        _confirmSingleRemove = confirmSingleRemove,
        _showBulkEditDialog = showBulkEditDialog;

  final BuildContext context;
  final WidgetRef ref;

  final LibraryTypeConfig Function() _getType;
  final Color Function() _getAccent;
  final bool Function() _getMounted;
  final LibraryMediaAdapter Function() _getAdapter;
  final LibraryViewPreferenceStore Function() _getViewPrefs;
  final String Function() _getSearchQuery;
  final void Function(String? query) _setSearchQuery;
  final LibraryWorkspaceViewState? Function() _getViewState;
  final void Function(LibraryWorkspaceViewState? value) _setViewState;
  final LibrarySelectionState Function() _getSelection;
  final void Function(LibrarySelectionState value) _setSelection;
  final String? Function() _getSelectedId;
  final void Function(String? value) _setSelectedId;
  final String? Function() _getSelectionAnchorId;
  final void Function(String? value) _setSelectionAnchorId;
  final String? Function() _getSelectedBucket;
  final void Function(String? value) _setSelectedBucket;
  final String? Function() _getSelectedLetter;
  final void Function(String? value) _setSelectedLetter;
  final LibraryLinkedMetadataFilter? Function() _getLinkedMetadataFilter;
  final void Function(LibraryLinkedMetadataFilter? value)
      _setLinkedMetadataFilter;
  final LibraryCollectionStatusScope Function() _getCollectionStatusScope;
  final void Function(LibraryCollectionStatusScope value)
      _setCollectionStatusScope;
  final LibrarySeriesCompletionScope Function() _getSeriesCompletionScope;
  final void Function(LibrarySeriesCompletionScope value)
      _setSeriesCompletionScope;
  final LibraryQuickView? Function() _getQuickView;
  final void Function(LibraryQuickView? value) _setQuickView;
  final LibraryFilterSelection Function() _getFilterSelection;
  final void Function(LibraryFilterSelection value) _setFilterSelection;
  final String? Function() _getActiveSmartListId;
  final void Function(String? value) _setActiveSmartListId;
  final String? Function() _getActiveSmartListName;
  final void Function(String? value) _setActiveSmartListName;
  final List<LibrarySidebarScopeSnapshot> Function() _getScopeHistory;
  final void Function(List<LibrarySidebarScopeSnapshot> value) _setScopeHistory;
  final Set<String> Function() _getActiveLoanOwnedItemIds;
  final Set<String> Function() _getPinnedSortFavoriteIds;
  final void Function(Set<String> value) _setPinnedSortFavoriteIds;
  final Set<String> Function() _getPinnedColumnFavoriteKeys;
  final List<LibrarySortFavorite> Function() _getSortFavorites;
  final LibrarySortFavorite? Function() _getActiveSortFavorite;
  final List<LibrarySortColumn> Function() _getScopeAvailableSortColumns;
  final bool Function() _getIsScanningCover;
  final void Function(bool value) _setIsScanningCover;
  final Future<void> Function() _loadColumnFavoritePresets;
  final Future<void> Function() _loadActiveLoanIds;
  final void Function(LibraryTableColumnPreset preset)
      _togglePinnedColumnFavorite;
  final LibraryPageRebuild _rebuild;
  final void Function(VoidCallback mutate) _mutateSidebarScope;
  final void Function(LibraryViewStateUpdater update) _updateViewState;
  final void Function(String id) _selectItem;
  final void Function() _syncRouteState;
  final LibraryBulkActions Function() _bulkActions;
  final Future<bool> Function(
    BuildContext context, {
    required int count,
    String itemLabel,
  }) _confirmBulkRemove;
  final Future<bool> Function(
    BuildContext context, {
    required String title,
    required String itemLabel,
  }) _confirmSingleRemove;
  final Future<LibraryBulkEditSelection?> Function(
    BuildContext context, {
    required LibraryTypeConfig type,
    required int selectedCount,
  }) _showBulkEditDialog;

  LibraryTypeConfig get type => _getType();
  Color get accent => _getAccent();
  bool get mounted => _getMounted();
  LibraryMediaAdapter get adapter => _getAdapter();
  LibraryViewPreferenceStore get viewPrefs => _getViewPrefs();
  String get searchQuery => _getSearchQuery();

  void setSearchQuery(String? query) => _setSearchQuery(query);
  void clearSearchQuery() => _setSearchQuery(null);

  LibraryWorkspaceViewState? get viewState => _getViewState();
  set viewState(LibraryWorkspaceViewState? value) => _setViewState(value);

  LibrarySelectionState get selection => _getSelection();
  set selection(LibrarySelectionState value) => _setSelection(value);

  String? get selectedId => _getSelectedId();
  set selectedId(String? value) => _setSelectedId(value);

  String? get selectionAnchorId => _getSelectionAnchorId();
  set selectionAnchorId(String? value) => _setSelectionAnchorId(value);

  String? get selectedBucket => _getSelectedBucket();
  set selectedBucket(String? value) => _setSelectedBucket(value);

  String? get selectedLetter => _getSelectedLetter();
  set selectedLetter(String? value) => _setSelectedLetter(value);

  LibraryLinkedMetadataFilter? get linkedMetadataFilter =>
      _getLinkedMetadataFilter();
  set linkedMetadataFilter(LibraryLinkedMetadataFilter? value) =>
      _setLinkedMetadataFilter(value);

  LibraryCollectionStatusScope get collectionStatusScope =>
      _getCollectionStatusScope();
  set collectionStatusScope(LibraryCollectionStatusScope value) =>
      _setCollectionStatusScope(value);

  LibrarySeriesCompletionScope get seriesCompletionScope =>
      _getSeriesCompletionScope();
  set seriesCompletionScope(LibrarySeriesCompletionScope value) =>
      _setSeriesCompletionScope(value);

  LibraryQuickView? get quickView => _getQuickView();
  set quickView(LibraryQuickView? value) => _setQuickView(value);

  LibraryFilterSelection get filterSelection => _getFilterSelection();
  set filterSelection(LibraryFilterSelection value) =>
      _setFilterSelection(value);

  String? get activeSmartListId => _getActiveSmartListId();
  set activeSmartListId(String? value) => _setActiveSmartListId(value);

  String? get activeSmartListName => _getActiveSmartListName();
  set activeSmartListName(String? value) => _setActiveSmartListName(value);

  List<LibrarySidebarScopeSnapshot> get scopeHistory => _getScopeHistory();
  set scopeHistory(List<LibrarySidebarScopeSnapshot> value) =>
      _setScopeHistory(value);

  Set<String> get activeLoanOwnedItemIds => _getActiveLoanOwnedItemIds();

  Set<String> get pinnedSortFavoriteIds => _getPinnedSortFavoriteIds();
  set pinnedSortFavoriteIds(Set<String> value) =>
      _setPinnedSortFavoriteIds(value);

  Set<String> get pinnedColumnFavoriteKeys => _getPinnedColumnFavoriteKeys();

  List<LibrarySortFavorite> get sortFavorites => _getSortFavorites();
  LibrarySortFavorite? get activeSortFavorite => _getActiveSortFavorite();
  List<LibrarySortColumn> get scopeAvailableSortColumns =>
      _getScopeAvailableSortColumns();

  bool get isScanningCover => _getIsScanningCover();
  set isScanningCover(bool value) => _setIsScanningCover(value);

  Future<void> loadColumnFavoritePresets() => _loadColumnFavoritePresets();
  Future<void> loadActiveLoanIds() => _loadActiveLoanIds();

  void togglePinnedColumnFavorite(LibraryTableColumnPreset preset) =>
      _togglePinnedColumnFavorite(preset);

  void rebuild([VoidCallback? fn]) => _rebuild(fn);
  void mutateSidebarScope(VoidCallback mutate) => _mutateSidebarScope(mutate);
  void updateViewState(LibraryViewStateUpdater update) =>
      _updateViewState(update);
  void selectItem(String id) => _selectItem(id);
  void syncRouteState() => _syncRouteState();

  LibraryBulkActions bulkActions() => _bulkActions();

  Future<bool> confirmBulkRemove(
    BuildContext context, {
    required int count,
    String itemLabel = 'items',
  }) {
    return _confirmBulkRemove(
      context,
      count: count,
      itemLabel: itemLabel,
    );
  }

  Future<bool> confirmSingleRemove(
    BuildContext context, {
    required String title,
    required String itemLabel,
  }) {
    return _confirmSingleRemove(
      context,
      title: title,
      itemLabel: itemLabel,
    );
  }

  Future<LibraryBulkEditSelection?> showBulkEditDialog(
    BuildContext context, {
    required LibraryTypeConfig type,
    required int selectedCount,
  }) {
    return _showBulkEditDialog(
      context,
      type: type,
      selectedCount: selectedCount,
    );
  }

  void clearSelection() {
    selection = selection.clear();
  }

  void invalidateShelf() {
    ref.invalidate(shelfProvider);
  }

  void invalidateCustomFieldCache() {
    ref.invalidate(
        libraryCustomFieldCacheProvider(type.workspace.kind.apiValue));
  }
}
