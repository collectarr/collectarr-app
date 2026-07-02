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
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
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
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
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
import 'package:collectarr_app/features/library/generic/facet_controller_provider.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_compare_dialog.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_item_context_menu.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
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
part 'page/hooks/page_kind_hooks.dart';
part 'page/hooks/page_sidebar_hooks.dart';
part 'page/hooks/page_video_hooks.dart';
part 'page/controllers/page_facet_controller.dart';
part 'page/controllers/page_scope_controller.dart';
part 'page/controllers/page_view_state_controller.dart';
part 'page/controllers/page_projection_controller.dart';
part 'page/controllers/page_projection_provider.dart';
part 'page/controllers/page_toolbar_controller.dart';
part 'page/controllers/page_toolbar_presenter.dart';
part 'page/controllers/page_toolbar_builder.dart';
part 'page/controllers/page_selection_controller.dart';

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
  ConsumerState<GenericLibraryPage> createState() => GenericLibraryPageState();
}

class GenericLibraryPageState extends ConsumerState<GenericLibraryPage>
    with LibraryPageUtilities {
  static bool _viewStateCacheWarmupStarted = false;

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
  int _columnFavoritesLoadToken = 0;
  int _activeLoanIdsLoadToken = 0;
  int _customFieldLoadToken = 0;
  Timer? _viewStateSaveDebounce;
  Timer? _searchDebounce;
  Timer? _selectionHydrationDebounce;
  ProviderSubscription<AsyncValue<ShelfState>>? _shelfSubscription;
  String? _lastFacetEnsureSignature;
  LibraryGroupMode? _lastFacetEnsureMode;
  LibraryKindBrowserDelegate _kindBrowserDelegate =
      LibraryNoopBrowserDelegate();

  String _appliedSearchQuery = '';
  String? _searchPinnedItemId;

  LibrarySearchTarget _searchTarget = LibrarySearchTarget.all;

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
    _kindBrowserDelegate = widget.type.kindBrowserDelegateBuilder?.call() ??
        LibraryNoopBrowserDelegate();
    _shelfSubscription = ref.listenManual<AsyncValue<ShelfState>>(
      shelfProvider,
      (_, next) {
        unawaited(_loadCustomFieldValuesForCurrentKind());
        final shelfState = next.asData?.value;
        if (shelfState != null) {
          _maybeEnsureFacetBucketsLoaded(shelfState, _activeGroupMode);
        }
      },
    );
    unawaited(_warmViewStateCachesOnce());
    _viewState = _adapter.viewProfile.defaults();
    _primeCachedViewPreferences();
    _applyRouteStateFromUri(widget.routeUri);
    unawaited(_loadViewState());
    unawaited(_loadViewPreferences());
    unawaited(_loadColumnFavoritePresets());
    unawaited(_loadActiveLoanIds());
  }

  Future<void> _loadViewPreferences() async {
    try {
      final loadToken = ++_viewPreferenceLoadToken;
      final expectedKind = widget.type.workspace.kind;
      final allowedGroupModes = _scopeAvailableGroupModes;
      final quickViewFuture = _viewPrefs.readQuickView();
      final groupModeFuture = _viewPrefs.readGroupMode(
        allowedModes: allowedGroupModes,
      );
      final folderPresetFuture = _viewPrefs.readFolderPreset(
        allowedModes: allowedGroupModes,
      );
      final pinnedPresetsFuture = _viewPrefs.readPinnedFolderPresets(
        allowedModes: allowedGroupModes,
      );
      final pinnedViewPresetsFuture = _viewPrefs.readPinnedViewPresets(
        fallback: libraryDefaultPinnedViewPresetsForType(widget.type),
      );
      final pinnedSortFavoriteIdsFuture = _viewPrefs.readPinnedSortFavoriteIds(
        fallback: libraryDefaultPinnedSortFavoriteIdsForType(widget.type),
      );
      final pinnedColumnFavoriteKeysFuture =
          _viewPrefs.readPinnedColumnFavoriteKeys(
        fallback: libraryDefaultPinnedColumnFavoriteKeysForType(widget.type),
      );

      final (
        quickView,
        groupMode,
        folderPreset,
        pinnedPresets,
        pinnedViewPresets,
        pinnedSortFavoriteIds,
        pinnedColumnFavoriteKeys,
      ) = await (
        quickViewFuture,
        groupModeFuture,
        folderPresetFuture,
        pinnedPresetsFuture,
        pinnedViewPresetsFuture,
        pinnedSortFavoriteIdsFuture,
        pinnedColumnFavoriteKeysFuture,
      ).wait;
      if (!mounted ||
          loadToken != _viewPreferenceLoadToken ||
          widget.type.workspace.kind != expectedKind) {
        return;
      }

      final nextGroupMode = folderPreset?.primaryMode ?? groupMode;
      final preferencesChanged = _quickView !=
              sanitizeLibraryQuickViewForType(quickView, widget.type) ||
          _folderPreset != folderPreset ||
          _groupMode != nextGroupMode ||
          !listEquals(_pinnedFolderPresets, pinnedPresets) ||
          !setEquals(_pinnedViewPresets, pinnedViewPresets) ||
          !setEquals(_pinnedSortFavoriteIds, pinnedSortFavoriteIds) ||
          !setEquals(_pinnedColumnFavoriteKeys, pinnedColumnFavoriteKeys);

      if (!preferencesChanged) {
        return;
      }

      setState(() {
        _quickView = sanitizeLibraryQuickViewForType(quickView, widget.type);
        _folderPreset = folderPreset;
        _groupMode = nextGroupMode;
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
    final allowedGroupModes = _scopeAvailableGroupModes.toSet();
    _quickView = sanitizeLibraryQuickViewForType(
      _viewPrefs.cachedQuickView,
      widget.type,
    );
    final cachedGroupMode =
        allowedGroupModes.contains(_viewPrefs.cachedGroupMode)
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
      _selection = LibrarySelectionState.empty();
      _filterSelection = LibraryFilterSelection.none;
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
      setActiveReleaseFolderTitleItemId(null);
      _searchTarget = LibrarySearchTarget.all;
      _appliedSearchQuery = '';
      _searchPinnedItemId = null;
      ref
          .read(
            libraryFacetControllerProvider(
              oldWidget.type.workspace.kind.apiValue,
            ).notifier,
          )
          .clearAll();
      ref
          .read(
            libraryFacetControllerProvider(
              widget.type.workspace.kind.apiValue,
            ).notifier,
          )
          .clearAll();
      _lastFacetEnsureSignature = null;
      _lastFacetEnsureMode = null;
      _searchController.clear();
      _primeCachedViewPreferences();
      // Start from the next kind's own cached defaults/chrome to avoid
      // a one-frame layout jump (e.g. right -> bottom details panel).
      _viewState = _adapter.viewProfile.defaults();
      unawaited(_loadViewState());
      unawaited(_loadViewPreferences());
      unawaited(_loadColumnFavoritePresets());
      unawaited(_loadCustomFieldValuesForCurrentKind());
      unawaited(_loadActiveLoanIds());
    } else if (oldWidget.routeUri.toString() != widget.routeUri.toString()) {
      _applyRouteStateFromUri(widget.routeUri);
    }
  }

  Future<void> _loadActiveLoanIds() async {
    try {
      final loadToken = ++_activeLoanIdsLoadToken;
      final expectedKind = widget.type.workspace.kind;
      final db = ref.read(localDatabaseProvider);
      final repo = LoanRepository(db);
      final activeLoans = await repo.getActiveLoans();
      final next = <String>{
        for (final loan in activeLoans) loan.ownedItemId,
      };
      if (!mounted ||
          loadToken != _activeLoanIdsLoadToken ||
          widget.type.workspace.kind != expectedKind) {
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
    _viewStateSaveDebounce?.cancel();
    _searchDebounce?.cancel();
    _selectionHydrationDebounce?.cancel();
    _shelfSubscription?.close();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    final trimmed = _searchController.text.trim();
    if (_appliedSearchQuery == trimmed && _searchPinnedItemId == null) {
      return;
    }
    setState(() {
      _appliedSearchQuery = trimmed;
      _searchPinnedItemId = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }

  void _onSearchInputChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 60), () {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _appliedSearchQuery = '';
      _searchPinnedItemId = null;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }

  void _applySearchSuggestion(LibraryToolbarSearchSuggestion suggestion) {
    setState(() {
      _searchController.value = _searchController.value.copyWith(
        text: suggestion.title,
        selection: TextSelection.collapsed(offset: suggestion.title.length),
        composing: TextRange.empty,
      );
      _appliedSearchQuery = suggestion.title.trim();
      _searchPinnedItemId = suggestion.id;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
  }

  void _onSearchTargetChanged(LibrarySearchTarget target) {
    if (!_supportsMusicTrackSearch || _searchTarget == target) {
      return;
    }
    setState(() {
      _searchTarget = target;
      _activeSmartListId = null;
      _activeSmartListName = null;
    });
    _syncRouteState();
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
    final shelf = ref.watch(shelfProvider);
    final ownedCopiesValue = ref.watch(collectionProvider);
    final wishlistValue = ref.watch(wishlistProvider);
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    final shelfState = shelf.asData?.value;
    final allOwnedCopies = _activeOwnedCopies(ownedCopiesValue);
    final allWishlistItems = _activeWishlistItems(wishlistValue);
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
      onNextItem: projection == null
          ? null
          : () => _navigateKeyboardSelection(projection, 1),
      onPreviousItem: projection == null
          ? null
          : () => _navigateKeyboardSelection(projection, -1),
      onEscape: _handleKeyboardEscape,
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
                  _buildToolbar(
                    projection: projection,
                    viewState: viewState,
                    shelfState: shelfState,
                  ),
                  Expanded(
                    child: shelf.when(
                      data: (state) => _buildBody(
                        projection ?? _projectionForShelf(state, viewState),
                        viewState,
                        shelfState: state,
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
    required ShelfState shelfState,
    required List<OwnedItem> allOwnedCopies,
    required List<WishlistItem> allWishlistItems,
  }) {
    final workspaceOverride = buildWorkspaceOverride(
      projection,
      viewState,
      allOwnedCopies: allOwnedCopies,
      allWishlistItems: allWishlistItems,
    );
    final releasePositionLabel = _releasePositionLabelForProjection(projection);
    if (activeReleaseFolderTitleItemId != null &&
        projection.filteredItems.isNotEmpty) {
      final hasSelection = projection.filteredItems.any(
        (item) => item.entry.id == _selectedId,
      );
      if (!hasSelection) {
        final firstReleaseId = projection.filteredItems.first.entry.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _selectedId == firstReleaseId) {
            return;
          }
          _activateItem(firstReleaseId);
        });
      }
    }
    final trimmedSearchQuery = _appliedSearchQuery.trim();
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
    final activeProjectionGroupMode = _projectionGroupMode;
    final activeFacetLoadKey = _facetLoadKey(
      activeProjectionGroupMode,
      _genericShelfSignature(shelfState),
    );
    final canUseSeriesCompletionScope =
        _activeGroupMode == LibraryGroupMode.series;
    final effectiveSeriesCompletionScope = canUseSeriesCompletionScope
        ? _seriesCompletionScope
        : LibrarySeriesCompletionScope.all;
    return LibraryBody(
      type: widget.type,
      adapter: _adapter,
      projection: projection,
      viewState: viewState,
      selectedId: _selectedId,
      selectedAnchorId: _selectionAnchorId,
      selectedBucket: _selectedBucket,
      groupMode: activeProjectionGroupMode,
      groupLoading: _isFacetLoadInFlight(activeFacetLoadKey),
      accent: widget.accent,
      hasActiveFilter: _hasActiveFilter,
      onAdd: () => showAddDialogFlow(),
      onClearFilters: _clearFilters,
      onEditFilters: () => showFilterDialogFlow(projection),
      selectionEnabled:
          _selection.enabled && viewState.viewMode != LibraryViewMode.cardFlow,
      selectedItemIds: _selection.itemIds,
      onApplySelection: _applySelection,
      onActivateItem: _activateItem,
      onToggleSelectionItem: _toggleSelectionItem,
      onOpenItem: (item) {
        final isMediaTitle =
            item.entry.browseScope == LibraryBrowserScope.title;
        if (_shouldOpenReleaseFolder(item) && isMediaTitle) {
          _openReleaseFolder(item);
          return;
        }
        showDetailPage(item);
      },
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
      onSidebarWidthChanged: (width) => _updateViewChrome(
        (state) => state.copyWith(sidebarWidth: width),
      ),
      onSidebarVisibilityChanged: _setGroupingPanelVisibility,
      onDetailsLayoutChanged: (layout) => _updateViewState(
        (state) => state.copyWith(detailsLayout: layout),
      ),
      onDetailsWidthChanged: (width) => _updateViewChrome(
        (state) => state.copyWith(detailsWidth: width),
      ),
      onDetailsHeightChanged: (height) => _updateViewChrome(
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
      searchTarget: _effectiveSearchTarget,
      activeSmartListName: _activeSmartListName,
      quickView: _quickView,
      collectionStatusScope: _collectionStatusScope,
      seriesCompletionScope: effectiveSeriesCompletionScope,
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
      onSeriesCompletionScopeChanged:
          canUseSeriesCompletionScope ? _setSeriesCompletionScope : null,
      onFilterByValue: _toggleLinkedMetadataFilter,
      selectedLetter: _selectedLetter,
      availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
        projection.filteredItems.map((i) => i.entry.resolvedTitle),
      ),
      onLetterSelected: _setSelectedLetter,
      db: ref.read(localDatabaseProvider),
      folderPreset: _activeFolderPreset,
      pinnedFolderPresets: _pinnedFolderPresets,
      onManageBuckets: supportsBucketManagement(activeProjectionGroupMode)
          ? () => unawaited(_showBucketManagerFlow(projection))
          : null,
      onPinnedFolderPresetsChanged: _setPinnedFolderPresets,
      inspectorContextLabel: releasePositionLabel,
      desktopToolbarBand: LibraryDesktopSecondaryToolbar(
        type: widget.type,
        viewState: viewState,
        adapter: _adapter,
        counts: projection.counts,
        onEditColumns: showColumnChooserFlow,
        columnFavoritePresets: _columnFavoritePresets,
        activeColumnFavoriteLabel: _activeColumnFavoriteLabel,
        onColumnFavoriteSelected: _applyColumnFavorite,
        pinnedColumnFavoriteKeys: _pinnedColumnFavoriteKeys,
        onEditSort: showSortDialogFlow,
        onSidebarVisibilityChanged: _setGroupingPanelVisibility,
        onViewModeChanged: (mode) => _updateViewState(
          (state) => state.copyWith(viewMode: mode),
        ),
        browserMode: _activeBrowserMode,
        supportsMediaReleaseSplit: _supportsMediaReleaseSplit,
        onBrowserModeChanged: _setBrowserMode,
        showReleaseFolderBack: widget.type.shouldShowReleaseFolderBack(
          browserMode: _activeBrowserMode,
          releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
        ),
        releaseFolderLabel: _releaseFolderLabelForProjection(projection),
        onReleaseFolderBack: widget.type.shouldShowReleaseFolderBack(
          browserMode: _activeBrowserMode,
          releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
        )
            ? _closeReleaseFolder
            : null,
        onDetailsLayoutChanged: (layout) => _updateViewState(
          (state) => state.copyWith(detailsLayout: layout),
        ),
        onCoverSizeChanged: (size) => _updateViewState(
          (state) => state.copyWith(coverSize: size),
        ),
        selectedBucket: _linkedMetadataFilter?.chipLabel ?? _selectedBucket,
        onClearBucket: _clearToolbarSearchChip,
        quickView: _quickView,
        activeSortFavoriteId: _activeSortFavorite?.id,
        sortFavorites: _sortFavorites,
        onSortFavoriteSelected: _applySortFavorite,
        pinnedSortFavoriteIds: _pinnedSortFavoriteIds,
        onTogglePinnedSortFavorite: _togglePinnedSortFavorite,
        onManageSortFavorites: showSortFavoritesManagerFlow,
        hasActiveFilters: _hasActiveFilter,
        onQuickViewSelected: (view) =>
            _setQuickView(_quickView == view ? null : view),
        onClearFilters: _clearFilters,
        onEditFilters: () => showFilterDialogFlow(projection),
        activeFilterCount: _filterSelection.activeFilterCount,
        onRandomPick: projection.filteredItems.isNotEmpty
            ? () => pickRandomItemFlow(projection)
            : null,
        onDownloadAllCovers: () => downloadAllCoversFlow(shelfState),
        shelfState: shelfState,
        onSmartLists: () => showSmartListsFlow(shelfState),
        onFolders: showUserFoldersFlow,
        onReadingQueue:
            widget.type.supportsReadingQueue ? showReadingQueueFlow : null,
        onEditConditionPickList: widget.type.hasConditionPickList
            ? showConditionPickListEditorFlow
            : null,
        onEditGradePickList:
            widget.type.hasGradePickList ? showGradePickListEditorFlow : null,
        onEditTagPickList: showTagPickListEditorFlow,
        onTransferFieldData: _hasOwnedItemsInProjection(projection)
            ? () => showTransferFieldDataFlow(projection)
            : null,
        onReassignIndex: widget.type.supportsIndexReassignment &&
                _hasOwnedItemsInProjection(projection)
            ? () => reassignIndexFlow(projection)
            : null,
        onPrintReport: projection.filteredItems.isNotEmpty
            ? () => printReportFlow(projection)
            : null,
        onShareCollection: projection.filteredItems.isNotEmpty
            ? () => shareCollectionFlow(projection)
            : null,
        onCompareMetadataWithServer: (() {
          if (!widget.type.supportsMetadataCompareWithServer) {
            return null;
          }
          final selected = selectedProjectionItemFor(projection);
          if (selected == null || !canCompareMetadataWithServerItem(selected)) {
            return null;
          }
          return () => unawaited(
                compareMetadataWithServerFlow(
                  projection,
                  item: selected,
                ),
              );
        })(),
        groupMode: _activeSidebarGroupMode,
        folderPreset: _activeFolderPreset,
        availableGroupModes: _scopeAvailableGroupModes,
        pinnedFolderPresets: _pinnedFolderPresets,
        onPinnedFolderPresetsChanged: _setPinnedFolderPresets,
        onGroupModeChanged: _setFolderPreset,
        selectionCallbacks: viewState.viewMode == LibraryViewMode.cardFlow
            ? null
            : _selectionCallbacksForProjection(projection),
        selectedCount: viewState.viewMode == LibraryViewMode.cardFlow
            ? 0
            : _selection.selectedCount,
        totalSelectableCount: projection.filteredItems.length,
      ),
    );
  }

  LibrarySelectionCallbacks _selectionCallbacksForProjection(
    LibraryProjection? projection,
  ) {
    return (
      onClearSelection: () => setState(() {
            _selection = _selection.clear();
            _selectionAnchorId = null;
          }),
      onSelectAll: () {
        if (projection != null) {
          _selectAllVisible(projection);
        }
      },
      onBulkEdit: _hasOwnedItemsInSelection(projection)
          ? () => bulkEditFlow(projection)
          : null,
      onPrintToPdf: _hasSelectedItemsInSelection(projection)
          ? () => printSelectedReportFlow(projection)
          : null,
      onExportCsvTxt: _hasSelectedItemsInSelection(projection)
          ? () => shareSelectedCollectionFlow(projection)
          : null,
      onBulkDuplicate: _hasOwnedItemsInSelection(projection)
          ? () => bulkDuplicateFlow(projection)
          : null,
      onBulkLoan: _hasLoanableOwnedItemsInSelection(projection)
          ? () => showLoanSelectionFlow(projection)
          : null,
      onTransferFieldData: _hasOwnedItemsInSelection(projection)
          ? () => showTransferFieldDataForSelectionFlow(projection)
          : null,
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToOwned: _hasMoveToOwnedEligibleItemsInSelection(projection)
          ? () => bulkMoveToOwnedFlow(projection)
          : null,
      onBulkMoveToWishlist:
          _hasMoveToWishlistEligibleItemsInSelection(projection)
              ? () => bulkMoveToWishlistFlow(projection)
              : null,
      onBulkRemove: _hasRemovableItemsInSelection(projection)
          ? () => bulkRemoveFlow(projection)
          : null,
      onBulkRefreshMetadata: _hasSelectedItemsInSelection(projection)
          ? () => bulkRefreshMetadataFlow(projection)
          : null,
    );
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
    if (projection == null ||
        !widget.type.supportsSeriesIssueJump ||
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
      _appliedSearchQuery = '';
      _searchPinnedItemId = null;
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

  Future<void> _loadCustomFieldValuesForCurrentKind() {
    final loadToken = ++_customFieldLoadToken;
    final expectedKind = widget.type.workspace.kind.apiValue;
    return loadCustomFieldValues(
      mediaKind: expectedKind,
      canApply: () {
        return mounted &&
            loadToken == _customFieldLoadToken &&
            widget.type.workspace.kind.apiValue == expectedKind;
      },
    );
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
      _appliedSearchQuery = '';
      _searchPinnedItemId = null;
    });
    _syncRouteState();
  }

  void _selectItem(String id) {
    _LibrarySelectionControllerOps.selectItem(this, id);
  }

  void _activateItem(String id) {
    _LibrarySelectionControllerOps.activateItem(this, id);
  }

  void _toggleSelectionItem(String id) {
    _LibrarySelectionControllerOps.toggleSelectionItem(this, id);
  }

  void _applySelection(Set<String> ids, String focusedId) {
    _LibrarySelectionControllerOps.applySelection(this, ids, focusedId);
  }

  void _selectAllVisible(LibraryProjection projection) {
    _LibrarySelectionControllerOps.selectAllVisible(this, projection);
  }

  void _removeVisibleSelection(LibraryProjection projection) {
    _LibrarySelectionControllerOps.removeVisibleSelection(this, projection);
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
    if (_videoShelfDrilldownTitleItemId != null) {
      setState(() {
        _videoShelfDrilldownTitleItemId = null;
        _videoShelfDrilldownReleaseId = null;
      });
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
    return libraryGroupModeSupportsBucketManagement(widget.type, mode);
  }

  @protected
  bool canOpenDefaultVideoShelfDrilldown(LibraryProjectionItem item) {
    return _canOpenVideoShelfDrilldown(item);
  }

  @protected
  bool canOpenItemDetailDrilldown(LibraryProjectionItem item) {
    return false;
  }

  @protected
  void openDefaultVideoShelfDrilldown(LibraryProjectionItem item) {
    _openVideoShelfDrilldown(item);
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
    return _buildVideoShelfDrilldown(
      projection,
      viewState,
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
          .getTypedMetadataItemDto(
            kind: widget.type.workspace.kind.apiValue,
            id: itemId,
          )
          .then((dto) => dto.toCatalogItem());
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
