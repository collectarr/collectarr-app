import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/services/image_download_service.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_launcher.dart';
import 'package:collectarr_app/features/library/config/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/column_chooser.dart';
import 'package:collectarr_app/features/library/generic/collection_actions.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/metadata_refresh.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/reports/collection_report.dart';
import 'package:collectarr_app/features/library/sharing/collection_share_dialog.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/config/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/library_item_context_menu.dart';
import 'package:collectarr_app/features/library/workspace/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  LibraryQuickView? _quickView;
  LibraryGroupMode? _groupMode;
  var _selection = LibrarySelectionState.empty();
  var _filterSelection = LibraryFilterSelection.none;
  final _detailHydrationInFlight = <String>{};
  final _facetBucketsByMode = <LibraryGroupMode, FacetBuckets>{};
  final _facetLoadsInFlight = <LibraryGroupMode>{};

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
    unawaited(loadCustomFieldValues());
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
      unawaited(loadCustomFieldValues());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    ref.listen<AsyncValue<ShelfState>>(shelfProvider, (_, next) {
      unawaited(loadCustomFieldValues());
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
        backgroundColor: kClzCanvas,
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
                onAdd: () => _showAddDialog(),
                onScan: _scanBarcode,
                onSearchChanged: (value) => setState(() {}),
                onEditColumns: _showColumnChooser,
                onSortChanged: (column) => _updateViewState(
                  (state) => state.withSortColumn(column, _adapter.viewProfile),
                ),
                onViewModeChanged: (mode) => _updateViewState(
                  (state) => state.copyWith(viewMode: mode),
                ),
                onDetailsLayoutChanged: (layout) => _updateViewState(
                  (state) => state.copyWith(detailsLayout: layout),
                ),
                onCoverSizeChanged: (size) => _updateViewState(
                  (state) => state.copyWith(coverSize: size),
                ),
                selectedBucket: _selectedBucket,
                onClearBucket: () => setState(() => _selectedBucket = null),
                onRefreshMetadata: () => _showMetadataRefreshDialog(
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
                onEditFilters: () => _showFilterDialog(projection),
                activeFilterCount: _filterSelection.activeFilterCount,
                onRandomPick:
                    projection != null && projection.filteredItems.isNotEmpty
                        ? () => _pickRandomItem(projection)
                        : null,
                onDownloadAllCovers: shelfState != null
                    ? () => _downloadAllCovers(shelfState)
                    : null,
                counts: projection?.counts ?? const LibraryToolbarCounts(),
                shelfState: shelfState,
                onSmartLists: () => _showSmartLists(shelfState),
                onPrintReport: projection != null &&
                        projection.filteredItems.isNotEmpty
                    ? () => _printReport(projection)
                    : null,
                onShareCollection: projection != null &&
                        projection.filteredItems.isNotEmpty
                    ? () => _shareCollection(projection)
                    : null,
                selectionEnabled: _selection.enabled,
                selectedCount: _selection.selectedCount,
                selectionCallbacks: (
                  onSelectionModeChanged: (enabled) => setState(
                      () => _selection = _selection.setEnabled(enabled)),
                  onClearSelection: () =>
                      setState(() => _selection = _selection.clear()),
                  onBulkEdit: () => _bulkEdit(projection),
                  onBulkMoveToOwned: () => _bulkMoveToOwned(projection),
                  onBulkMoveToWishlist: () => _bulkMoveToWishlist(projection),
                  onBulkRemove: () => _bulkRemove(projection),
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
      onAdd: () => _showAddDialog(),
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
      onAddOwned: (item) => _runCollectionAction(
        (actions) => actions.addOwned(item),
      ),
      onRemoveOwned: _confirmRemoveOwned,
      onAddWishlist: (item) => _runCollectionAction(
        (actions) => actions.addWishlist(item),
      ),
      onRemoveWishlist: (item) => _runCollectionAction(
        (actions) => actions.removeWishlist(item),
      ),
      onEditItem: (item) => unawaited(_showEditDialog(item)),
      onItemContextMenu: _handleItemContextMenu,
      onFilterByValue: (value) => setState(() {
        _searchController.text = value;
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
      selectedBucket: _usesExternalFacetBuckets(mode) ? null : _selectedBucket,
      selectedItemId: _selectedId,
      quickView: _quickView,
      groupMode: mode,
      overrideBuckets: facetBuckets?.buckets,
      constrainedItemIds: constrainedItemIds,
      filterSelection: _filterSelection,
      customFieldValuesByItem: customFieldValuesByItem,
    );
  }

  LibraryGroupMode get _activeGroupMode =>
      _groupMode ?? libraryDefaultGroupMode(widget.type);

  bool get _hasActiveFilter =>
      _searchController.text.trim().isNotEmpty ||
      _selectedBucket != null ||
      _quickView != null ||
      _filterSelection.hasActiveFilters;

  bool _usesExternalFacetBuckets(LibraryGroupMode mode) {
    if (widget.type.workspace.kind != 'comic') {
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
      _quickView = null;
      _filterSelection = LibraryFilterSelection.none;
      _searchController.clear();
    });
  }

  Future<void> _showFilterDialog(
    LibraryProjection? projection,
  ) async {
    final allEntries = projection?.allItems
            .map((i) => i.entry)
            .toList(growable: false) ??
        const [];
    final options = LibraryFilterOptions.fromEntries(allEntries);
    final result = await showLibraryFilterDialog(
      context: context,
      type: widget.type,
      current: _filterSelection,
      options: options,
    );
    if (result != null && mounted) {
      setState(() => _filterSelection = result);
    }
  }

  Future<void> _showSmartLists(ShelfState? shelfState) async {
    final db = ref.read(localDatabaseProvider);
    final result = await showSmartListsDialog(
      context: context,
      db: db,
      mediaKind: widget.type.workspace.kind,
      currentFilter: _filterSelection,
      currentQuickView: _quickView,
      currentSortColumn: _viewState?.sortColumn,
      currentSortAscending: _viewState?.sortAscending,
      currentSearchQuery: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
    );
    if (result != null && mounted) {
      setState(() {
        _filterSelection = result.filterSelection;
        _quickView = result.quickView;
        if (result.searchQuery != null) {
          _searchController.text = result.searchQuery!;
        } else {
          _searchController.clear();
        }
        if (result.sortColumn != null && _viewState != null) {
          _viewState = _viewState!.copyWith(
            sortColumn: result.sortColumn,
            sortAscending: result.sortAscending ?? true,
          );
        }
      });
    }
  }

  void _printReport(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    printCollectionReport(
      title: widget.type.workspace.title,
      items: items,
    );
  }

  void _shareCollection(LibraryProjection projection) {
    final items = projection.filteredItems.map((i) => i.entry).toList();
    showCollectionShareDialog(
      context: context,
      title: widget.type.workspace.title,
      items: items,
    );
  }

  void _pickRandomItem(LibraryProjection projection) {
    final items = projection.filteredItems;
    if (items.isEmpty) return;
    final random = items[_random.nextInt(items.length)];
    _selectItem(random.entry.id);
  }

  Future<void> _downloadAllCovers(ShelfState shelfState) async {
    final db = ref.read(localDatabaseProvider);
    final imagesRepo = ItemImagesCacheRepository(db);
    final service = ImageDownloadService(imagesRepo: imagesRepo);

    // Build map: ownedItemId → coverUrl for items that have owned entries.
    final itemsToCover = <String, String?>{};
    for (final entry in shelfState.entries) {
      final ownedId = entry.ownedItem?.id;
      if (ownedId == null) continue;
      itemsToCover[ownedId] = entry.catalogItem?.displayCoverUrl;
    }
    if (itemsToCover.isEmpty) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading covers for ${itemsToCover.length} items...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final results = await service.downloadCoversForItems(itemsToCover);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${results.length} covers.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  static final _random = math.Random();

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

  Future<void> _showColumnChooser() async {
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

  Future<void> _showAddDialog({String? barcode}) async {
    final added = await showLibraryAddDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      initialQuery: _searchController.text,
      initialBarcode: barcode,
    );
    if (added == true && mounted) {
      ref.invalidate(shelfProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.type.singularLabel} added')),
      );
    }
  }

  Future<void> _handleItemContextMenu(
    LibraryProjectionItem item,
    Offset position,
  ) async {
    _selectItem(item.entry.id);
    final result = await showLibraryItemContextMenu(
      context: context,
      position: position,
      entry: item.entry,
      accent: widget.accent,
    );
    if (result == null || !mounted) return;
    switch (result.action) {
      case LibraryItemContextAction.edit:
        unawaited(_showEditDialog(item));
      case LibraryItemContextAction.addToOwned:
        await _runCollectionAction((a) => a.addOwned(item));
      case LibraryItemContextAction.removeFromOwned:
        await _confirmRemoveOwned(item);
      case LibraryItemContextAction.addToWishlist:
        await _runCollectionAction((a) => a.addWishlist(item));
      case LibraryItemContextAction.removeFromWishlist:
        await _runCollectionAction((a) => a.removeWishlist(item));
      case LibraryItemContextAction.copyTitle:
        await Clipboard.setData(ClipboardData(text: item.entry.title));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Title copied')),
          );
        }
      case LibraryItemContextAction.copyBarcode:
        final barcode = item.entry.barcode;
        if (barcode != null && barcode.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: barcode));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Barcode copied')),
            );
          }
        }
    }
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
            kind: widget.type.workspace.kind,
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

  Future<void> _showEditDialog(LibraryProjectionItem item) async {
    final catalogItem = item.source.catalogItem;
    if (catalogItem == null) {
      return;
    }
    final catalog = ref.read(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final db = ref.read(localDatabaseProvider);
    final customFieldRepo = CustomFieldRepository(db);
    final itemImageRepo = ItemImageRepository(db);
    final owned = item.source.ownedItem;
    final definitions = await customFieldRepo.listDefinitions(
      mediaKind: widget.type.workspace.kind,
    );
    final cfValues = owned != null
        ? await customFieldRepo.listValuesForItem(owned.id)
        : <dynamic>[];
    final images =
        owned != null ? await itemImageRepo.listForItem(owned.id) : <dynamic>[];
    if (!mounted) return;
    final result = await showLibraryEditDialog(
      context: context,
      request: LibraryEditDialogRequest(
        type: widget.type,
        item: catalogItem,
        ownedItem: owned,
        accent: widget.accent,
        physicalFormats: physicalMediaFormatsForKind(
          catalog,
          widget.type.workspace.kind,
        ),
        customFieldDefinitions: definitions,
        customFieldValues: cfValues.cast(),
        itemImages: images.cast(),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    final mutations = ref.read(collectionMutationsProvider);
    await mutations.updateCatalogSnapshot(
      result.catalogItem,
      notify: owned == null,
    );
    final personal = result.personal;
    if (owned != null && personal != null) {
      await mutations.updateItem(
        owned,
        condition: personal.condition,
        grade: personal.grade,
        purchaseDate: personal.purchaseDate,
        pricePaidCents: personal.pricePaidCents,
        currency: personal.currency,
        personalNotes: personal.personalNotes,
        quantity: personal.quantity,
        storageBox: personal.storageBox,
        indexNumber: owned.indexNumber,
        coverPriceCents: personal.coverPriceCents,
        rawOrSlabbed: personal.rawOrSlabbed,
        gradingCompany: personal.gradingCompany,
        graderNotes: personal.graderNotes,
        signedBy: personal.signedBy,
        keyComic: personal.keyComic,
        keyReason: personal.keyReason,
        rating: personal.rating,
        readStatus: personal.readStatus,
        startedAt: personal.startedAt,
        finishedAt: personal.finishedAt,
        tags: personal.tags,
        soldAt: personal.soldAt,
        sellPriceCents: personal.sellPriceCents,
        soldTo: personal.soldTo,
      );
      // Save custom field values
      final now = DateTime.now();
      final cfList = result.customFieldEdits.entries.map((e) {
        return CustomFieldValue(
          id: const Uuid().v4(),
          ownedItemId: owned.id,
          fieldDefinitionId: e.key,
          value: e.value,
          updatedAt: now,
        );
      }).toList();
      await customFieldRepo.upsertValues(cfList);
      // Save item image edits
      for (final edit in result.itemImageEdits) {
        if (edit.deleted) {
          await itemImageRepo.delete(edit.id);
        } else if (edit.imageData != null) {
          await itemImageRepo.add(ItemImage(
            id: edit.id,
            ownedItemId: owned.id,
            imageData: edit.imageData!,
            caption: edit.caption,
            sortOrder: edit.sortOrder,
            createdAt: now,
          ));
        } else {
          await itemImageRepo.updateCaption(edit.id, edit.caption);
        }
      }
    }
    if (!mounted) {
      return;
    }
    ref.invalidate(shelfProvider);
    unawaited(loadCustomFieldValues());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.type.singularLabel} updated')),
    );
  }

  Future<void> _scanBarcode() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BarcodeScanSheet(
        title: 'Scan ${widget.type.singularLabel.toLowerCase()} barcode',
        description:
            'Scan or enter a barcode, UPC, or ISBN. Collectarr will open Add ${widget.type.pluralLabel} with this code prefilled.',
        manualLabel: '${widget.type.singularLabel} barcode / UPC / ISBN',
        submitLabel: 'Continue to Add ${widget.type.pluralLabel}',
        leadingIcon: widget.type.workspace.icon,
      ),
    );
    if (code != null && mounted) {
      await _showAddDialog(barcode: code);
    }
  }

  Future<void> _showMetadataRefreshDialog(
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

  Future<void> _runCollectionAction(
    Future<void> Function(LibraryCollectionActions actions) action,
  ) async {
    await action(ref.read(genericLibraryCollectionActionsProvider));
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _confirmRemoveOwned(LibraryProjectionItem item) async {
    final confirmed = await confirmSingleRemove(
      context,
      title: item.entry.title,
      itemLabel: widget.type.singularLabel.toLowerCase(),
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _runCollectionAction((actions) => actions.removeOwned(item));
  }

  Future<void> _bulkEdit(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final selection = await showBulkEditDialog(
      context,
      type: widget.type,
      selectedCount: _selection.selectedCount,
    );
    if (selection == null || !mounted) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    await bulkActions().editSelected(entries: entries, selection: selection);
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> _bulkMoveToOwned(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    await bulkActions().moveSelectedToOwned(
      entries,
      defaultCondition: widget.type.defaultCondition,
      defaultGrade: widget.type.defaultGrade,
    );
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> _bulkMoveToWishlist(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    await bulkActions().moveSelectedToWishlist(entries);
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> _bulkRemove(LibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final confirmed = await confirmBulkRemove(
      context,
      count: entries.length,
      itemLabel: widget.type.pluralLabel.toLowerCase(),
    );
    if (!confirmed || !mounted) return;
    await bulkActions().removeSelected(entries);
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }
}
