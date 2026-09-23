import 'dart:async';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/config/library_browser_navigation_policy.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_route_state.dart';
import 'package:collectarr_app/features/library/generic/page_search_state.dart';
import 'package:collectarr_app/features/library/generic/page/collection_tabs.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_collection_action_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_cover_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_bucket_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_dialog_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_metadata_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_report_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_sharing_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_history.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/skeleton_grid.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/generic/facet_controller_provider.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot_provider.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/state/library_workspace_providers.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_toolbar_presenter.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/library_toolbar_action_registry.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_search_controller.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/page_selection_controller.dart';
import 'package:collectarr_app/features/library/generic/page/library_page_session.dart';
import 'package:collectarr_app/features/library/generic/library_custom_field_cache.dart';
import 'package:collectarr_app/features/library/generic/library_facet_bucket_service.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/library_projection_provider.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
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
part 'controllers/page_preferences_controller.dart';
part 'controllers/page_number_navigation_controller.dart';
part 'controllers/page_projection_controller.dart';
part 'controllers/page_lifecycle_controller.dart';
part 'controllers/page_toolbar_controller.dart';
part 'controllers/page_shell_presenter.dart';

class GenericLibraryPage extends ConsumerStatefulWidget {
  const GenericLibraryPage({
    super.key,
    required this.type,
    required this.topBar,
    required this.accent,
    required this.routeUri,
    this.switchLayoutSnapshot,
  });

  final LibraryKindRegistration type;
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
  late final LibraryPageBucketCoordinator _bucketCoordinator;
  late final LibraryPageToolbarController _toolbarController;
  late final LibraryPageSearchController _searchControllerOps;
  late final LibraryPageSelectionController _selectionController;

  // ---------------------------------------------------------------------------
  // State fields
  // ---------------------------------------------------------------------------
  final LibraryPageSession _session = LibraryPageSession();
  final _searchStateKey = const Uuid().v4();
  final _searchController = TextEditingController();
  WidgetRef get _pageRef => ref;

  LibraryEntityScope get activeEntityScope =>
      libraryBrowserNavigationPolicy.entityScopeForBrowserMode(
        _session.preferences.viewState?.browserMode ??
            LibraryWorkspaceBrowserMode.work,
      );

  final _detailHydrationInFlight = <String>{};
  Set<OwnedItemRef> _activeLoanOwnedItemIds = const {};
  bool _isEditDialogInFlight = false;
  bool _isScanningCover = false;
  int _activeLoanIdsLoadToken = 0;
  ProviderSubscription<AsyncValue<ShelfState>>? _shelfSubscription;
  late final workspaceKey = LibraryWorkspaceKey(
    kind: widget.type.kind,
  );
  ProviderSubscription<LibraryFilterState>? _filtersSubscription;
  ProviderSubscription<LibraryViewConfigState>? _viewConfigSubscription;
  LibraryKindBrowserDelegate _kindBrowserDelegate =
      LibraryNoopBrowserDelegate();

  bool get ownsKindReleaseFolderState => true;

  String? get kindReleaseFolderTitleItemId =>
      _kindBrowserDelegate.releaseFolderWorkId;

