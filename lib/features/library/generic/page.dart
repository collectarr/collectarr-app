import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/services/image_download_service.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/column_chooser.dart';
import 'package:collectarr_app/features/library/generic/collection_actions.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_route_state.dart';
import 'package:collectarr_app/features/library/generic/metadata_refresh.dart';
import 'package:collectarr_app/features/library/generic/page/collection_tabs.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_history.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/reading_queue_dialog.dart';
import 'package:collectarr_app/features/library/generic/skeleton_grid.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/generic/user_folders_dialog.dart';
import 'package:collectarr_app/features/library/generic/transfer_field_data_dialog.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_item_context_menu.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

part 'page_edit_handler.dart';
part 'page_dialogs.dart';
part 'page_collection_actions.dart';

class GenericLibraryPage extends ConsumerStatefulWidget {
  const GenericLibraryPage({
    super.key,
    required this.type,
    required this.topBar,
    required this.accent,
    required this.routeUri,
  });

  final LibraryTypeConfig type;
  final Widget topBar;
  final Color accent;
  final Uri routeUri;

  @override
  ConsumerState<GenericLibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<GenericLibraryPage>
    with LibraryPageUtilities {
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
  var _selection = LibrarySelectionState.empty();
  String? _selectionAnchorId;
  var _filterSelection = LibraryFilterSelection.none;
  final _detailHydrationInFlight = <String>{};
  final _facetBucketsByMode = <LibraryGroupMode, FacetBuckets>{};
  final _facetLoadsInFlight = <LibraryGroupMode>{};
  Set<String> _activeLoanOwnedItemIds = const {};
  List<LibraryFolderPreset> _pinnedFolderPresets = const [];
  String? _videoShelfDrilldownTitleItemId;
  String? _videoShelfDrilldownReleaseId;
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

  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.workspace.kind);

