import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/generic_library_body.dart';
import 'package:collectarr_app/features/library/generic_library_column_chooser.dart';
import 'package:collectarr_app/features/library/generic_library_collection_actions.dart';
import 'package:collectarr_app/features/library/edit/generic_library_edit_dialog.dart';
import 'package:collectarr_app/features/library/generic_library_metadata_refresh.dart';
import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/generic_library_toolbar.dart';
import 'package:collectarr_app/features/library/library_media_adapter.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class GenericLibraryPage extends ConsumerStatefulWidget {
  const GenericLibraryPage({
    super.key,
    required this.type,
    required this.topBar,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final Widget topBar;
  final Color accent;

  @override
  ConsumerState<GenericLibraryPage> createState() => _GenericLibraryPageState();
}

class _GenericLibraryPageState extends ConsumerState<GenericLibraryPage> {
  final _searchController = TextEditingController();
  LibraryWorkspaceViewState? _viewState;
  String? _selectedId;
  String? _selectedBucket;
  GenericQuickView? _quickView;
  GenericLibraryGroupMode? _groupMode;
  Map<String, List<String>> _customFieldValuesByItem = const {};
  var _selection = LibrarySelectionState.empty();

  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  @override
  void initState() {
    super.initState();
    _viewState = _adapter.viewProfile.defaults();
    unawaited(_loadViewState());
    unawaited(_loadCustomFieldValues());
  }

  @override
  void didUpdateWidget(covariant GenericLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.workspace.kind != widget.type.workspace.kind) {
      _selectedId = null;
      _selectedBucket = null;
      _quickView = null;
      _groupMode = null;
      _searchController.clear();
      _viewState = _adapter.viewProfile.defaults().withChrome(
            _viewState?.toPreferenceSnapshot().chrome,
          );
      unawaited(_loadViewState());
      unawaited(_loadCustomFieldValues());
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
    ref.listen(shelfProvider, (_, __) => unawaited(_loadCustomFieldValues()));
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
    final shelfState = shelf.asData?.value;
    final projection = shelfState == null
        ? null
        : _projectionForShelf(
            shelfState,
            viewState,
          );
    return Theme(
      data: kClzComicsTheme,
      child: Scaffold(
        backgroundColor: kClzCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              widget.topBar,
              GenericLibraryToolbar(
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
                onViewPresetSelected: (preset) => _updateViewState(
                  (state) => state.withPreset(preset, _adapter.viewProfile),
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
                onQuickViewSelected: (view) => setState(() {
                  _quickView = _quickView == view ? null : view;
                }),
                hasActiveFilters: _hasActiveFilter,
                onClearFilters: _clearFilters,
                onRandomPick: projection != null &&
                        projection.filteredItems.isNotEmpty
                    ? () => _pickRandomItem(projection)
                    : null,
                counts: projection?.counts ?? const GenericToolbarCounts(),
                shelfState: shelfState,
                selectionEnabled: _selection.enabled,
                selectedCount: _selection.selectedCount,
                selectionCallbacks: (
                  onSelectionModeChanged: (enabled) =>
                      setState(() => _selection = _selection.setEnabled(enabled)),
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
      ),
    );
  }

  Widget _buildBody(
    GenericLibraryProjection projection,
    LibraryWorkspaceViewState viewState,
  ) {
    return GenericLibraryBody(
      type: widget.type,
      adapter: _adapter,
      projection: projection,
      viewState: viewState,
      selectedId: _selectedId,
      selectedBucket: _selectedBucket,
      groupMode: _activeGroupMode,
      accent: widget.accent,
      hasActiveFilter: _hasActiveFilter,
      onAdd: () => _showAddDialog(),
      onClearFilters: _clearFilters,
      onSelectItem: (id) {
        if (_selection.enabled) {
          setState(() => _selection = _selection.toggle(id));
        } else {
          setState(() => _selectedId = id);
        }
      },
      onBucketChanged: (bucket) => setState(() => _selectedBucket = bucket),
      onGroupModeChanged: (mode) => setState(() {
        _groupMode = mode;
        _selectedBucket = null;
      }),
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
      onRemoveOwned: (item) => _runCollectionAction(
        (actions) => actions.removeOwned(item),
      ),
      onAddWishlist: (item) => _runCollectionAction(
        (actions) => actions.addWishlist(item),
      ),
      onRemoveWishlist: (item) => _runCollectionAction(
        (actions) => actions.removeWishlist(item),
      ),
      onEditItem: (item) => unawaited(_showEditDialog(item)),
      onFilterByValue: (value) => setState(() {
        _searchController.text = value;
      }),
      db: ref.read(localDatabaseProvider),
    );
  }

  GenericLibraryProjection _projectionForShelf(
    ShelfState shelf,
    LibraryWorkspaceViewState viewState,
  ) {
    return GenericLibraryProjection.fromShelf(
      shelf: shelf,
      type: widget.type,
      viewState: viewState,
      query: _searchController.text,
      selectedBucket: _selectedBucket,
      selectedItemId: _selectedId,
      quickView: _quickView,
      groupMode: _activeGroupMode,
      customFieldValuesByItem: _customFieldValuesByItem,
    );
  }

  GenericLibraryGroupMode get _activeGroupMode =>
      _groupMode ?? genericDefaultGroupMode(widget.type);

  bool get _hasActiveFilter =>
      _searchController.text.trim().isNotEmpty ||
      _selectedBucket != null ||
      _quickView != null;

  void _clearFilters() {
    setState(() {
      _selectedBucket = null;
      _quickView = null;
      _searchController.clear();
    });
  }

  void _pickRandomItem(GenericLibraryProjection projection) {
    final items = projection.filteredItems;
    if (items.isEmpty) return;
    final random = items[_random.nextInt(items.length)];
    setState(() => _selectedId = random.entry.id);
  }

  static final _random = math.Random();

  Future<void> _loadViewState() async {
    final state = await _adapter.viewProfile.load();
    if (mounted) {
      setState(() => _viewState = state);
    }
  }

  Future<void> _loadCustomFieldValues() async {
    final db = ref.read(localDatabaseProvider);
    final repo = CustomFieldRepository(db);
    final allValues = await repo.listAllValues();
    final flat = <String, List<String>>{};
    for (final entry in allValues.entries) {
      flat[entry.key] = [
        for (final v in entry.value)
          if (v.value != null && v.value!.trim().isNotEmpty) v.value!,
      ];
    }
    if (mounted) {
      setState(() => _customFieldValuesByItem = flat);
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
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => LibraryAddDialog(
        type: widget.type,
        initialQuery: _searchController.text,
        initialBarcode: barcode,
      ),
    );
    if (added == true && mounted) {
      ref.invalidate(shelfProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.type.singularLabel} added')),
      );
    }
  }

  Future<void> _showEditDialog(GenericLibraryItem item) async {
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
    final images = owned != null
        ? await itemImageRepo.listForItem(owned.id)
        : <dynamic>[];
    if (!mounted) return;
    final result = await showDialog<GenericLibraryEditSelection>(
      context: context,
      builder: (context) => GenericLibraryEditDialog(
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
        coverPriceCents: personal.coverPriceCents ?? owned.coverPriceCents,
        rawOrSlabbed: personal.rawOrSlabbed ?? owned.rawOrSlabbed,
        gradingCompany: personal.gradingCompany ?? owned.gradingCompany,
        graderNotes: personal.graderNotes ?? owned.graderNotes,
        signedBy: personal.signedBy ?? owned.signedBy,
        keyComic: personal.keyComic ?? owned.keyComic,
        keyReason: personal.keyReason ?? owned.keyReason,
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
    unawaited(_loadCustomFieldValues());
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
    GenericLibraryProjection? projection,
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
    Future<void> Function(GenericLibraryCollectionActions actions) action,
  ) async {
    await action(ref.read(genericLibraryCollectionActionsProvider));
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _bulkEdit(GenericLibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final selection = await showDialog<LibraryBulkEditSelection>(
      context: context,
      builder: (context) => LibraryBulkEditDialog(
        type: widget.type,
        selectedCount: _selection.selectedCount,
      ),
    );
    if (selection == null || !mounted) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final actions = LibraryBulkActions(ref.read(collectionMutationsProvider));
    await actions.editSelected(entries: entries, selection: selection);
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> _bulkMoveToOwned(GenericLibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final actions = LibraryBulkActions(ref.read(collectionMutationsProvider));
    await actions.moveSelectedToOwned(
      entries,
      defaultCondition: widget.type.defaultCondition,
      defaultGrade: widget.type.defaultGrade,
    );
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> _bulkMoveToWishlist(GenericLibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final actions = LibraryBulkActions(ref.read(collectionMutationsProvider));
    await actions.moveSelectedToWishlist(entries);
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }

  Future<void> _bulkRemove(GenericLibraryProjection? projection) async {
    if (projection == null || _selection.itemIds.isEmpty) return;
    final entries = selectedShelfEntries(
      projection.filteredItems,
      _selection.itemIds,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove selected items?'),
        content: Text(
          'This removes ${entries.length} selected item${entries.length == 1 ? '' : 's'} from the local shelf and queues the change for sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final actions = LibraryBulkActions(ref.read(collectionMutationsProvider));
    await actions.removeSelected(entries);
    setState(() => _selection = _selection.clear());
    ref.invalidate(shelfProvider);
  }
}