  set kindReleaseFolderTitleItemId(String? value) {
    _kindBrowserDelegate.releaseFolderWorkId = value;
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
      showAddDialog: ({identifierCode}) =>
          _dialogCoordinator.showAddDialogFlow(identifierCode: identifierCode),
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
    _bucketCoordinator = LibraryPageBucketCoordinator(coordinatorContext);
    _selectionController = LibraryPageSelectionController(
      selection: _session.selection,
      facets: _session.facets,
      isMounted: () => mounted,
      mutateState: _mutateState,
      hasItemDrilldown: () => _kindBrowserDelegate.hasItemDrilldown,
      drilldownRootItemId: () => _kindBrowserDelegate.drilldownRootItemId,
      closeItemDrilldown: _kindBrowserDelegate.closeItemDrilldown,
      hydrateSelectedItem: _hydrateSelectedItem,
      removeVisibleSelection: (projection) {
        unawaited(_collectionActionCoordinator.bulkRemoveFlow(projection));
      },
    );
    _toolbarController = LibraryPageToolbarController(this);
    _searchControllerOps = LibraryPageSearchController(
      ref: ref,
      searchStateKey: _searchStateKey,
      searchController: _searchController,
      searchTargetOptions: librarySearchTargetOptionsForKind(widget.type.kind),
      clearActiveSmartLists: () => _mutateState(() {
        _session.preferences.activeSmartListId = null;
        _session.preferences.activeSmartListName = null;
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
      getViewState: () => _session.preferences.viewState,
      setViewState: (value) => _session.preferences.viewState = value,
      getSelection: () => _session.selection.value,
      setSelection: (value) => _session.selection.value = value,
      getSelectedId: () => _session.selection.selectedId,
      setSelectedId: (value) => _session.selection.selectedId = value,
      getSelectionAnchorId: () => _session.selection.anchorId,
      setSelectionAnchorId: (value) => _session.selection.anchorId = value,
      getSelectedBucket: () => _session.facets.selectedBucket,
      setSelectedBucket: (value) => _session.facets.selectedBucket = value,
      getSelectedLetter: () => _session.facets.selectedLetter,
      setSelectedLetter: (value) => _session.facets.selectedLetter = value,
      getLinkedMetadataFilter: () => _session.facets.linkedMetadataFilter,
      setLinkedMetadataFilter: (value) =>
          _session.facets.linkedMetadataFilter = value,
      getCollectionStatusScope: () => _session.facets.collectionStatusScope,
      setCollectionStatusScope: (value) =>
          _session.facets.collectionStatusScope = value,
      getBucketCompletionScope: () => _session.facets.bucketCompletionScope,
      setBucketCompletionScope: (value) =>
          _session.facets.bucketCompletionScope = value,
      getQuickView: () => _session.facets.quickView,
      setQuickView: (value) => _session.facets.quickView = value,
      getFilterSelection: () => _session.selection.filterSelection,
      setFilterSelection: (value) => _session.selection.filterSelection = value,
      getActiveSmartListId: () => _session.preferences.activeSmartListId,
      setActiveSmartListId: (value) =>
          _session.preferences.activeSmartListId = value,
      getActiveSmartListName: () => _session.preferences.activeSmartListName,
      setActiveSmartListName: (value) =>
          _session.preferences.activeSmartListName = value,
      getScopeHistory: () => _session.preferences.scopeHistory,
      setScopeHistory: (value) => _session.preferences.scopeHistory = value,
      getActiveLoanOwnedItemIds: () => _activeLoanOwnedItemIds,
      getPinnedSortFavoriteIds: () =>
          _session.preferences.pinnedSortFavoriteIds,
      setPinnedSortFavoriteIds: (value) =>
          _session.preferences.pinnedSortFavoriteIds = value,
      getPinnedColumnFavoriteKeys: () =>
          _session.preferences.pinnedColumnFavoriteKeys,
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
    String mode,
  ) {
    _LibraryFacetControllerOps.maybeEnsureFacetBucketsLoaded(this, shelf, mode);
  }

  bool _usesExternalFacetBuckets(String mode) {
    return _LibraryFacetControllerOps.usesExternalFacetBuckets(this, mode);
  }

  LibraryFacetIdRuntime? _facetIdForMode(String mode) {
    return _LibraryFacetControllerOps.facetIdForMode(this, mode);
  }

  FacetBuckets? _facetBucketsForMode(
    String mode,
    ShelfState shelf,
  ) {
    return _LibraryFacetControllerOps.facetBucketsForMode(this, mode, shelf);
  }

  String _facetLoadKey(LibraryFacetIdRuntime facetId, String signature) {
    return _LibraryFacetControllerOps.facetLoadKey(this, facetId, signature);
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
    await _bucketCoordinator.showBucketManagerFlow(
      projection,
      mode: _activeGroupMode,
    );
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
    return LibraryPagePreferencesControllerOps.loadColumnFavoritePresets(this);
  }

  List<LibraryTableColumnPreset> get _columnFavoritePresets {
    final merged = <LibraryTableColumnPreset>[];
    final seenLabels = <String>{};
    for (final preset in [
      ...libraryColumnFavoritesForType(widget.type),
      ..._session.preferences.savedColumnFavoritePresets,
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
    LibraryPagePreferencesControllerOps.setPinnedFolderPresets(this, presets);
  }

  Future<void> _loadFolderTreePreferencesForActivePreset() async {
    return LibraryPagePreferencesControllerOps
        .loadFolderTreePreferencesForActivePreset(this);
  }

  void _setFolderDisplayMode(LibraryFolderDisplayMode mode) {
    LibraryPagePreferencesControllerOps.setFolderDisplayMode(this, mode);
  }

  void _toggleFolderTreeNodeExpanded(String nodeId) {
    LibraryPagePreferencesControllerOps.toggleFolderTreeNodeExpanded(
      this,
      nodeId,
    );
  }

  void _selectFolderTreePath(List<LibraryFolderTreeNode> path) {
    LibraryPagePreferencesControllerOps.selectFolderTreePath(this, path);
  }

  String? get _activeColumnFavoriteLabel {
    return LibraryPagePreferencesControllerOps.activeColumnFavoriteLabel(this);
  }

  List<LibrarySortFavorite> get _sortFavorites =>
      librarySortFavoritesForType(widget.type);

  LibrarySortFavorite? get _activeSortFavorite {
    return LibraryPagePreferencesControllerOps.activeSortFavorite(this);
  }

  LibraryWorkspacePreset? get _activeViewPreset {
    return LibraryPagePreferencesControllerOps.activeViewPreset(this);
  }

  void _applyViewPreset(LibraryWorkspacePreset preset) {
    LibraryPagePreferencesControllerOps.applyViewPreset(this, preset);
  }

  void _togglePinnedViewPreset(LibraryWorkspacePreset preset) {
    LibraryPagePreferencesControllerOps.togglePinnedViewPreset(this, preset);
  }

  void _applySortFavorite(LibrarySortFavorite favorite) {
    LibraryPagePreferencesControllerOps.applySortFavorite(this, favorite);
  }

  void _togglePinnedSortFavorite(LibrarySortFavorite favorite) {
    LibraryPagePreferencesControllerOps.togglePinnedSortFavorite(
      this,
      favorite,
    );
  }

  void _applyColumnFavorite(LibraryTableColumnPreset preset) {
    LibraryPagePreferencesControllerOps.applyColumnFavorite(this, preset);
  }

  void _togglePinnedColumnFavorite(LibraryTableColumnPreset preset) {
    LibraryPagePreferencesControllerOps.togglePinnedColumnFavorite(
      this,
      preset,
    );
  }

  void _setCollectionStatusScope(LibraryCollectionStatusScope scope) {
    _mutateSidebarScope(() {
      _session.facets.collectionStatusScope = scope;
      _session.preferences.activeSmartListId = null;
      _session.preferences.activeSmartListName = null;
    });
  }

  void _toggleCollectionStatusScope(LibraryCollectionStatusScope scope) {
    _setCollectionStatusScope(
      _session.facets.collectionStatusScope == scope
          ? LibraryCollectionStatusScope.all
          : scope,
    );
  }

  void _setBucketCompletionScope(LibraryBucketCompletionScope scope) {
    if (!libraryGroupModeSupportsCompletion(widget.type, _activeGroupMode)) {
      return;
    }
    _mutateSidebarScope(() {
      _session.facets.bucketCompletionScope = scope;
    });
  }

  bool _canJumpToKindDrilldown(LibraryProjection? projection) {
    return LibraryPageNumberNavigationControllerOps.canJumpToKindDrilldown(
      this,
      projection,
    );
  }

  Future<void> _jumpToNumber(
    LibraryProjection projection,
    String rawNumber,
  ) async {
    await LibraryPageNumberNavigationControllerOps.jumpToNumber(
      this,
      projection,
      rawNumber,
    );
  }

  bool _hasOwnedItemsInProjection(LibraryProjection? projection) {
    if (projection == null) {
      return false;
    }
    return projection.filteredItems.any((item) => item.source.ownedRef != null);
  }

  bool _hasOwnedItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _session.selection.value.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _session.selection.value.itemIds.contains(item.node.id) &&
          item.source.ownedRef != null,
    );
  }

  bool _hasSelectedItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _session.selection.value.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) => _session.selection.value.itemIds.contains(item.node.id),
    );
  }