  @override
  void initState() {
    super.initState();
    _viewState = _adapter.viewProfile.defaults();
    _primeCachedViewPreferences();
    _applyRouteStateFromUri(widget.routeUri);
    unawaited(_loadViewState());
    unawaited(_loadViewPreferences());
    unawaited(_loadColumnFavoritePresets());
    unawaited(
      loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue),
    );
    unawaited(_loadActiveLoanIds());
  }

  Future<void> _loadViewPreferences() async {
    try {
      final loadToken = ++_viewPreferenceLoadToken;
      final expectedKind = widget.type.workspace.kind;
      final allowedGroupModes = widget.type.availableGroupModes;
      final quickView = await _viewPrefs.readQuickView();
      final groupMode = await _viewPrefs.readGroupMode(
        allowedModes: allowedGroupModes,
      );
      final folderPreset = await _viewPrefs.readFolderPreset(
        allowedModes: allowedGroupModes,
      );
      final pinnedPresets = await _viewPrefs.readPinnedFolderPresets(
        allowedModes: allowedGroupModes,
      );
      final pinnedViewPresets = await _viewPrefs.readPinnedViewPresets(
        fallback: libraryDefaultPinnedViewPresetsForType(widget.type),
      );
      final pinnedSortFavoriteIds = await _viewPrefs.readPinnedSortFavoriteIds(
        fallback: libraryDefaultPinnedSortFavoriteIdsForType(widget.type),
      );
      final pinnedColumnFavoriteKeys =
          await _viewPrefs.readPinnedColumnFavoriteKeys(
        fallback: libraryDefaultPinnedColumnFavoriteKeysForType(widget.type),
      );
      if (!mounted ||
          loadToken != _viewPreferenceLoadToken ||
          widget.type.workspace.kind != expectedKind) {
        return;
      }
      setState(() {
        _quickView = quickView;
        _folderPreset = folderPreset;
        _groupMode = folderPreset?.primaryMode ?? groupMode;
        _pinnedFolderPresets = pinnedPresets;
        _pinnedViewPresets = pinnedViewPresets;
        _pinnedSortFavoriteIds = pinnedSortFavoriteIds;
        _pinnedColumnFavoriteKeys = pinnedColumnFavoriteKeys;
        _applyRouteStateFromUri(widget.routeUri);
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load view preferences.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _primeCachedViewPreferences() {
    final allowedGroupModes = widget.type.availableGroupModes.toSet();
    _quickView = _viewPrefs.cachedQuickView;
    final cachedGroupMode = allowedGroupModes.contains(_viewPrefs.cachedGroupMode)
        ? _viewPrefs.cachedGroupMode
        : null;
    _folderPreset = sanitizeLibraryFolderPreset(
          _viewPrefs.cachedFolderPreset,
          allowedModes: allowedGroupModes,
        ) ??
        (cachedGroupMode == null
            ? null
            : LibraryFolderPreset.single(cachedGroupMode));
    _groupMode = _folderPreset?.primaryMode ?? cachedGroupMode;
    _pinnedFolderPresets = _viewPrefs.cachedPinnedFolderPresets
        .map(
          (preset) => sanitizeLibraryFolderPreset(
            preset,
            allowedModes: allowedGroupModes,
          ),
        )
        .whereType<LibraryFolderPreset>()
        .toList(growable: false);
    _pinnedViewPresets = _viewPrefs.cachedPinnedViewPresets.isNotEmpty
        ? _viewPrefs.cachedPinnedViewPresets
        : libraryDefaultPinnedViewPresetsForType(widget.type);
    _pinnedSortFavoriteIds = _viewPrefs.cachedPinnedSortFavoriteIds.isNotEmpty
        ? _viewPrefs.cachedPinnedSortFavoriteIds
        : libraryDefaultPinnedSortFavoriteIdsForType(widget.type);
    _pinnedColumnFavoriteKeys =
        _viewPrefs.cachedPinnedColumnFavoriteKeys.isNotEmpty
            ? _viewPrefs.cachedPinnedColumnFavoriteKeys
            : libraryDefaultPinnedColumnFavoriteKeysForType(widget.type);
  }

  @override
  void didUpdateWidget(covariant GenericLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.workspace.kind != widget.type.workspace.kind) {
      _selectedId = null;
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _collectionStatusScope = LibraryCollectionStatusScope.all;
      _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _pinnedViewPresets = const {};
      _pinnedSortFavoriteIds = const {};
      _pinnedColumnFavoriteKeys = const {};
      _savedColumnFavoritePresets = const [];
      _scopeHistory = const [];
      _selectionAnchorId = null;
      _videoShelfDrilldownTitleItemId = null;
      _videoShelfDrilldownReleaseId = null;
      _facetBucketsByMode.clear();
      _facetLoadsInFlight.clear();
      _searchController.clear();
      _primeCachedViewPreferences();
      _viewState = _adapter.viewProfile.defaults().withChrome(
            _viewState?.toPreferenceSnapshot().chrome,
          );
      unawaited(_loadViewState());
      unawaited(_loadViewPreferences());
      unawaited(_loadColumnFavoritePresets());
      unawaited(
        loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue),
      );
      unawaited(_loadActiveLoanIds());
    } else if (oldWidget.routeUri.toString() != widget.routeUri.toString()) {
      _applyRouteStateFromUri(widget.routeUri);
    }
  }

  Future<void> _loadActiveLoanIds() async {
    try {
      final db = ref.read(localDatabaseProvider);
      final repo = LoanRepository(db);
      final activeLoans = await repo.getActiveLoans();
      final next = <String>{
        for (final loan in activeLoans) loan.ownedItemId,
      };
      if (!mounted) {
        return;
      }
      setState(() => _activeLoanOwnedItemIds = next);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load active loan IDs.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Wrapper for [setState] accessible from part-file extensions.
  void _rebuild([VoidCallback? fn]) {
    setState(fn ?? () {});
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    final ownedCopiesValue = ref.watch(collectionProvider);
    final wishlistValue = ref.watch(wishlistProvider);
    ref.listen<AsyncValue<ShelfState>>(shelfProvider, (_, next) {
      unawaited(
        loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue),
      );
      final shelfState = next.asData?.value;
      if (shelfState != null) {
        _ensureFacetBucketsLoaded(shelfState, _activeGroupMode);
      }
    });
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    final shelfState = shelf.asData?.value;
    final allOwnedCopies = ownedCopiesValue.maybeWhen(
      data: (items) =>
          items.where((item) => !item.isDeleted).toList(growable: false),
      orElse: () => const <OwnedItem>[],
    );
    final allWishlistItems = wishlistValue.maybeWhen(
      data: (items) =>
          items.where((item) => !item.isDeleted).toList(growable: false),
      orElse: () => const <WishlistItem>[],
    );
    if (shelfState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureFacetBucketsLoaded(shelfState, _activeGroupMode);
      });
    }
    final projection = shelfState == null
        ? null
        : _projectionForShelf(
            shelfState,
            viewState,
          );
    final useFab =
        ref.watch(uiPreferencesProvider.select((p) => p.fabAddButton));
    return LibraryKeyboardShortcuts(
      onSelectAll:
          projection == null ? null : () => _selectAllVisible(projection),
      onDelete:
          projection == null ? null : () => _removeVisibleSelection(projection),
      child: Scaffold(
        backgroundColor: appPalette(context).canvas,
        floatingActionButton: useFab
            ? FloatingActionButton(
                onPressed: () => showAddDialogFlow(),
                backgroundColor: widget.accent,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  widget.topBar,
                  LibraryToolbar(
                    type: widget.type,
                    searchController: _searchController,
                    viewState: viewState,
                    adapter: _adapter,
                    onAdd: () => showAddDialogFlow(),
                    onScan: scanBarcodeFlow,
                    onSearchChanged: (value) => _mutateSidebarScope(() {
                      _activeSmartListId = null;
                      _activeSmartListName = null;
                    }),
                    onEditColumns: showColumnChooserFlow,
                    onSortChanged: (column) => _updateViewState(
                      (state) =>
                          state.withSortColumn(column, _adapter.viewProfile),
                    ),
                    onEditSort: showSortDialogFlow,
                    onSidebarVisibilityChanged: _setGroupingPanelVisibility,
                    onViewModeChanged: (mode) => _updateViewState(
                      (state) => state.copyWith(viewMode: mode),
                    ),
                    onDetailsLayoutChanged: (layout) => _updateViewState(
                      (state) => state.copyWith(detailsLayout: layout),
                    ),
                    onCoverSizeChanged: (size) => _updateViewState(
                      (state) => state.copyWith(coverSize: size),
                    ),
                    selectedBucket:
                        _linkedMetadataFilter?.chipLabel ?? _selectedBucket,
                    onClearBucket: _clearToolbarSearchChip,
                    onRefreshMetadata: () => showMetadataRefreshFlow(
                      projection,
                    ),
                    collectionStatusScope: _collectionStatusScope,
                    onCollectionStatusScopeChanged: _setCollectionStatusScope,
                    quickView: _quickView,
                    onQuickViewSelected: (view) =>
                        _setQuickView(_quickView == view ? null : view),
                    availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
                      (projection?.filteredItems ??
                              const <LibraryProjectionItem>[])
                          .map((i) => i.entry.resolvedTitle),
                    ),
                    selectedLetter: _selectedLetter,
                    onLetterSelected: _setSelectedLetter,
                    activeViewPreset: _activeViewPreset,
                    onViewPresetSelected: _applyViewPreset,
                    sortFavorites: _sortFavorites,
                    activeSortFavoriteId: _activeSortFavorite?.id,
                    onSortFavoriteSelected: _applySortFavorite,
                    pinnedViewPresets: _pinnedViewPresets,
                    onTogglePinnedViewPreset: _togglePinnedViewPreset,
                    pinnedSortFavoriteIds: _pinnedSortFavoriteIds,
                    onTogglePinnedSortFavorite: _togglePinnedSortFavorite,
                    onManageSortFavorites: showSortFavoritesManagerFlow,
                    columnFavoritePresets: _columnFavoritePresets,
                    activeColumnFavoriteLabel: _activeColumnFavoriteLabel,
                    onColumnFavoriteSelected: _applyColumnFavorite,
                    pinnedColumnFavoriteKeys: _pinnedColumnFavoriteKeys,
                    onTogglePinnedColumnFavorite: _togglePinnedColumnFavorite,
                    canJumpToIssue: _canJumpToIssue(projection),
                    onJumpToIssueSubmitted: projection == null
                        ? null
                        : (value) => _jumpToIssue(projection, value),
                    hasActiveFilters: _hasActiveFilter,
                    onClearFilters: _clearFilters,
                    onEditFilters: () => showFilterDialogFlow(projection),
                    activeFilterCount: _filterSelection.activeFilterCount,
                    onRandomPick: projection != null &&
                            projection.filteredItems.isNotEmpty
                        ? () => pickRandomItemFlow(projection)
                        : null,
                    onScanCover: () => scanCoverFlow(),
                    onDownloadAllCovers: shelfState != null
                        ? () => downloadAllCoversFlow(shelfState)
                        : null,
                    counts: projection?.counts ?? const LibraryToolbarCounts(),
                    shelfState: shelfState,
                    onEditConditionPickList: widget.type.conditions.isNotEmpty
                        ? showConditionPickListEditorFlow
                        : null,
                    onEditGradePickList: widget.type.grades.isNotEmpty
                        ? showGradePickListEditorFlow
                        : null,
                    onEditTagPickList: showTagPickListEditorFlow,
                    onSmartLists: () => showSmartListsFlow(shelfState),
                    onFolders: showUserFoldersFlow,
                    onReadingQueue:
                        libraryShowsReadingQueue(widget.type.workspace.kind)
                            ? showReadingQueueFlow
                            : null,
                    onTransferFieldData: projection != null &&
                            projection.filteredItems.isNotEmpty
                        ? () => showTransferFieldDataFlow(projection)
                        : null,
                    onReassignIndex: projection != null &&
                            projection.filteredItems.isNotEmpty
                        ? () => reassignIndexFlow(projection)
                        : null,
                    onPrintReport: projection != null &&
                            projection.filteredItems.isNotEmpty
                        ? () => printReportFlow(projection)
                        : null,
                    onShareCollection: projection != null &&
                            projection.filteredItems.isNotEmpty
                        ? () => shareCollectionFlow(projection)
                        : null,
                    selectionEnabled: _selection.enabled,
                    selectedCount: _selection.selectedCount,
                    totalSelectableCount: projection?.filteredItems.length ?? 0,
                    includeDesktopSecondaryBand: false,
                    selectionCallbacks: (
                      onClearSelection: () => setState(() {
                            _selection = _selection.clear();
                            _selectionAnchorId = null;
                          }),
                      onSelectAll: () {
                        if (projection != null) {
                          _selectAllVisible(projection);
                        }
                      },
                      onBulkEdit: () => bulkEditFlow(projection),
                        onPrintToPdf: () => printSelectedReportFlow(projection),
                        onExportCsvTxt: () =>
                          shareSelectedCollectionFlow(projection),
                        onBulkDuplicate: () => bulkDuplicateFlow(projection),
                          onBulkLoan: () => showLoanSelectionFlow(projection),
                        onTransferFieldData: () =>
                          showTransferFieldDataForSelectionFlow(projection),
                        onBulkUpdateValues: null,
                        onBulkUpdateKeyInfo: null,
                      onBulkMoveToOwned: () => bulkMoveToOwnedFlow(projection),
                      onBulkMoveToWishlist: () =>
                          bulkMoveToWishlistFlow(projection),
                      onBulkRemove: () => bulkRemoveFlow(projection),
                      onBulkRefreshMetadata: () =>
                          bulkRefreshMetadataFlow(projection),
                    ),
                  ),
                  Expanded(
                    child: shelf.when(
                      data: (state) => _buildBody(
                        projection ?? _projectionForShelf(state, viewState),
                        viewState,
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
                    mediaKind: widget.type.workspace.kind.apiValue,
                    activeSmartListId: _activeSmartListId,
                    onSmartListSelected: _applySmartList,
                    onAllSelected: _clearSmartList,
                  ),
                ],
              ),
              if (_isScanningCover)
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

  Widget _buildBody(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final workspaceOverride = _buildVideoShelfDrilldown(
      projection,
      viewState,
      allOwnedCopies: allOwnedCopies,
      allWishlistItems: allWishlistItems,
    );
    final trimmedSearchQuery = _searchController.text.trim();
    final seriesStatusSummary = _seriesStatusSummaryForProjection(projection);
    if (kDebugMode &&
        kIsWeb &&
        _selectedId == null &&
        _selection.itemIds.isEmpty &&
        projection.filteredItems.isNotEmpty) {
      final firstVisibleId = projection.filteredItems.first.entry.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _selectedId != null || _selection.itemIds.isNotEmpty) {
          return;
        }
        _activateItem(firstVisibleId);
      });
    }
    return LibraryBody(
      type: widget.type,
      adapter: _adapter,
      projection: projection,
      viewState: viewState,
      selectedId: _selectedId,
      selectedAnchorId: _selectionAnchorId,
      selectedBucket: _selectedBucket,
      groupMode: _activeGroupMode,
      groupLoading: _facetLoadsInFlight.contains(_activeGroupMode),
      accent: widget.accent,
      hasActiveFilter: _hasActiveFilter,
      onAdd: () => showAddDialogFlow(),
      onClearFilters: _clearFilters,
      onEditFilters: () => showFilterDialogFlow(projection),
      selectionEnabled: _selection.enabled,
      selectedItemIds: _selection.itemIds,
      onApplySelection: _applySelection,
      onActivateItem: _activateItem,
      onToggleSelectionItem: _toggleSelectionItem,
      onOpenItem: showDetailPage,
      onBoxSelectionChanged: (ids) => setState(() {
        _selection = _selection.replace(ids);
        if (ids.isEmpty) {
          _selectionAnchorId = null;
        } else {
          _selectionAnchorId ??= ids.first;
          _selectedId = ids.contains(_selectedId) ? _selectedId : ids.first;
        }
      }),
      onBucketChanged: _setSelectedBucket,
      onGroupModeChanged: _setGroupMode,
      onSortChanged: (column) => _updateViewState(
        (state) => state.withSortColumn(column, _adapter.viewProfile),
      ),
      onColumnWidthChanged: (column, width) => _updateViewState(
        (state) => state.withColumnWidth(
          column,
          width,
          _adapter.viewProfile,
        ),
      ),
      onColumnReordered: (column, beforeColumn) => _updateViewState(
        (state) => state.withReorderedColumn(
          column: column,
          beforeColumn: beforeColumn,
        ),
      ),
      onCoverSizeChanged: (size) => _updateViewState(
        (state) => state.copyWith(coverSize: size),
      ),
      onSidebarWidthChanged: (width) => _updateViewState(
        (state) => state.copyWith(sidebarWidth: width),
      ),
      onSidebarVisibilityChanged: _setGroupingPanelVisibility,
      onDetailsLayoutChanged: (layout) => _updateViewState(
        (state) => state.copyWith(detailsLayout: layout),
      ),
      onDetailsWidthChanged: (width) => _updateViewState(
        (state) => state.copyWith(detailsWidth: width),
      ),
      onDetailsHeightChanged: (height) => _updateViewState(
        (state) => state.copyWith(detailsHeight: height),
      ),
      onAddOwned: (item) => runCollectionAction(
        (actions) => actions.addOwned(item),
      ),
      onRemoveOwned: confirmAndRemoveOwned,
      onAddWishlist: (item) => runCollectionAction(
        (actions) => actions.addWishlist(item),
      ),
      onRemoveWishlist: (item) => runCollectionAction(
        (actions) => actions.removeWishlist(item),
      ),
      onEditItem: (item, ownedItem) =>
          unawaited(showEditDialog(item, ownedItem)),
      workspaceOverride: workspaceOverride,
      onItemContextMenu: (item, position) =>
          handleItemContextMenu(projection, item, position),
      sidebarBreadcrumbs: _sidebarBreadcrumbs,
        sidebarAncestorScopeLabels: _sidebarAncestorScopeLabels,
      onSidebarNavigateBack:
          _scopeHistory.isEmpty ? null : _navigateSidebarBack,
      onSidebarNavigateToBreadcrumb: _navigateSidebarToBreadcrumb,
        onSidebarNavigateToAncestorScope: _navigateSidebarToAncestorScope,
      searchQuery: trimmedSearchQuery.isEmpty ? null : trimmedSearchQuery,
      activeSmartListName: _activeSmartListName,
      quickView: _quickView,
      collectionStatusScope: _collectionStatusScope,
        seriesCompletionScope: _seriesCompletionScope,
      collectionStatusScopeLabel:
          _collectionStatusScope == LibraryCollectionStatusScope.all
              ? null
              : _collectionStatusScope.label,
      linkedMetadataFilterLabel: _linkedMetadataFilter?.chipLabel,
      sidebarSelectedLetter: _selectedLetter,
      seriesStatusSummary: seriesStatusSummary,
      filterSelection: _filterSelection,
      preferToolbarAlphabet: true,
      onCollectionStatusScopeChanged: _toggleCollectionStatusScope,
      onSeriesCompletionScopeChanged: _setSeriesCompletionScope,
      onFilterByValue: _toggleLinkedMetadataFilter,
      selectedLetter: _selectedLetter,
      availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
        projection.filteredItems.map((i) => i.entry.resolvedTitle),
      ),
      onLetterSelected: _setSelectedLetter,
      db: ref.read(localDatabaseProvider),
      folderPreset: _activeFolderPreset,
      pinnedFolderPresets: _pinnedFolderPresets,
      onManageBuckets: libraryGroupModeSupportsBucketManagement(
          widget.type,
          _activeGroupMode,
        )
          ? () => unawaited(_showBucketManagerFlow(projection))
          : null,
      onPinnedFolderPresetsChanged: _setPinnedFolderPresets,
      desktopToolbarBand: LibraryDesktopSecondaryToolbar(
        type: widget.type,
        viewState: viewState,
        adapter: _adapter,
        counts: projection.counts,
        onEditColumns: showColumnChooserFlow,
        onEditSort: showSortDialogFlow,
        onSidebarVisibilityChanged: _setGroupingPanelVisibility,
        onViewModeChanged: (mode) => _updateViewState(
          (state) => state.copyWith(viewMode: mode),
        ),
        onDetailsLayoutChanged: (layout) => _updateViewState(
          (state) => state.copyWith(detailsLayout: layout),
        ),
        onCoverSizeChanged: (size) => _updateViewState(
          (state) => state.copyWith(coverSize: size),
        ),
        selectedBucket: _linkedMetadataFilter?.chipLabel ?? _selectedBucket,
        onClearBucket: _clearToolbarSearchChip,
        quickView: _quickView,
        hasActiveFilters: _hasActiveFilter,
        onQuickViewSelected: (view) =>
            _setQuickView(_quickView == view ? null : view),
        onClearFilters: _clearFilters,
        onEditFilters: () => showFilterDialogFlow(projection),
        activeFilterCount: _filterSelection.activeFilterCount,
        activeSortFavoriteId: _activeSortFavorite?.id,
        sortFavorites: _sortFavorites,
        onSortFavoriteSelected: _applySortFavorite,
        pinnedSortFavoriteIds: _pinnedSortFavoriteIds,
        onManageSortFavorites: showSortFavoritesManagerFlow,
        onRandomPick: projection.filteredItems.isNotEmpty
            ? () => pickRandomItemFlow(projection)
            : null,
        onDownloadAllCovers: ref.read(shelfProvider).asData?.value != null
            ? () => downloadAllCoversFlow(ref.read(shelfProvider).asData!.value)
            : null,
        shelfState: ref.read(shelfProvider).asData?.value,
        onSmartLists: () =>
            showSmartListsFlow(ref.read(shelfProvider).asData?.value),
        onFolders: showUserFoldersFlow,
        onReadingQueue: libraryShowsReadingQueue(widget.type.workspace.kind)
            ? showReadingQueueFlow
            : null,
        onEditConditionPickList: widget.type.conditions.isNotEmpty
            ? showConditionPickListEditorFlow
            : null,
        onEditGradePickList:
            widget.type.grades.isNotEmpty ? showGradePickListEditorFlow : null,
        onEditTagPickList: showTagPickListEditorFlow,
        onTransferFieldData: projection.filteredItems.isNotEmpty
            ? () => showTransferFieldDataFlow(projection)
            : null,
        onReassignIndex: projection.filteredItems.isNotEmpty
            ? () => reassignIndexFlow(projection)
            : null,
        onPrintReport: projection.filteredItems.isNotEmpty
            ? () => printReportFlow(projection)
            : null,
        onShareCollection: projection.filteredItems.isNotEmpty
            ? () => shareCollectionFlow(projection)
            : null,
        folderPreset: _activeFolderPreset,
        groupMode: _groupMode,
        pinnedFolderPresets: _pinnedFolderPresets,
        onPinnedFolderPresetsChanged: _setPinnedFolderPresets,
        onGroupModeChanged: _setFolderPreset,
      ),
    );
  }

  Future<void> _showBucketManagerFlow(LibraryProjection projection) async {
    final mode = _activeGroupMode;
    if (!libraryGroupModeSupportsBucketManagement(widget.type, mode)) {
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
    final mode = _activeGroupMode;
    final facetBuckets = _facetBucketsForMode(mode, shelf);
    final constrainedItemIds =
        (_usesExternalFacetBuckets(mode) && _selectedBucket != null)
            ? facetBuckets?.itemIdsByBucket[_selectedBucket!]
            : null;
    return LibraryProjection.fromShelf(
      shelf: shelf,
      type: widget.type,
      adapter: _adapter,
      viewState: viewState,
      query: _searchController.text,
      linkedMetadataFilter: _linkedMetadataFilter,
      selectedBucket: _usesExternalFacetBuckets(mode) ? null : _selectedBucket,
      selectedItemId: _selectedId,
      quickView: _quickView,
      collectionStatusScope: _collectionStatusScope,
      groupMode: mode,
      bucketScopeFilters: _sidebarBucketScopeFilters,
      overrideBuckets: facetBuckets?.buckets,
      constrainedItemIds: constrainedItemIds,
      filterSelection: _filterSelection,
      customFieldValuesByItem: customFieldValuesByItem,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
      activeLoanOwnedItemIds: _activeLoanOwnedItemIds,
    );
  }

  LibraryGroupMode get _activeGroupMode =>
      widget.type.availableGroupModes.contains(_groupMode)
        ? _groupMode!
        : ((_viewState ?? _adapter.viewProfile.defaults()).isSidebarVisible
          ? libraryDefaultGroupMode(widget.type)
          : LibraryGroupMode.title);

  LibraryFolderPreset get _activeFolderPreset =>
      sanitizeLibraryFolderPreset(
        _folderPreset,
        allowedModes: widget.type.availableGroupModes,
      ) ??
      LibraryFolderPreset.single(_activeGroupMode);

  bool get _hasActiveFilter =>
      _searchController.text.trim().isNotEmpty ||
      _linkedMetadataFilter != null ||
      _selectedBucket != null ||
      _selectedLetter != null ||
      _collectionStatusScope != LibraryCollectionStatusScope.all ||
      _quickView != null ||
      _activeSmartListId != null ||
      _filterSelection.hasActiveFilters;

  bool _usesExternalFacetBuckets(LibraryGroupMode mode) {
    return widget.type.presentation.externalFacetBucketModes.contains(mode);
  }

  FacetBuckets? _facetBucketsForMode(
    LibraryGroupMode mode,
    ShelfState shelf,
  ) {
    if (!_usesExternalFacetBuckets(mode)) {
      return null;
    }
    final signature = _genericShelfSignature(shelf);
    final cached = _facetBucketsByMode[mode];
    if (cached != null && cached.shelfSignature == signature) {
      return cached;
    }
    return FacetBuckets(
      shelfSignature: signature,
      buckets: [
        LibrarySeriesBucket(
          title: genericAllBucketLabel(widget.type),
          count: libraryItemsForShelf(shelf, widget.type).length,
        ),
      ],
      itemIdsByBucket: const {},
    );
  }

  void _ensureFacetBucketsLoaded(
    ShelfState shelf,
    LibraryGroupMode mode,
  ) {
    if (!_usesExternalFacetBuckets(mode)) {
      return;
    }
    final signature = _genericShelfSignature(shelf);
    final cached = _facetBucketsByMode[mode];
    if (cached != null && cached.shelfSignature == signature) {
      return;
    }
    if (_facetLoadsInFlight.contains(mode)) {
      return;
    }
    _facetLoadsInFlight.add(mode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
    unawaited(_loadFacetBuckets(mode, shelf, signature));
  }

  Future<void> _loadFacetBuckets(
    LibraryGroupMode mode,
    ShelfState shelf,
    String signature,
  ) async {
    final shelfItemIds = {
      for (final item in libraryItemsForShelf(shelf, widget.type))
        item.entry.id,
    };
    try {
      final buckets = await fetchFacetBuckets(
        itemIds: shelfItemIds,
        signature: signature,
        isStoryArc: mode == LibraryGroupMode.storyArc,
        allBucketLabel: genericAllBucketLabel(widget.type),
      ).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final latestShelf = ref.read(shelfProvider).asData?.value;
      if (latestShelf == null ||
          _genericShelfSignature(latestShelf) != signature) {
        return;
      }
      setState(() {
        _facetBucketsByMode[mode] = buckets;
        if (_selectedBucket != null &&
            !buckets.buckets.any((b) => b.title == _selectedBucket)) {
          _selectedBucket = null;
        }
      });
    } catch (e, st) {
      logRecoverableError(
        source: 'GenericLibraryPage',
        message: 'Facet load failed for $mode',
        error: e,
        stackTrace: st,
      );
      if (!mounted) {
        return;
      }
      final latestShelf = ref.read(shelfProvider).asData?.value;
      if (latestShelf == null ||
          _genericShelfSignature(latestShelf) != signature) {
        return;
      }
      setState(() {
        _facetBucketsByMode[mode] = FacetBuckets(
          shelfSignature: signature,
          buckets: [
            LibrarySeriesBucket(
              title: genericAllBucketLabel(widget.type),
              count: shelfItemIds.length,
            ),
          ],
          itemIdsByBucket: const {},
        );
        _selectedBucket = null;
      });
    } finally {
      _facetLoadsInFlight.remove(mode);
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _genericShelfSignature(ShelfState shelf) {
    return LibraryPageUtilities.shelfSignature([
      for (final item in libraryItemsForShelf(shelf, widget.type))
        item.entry.id,
    ]);
  }

  Future<void> _loadColumnFavoritePresets() async {
    try {
      final presets =
          await LibraryColumnPresetStore(widget.type.workspace).read();
      if (!mounted) {
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
        allowedModes: widget.type.availableGroupModes,
      );
      if (sanitized != null && !updated.contains(sanitized)) {
        updated.add(sanitized);
      }
    }
    setState(() => _pinnedFolderPresets = updated);
    unawaited(_viewPrefs.writePinnedFolderPresets(updated));
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
    _mutateSidebarScope(() {
      _seriesCompletionScope = scope;
    });
  }

  bool _canJumpToIssue(LibraryProjection? projection) {
    if (projection == null ||
        !widget.type.presentation.supportsSeriesIssueJump ||
        _activeGroupMode != LibraryGroupMode.series ||
        _selectedBucket == null) {
      return false;
    }
    return _seriesBucketItems(projection).any(
      (item) => _issueSortNumber(item.entry.itemNumber) != null,
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

  List<String> get _sidebarBreadcrumbs {
    return buildLibrarySidebarBreadcrumbs(
      rootLabel: 'All ${widget.type.pluralLabel}',
      history: _scopeHistory,
      current: _captureSidebarScope(),
      labelForScope: _sidebarScopeLabel,
    );
  }

  List<LibraryBucketScopeFilter> get _sidebarBucketScopeFilters {
    return [
      for (final snapshot in _scopeHistory)
        if (snapshot.selectedBucket != null)
          LibraryBucketScopeFilter(
            groupMode: snapshot.groupMode,
            bucket: snapshot.selectedBucket!,
          ),
    ];
  }

  List<String> get _sidebarAncestorScopeLabels {
    return [
      for (final snapshot in _scopeHistory)
        if (snapshot.selectedBucket != null) _sidebarScopeLabel(snapshot),
    ];
  }

  void _navigateSidebarToAncestorScope(int index) {
    final bucketIndexes = <int>[
      for (var historyIndex = 0;
          historyIndex < _scopeHistory.length;
          historyIndex += 1)
        if (_scopeHistory[historyIndex].selectedBucket != null) historyIndex,
    ];
    if (index < 0 || index >= bucketIndexes.length) {
      return;
    }
    _navigateSidebarToBreadcrumb(bucketIndexes[index] + 1);
  }

  void _setSelectedBucket(String? bucket) {
    final childMode = bucket == null
        ? null
        : _activeFolderPreset.nextModeAfter(_activeGroupMode);
    if (childMode != null) {
      final previous = _captureSidebarScope();
      final drilldownSource = LibrarySidebarScopeSnapshot(
        groupMode: previous.groupMode,
        selectedBucket: bucket,
        selectedLetter: null,
        linkedMetadataFilter: null,
        collectionStatusScope: previous.collectionStatusScope,
        quickView: previous.quickView,
        filterSelection: previous.filterSelection,
        activeSmartListId: null,
        activeSmartListName: null,
        searchQuery: previous.searchQuery,
      );
      final next = LibrarySidebarScopeSnapshot(
        groupMode: childMode,
        collectionStatusScope: previous.collectionStatusScope,
        quickView: previous.quickView,
        filterSelection: previous.filterSelection,
        searchQuery: previous.searchQuery,
      );
      setState(() {
        _scopeHistory = updateLibrarySidebarScopeHistory(
          history: _scopeHistory,
          previous: drilldownSource,
          next: next,
        );
        _groupMode = childMode;
        _selectedBucket = null;
        _selectedLetter = null;
        _linkedMetadataFilter = null;
        _activeSmartListId = null;
        _activeSmartListName = null;
      });
      _syncRouteState();
      return;
    }
    _mutateSidebarScope(() {
      _selectedBucket = bucket;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
  }

  void _setSelectedLetter(String? letter) {
    _mutateSidebarScope(() {
      _selectedLetter = letter;
      _selectedBucket = null;
      _linkedMetadataFilter = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
  }

  void _toggleLinkedMetadataFilter(String value) {
    _mutateSidebarScope(() {
      _linkedMetadataFilter = _linkedMetadataFilter?.value == value
          ? null
          : LibraryLinkedMetadataFilter(value: value);
      _selectedBucket = null;
      _selectedLetter = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
  }

  void _mutateSidebarScope(VoidCallback mutate) {
    final previous = _captureSidebarScope();
    mutate();
    final next = _captureSidebarScope();
    if (next == previous) {
      return;
    }
    setState(() {
      _scopeHistory = updateLibrarySidebarScopeHistory(
        history: _scopeHistory,
        previous: previous,
        next: next,
      );
    });
    _syncRouteState();
  }

  LibrarySidebarScopeSnapshot _captureSidebarScope() {
    return LibrarySidebarScopeSnapshot(
      groupMode: _activeGroupMode,
      selectedBucket: _selectedBucket,
      selectedLetter: _selectedLetter,
      linkedMetadataFilter: _linkedMetadataFilter,
      collectionStatusScope: _collectionStatusScope,
      seriesCompletionScope: _seriesCompletionScope,
      quickView: _quickView,
      filterSelection: _filterSelection,
      activeSmartListId: _activeSmartListId,
      activeSmartListName: _activeSmartListName,
      searchQuery: _searchController.text.trim(),
    );
  }

  void _applySidebarScopeSnapshot(LibrarySidebarScopeSnapshot snapshot) {
    _groupMode = snapshot.groupMode;
    _selectedBucket = snapshot.selectedBucket;
    _selectedLetter = snapshot.selectedLetter;
    _linkedMetadataFilter = snapshot.linkedMetadataFilter;
    _collectionStatusScope = snapshot.collectionStatusScope;
    _seriesCompletionScope = snapshot.seriesCompletionScope;
    _quickView = snapshot.quickView;
    _filterSelection = snapshot.filterSelection;
    _activeSmartListId = snapshot.activeSmartListId;
    _activeSmartListName = snapshot.activeSmartListName;
    _searchController.value = _searchController.value.copyWith(
      text: snapshot.searchQuery,
      selection: TextSelection.collapsed(offset: snapshot.searchQuery.length),
      composing: TextRange.empty,
    );
  }

  void _navigateSidebarBack() {
    final navigation = popLibrarySidebarScopeHistory(_scopeHistory);
    if (navigation == null) {
      return;
    }
    setState(() {
      _scopeHistory = navigation.history;
      _applySidebarScopeSnapshot(navigation.target);
    });
    _syncRouteState();
  }

  void _navigateSidebarToBreadcrumb(int index) {
    final navigation = navigateLibrarySidebarScopeHistoryToBreadcrumb(
      history: _scopeHistory,
      index: index,
      rootScope: LibrarySidebarScopeSnapshot(groupMode: _activeGroupMode),
    );
    if (navigation == null) {
      return;
    }
    setState(() {
      _scopeHistory = navigation.history;
      _applySidebarScopeSnapshot(navigation.target);
    });
    _syncRouteState();
  }

  String _sidebarScopeLabel(LibrarySidebarScopeSnapshot snapshot) {
    if (snapshot.selectedBucket != null) {
      return '${genericGroupModeLabel(snapshot.groupMode, widget.type)}: ${snapshot.selectedBucket}';
    }
    if (snapshot.linkedMetadataFilter != null) {
      return snapshot.linkedMetadataFilter!.chipLabel;
    }
    if (snapshot.collectionStatusScope != LibraryCollectionStatusScope.all) {
      return snapshot.collectionStatusScope.label;
    }
    if (snapshot.seriesCompletionScope != LibrarySeriesCompletionScope.all) {
      return snapshot.seriesCompletionScope.label;
    }
    if (snapshot.selectedLetter != null) {
      return 'Letter ${snapshot.selectedLetter}';
    }
    if (snapshot.activeSmartListName != null &&
        snapshot.activeSmartListName!.trim().isNotEmpty) {
      return snapshot.activeSmartListName!;
    }
    if (snapshot.quickView != null) {
      return snapshot.quickView!.label;
    }
    if (snapshot.filterSelection.hasActiveFilters) {
      return '${snapshot.filterSelection.activeFilterCount} filters';
    }
    if (snapshot.searchQuery.trim().isNotEmpty) {
      return 'Search';
    }
    return 'All ${widget.type.pluralLabel}';
  }

  void _clearFilters() {
    setState(() {
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _collectionStatusScope = LibraryCollectionStatusScope.all;
      _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _quickView = null;
      _filterSelection = LibraryFilterSelection.none;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _scopeHistory = const [];
      _searchController.clear();
      _selectionAnchorId = null;
    });
    _syncRouteState();
  }

  void _applySmartList(SmartList smartList) {
    setState(() {
      _activeSmartListId = smartList.id;
      _activeSmartListName = smartList.name;
      _filterSelection = smartList.filterSelection;
      _quickView = smartList.quickView;
      if (smartList.searchQuery != null) {
        _searchController.text = smartList.searchQuery!;
      } else {
        _searchController.clear();
      }
      if (_viewState != null) {
        if (smartList.sortRules != null && smartList.sortRules!.isNotEmpty) {
          _viewState = _viewState!.withSortRules(
            smartList.sortRules!,
            _adapter.viewProfile,
          );
        } else if (smartList.sortColumn != null) {
          _viewState = _viewState!.copyWith(
            sortColumn: smartList.sortColumn,
            sortAscending: smartList.sortAscending ?? true,
          );
        }
      }
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _collectionStatusScope = LibraryCollectionStatusScope.all;
      _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _scopeHistory = const [];
    });
    _syncRouteState();
  }

  void _clearSmartList() {
    setState(() {
      _activeSmartListId = null;
      _activeSmartListName = null;
      _filterSelection = LibraryFilterSelection.none;
      _quickView = null;
      _collectionStatusScope = LibraryCollectionStatusScope.all;
      _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _searchController.clear();
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _scopeHistory = const [];
    });
    _syncRouteState();
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

  Future<void> _loadViewState() async {
    try {
      final token = ++_viewStateLoadToken;
      final expectedKind = widget.type.workspace.kind;
      final state = await _adapter.viewProfile.load();
      if (mounted &&
          token == _viewStateLoadToken &&
          widget.type.workspace.kind == expectedKind) {
        setState(() {
          _viewState = state;
          _applyRouteStateFromUri(widget.routeUri);
        });
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_page',
        message: 'Failed to load view state.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateViewState(
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState state) update,
  ) {
    final next = update(_viewState ?? _adapter.viewProfile.defaults());
    setState(() => _viewState = next);
    _syncRouteState();
    unawaited(_adapter.viewProfile.save(next));
  }

  void _setGroupingPanelVisibility(bool isVisible) {
    final current = _viewState ?? _adapter.viewProfile.defaults();
    final next = current.copyWith(isSidebarVisible: isVisible);
    setState(() {
      _viewState = next;
      if (!isVisible) {
        _groupMode = null;
        _selectedBucket = null;
        _scopeHistory = const [];
      }
    });
    if (!isVisible) {
      unawaited(_viewPrefs.writeGroupMode(null));
    }
    _syncRouteState();
    unawaited(_adapter.viewProfile.save(next));
  }

  void _setQuickView(LibraryQuickView? view) {
    _mutateSidebarScope(() {
      _quickView = view;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    unawaited(_viewPrefs.writeQuickView(view));
  }

  void _setGroupMode(LibraryGroupMode mode) {
    _setFolderPreset(LibraryFolderPreset.single(mode));
  }

  void _setFolderPreset(LibraryFolderPreset preset) {
    final sanitized = sanitizeLibraryFolderPreset(
      preset,
      allowedModes: widget.type.availableGroupModes,
    );
    if (sanitized == null) {
      return;
    }
    setState(() {
      _folderPreset = sanitized;
      _groupMode = sanitized.primaryMode;
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _scopeHistory = const [];
    });
    _syncRouteState();
    final shelfState = ref.read(shelfProvider).asData?.value;
    if (shelfState != null) {
      _ensureFacetBucketsLoaded(shelfState, sanitized.primaryMode);
    }
    unawaited(_viewPrefs.writeFolderPreset(sanitized));
    unawaited(_viewPrefs.writeGroupMode(sanitized.primaryMode));
  }

  LibraryRouteState _buildRouteState() {
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    return LibraryRouteState(
      kind: widget.type.workspace.kind.apiValue,
      searchQuery: _trimmedQuery(_searchController.text),
      groupMode: viewState.isSidebarVisible ? _activeGroupMode : null,
      folderPreset: viewState.isSidebarVisible ? _activeFolderPreset : null,
      selectedBucket: _selectedBucket,
      linkedMetadataValue: _linkedMetadataFilter?.value,
      selectedLetter: _selectedLetter,
      collectionStatusScope: _collectionStatusScope,
      seriesCompletionScope: _seriesCompletionScope,
      quickView: _quickView,
      filterSelection: _filterSelection,
      sortRules: viewState.sortRules,
      isSidebarVisible: viewState.isSidebarVisible,
    );
  }

  void _syncRouteState() {
    if (!mounted) {
      return;
    }
    if (GoRouter.maybeOf(context) == null) {
      return;
    }
    final nextUri = _buildRouteState().toUri(
      widget.routeUri,
      kind: widget.type.workspace.kind.apiValue,
    );
    if (nextUri.toString() == widget.routeUri.toString()) {
      return;
    }
    context.replace(nextUri.toString());
  }

  void _applyRouteStateFromUri(Uri uri) {
    final routeState = LibraryRouteState.fromUri(uri).filteredForType(widget.type);
    if (!routeState.hasExplicitViewState) {
      return;
    }
    final currentViewState = _viewState ?? _adapter.viewProfile.defaults();
    _viewState = currentViewState.copyWith(
      isSidebarVisible:
          routeState.isSidebarVisible ?? currentViewState.isSidebarVisible,
      sortRules: routeState.sortRules ?? currentViewState.sortRules,
    );
    final sidebarVisible = _viewState!.isSidebarVisible;
    final routeFolderPreset = sanitizeLibraryFolderPreset(
      routeState.folderPreset,
      allowedModes: widget.type.availableGroupModes,
    );
    _groupMode = sidebarVisible
      ? routeFolderPreset?.primaryMode ??
        routeState.groupMode ??
        libraryDefaultGroupMode(widget.type)
      : null;
    _folderPreset = !sidebarVisible
      ? null
      : routeFolderPreset ??
        (_groupMode == null ? null : LibraryFolderPreset.single(_groupMode!));
    _selectedBucket = routeState.selectedBucket;
    _selectedLetter = routeState.selectedLetter;
    _linkedMetadataFilter = routeState.linkedMetadataValue == null
        ? null
        : LibraryLinkedMetadataFilter(value: routeState.linkedMetadataValue!);
    _collectionStatusScope = routeState.collectionStatusScope;
    _seriesCompletionScope = routeState.seriesCompletionScope;
    _quickView = routeState.quickView;
    _filterSelection = routeState.filterSelection;
    _activeSmartListId = null;
    _activeSmartListName = null;
    _scopeHistory = const [];
    final routeQuery = routeState.searchQuery ?? '';
    _searchController.value = _searchController.value.copyWith(
      text: routeQuery,
      selection: TextSelection.collapsed(offset: routeQuery.length),
      composing: TextRange.empty,
    );
  }

  String? _trimmedQuery(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> showAddDialogFlow({String? barcode}) async {
    final added = await showLibraryAddDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      initialQuery: _searchController.text,
      initialBarcode: barcode,
    );
    if (added != null && mounted) {
      ref.invalidate(shelfProvider);
      _revealAddedItems(added.itemIds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added.target == LibraryAddTarget.track
                ? '${widget.type.singularLabel} added to tracking'
                : '${widget.type.singularLabel} added',
          ),
        ),
      );
    }
  }

  void _revealAddedItems(List<String> itemIds) {
    if (itemIds.isEmpty) {
      return;
    }
    setState(() {
      _selectedId = itemIds.first;
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _collectionStatusScope = LibraryCollectionStatusScope.all;
      _seriesCompletionScope = LibrarySeriesCompletionScope.all;
      _quickView = null;
      _filterSelection = LibraryFilterSelection.none;
      _activeSmartListId = null;
      _activeSmartListName = null;
      _scopeHistory = const [];
      _searchController.clear();
    });
    _syncRouteState();
  }

  void _selectItem(String id) {
    setState(() {
      _selectedId = id;
      if (_videoShelfDrilldownTitleItemId != null &&
          _videoShelfDrilldownTitleItemId != id) {
        _videoShelfDrilldownTitleItemId = null;
        _videoShelfDrilldownReleaseId = null;
      }
    });
    if (widget.type.capabilities.showsTrackData) {
      unawaited(_hydrateSelectedItem(id));
    }
  }

  void _activateItem(String id) {
    if (_selection.enabled) {
      setState(() => _selection = _selection.clear());
    }
    _selectionAnchorId = id;
    _selectItem(id);
  }

  void _toggleSelectionItem(String id) {
    setState(() {
      _selection = _selection.toggle(id);
      _selectedId = id;
      _selectionAnchorId = id;
    });
  }

  void _applySelection(Set<String> ids, String focusedId) {
    setState(() {
      _selection = _selection.replace(ids);
      _selectedId = focusedId;
      _selectionAnchorId ??= focusedId;
    });
  }

  void _selectAllVisible(LibraryProjection projection) {
    if (_isTextInputFocused) {
      return;
    }
    final visibleIds = _visibleSelectionItemIds(projection);
    if (visibleIds.isEmpty) {
      return;
    }
    _applySelection(visibleIds, _selectedId ?? visibleIds.first);
  }

  void _removeVisibleSelection(LibraryProjection projection) {
    if (_isTextInputFocused || _selection.itemIds.isEmpty) {
      return;
    }
    unawaited(bulkRemoveFlow(projection));
  }

  Set<String> _visibleSelectionItemIds(LibraryProjection projection) {
    final visibleItems = _selectedLetter == null
        ? projection.filteredItems
        : projection.filteredItems
            .where(
              (item) => LibraryAlphaJumpBar.matchesLetter(
                item.entry.resolvedTitle,
                _selectedLetter!,
              ),
            )
            .toList(growable: false);
    return visibleItems.map((item) => item.entry.id).toSet();
  }

  bool get _isTextInputFocused {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) {
      return false;
    }
    return focusedContext.widget is EditableText;
  }

  bool _canOpenVideoShelfDrilldown(LibraryProjectionItem item) {
    return canOpenVideoShelfDrilldown(widget.type, item.entry);
  }

  void _openVideoShelfDrilldown(LibraryProjectionItem item) {
    setState(() {
      _selectedId = item.entry.id;
      _videoShelfDrilldownTitleItemId = item.entry.id;
      _videoShelfDrilldownReleaseId = null;
    });
  }

  Future<void> _refreshVideoTitleFromCore(LibraryProjectionItem item) async {
    final result = await showLibraryMetadataRefreshDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      allEntries: [item.entry],
      shownEntries: [item.entry],
      selectedEntry: item.entry,
    );
    if (result == null || !mounted) {
      return;
    }
    ref.invalidate(shelfProvider);
    showAppToast(
      context,
      'Metadata refresh finished: ${result.matched}/${result.targets} matched, ${result.cached} cached, ${result.failed} failed.',
      tone: AppToastTone.success,
    );
  }

  Widget? _buildVideoShelfDrilldown(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState, {
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final titleItemId = _videoShelfDrilldownTitleItemId;
    if (titleItemId == null) {
      return null;
    }
    LibraryProjectionItem? titleItem;
    for (final item in projection.allItems) {
      if (item.entry.id == titleItemId) {
        titleItem = item;
        break;
      }
    }
    if (titleItem == null || !_canOpenVideoShelfDrilldown(titleItem)) {
      if (_videoShelfDrilldownTitleItemId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _videoShelfDrilldownTitleItemId = null;
            _videoShelfDrilldownReleaseId = null;
          });
        });
      }
      return null;
    }

    final ownedCopies = allOwnedCopies
        .where((item) => item.itemId == titleItemId)
        .toList(growable: false);
    final wishlistItems = allWishlistItems
        .where((item) => item.itemId == titleItemId)
        .toList(growable: false);
    final drilldownItems = buildVideoShelfReleaseItems(
      titleItem: titleItem,
      ownedCopies: ownedCopies,
      wishlistItems: wishlistItems,
      releaseEntryBuilder: widget.type.presentation.releaseEntryBuilder,
    );

    if (_videoShelfDrilldownReleaseId == null && drilldownItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _videoShelfDrilldownReleaseId != null) {
          return;
        }
        setState(() =>
            _videoShelfDrilldownReleaseId = drilldownItems.first.entry.id);
      });
    }

    return VideoShelfReleaseDrilldown(
      titleItem: titleItem,
      items: drilldownItems,
      selectedReleaseId: _videoShelfDrilldownReleaseId,
      coverSize: viewState.coverSize,
      accent: widget.accent,
      onBack: () => setState(() {
        _videoShelfDrilldownTitleItemId = null;
        _videoShelfDrilldownReleaseId = null;
      }),
      onRefreshFromCore: () => _refreshVideoTitleFromCore(titleItem!),
      onSelectRelease: (releaseId) =>
          setState(() => _videoShelfDrilldownReleaseId = releaseId),
      onOpenTitleDetails: () => showLibraryDetailPage(
        context: context,
        request: LibraryDetailPageRequest(
          type: widget.type,
          entry: titleItem!.entry,
          ownedItem: titleItem.source.ownedItem,
          accent: widget.accent,
          onAddOwned: () => runCollectionAction(
            (actions) => actions.addOwned(titleItem!),
          ),
          onRemoveOwned: titleItem.source.ownedItem == null
              ? null
              : () => confirmAndRemoveOwned(titleItem!),
          onAddWishlist: () => runCollectionAction(
            (actions) => actions.addWishlist(titleItem!),
          ),
          onRemoveWishlist: titleItem.source.isWishlisted
              ? () => runCollectionAction(
                    (actions) => actions.removeWishlist(titleItem!),
                  )
              : null,
          onEdit: (ownedItem) =>
              unawaited(showEditDialog(titleItem!, ownedItem)),
          onFilterByValue: _toggleLinkedMetadataFilter,
        ),
      ),
    );
  }

  Future<void> _hydrateSelectedItem(String itemId) async {
    if (!_detailHydrationInFlight.add(itemId)) {
      return;
    }
    try {
      final item = await ref.read(apiClientProvider).getMetadataItem(
            kind: widget.type.workspace.kind.apiValue,
            id: itemId,
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

