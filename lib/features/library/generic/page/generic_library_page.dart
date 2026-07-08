import 'dart:async';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_route_state.dart';
import 'package:collectarr_app/features/library/generic/page_search_state.dart';
import 'package:collectarr_app/features/library/generic/page/collection_tabs.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_collection_action_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_cover_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_dialog_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_metadata_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_report_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_sharing_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_history.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/skeleton_grid.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/generic/facet_controller_provider.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot_provider.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_toolbar_presenter.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/library_toolbar_action_registry.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_search_controller.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_selection_controller.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_shell_presenter.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

part 'coordinators/page_edit_coordinator.dart';
part 'hooks/page_kind_hooks.dart';
part 'hooks/page_sidebar_hooks.dart';
part 'controllers/page_facet_controller.dart';
part 'controllers/page_scope_controller.dart';
part 'controllers/page_view_state_controller.dart';
part 'controllers/page_projection_controller.dart';
part 'controllers/page_projection_provider.dart';
part 'controllers/page_lifecycle_controller.dart';
part 'controllers/page_toolbar_controller.dart';

class GenericLibraryPage extends ConsumerStatefulWidget {
  const GenericLibraryPage({
    super.key,
    required this.type,
    required this.topBar,
    required this.accent,
    required this.routeUri,
    this.switchLayoutSnapshot,
  });

  final LibraryTypeConfig type;
  final Widget topBar;
  final Color accent;
  final Uri routeUri;
  final LibraryLayoutSnapshot? switchLayoutSnapshot;

  @override
  ConsumerState<GenericLibraryPage> createState() => GenericLibraryPageState();
}