  bool _hasLoanableOwnedItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _session.selection.value.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _session.selection.value.itemIds.contains(item.node.id) &&
          item.source.ownedRef != null &&
          !_activeLoanOwnedItemIds.contains(item.source.ownedRef),
    );
  }

  bool _hasMoveToOwnedEligibleItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _session.selection.value.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _session.selection.value.itemIds.contains(item.node.id) &&
          !item.source.isOwned,
    );
  }

  bool _hasMoveToWishlistEligibleItemsInSelection(
    LibraryProjection? projection,
  ) {
    if (projection == null || _session.selection.value.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _session.selection.value.itemIds.contains(item.node.id) &&
          !item.source.isWishlisted,
    );
  }

  bool _hasRemovableItemsInSelection(LibraryProjection? projection) {
    if (projection == null || _session.selection.value.itemIds.isEmpty) {
      return false;
    }
    return projection.filteredItems.any(
      (item) =>
          _session.selection.value.itemIds.contains(item.node.id) &&
          (item.source.ownedRef != null ||
              item.source.isWishlisted ||
              item.source.isTracked),
    );
  }

  LibraryBucketStatusSummary? _bucketStatusSummaryForProjection(
    LibraryProjection projection,
  ) {
    if (!libraryGroupModeSupportsCompletion(widget.type, _activeGroupMode) ||
        _session.facets.selectedBucket == null) {
      return null;
    }
    LibraryBucket? selectedBucket;
    for (final bucket in projection.buckets) {
      if (bucket.title == _session.facets.selectedBucket) {
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
    for (final item in LibraryPageNumberNavigationControllerOps
        .bucketItemsForSelectedBucket(
      this,
      projection,
    )) {
      if (item.source.ownedSummary?.soldAt != null) {
        soldCount += 1;
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

    return LibraryBucketStatusSummary(
      title: selectedBucket.title,
      totalCount: selectedBucket.count,
      ownedCount: selectedBucket.ownedCount ?? 0,
      wishlistCount: wishlistCount,
      forSaleCount: forSaleCount,
      onOrderCount: onOrderCount,
      soldCount: soldCount,
      catalogOnlyCount: catalogOnlyCount,
      missingSequenceSummary: selectedBucket.missingNumbers.isEmpty
          ? null
          : LibraryPageNumberNavigationControllerOps.formatNumberRanges(
              selectedBucket.missingNumbers,
            ),
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
      if (_session.facets.linkedMetadataFilter != null) {
        _session.facets.linkedMetadataFilter = null;
      } else {
        _session.facets.selectedBucket = null;
      }
      _session.preferences.activeSmartListId = null;
      _session.preferences.activeSmartListName = null;
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
      _session.facets.quickView = nextView;
      _session.preferences.activeSmartListId = null;
      _session.preferences.activeSmartListName = null;
    });
    unawaited(_viewPrefs.writeQuickView(nextView));
  }

  void _selectItem(String id) {
    _selectionController.selectItem(id);
  }

  void _activateItem(String id) {
    _selectionController.activateItem(id);
  }

  void _toggleSelectionItem(String id) {
    _selectionController.toggleSelectionItem(id);
  }

  void _applySelection(Set<String> ids, String focusedId) {
    _selectionController.applySelection(ids, focusedId);
  }

  void _selectAllVisible(LibraryProjection projection) {
    _selectionController.selectAllVisible(projection);
  }

  void _removeVisibleSelection(LibraryProjection projection) {
    _selectionController.removeVisibleItems(projection);
  }

  void _navigateKeyboardSelection(LibraryProjection projection, int delta) {
    final items = projection.filteredItems;
    if (items.isEmpty) {
      return;
    }
    final currentIndex = items
        .indexWhere((item) => item.node.id == _session.selection.selectedId);
    final nextIndex = currentIndex < 0
        ? (delta < 0 ? items.length - 1 : 0)
        : (currentIndex + delta).clamp(0, items.length - 1);
    _activateItem(items[nextIndex].node.id);
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
    if (_session.selection.value.itemIds.isNotEmpty ||
        _session.selection.selectedId != null) {
      setState(() {
        _session.selection.value = _session.selection.value.clear();
        _session.selection.anchorId = null;
        _session.selection.selectedId = null;
      });
    }
  }

  @protected
  bool supportsBucketManagement(String mode) {
    final fields = libraryKindWorkspaceForKind(widget.type.kind).fields;
    final groupDef = fields.findGroupDefinition(fields.decodeGroupId(mode));
    return groupDef?.supportsBucketManagement ?? false;
  }

  @protected
  bool canOpenKindDrilldown(LibraryProjectionItem item) {
    return _kindBrowserDelegate.canOpenItemDetailDrilldown(widget.type, item);
  }

  @protected
  bool canOpenItemDetailDrilldown(LibraryProjectionItem item) {
    return false;
  }

  @protected
  void openKindDrilldown(LibraryProjectionItem item) {
    _kindBrowserDelegate.openItemDetailDrilldown(widget.type, item);
  }

  @protected
  void openItemDetailDrilldown(LibraryProjectionItem item) {}

  @protected
  Widget? buildKindWorkspaceOverride(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItemSummary> allOwnedCopies,
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
          item: selectedItem,
          ownedSummary: selectedItem.source.ownedSummary,
          ownedItemDispatch: selectedItem.source.ownedItemDispatch,
          accent: widget.accent,
          onAddOwned: () => _collectionActionCoordinator.runCollectionAction(
            (actions) => actions.addOwned(selectedItem),
          ),
          onRemoveOwned: selectedItem.source.isOwned != true
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
          onEdit: (_) => unawaited(
            _editCoordinator.showEditDialog(
              selectedItem,
              null,
            ),
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
    required List<OwnedItemSummary> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    return null;
  }

  Future<void> _hydrateSelectedItem(String itemId) async {
    if (!_detailHydrationInFlight.add(itemId)) {
      return;
    }
    try {
      final candidate = await ref
          .read(apiClientProvider)
          .getTypedMetadataItem(
            kind: widget.type.kind,
            id: itemId,
          )
          .then(
            (dto) => CatalogSearchCandidate.fromJson({
              ...dto.raw,
              'id': dto.id,
              'title': dto.title,
              'kind': dto.kind,
            }),
          );
      await CatalogTransportRepository(ref.read(localDatabaseProvider))
          .upsertTransports([candidate.kindCapability.toImportTransport()]);
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
