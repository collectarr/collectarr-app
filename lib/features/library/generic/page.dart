import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
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
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/column_chooser.dart';
import 'package:collectarr_app/features/library/generic/collection_actions.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/metadata_refresh.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/reading_queue_dialog.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/library_item_context_menu.dart';
import 'package:collectarr_app/features/library/workspace/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:collectarr_app/features/settings/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/settings/pick_list_options.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

part 'page_edit_handler.dart';
part 'page_dialogs.dart';
part 'page_collection_actions.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({
    super.key,
    required this.type,
    required this.topBar,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final Widget topBar;
  final Color accent;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with LibraryPageUtilities {
  final _searchController = TextEditingController();
  LibraryWorkspaceViewState? _viewState;
  String? _selectedId;
  String? _selectedBucket;
  String? _selectedLetter;
  LibraryLinkedMetadataFilter? _linkedMetadataFilter;
  LibraryQuickView? _quickView;
  LibraryGroupMode? _groupMode;
  var _selection = LibrarySelectionState.empty();
  var _filterSelection = LibraryFilterSelection.none;
  final _detailHydrationInFlight = <String>{};
  final _facetBucketsByMode = <LibraryGroupMode, FacetBuckets>{};
  final _facetLoadsInFlight = <LibraryGroupMode>{};
  Set<String> _activeLoanOwnedItemIds = const {};

  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.workspace.kind);

  @override
  void initState() {
    super.initState();
    _viewState = _adapter.viewProfile.defaults();
    unawaited(_loadViewState());
    unawaited(_loadViewPreferences());
    unawaited(
      loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue),
    );
    unawaited(_loadActiveLoanIds());
  }

  Future<void> _loadViewPreferences() async {
    final quickView = await _viewPrefs.readQuickView();
    final groupMode = await _viewPrefs.readGroupMode();
    if (!mounted) return;
    setState(() {
      _quickView = quickView;
      _groupMode = groupMode;
    });
  }

  @override
  void didUpdateWidget(covariant LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.workspace.kind != widget.type.workspace.kind) {
      _selectedId = null;
      _selectedBucket = null;
      _selectedLetter = null;
      _linkedMetadataFilter = null;
      _quickView = null;
      _groupMode = null;
      _facetBucketsByMode.clear();
      _facetLoadsInFlight.clear();
      _searchController.clear();
      _viewState = _adapter.viewProfile.defaults().withChrome(
            _viewState?.toPreferenceSnapshot().chrome,
          );
      unawaited(_loadViewState());
      unawaited(_loadViewPreferences());
      unawaited(
        loadCustomFieldValues(mediaKind: widget.type.workspace.kind.apiValue),
      );
      unawaited(_loadActiveLoanIds());
    }
  }

  Future<void> _loadActiveLoanIds() async {
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
    return Scaffold(
        backgroundColor: kAppCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              widget.topBar,
              LibraryToolbar(
                type: widget.type,
                searchController: _searchController,
                viewState: viewState,
                adapter: _adapter,
                onAdd: () => showAddDialogFlow(),
                onScan: scanBarcodeFlow,
                onSearchChanged: (value) => setState(() {}),
                onEditColumns: showColumnChooserFlow,
                onSortChanged: (column) => _updateViewState(
                  (state) => state.withSortColumn(column, _adapter.viewProfile),
                ),
                onEditSort: showSortDialogFlow,
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
                onRefreshMetadata: () => showMetadataRefreshFlow(
                  projection,
                ),
                quickView: _quickView,
                onQuickViewSelected: (view) {
                  final next = _quickView == view ? null : view;
                  setState(() => _quickView = next);
                  unawaited(_viewPrefs.writeQuickView(next));
                },
                hasActiveFilters: _hasActiveFilter,
                onClearFilters: _clearFilters,
                onEditFilters: () => showFilterDialogFlow(projection),
                activeFilterCount: _filterSelection.activeFilterCount,
                onRandomPick:
                    projection != null && projection.filteredItems.isNotEmpty
                        ? () => pickRandomItemFlow(projection)
                        : null,
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
                onReadingQueue: libraryShowsReadingQueue(widget.type.workspace.kind)
                  ? showReadingQueueFlow
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
                selectionCallbacks: (
                  onSelectionModeChanged: (enabled) => setState(
                      () => _selection = _selection.setEnabled(enabled)),
                  onClearSelection: () =>
                      setState(() => _selection = _selection.clear()),
                  onBulkEdit: () => bulkEditFlow(projection),
                  onBulkMoveToOwned: () => bulkMoveToOwnedFlow(projection),
                  onBulkMoveToWishlist: () => bulkMoveToWishlistFlow(projection),
                  onBulkRemove: () => bulkRemoveFlow(projection),
                ),
              ),
              Expanded(
                child: shelf.when(
                  data: (state) => _buildBody(
                    projection ?? _projectionForShelf(state, viewState),
                    viewState,
                  ),
                  error: (error, _) => Center(child: Text(error.toString())),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildBody(
    LibraryProjection projection,
    LibraryWorkspaceViewState viewState,
  ) {
    return LibraryBody(
      type: widget.type,
      adapter: _adapter,
      projection: projection,
      viewState: viewState,
      selectedId: _selectedId,
      selectedBucket: _selectedBucket,
      groupMode: _activeGroupMode,
      groupLoading: _facetLoadsInFlight.contains(_activeGroupMode),
      accent: widget.accent,
      hasActiveFilter: _hasActiveFilter,
      onAdd: () => showAddDialogFlow(),
      onClearFilters: _clearFilters,
      selectionEnabled: _selection.enabled,
      selectedItemIds: _selection.itemIds,
      onSelectItem: (id) {
        if (_selection.enabled) {
          setState(() => _selection = _selection.toggle(id));
        } else {
          _selectItem(id);
        }
      },
      onBoxSelectionChanged: (ids) => setState(
        () => _selection = _selection.replace(ids),
      ),
      onBucketChanged: (bucket) => setState(() => _selectedBucket = bucket),
      onGroupModeChanged: (mode) {
        setState(() {
          _groupMode = mode;
          _selectedBucket = null;
          final shelfState = ref.read(shelfProvider).asData?.value;
          if (shelfState != null) {
            _ensureFacetBucketsLoaded(shelfState, mode);
          }
        });
        unawaited(_viewPrefs.writeGroupMode(mode));
      },
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
      onDetailsWidthChanged: (width) => _updateViewState(
        (state) => state.copyWith(detailsWidth: width),
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
      onEditItem: (item, ownedItem) => unawaited(showEditDialog(item, ownedItem)),
      onItemContextMenu: handleItemContextMenu,
      onFilterByValue: (value) => setState(() {
        _linkedMetadataFilter =
            _linkedMetadataFilter?.value == value
                ? null
                : LibraryLinkedMetadataFilter(value: value);
        _selectedBucket = null;
        _selectedLetter = null;
      }),
      selectedLetter: _selectedLetter,
      availableLetters: LibraryAlphaJumpBar.lettersFromTitles(
        projection.filteredItems.map((i) => i.entry.title),
      ),
      onLetterSelected: (letter) => setState(() => _selectedLetter = letter),
      db: ref.read(localDatabaseProvider),
    );
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
      viewState: viewState,
      query: _searchController.text,
      linkedMetadataFilter: _linkedMetadataFilter,
      selectedBucket: _usesExternalFacetBuckets(mode) ? null : _selectedBucket,
      selectedItemId: _selectedId,
      quickView: _quickView,
      groupMode: mode,
      overrideBuckets: facetBuckets?.buckets,
      constrainedItemIds: constrainedItemIds,
      filterSelection: _filterSelection,
      customFieldValuesByItem: customFieldValuesByItem,
      customFieldValuesByDefinitionByItem:
          customFieldValuesByDefinitionByItem,
      activeLoanOwnedItemIds: _activeLoanOwnedItemIds,
    );
  }

  LibraryGroupMode get _activeGroupMode =>
      _groupMode ?? libraryDefaultGroupMode(widget.type);

  bool get _hasActiveFilter =>
      _searchController.text.trim().isNotEmpty ||
      _linkedMetadataFilter != null ||
      _selectedBucket != null ||
      _quickView != null ||
      _filterSelection.hasActiveFilters;

  bool _usesExternalFacetBuckets(LibraryGroupMode mode) {
    if (widget.type.workspace.kind != CatalogMediaKind.comic) {
      return false;
    }
    return mode == LibraryGroupMode.storyArc ||
        mode == LibraryGroupMode.character;
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
      );
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
      debugPrint('Facet load failed for $mode: $e\n$st');
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

  void _clearFilters() {
    setState(() {
      _selectedBucket = null;
      _linkedMetadataFilter = null;
      _quickView = null;
      _filterSelection = LibraryFilterSelection.none;
      _searchController.clear();
    });
  }

  void _clearToolbarSearchChip() {
    setState(() {
      if (_linkedMetadataFilter != null) {
        _linkedMetadataFilter = null;
      } else {
        _selectedBucket = null;
      }
    });
  }

  Future<void> _loadViewState() async {
    final state = await _adapter.viewProfile.load();
    if (mounted) {
      setState(() => _viewState = state);
    }
  }

  void _updateViewState(
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState state) update,
  ) {
    final next = update(_viewState ?? _adapter.viewProfile.defaults());
    setState(() => _viewState = next);
    unawaited(_adapter.viewProfile.save(next));
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
      _quickView = null;
      _filterSelection = LibraryFilterSelection.none;
      _searchController.clear();
    });
  }

  void _selectItem(String id) {
    setState(() => _selectedId = id);
    if (widget.type.capabilities.showsTrackData) {
      unawaited(_hydrateSelectedItem(id));
    }
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
    } catch (_) {
      // Keep the local snapshot when detail hydration is unavailable.
    } finally {
      _detailHydrationInFlight.remove(itemId);
    }
  }
}