class GenericLibraryPageState extends ConsumerState<GenericLibraryPage>
    with LibraryPageUtilities {
  static bool _viewStateCacheWarmupStarted = false;

  // ---------------------------------------------------------------------------
  // Coordinator instances
  // ---------------------------------------------------------------------------
  late final LibraryPageDialogCoordinator _dialogCoordinator;
  late final LibraryPageEditCoordinator _editCoordinator;
  late final LibraryPageCollectionActionCoordinator
      _collectionActionCoordinator;
  late final LibraryPageMetadataCoordinator _metadataCoordinator;
  late final LibraryPageSharingCoordinator _sharingCoordinator;
  late final LibraryPageReportCoordinator _reportCoordinator;
  late final LibraryPageCoverCoordinator _coverCoordinator;
  late final LibraryPageToolbarController _toolbarController;
  late final LibraryPageSearchController _searchControllerOps;

  // ---------------------------------------------------------------------------
  // State fields
  // ---------------------------------------------------------------------------
  final _searchStateKey = const Uuid().v4();
  final _searchController = TextEditingController();
  LibraryWorkspaceViewState? _viewState;
  String? _selectedId;
  String? _selectedBucket;
  String? _selectedLetter;
  LibraryLinkedMetadataFilter? _linkedMetadataFilter;
  LibraryQuickView? _quickView;
  var _collectionStatusScope = LibraryCollectionStatusScope.all;
  var _seriesCompletionScope = LibrarySeriesCompletionScope.all;
  LibraryGroupMode? _groupMode;
  LibraryFolderPreset? _folderPreset;
  LibraryGroupPresentation? _groupPresentationOverride;
  Set<String> _collapsedGroupBuckets = const <String>{};
  LibraryFolderDisplayMode _folderDisplayMode =
      LibraryFolderDisplayMode.drilldown;
  Set<String> _folderTreeExpandedNodeIds = const <String>{};
  String? _folderTreeSelectedNodeId;
  var _selection = LibrarySelectionState.empty();
  String? _selectionAnchorId;
  var _filterSelection = LibraryFilterSelection.none;
  final _detailHydrationInFlight = <String>{};
  Set<String> _activeLoanOwnedItemIds = const {};
  List<LibraryFolderPreset> _pinnedFolderPresets = const [];
  String? _activeSmartListId;
  String? _activeSmartListName;
  Set<LibraryWorkspacePreset> _pinnedViewPresets = const {};
  Set<String> _pinnedSortFavoriteIds = const {};
  Set<String> _pinnedColumnFavoriteKeys = const {};
  List<LibraryTableColumnPreset> _savedColumnFavoritePresets = const [];
  List<LibrarySidebarScopeSnapshot> _scopeHistory = const [];
  bool _isEditDialogInFlight = false;
  bool _isScanningCover = false;
  int _viewStateLoadToken = 0;
  int _viewPreferenceLoadToken = 0;
  int _folderTreePreferenceLoadToken = 0;
  int _columnFavoritesLoadToken = 0;
  int _activeLoanIdsLoadToken = 0;
  Timer? _viewStateSaveDebounce;
  Timer? _selectionHydrationDebounce;
  ProviderSubscription<AsyncValue<ShelfState>>? _shelfSubscription;
  String? _lastFacetEnsureSignature;
  LibraryGroupMode? _lastFacetEnsureMode;
  LibraryKindBrowserDelegate _kindBrowserDelegate =
      LibraryNoopBrowserDelegate();

  bool get ownsKindReleaseFolderState => true;

  String? get kindReleaseFolderTitleItemId =>
      _kindBrowserDelegate.releaseFolderTitleItemId;

  set kindReleaseFolderTitleItemId(String? value) {
    _kindBrowserDelegate.releaseFolderTitleItemId = value;
  }

  String? get activeReleaseFolderTitleItemId => kindReleaseFolderTitleItemId;

  void setActiveReleaseFolderTitleItemId(String? value) {
    kindReleaseFolderTitleItemId = value;
  }

  @override
  void initState() {
    super.initState();
    final coordinatorContext = _createCoordinatorContext();
    _dialogCoordinator = LibraryPageDialogCoordinator(coordinatorContext);
    _editCoordinator = LibraryPageEditCoordinator(this);
    _collectionActionCoordinator = LibraryPageCollectionActionCoordinator(
      coordinatorContext,
      showEditDialog: (item, ownedItemOverride) =>
          _editCoordinator.showEditDialog(item, ownedItemOverride),
      compareMetadataWithServer: (projection, {item}) =>
          _metadataCoordinator.compareMetadataWithServerFlow(
        projection,
        item: item,
      ),
      showAddDialog: ({barcode}) =>
          _dialogCoordinator.showAddDialogFlow(barcode: barcode),
    );
    _metadataCoordinator = LibraryPageMetadataCoordinator(
      coordinatorContext,
      selectedProjectionItemFor:
          _collectionActionCoordinator.selectedProjectionItemFor,
      canCompareMetadataWithServerItem:
          _collectionActionCoordinator.canCompareMetadataWithServerItem,
    );
    _sharingCoordinator = LibraryPageSharingCoordinator(coordinatorContext);
    _reportCoordinator = LibraryPageReportCoordinator(coordinatorContext);
    _coverCoordinator = LibraryPageCoverCoordinator(coordinatorContext);
    _toolbarController = LibraryPageToolbarController(this);
    _searchControllerOps = LibraryPageSearchController(
      ref: ref,
      searchStateKey: _searchStateKey,
      searchController: _searchController,
      supportsMusicTrackSearch: _supportsMusicTrackSearch,
      clearActiveSmartLists: () => _mutateState(() {
        _activeSmartListId = null;
        _activeSmartListName = null;
      }),
      syncRouteState: _syncRouteState,
    );
    _LibraryPageLifecycleControllerOps.initState(this);
  }

  @override
  void didUpdateWidget(covariant GenericLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _LibraryPageLifecycleControllerOps.didUpdateWidget(this, oldWidget);
  }

  @override
  void dispose() {
    _LibraryPageLifecycleControllerOps.dispose(this);
    super.dispose();
  }

  void _onSearchChanged(String value) =>
      _searchControllerOps.onSearchChanged(value);

  void _onSearchInputChanged(String value) =>
      _searchControllerOps.onSearchInputChanged(value);

  void _clearSearch() => _searchControllerOps.clearSearch();

  void _applySearchSuggestion(LibraryToolbarSearchSuggestion suggestion) =>
      _searchControllerOps.applySearchSuggestion(suggestion);

  void _onSearchTargetChanged(LibrarySearchTarget target) =>
      _searchControllerOps.onSearchTargetChanged(target);

  LibraryPageCoordinatorContext _createCoordinatorContext() {
    return LibraryPageCoordinatorContext(
      context: context,
      ref: ref,
      getType: () => widget.type,
      getAccent: () => widget.accent,
      getMounted: () => mounted,
      getAdapter: () => _adapter,
      getViewPrefs: () => _viewPrefs,
      getSearchQuery: () => _searchControllerOps.state.query,
      setSearchQuery: (query) {
        if (query == null) {
          _searchController.clear();
          _searchControllerOps.clearSearch();
          return;
        }
        _searchController.text = query;
        _searchControllerOps.state.setQuery(query);
      },
      getViewState: () => _viewState,
      setViewState: (value) => _viewState = value,
      getSelection: () => _selection,
      setSelection: (value) => _selection = value,
      getSelectedId: () => _selectedId,
      setSelectedId: (value) => _selectedId = value,
      getSelectionAnchorId: () => _selectionAnchorId,
      setSelectionAnchorId: (value) => _selectionAnchorId = value,
      getSelectedBucket: () => _selectedBucket,
      setSelectedBucket: (value) => _selectedBucket = value,
      getSelectedLetter: () => _selectedLetter,
      setSelectedLetter: (value) => _selectedLetter = value,
      getLinkedMetadataFilter: () => _linkedMetadataFilter,
      setLinkedMetadataFilter: (value) => _linkedMetadataFilter = value,
      getCollectionStatusScope: () => _collectionStatusScope,
      setCollectionStatusScope: (value) => _collectionStatusScope = value,
      getSeriesCompletionScope: () => _seriesCompletionScope,
      setSeriesCompletionScope: (value) => _seriesCompletionScope = value,
      getQuickView: () => _quickView,
      setQuickView: (value) => _quickView = value,
      getFilterSelection: () => _filterSelection,
      setFilterSelection: (value) => _filterSelection = value,
      getActiveSmartListId: () => _activeSmartListId,
      setActiveSmartListId: (value) => _activeSmartListId = value,
      getActiveSmartListName: () => _activeSmartListName,
      setActiveSmartListName: (value) => _activeSmartListName = value,
      getScopeHistory: () => _scopeHistory,
      setScopeHistory: (value) => _scopeHistory = value,
      getActiveLoanOwnedItemIds: () => _activeLoanOwnedItemIds,
      getPinnedSortFavoriteIds: () => _pinnedSortFavoriteIds,
      setPinnedSortFavoriteIds: (value) => _pinnedSortFavoriteIds = value,
      getPinnedColumnFavoriteKeys: () => _pinnedColumnFavoriteKeys,
      getSortFavorites: () => _sortFavorites,
      getActiveSortFavorite: () => _activeSortFavorite,
      getScopeAvailableSortColumns: () => _scopeAvailableSortColumns,
      getIsScanningCover: () => _isScanningCover,
      setIsScanningCover: (value) => _isScanningCover = value,
      loadColumnFavoritePresets: _loadColumnFavoritePresets,
      loadActiveLoanIds: _loadActiveLoanIds,
      togglePinnedColumnFavorite: _togglePinnedColumnFavorite,
      rebuild: _rebuild,
      mutateSidebarScope: _mutateSidebarScope,
      updateViewState: _updateViewState,
      selectItem: _selectItem,
      syncRouteState: _syncRouteState,
      bulkActions: bulkActions,
      confirmBulkRemove: confirmBulkRemove,
      confirmSingleRemove: confirmSingleRemove,
      showBulkEditDialog: showBulkEditDialog,
    );
  }

  void _primeCachedViewPreferences() {
    _LibraryPageLifecycleControllerOps.primeCachedViewPreferences(this);
  }

  Future<void> _loadViewPreferences() {
    return _LibraryPageLifecycleControllerOps.loadViewPreferences(this);
  }

  Future<void> _loadActiveLoanIds() {
    return _LibraryPageLifecycleControllerOps.loadActiveLoanIds(this);
  }

  void _mutateState(VoidCallback mutate) {
    if (!mounted) {
      return;
    }
    setState(mutate);
  }

  void _maybeEnsureFacetBucketsLoaded(
    ShelfState shelf,
    LibraryGroupMode mode,
  ) {
    _LibraryFacetControllerOps.maybeEnsureFacetBucketsLoaded(this, shelf, mode);
  }

  bool _usesExternalFacetBuckets(LibraryGroupMode mode) {
    return _LibraryFacetControllerOps.usesExternalFacetBuckets(this, mode);
  }

  FacetBuckets? _facetBucketsForMode(
    LibraryGroupMode mode,
    ShelfState shelf,
  ) {
    return _LibraryFacetControllerOps.facetBucketsForMode(this, mode, shelf);
  }

  String _facetLoadKey(LibraryGroupMode mode, String signature) {
    return _LibraryFacetControllerOps.facetLoadKey(this, mode, signature);
  }

  bool _isFacetLoadInFlight(String loadKey) {
    return _LibraryFacetControllerOps.isFacetLoadInFlight(this, loadKey);
  }

  String _genericShelfSignature(ShelfState shelf) {
    return _LibraryFacetControllerOps.genericShelfSignature(this, shelf);
  }

  /// Wrapper for [setState] accessible from part-file extensions.
  void _rebuild([VoidCallback? fn]) {
    setState(fn ?? () {});
  }

  @override
  Widget build(BuildContext context) {
    return LibraryPageShellPresenter.build(this, context);
  }

  List<OwnedItem> _activeOwnedCopies(AsyncValue<List<OwnedItem>> value) {
    final items = value.asData?.value;
    if (items == null) {
      return const <OwnedItem>[];
    }
    return items.where((item) => !item.isDeleted).toList(growable: false);
  }

  List<WishlistItem> _activeWishlistItems(
    AsyncValue<List<WishlistItem>> value,
  ) {
    final items = value.asData?.value;
    if (items == null) {
      return const <WishlistItem>[];
    }
    return items.where((item) => !item.isDeleted).toList(growable: false);
  }

  LibrarySelectionCallbacks _selectionCallbacksForProjection(
    LibraryProjection? projection,
  ) {
    return LibraryPageShellPresenter.selectionCallbacksForProjection(
      this,
      projection,
    );
  }

  Future<void> _showBucketManagerFlow(LibraryProjection projection) async {
    final mode = _activeGroupMode;
    if (!supportsBucketManagement(mode)) {
      return;
    }
    final entries = [
      for (final bucket in projection.buckets)
        if (bucket.title != genericAllBucketLabel(widget.type))
          LibraryBucketManagerEntry(label: bucket.title, count: bucket.count),
    ];
    if (entries.isEmpty) {
      return;
    }
    await showLibraryBucketManagerDialog(
      context: context,
      type: widget.type,
      groupMode: mode,
      accent: widget.accent,
      entries: entries,
      onRenameBucket: (currentLabel, nextLabel) => _mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: nextLabel,
      ),
      onMergeBucket: (currentLabel, targetLabel) => _mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: targetLabel,
      ),
      onDeleteBucket: (currentLabel) =>
          _mutateBucketValues(projection, mode, currentLabel),
    );
  }

  Future<int> _mutateBucketValues(
    LibraryProjection projection,
    LibraryGroupMode mode,
    String currentLabel, {
    String? replacement,
  }) async {
    final updates = <CatalogItem>[];
    for (final item in projection.allItems) {
      final catalogItem = item.source.catalogItem;
      if (catalogItem == null ||
          genericBucketForItemMode(item, widget.type, mode) != currentLabel) {
        continue;
      }
      final updated = replacement == null
          ? deleteLibraryGroupBucketValue(catalogItem, mode, currentLabel)
          : renameLibraryGroupBucketValue(
              catalogItem,
              mode,
              currentLabel,
              replacement,
            );
      if (updated != null) {
        updates.add(updated);
      }
    }
    if (updates.isEmpty) {
      return 0;
    }
    final mutations = ref.read(collectionMutationsProvider);
    await mutations.updateCatalogSnapshots(updates);
    if (!mounted) {
      return updates.length;
    }
    setState(() {
      if (_selectedBucket == currentLabel) {
        final nextBucket = replacement?.trim();
        _selectedBucket =
            nextBucket == null || nextBucket.isEmpty ? null : nextBucket;
      }
    });
    return updates.length;
  }

  LibraryProjection _projectionForShelf(
    ShelfState shelf,
    LibraryWorkspaceViewState viewState,
  ) {
    return _LibraryProjectionControllerOps.projectionForShelf(
      this,
      shelf,
      viewState,
    );
  }

  Future<void> _loadColumnFavoritePresets() async {
    try {
      final loadToken = ++_columnFavoritesLoadToken;
      final expectedKind = widget.type.workspace.kind;
      final presets =
          await LibraryColumnPresetStore(widget.type.workspace).read();
      if (!mounted ||
          loadToken != _columnFavoritesLoadToken ||
          widget.type.workspace.kind != expectedKind) {
        return;
      }
      setState(() => _savedColumnFavoritePresets = presets);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load column favorites.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  List<LibraryTableColumnPreset> get _columnFavoritePresets {
    final merged = <LibraryTableColumnPreset>[];
    final seenLabels = <String>{};
    for (final preset in [
      ...libraryColumnFavoritesForType(widget.type),
      ..._savedColumnFavoritePresets,
    ]) {
      final normalized = preset.label.trim().toLowerCase();
      if (normalized.isEmpty || !seenLabels.add(normalized)) {
        continue;
      }
      merged.add(preset);
    }
    return merged;
  }

  void _setPinnedFolderPresets(List<LibraryFolderPreset> presets) {
    final updated = <LibraryFolderPreset>[];
    for (final preset in presets) {
      final sanitized = sanitizeLibraryFolderPreset(
        preset,
        allowedModes: _scopeAvailableGroupModes,
      );
      if (sanitized != null && !updated.contains(sanitized)) {
        updated.add(sanitized);
      }
    }
    setState(() => _pinnedFolderPresets = updated);
    unawaited(_viewPrefs.writePinnedFolderPresets(updated));
  }

  Future<void> _loadFolderTreePreferencesForActivePreset() async {
    final preset = _activeFolderPreset;
    try {
      final loadToken = ++_folderTreePreferenceLoadToken;
      final expectedKind = widget.type.workspace.kind;
      final displayModeFuture = _viewPrefs.readFolderDisplayMode(preset);
      final expandedNodeIdsFuture =
          _viewPrefs.readFolderTreeExpandedNodeIds(preset);
      final selectedNodeIdFuture =
          _viewPrefs.readFolderTreeSelectedNodeId(preset);
      final groupPresentationFuture =
          _viewPrefs.readGroupPresentationOverride(preset);
      final collapsedGroupBucketsFuture =
          _viewPrefs.readCollapsedGroupBuckets(preset);
      final (displayMode, expandedNodeIds, selectedNodeId) = await (
        displayModeFuture,
        expandedNodeIdsFuture,
        selectedNodeIdFuture
      ).wait;
      final groupPresentationOverride = await groupPresentationFuture;
      final collapsedGroupBuckets = await collapsedGroupBucketsFuture;
      if (!mounted ||
          loadToken != _folderTreePreferenceLoadToken ||
          widget.type.workspace.kind != expectedKind) {
        return;
      }
      _mutateState(() {
        _folderDisplayMode = displayMode ?? LibraryFolderDisplayMode.drilldown;
        _folderTreeExpandedNodeIds = expandedNodeIds;
        _folderTreeSelectedNodeId = selectedNodeId;
        _groupPresentationOverride = groupPresentationOverride;
        _collapsedGroupBuckets = collapsedGroupBuckets;
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load folder tree preferences.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _setFolderDisplayMode(LibraryFolderDisplayMode mode) {
    final preset = _activeFolderPreset;
    _mutateState(() {
      _folderDisplayMode = mode;
      if (mode == LibraryFolderDisplayMode.drilldown) {
        _folderTreeExpandedNodeIds = const <String>{};
        _folderTreeSelectedNodeId = null;
      }
    });
    unawaited(_viewPrefs.writeFolderDisplayMode(preset, mode));
    if (mode == LibraryFolderDisplayMode.drilldown) {
      unawaited(_viewPrefs.writeFolderTreeExpandedNodeIds(preset, const {}));
      unawaited(_viewPrefs.writeFolderTreeSelectedNodeId(preset, null));
    }
  }

  void _toggleFolderTreeNodeExpanded(String nodeId) {
    final preset = _activeFolderPreset;
    final next = Set<String>.from(_folderTreeExpandedNodeIds);
    if (!next.add(nodeId)) {
      next.remove(nodeId);
    }
    _mutateState(() {
      _folderTreeExpandedNodeIds = next;
    });
    unawaited(_viewPrefs.writeFolderTreeExpandedNodeIds(preset, next));
  }

  void _selectFolderTreePath(List<LibraryFolderTreeNode> path) {
    if (path.isEmpty) {
      return;
    }
    final preset = _activeFolderPreset;
    final leaf = path.last;
    final expanded = Set<String>.from(_folderTreeExpandedNodeIds);
    for (final node in path) {
      expanded.add(node.id);
    }
    _mutateState(() {
      _folderTreeExpandedNodeIds = expanded;
      _folderTreeSelectedNodeId = leaf.id;
    });
    unawaited(_viewPrefs.writeFolderTreeExpandedNodeIds(preset, expanded));
    unawaited(_viewPrefs.writeFolderTreeSelectedNodeId(preset, leaf.id));
    final bucketPath = [
      for (final node in path)
        if (node.bucketValue != null) node.bucketValue!,
    ];
    if (bucketPath.isEmpty) {
      _setSelectedBucket(null);
      return;
    }
    _mutateState(() {
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _scopeHistory = const [];
      _groupMode = preset.primaryMode;
    });
    for (final bucket in bucketPath) {
      _setSelectedBucket(bucket);
    }
  }

  String? get _activeColumnFavoriteLabel {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    for (final preset in _columnFavoritePresets) {
      if (setEquals(preset.columns, viewState.visibleColumns)) {
        return preset.label;
      }
    }
    return null;
  }

  List<LibrarySortFavorite> get _sortFavorites =>
      librarySortFavoritesForType(widget.type);

  LibrarySortFavorite? get _activeSortFavorite {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    for (final favorite in _sortFavorites) {
      if (_sameSortRules(favorite.rules, viewState.sortRules)) {
        return favorite;
      }
    }
    return null;
  }

  LibraryWorkspacePreset? get _activeViewPreset {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    for (final preset in LibraryWorkspacePreset.values) {
      final config = _adapter.viewProfile.presetConfig(preset);
      if (viewState.viewMode == config.viewMode &&
          viewState.detailsLayout == config.detailsLayout &&
          viewState.coverSize == config.coverSize &&
          setEquals(viewState.visibleColumns, config.visibleColumns)) {
        return preset;
      }
    }
    return null;
  }

  void _applyViewPreset(LibraryWorkspacePreset preset) {
    _updateViewState((state) => state.withPreset(preset, _adapter.viewProfile));
  }

  void _togglePinnedViewPreset(LibraryWorkspacePreset preset) {
    final next = Set<LibraryWorkspacePreset>.from(_pinnedViewPresets);
    if (!next.add(preset)) {
      next.remove(preset);
    }
    setState(() => _pinnedViewPresets = next);
    unawaited(_viewPrefs.writePinnedViewPresets(next));
  }

  void _applySortFavorite(LibrarySortFavorite favorite) {
    _updateViewState(
      (state) => state.withSortRules(favorite.rules, _adapter.viewProfile),
    );
  }

  void _togglePinnedSortFavorite(LibrarySortFavorite favorite) {
    final next = Set<String>.from(_pinnedSortFavoriteIds);
    if (!next.add(favorite.id)) {
      next.remove(favorite.id);
    }
    setState(() => _pinnedSortFavoriteIds = next);
    unawaited(_viewPrefs.writePinnedSortFavoriteIds(next));
  }

  void _applyColumnFavorite(LibraryTableColumnPreset preset) {
    _updateViewState((state) => state.copyWith(visibleColumns: preset.columns));
  }

  void _togglePinnedColumnFavorite(LibraryTableColumnPreset preset) {
    final key = libraryColumnFavoriteKey(preset);
    final next = Set<String>.from(_pinnedColumnFavoriteKeys);
    if (!next.add(key)) {
      next.remove(key);
    }
    setState(() => _pinnedColumnFavoriteKeys = next);
    unawaited(_viewPrefs.writePinnedColumnFavoriteKeys(next));
  }

  void _setCollectionStatusScope(LibraryCollectionStatusScope scope) {
    _mutateSidebarScope(() {
      _collectionStatusScope = scope;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
  }

  void _toggleCollectionStatusScope(LibraryCollectionStatusScope scope) {
    _setCollectionStatusScope(
      _collectionStatusScope == scope
          ? LibraryCollectionStatusScope.all
          : scope,
    );
  }

  void _setSeriesCompletionScope(LibrarySeriesCompletionScope scope) {
    if (_activeGroupMode != LibraryGroupMode.series) {
      return;
    }
    _mutateSidebarScope(() {
      _seriesCompletionScope = scope;
    });
  }

  bool _canJumpToIssue(LibraryProjection? projection) {
    return widget.type.kindUiAdapter.canJumpToIssue(
      widget.type,
      projection,
      activeGroupMode: _activeGroupMode,
      selectedBucket: _selectedBucket,
    );
  }

  Future<void> _jumpToIssue(
    LibraryProjection projection,
    String rawIssue,
  ) async {
    final normalizedIssue = rawIssue.trim();
    if (normalizedIssue.isEmpty) {
      return;
    }
    final match = _matchIssueInProjection(projection, normalizedIssue);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue #$normalizedIssue was not found.')),
      );
      return;
    }
    _mutateSidebarScope(() {
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _collectionStatusScope = LibraryCollectionStatusScope.all;
      _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _quickView = null;
      _filterSelection = LibraryFilterSelection.none;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _searchController.clear();
    });
    _searchControllerOps.clearSearch();
    _selectItem(match.entry.id);
  }

  LibraryProjectionItem? _matchIssueInProjection(
    LibraryProjection projection,
    String rawIssue,
  ) {
    final target = int.tryParse(rawIssue.trim());
    if (target == null) {
      return null;
    }
    for (final item in _seriesBucketItems(projection)) {
      if (_issueSortNumber(item.entry.itemNumber) == target) {
        return item;
      }
    }
    return null;
  }

  List<LibraryProjectionItem> _seriesBucketItems(LibraryProjection projection) {
    final selectedBucket = _selectedBucket;
    if (selectedBucket == null) {
      return const [];
    }
    return [
      for (final item in projection.allItems)
        if (genericBucketForItemMode(
                item, widget.type, LibraryGroupMode.series) ==
            selectedBucket)
          item,
    ];
  }

  bool _hasOwnedItemsInProjection(LibraryProjection? projection) {
    if (projection == null) {
      return false;
    }
    return projection.filteredItems
        .any((item) => item.entry.ownedItemId != null);
  }

  bool _hasOwnedItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _selection.itemIds.contains(item.entry.id) &&
          item.entry.ownedItemId != null,
    );
  }

  bool _hasSelectedItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) => _selection.itemIds.contains(item.entry.id),
    );
  }

  bool _hasLoanableOwnedItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _selection.itemIds.contains(item.entry.id) &&
          item.entry.ownedItemId != null &&
          !_activeLoanOwnedItemIds.contains(item.entry.ownedItemId),
    );
  }

  bool _hasMoveToOwnedEligibleItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _selection.itemIds.contains(item.entry.id) && !item.entry.isOwned,
    );
  }

  bool _hasMoveToWishlistEligibleItemsInSelection(
    LibraryProjection? projection,
  ) {
    if (projection == null || _selection.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _selection.itemIds.contains(item.entry.id) &&
          !item.entry.isWishlisted,
    );
  }

  bool _hasRemovableItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _selection.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _selection.itemIds.contains(item.entry.id) &&
          (item.entry.ownedItemId != null ||
              item.entry.isWishlisted ||
              item.source.trackingEntry != null),
    );
  }

  LibrarySeriesStatusSummary? _seriesStatusSummaryForProjection(
    LibraryProjection projection,
  ) {
    if (_activeGroupMode != LibraryGroupMode.series ||
        _selectedBucket == null) {
      return null;
    }
    LibrarySeriesBucket? selectedBucket;
    for (final bucket in projection.buckets) {
      if (bucket.title == _selectedBucket) {
        selectedBucket = bucket;
        break;
      }
    }
    if (selectedBucket == null) {
      return null;
    }

    var wishlistCount = 0;
    var forSaleCount = 0;
    var onOrderCount = 0;
    var soldCount = 0;
    var catalogOnlyCount = 0;
    for (final item in _seriesBucketItems(projection)) {
      final ownedItem = item.source.ownedItem;
      final status = item.entry.collectionStatus?.trim().toLowerCase();
      if (ownedItem?.isSold == true) {
        soldCount += 1;
        continue;
      }
      if (status == 'for_sale') {
        forSaleCount += 1;
        continue;
      }
      if (status == 'on_order') {
        onOrderCount += 1;
        continue;
      }
      if (item.source.isWishlisted && !item.source.isOwned) {
        wishlistCount += 1;
        continue;
      }
      if (!item.source.isOwned && !item.source.isWishlisted) {
        catalogOnlyCount += 1;
      }
    }

    return LibrarySeriesStatusSummary(
      title: selectedBucket.title,
      totalCount: selectedBucket.count,
      ownedCount: selectedBucket.ownedCount ?? 0,
      wishlistCount: wishlistCount,
      forSaleCount: forSaleCount,
      onOrderCount: onOrderCount,
      soldCount: soldCount,
      catalogOnlyCount: catalogOnlyCount,
      missingIssueSummary: selectedBucket.missingNumbers.isEmpty
          ? null
          : _formatIssueRanges(selectedBucket.missingNumbers),
    );
  }

  bool _sameSortRules(List<LibrarySortRule> a, List<LibrarySortRule> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  int? _issueSortNumber(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }
    final match = RegExp(r'^\s*(\d+)').firstMatch(rawValue);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  String _formatIssueRanges(List<int> numbers) {
    if (numbers.isEmpty) {
      return '';
    }
    final sorted = numbers.toList(growable: false)..sort();
    final labels = <String>[];
    var start = sorted.first;
    var end = start;
    for (var index = 1; index < sorted.length; index += 1) {
      final current = sorted[index];
      if (current == end + 1) {
        end = current;
        continue;
      }
      labels.add(start == end ? '#$start' : '#$start-#$end');
      start = current;
      end = current;
    }
    labels.add(start == end ? '#$start' : '#$start-#$end');
    return labels.take(8).join(', ');
  }

  List<String> get _sidebarBreadcrumbs =>
      _LibraryScopeControllerOps.sidebarBreadcrumbs(this);

  List<LibraryBucketScopeFilter> get _sidebarBucketScopeFilters =>
      _LibraryScopeControllerOps.sidebarBucketScopeFilters(this);

  List<String> get _sidebarAncestorScopeLabels =>
      _LibraryScopeControllerOps.sidebarAncestorScopeLabels(this);

  void _navigateSidebarToAncestorScope(int index) {
    _LibraryScopeControllerOps.navigateSidebarToAncestorScope(this, index);
  }

  void _setSelectedBucket(String? bucket) {
    _LibraryScopeControllerOps.setSelectedBucket(this, bucket);
  }

  void _setSelectedLetter(String? letter) {
    _LibraryScopeControllerOps.setSelectedLetter(this, letter);
  }

  void _toggleLinkedMetadataFilter(String value) {
    _LibraryScopeControllerOps.toggleLinkedMetadataFilter(this, value);
  }

  void _mutateSidebarScope(VoidCallback mutate) {
    _LibraryScopeControllerOps.mutateSidebarScope(this, mutate);
  }

  void _navigateSidebarBack() {
    _LibraryScopeControllerOps.navigateSidebarBack(this);
  }

  void _navigateSidebarToBreadcrumb(int index) {
    _LibraryScopeControllerOps.navigateSidebarToBreadcrumb(this, index);
  }

  void _clearFilters() {
    _LibraryScopeControllerOps.clearFilters(this);
  }

  void _applySmartList(SmartList smartList) {
    _LibraryScopeControllerOps.applySmartList(this, smartList);
  }

  void _clearSmartList() {
    _LibraryScopeControllerOps.clearSmartList(this);
  }

  void _clearToolbarSearchChip() {
    _mutateSidebarScope(() {
      if (_linkedMetadataFilter != null) {
        _linkedMetadataFilter = null;
      } else {
        _selectedBucket = null;
      }
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
  }

  Future<void> _loadViewState() {
    return _LibraryViewStateControllerOps.loadViewState(this);
  }

  Future<void> _warmViewStateCachesOnce() {
    return _LibraryViewStateControllerOps.warmViewStateCachesOnce(this);
  }

  void _updateViewState(
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState state) update,
  ) {
    _LibraryViewStateControllerOps.updateViewState(this, update);
  }

  void _updateViewChrome(
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState state) update,
  ) {
    _LibraryViewStateControllerOps.updateViewChrome(this, update);
  }

  void _setGroupingPanelVisibility(bool isVisible) {
    _LibraryViewStateControllerOps.setGroupingPanelVisibility(this, isVisible);
  }

  void _setQuickView(LibraryQuickView? view) {
    final nextView = sanitizeLibraryQuickViewForType(view, widget.type);
    _mutateSidebarScope(() {
      _quickView = nextView;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    unawaited(_viewPrefs.writeQuickView(nextView));
  }

  void _selectItem(String id) {
    LibraryPageSelectionControllerOps.selectItem(this, id);
  }

  void _activateItem(String id) {
    LibraryPageSelectionControllerOps.activateItem(this, id);
  }

  void _toggleSelectionItem(String id) {
    LibraryPageSelectionControllerOps.toggleSelectionItem(this, id);
  }

  void _applySelection(Set<String> ids, String focusedId) {
    LibraryPageSelectionControllerOps.applySelection(this, ids, focusedId);
  }

  void _selectAllVisible(LibraryProjection projection) {
    LibraryPageSelectionControllerOps.selectAllVisible(this, projection);
  }

  void _removeVisibleSelection(LibraryProjection projection) {
    LibraryPageSelectionControllerOps.removeVisibleSelection(this, projection);
  }

  void _navigateKeyboardSelection(LibraryProjection projection, int delta) {
    final items = projection.filteredItems;
    if (items.isEmpty) {
      return;
    }
    final currentIndex =
        items.indexWhere((item) => item.entry.id == _selectedId);
    final nextIndex = currentIndex < 0
        ? (delta < 0 ? items.length - 1 : 0)
        : (currentIndex + delta).clamp(0, items.length - 1);
    _activateItem(items[nextIndex].entry.id);
  }

  void _handleKeyboardEscape() {
    if (activeReleaseFolderTitleItemId != null) {
      _closeReleaseFolder();
      return;
    }
    if (_kindBrowserDelegate.hasItemDrilldown) {
      setState(_kindBrowserDelegate.closeItemDrilldown);
      return;
    }
    if (_selection.itemIds.isNotEmpty || _selectedId != null) {
      setState(() {
        _selection = _selection.clear();
        _selectionAnchorId = null;
        _selectedId = null;
      });
    }
  }

  @protected
  bool supportsBucketManagement(LibraryGroupMode mode) {
    return widget.type.kindUiAdapter
        .supportsBucketManagement(widget.type, mode);
  }

  @protected
  bool canOpenDefaultVideoShelfDrilldown(LibraryProjectionItem item) {
    return _kindBrowserDelegate.canOpenItemDetailDrilldown(widget.type, item);
  }

  @protected
  bool canOpenItemDetailDrilldown(LibraryProjectionItem item) {
    return false;
  }

  @protected
  void openDefaultVideoShelfDrilldown(LibraryProjectionItem item) {
    _kindBrowserDelegate.openItemDetailDrilldown(widget.type, item);
  }

  @protected
  void openItemDetailDrilldown(LibraryProjectionItem item) {}

  @protected
  Widget? buildDefaultVideoShelfWorkspaceOverride(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final selectedItem = projection.selectedItem;
    if (selectedItem == null) {
      return null;
    }
    return _kindBrowserDelegate.buildWorkspaceOverride(
      context: context,
      type: widget.type,
      projection: projection,
      selectedItem: selectedItem,
      viewState: viewState,
      accent: widget.accent,
      onRefreshFromCore: () =>
          _metadataCoordinator.refreshVideoTitleFromCore(selectedItem),
      onOpenTitleDetails: () => showLibraryDetailPage(
        context: context,
        request: LibraryDetailPageRequest(
          type: widget.type,
          entry: selectedItem.entry,
          ownedItem: selectedItem.source.ownedItem,
          accent: widget.accent,
          onAddOwned: () => _collectionActionCoordinator.runCollectionAction(
            (actions) => actions.addOwned(selectedItem),
          ),
          onRemoveOwned: selectedItem.source.ownedItem == null
              ? null
              : () => _collectionActionCoordinator.confirmAndRemoveOwned(
                    selectedItem,
                  ),
          onAddWishlist: () => _collectionActionCoordinator.runCollectionAction(
            (actions) => actions.addWishlist(selectedItem),
          ),
          onRemoveWishlist: selectedItem.source.isWishlisted
              ? () => _collectionActionCoordinator.runCollectionAction(
                    (actions) => actions.removeWishlist(selectedItem),
                  )
              : null,
          onEdit: (ownedItem) => unawaited(
            _editCoordinator.showEditDialog(selectedItem, ownedItem),
          ),
          onFilterByValue: _toggleLinkedMetadataFilter,
        ),
      ),
      allOwnedCopies: allOwnedCopies,
      allWishlistItems: allWishlistItems,
    );
  }

  @protected
  Widget? buildWorkspaceOverride(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    return null;
  }

  Future<void> _hydrateSelectedItem(String itemId) async {
    if (!_detailHydrationInFlight.add(itemId)) {
      return;
    }
    try {
      final item = await ref
          .read(apiClientProvider)
          .getTypedMetadataItem(
            kind: widget.type.workspace.kind.apiValue,
            id: itemId,
          )
          .then(
            (dto) => CatalogItem.fromJson({
              ...dto.raw,
              'id': dto.id,
              'title': dto.title,
              'kind': dto.kind,
            }),
          );
      await CatalogCacheRepository(ref.read(localDatabaseProvider)).upsertAll([
        item,
      ]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to hydrate selected library item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _detailHydrationInFlight.remove(itemId);
    }
  }
}
