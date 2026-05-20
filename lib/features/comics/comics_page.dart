import 'dart:async';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/comics/comics_barcode_add_workflow.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_filter_store.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_grouping_store.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_page_dialogs.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/features/comics/comics_page_state.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_projection.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_state.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_page_utilities.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzCanvas = kClzCanvas;

final ThemeData _kClzComicsTheme = kClzComicsTheme;

class ComicsPage extends ConsumerStatefulWidget {
  const ComicsPage({
    super.key,
    this.onOpenLibraries,
    this.topBar,
  });

  final VoidCallback? onOpenLibraries;
  final Widget? topBar;

  @override
  ConsumerState<ComicsPage> createState() => _ComicsPageState();
}

class _ComicsPageState extends ConsumerState<ComicsPage>
    with LibraryPageUtilities {
  ComicsPageUiState pageState = ComicsPageUiState.initial();
  late final TextEditingController _controller;
  final _facetBucketsByMode = <ComicsShelfGroupMode, _ComicsFacetBuckets>{};
  final _facetLoadsInFlight = <ComicsShelfGroupMode>{};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: pageState.query);
    _loadViewPreferences();
    _loadFilterPreferences();
    _loadGroupingPreference();
    unawaited(loadCustomFieldValues());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    ref.listen(shelfProvider, (_, __) => unawaited(loadCustomFieldValues()));

    return Scaffold(
      backgroundColor: _kClzCanvas,
      body: SafeArea(
        bottom: false,
        child: Theme(
          data: _kClzComicsTheme,
          child: shelf.when(
            data: (state) {
              final uiState = pageState;
              final viewState = uiState.workspaceViewState;
              final shelfProjection = ref.watch(
                comicsShelfProjectionProvider(
                  ComicsShelfProjectionRequest(
                    state: state,
                    query: uiState.query,
                    filters: uiState.filterSelection,
                    customFieldValuesByItem: customFieldValuesByItem,
                  ),
                ),
              );
              final entries = shelfProjection.entries;
              _ensureFacetBucketsLoaded(state, uiState.groupMode);
              final facetBuckets = _facetBucketsForMode(uiState.groupMode);
              final usesExternalFacets =
                  _usesExternalFacetBuckets(uiState.groupMode);
              return ComicsWorkspace(
                shelfState: state,
                entries: entries,
                queryController: _controller,
                selectedItemId: uiState.selectedItemId,
                selectedGroup: uiState.selectedGroup,
                groupMode: uiState.groupMode,
                groupLoading: _facetLoadsInFlight.contains(uiState.groupMode),
                facetBuckets: usesExternalFacets
                    ? (facetBuckets?.buckets ?? const [])
                    : null,
                facetItemIdsByBucket: usesExternalFacets
                    ? (facetBuckets?.itemIdsByBucket ?? const {})
                    : null,
                viewMode: viewState.viewMode,
                detailsLayout: viewState.detailsLayout,
                sortColumn: viewState.sortColumn,
                sortAscending: viewState.sortAscending,
                coverSize: viewState.coverSize,
                sidebarWidth: viewState.sidebarWidth,
                detailsWidth: viewState.detailsWidth,
                visibleColumns: viewState.visibleColumns,
                columnWidths: viewState.columnWidths,
                selectionMode: uiState.selectionState.enabled,
                selectedItemIds: uiState.selectionState.itemIds,
                quickView: uiState.filterSelection.quickView,
                hasActiveFilters: shelfProjection.hasActiveFilters,
                activeFilterCount: uiState.filterSelection.activeFilterCount,
                onQuickViewSelected: _handleQuickViewSelected,
                onEditFilters: () => _showFiltersDialog(
                  context,
                  options: shelfProjection.filterOptions,
                ),
                onClearFilters: _clearFilters,
                onSearch: (value) =>
                    setState(() => pageState = pageState.withSearch(value)),
                onAddComic: () => _showAddComicDialog(context),
                onSelectItem: (item) {
                  if (pageState.selectionState.enabled) {
                    _toggleSelection(item.id);
                  } else {
                    setState(
                      () => pageState = pageState.withSelectedItem(item.id),
                    );
                  }
                },
                onSelectGroup: (group) => setState(
                  () => pageState = pageState.withSelectedGroup(group),
                ),
                onClearGroup: () => setState(
                  () => pageState = pageState.withoutSelectedGroup(),
                ),
                onGroupModeChanged: _handleGroupModeChanged,
                onScanBarcode: () => _handleBarcodeScan(context),
                onRefreshMetadata: () =>
                    _showMetadataRefreshDialog(context, state, entries),
                onEditColumns: () => _showColumnChooser(context),
                onViewModeChanged: _handleViewModeChanged,
                onDetailsLayoutChanged: _handleDetailsLayoutChanged,
                onViewPresetSelected: _handleViewPresetSelected,
                onSortChanged: _handleSortChanged,
                onColumnWidthChanged: _handleColumnWidthChanged,
                onColumnReordered: _handleColumnReordered,
                onCoverSizeChanged: _handleCoverSizeChanged,
                onSidebarWidthChanged: _handleSidebarWidthChanged,
                onDetailsWidthChanged: _handleDetailsWidthChanged,
                onSelectionModeChanged: _setSelectionMode,
                onClearSelection: _clearSelection,
                onBulkEdit: () => _showBulkEditDialog(context, entries),
                onBulkMoveToOwned: () => _bulkMoveToOwned(entries),
                onBulkMoveToWishlist: () => _bulkMoveToWishlist(entries),
                onBulkRemove: () => _bulkRemove(context, entries),
                onOpenLibraries: widget.onOpenLibraries,
                topBar: widget.topBar,
              );
            },
            error: (error, stackTrace) =>
                _ErrorState(message: error.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBarcodeScan(BuildContext context) async {
    final code = await showComicsBarcodeScanSheet(context);
    if (code == null || !context.mounted) {
      return;
    }

    try {
      final item = await addComicByBarcodeToCollection(
        api: ref.read(apiClientProvider),
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        mutations: ref.read(collectionMutationsProvider),
        barcode: code,
      );
      if (!mounted) {
        return;
      }
      ref.invalidate(shelfProvider);
      setState(() {
        pageState = pageState.withBarcodeAdded(item.id);
        _controller.clear();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${item.title} to local collection')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No metadata found for barcode $code')),
        );
      }
    }
  }

  Future<void> _showAddComicDialog(BuildContext context) async {
    final added = await showAddComicsDialog(context);
    if (added == true && mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _showFiltersDialog(
    BuildContext context, {
    required ComicsFilterOptions options,
  }) async {
    final selection = await showComicsFiltersDialog(
      context,
      initialSelection: pageState.filterSelection,
      options: options,
    );
    if (selection == null || !mounted) {
      return;
    }
    _setFilterSelection(selection);
  }

  void _toggleSelection(String itemId) {
    setState(() => pageState = pageState.withSelectionToggled(itemId));
  }

  void _setSelectionMode(bool value) {
    setState(() => pageState = pageState.withSelectionMode(value));
  }

  void _clearSelection() {
    setState(() => pageState = pageState.withoutSelection());
  }

  List<ShelfEntry> _selectedEntries(List<ShelfEntry> visibleEntries) {
    final ids = pageState.selectionState.itemIds;
    return [
      for (final entry in visibleEntries)
        if (ids.contains(entry.itemId)) entry,
    ];
  }

  Future<void> _showBulkEditDialog(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final entries = _selectedEntries(visibleEntries);
    if (entries.isEmpty) return;
    final selection = await showDialog<LibraryBulkEditSelection>(
      context: context,
      builder: (context) => LibraryBulkEditDialog(
        type: comicsLibraryConfig,
        selectedCount: entries.length,
      ),
    );
    if (selection == null || !mounted) return;
    await _bulkActions().editSelected(entries: entries, selection: selection);
    _clearSelection();
  }

  Future<void> _bulkMoveToOwned(List<ShelfEntry> visibleEntries) async {
    final entries = _selectedEntries(visibleEntries);
    if (entries.isEmpty) return;
    await _bulkActions().moveSelectedToOwned(
      entries,
      defaultCondition: comicsLibraryConfig.defaultCondition,
      defaultGrade: comicsLibraryConfig.defaultGrade,
    );
    if (mounted) _clearSelection();
  }

  Future<void> _bulkMoveToWishlist(List<ShelfEntry> visibleEntries) async {
    final entries = _selectedEntries(visibleEntries);
    if (entries.isEmpty) return;
    await _bulkActions().moveSelectedToWishlist(entries);
    if (mounted) _clearSelection();
  }

  Future<void> _bulkRemove(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final entries = _selectedEntries(visibleEntries);
    if (entries.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove selected comics?'),
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
    await _bulkActions().removeSelected(entries);
    _clearSelection();
  }

  LibraryBulkActions _bulkActions() {
    return LibraryBulkActions(ref.read(collectionMutationsProvider));
  }

  void _handleSortChanged(LibrarySortColumn column) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.withSortColumn(
        column,
        comicsWorkspaceViewProfile,
      ),
    );
  }

  void _handleViewModeChanged(LibraryViewMode value) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.copyWith(viewMode: value),
    );
  }

  void _handleDetailsLayoutChanged(LibraryDetailsLayout value) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.copyWith(detailsLayout: value),
    );
  }

  void _handleViewPresetSelected(LibraryWorkspacePreset preset) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.withPreset(
        preset,
        comicsWorkspaceViewProfile,
      ),
    );
  }

  void _handleCoverSizeChanged(double value) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.copyWith(coverSize: value),
    );
  }

  void _handleSidebarWidthChanged(double value) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.copyWith(sidebarWidth: value),
    );
  }

  void _handleDetailsWidthChanged(double value) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.copyWith(detailsWidth: value),
    );
  }

  void _handleVisibleColumnsChanged(Set<LibraryTableColumn> columns) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.copyWith(visibleColumns: columns),
    );
  }

  void _handleColumnWidthChanged(LibraryTableColumn column, double width) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.withColumnWidth(
        column,
        width,
        comicsWorkspaceViewProfile,
      ),
    );
  }

  void _handleColumnReordered(
    LibraryTableColumn column,
    LibraryTableColumn? beforeColumn,
  ) {
    _setWorkspaceViewState(
      pageState.workspaceViewState.withReorderedColumn(
        column: column,
        beforeColumn: beforeColumn,
      ),
    );
  }

  Future<void> _showColumnChooser(BuildContext context) async {
    final selected = await showComicsColumnChooserDialog(
      context,
      workspaceViewState: pageState.workspaceViewState,
    );
    if (selected != null) {
      _handleVisibleColumnsChanged(selected);
    }
  }

  Future<void> _showMetadataRefreshDialog(
    BuildContext context,
    ShelfState shelf,
    List<ShelfEntry> shownEntries,
  ) async {
    final allEntries = comicsShelfEntriesOnly(shelf.entries);
    final selectedEntry = _selectedShelfEntry(shownEntries);
    final workspaceEntriesById = {
      for (final entry in allEntries)
        entry.itemId: _workspaceEntryForShelf(entry),
    };
    final result = await showLibraryMetadataRefreshDialog(
      context: context,
      type: comicsLibraryConfig,
      accent: libraryAccentForKind(comicsLibraryConfig.workspace.kind),
      allEntries: workspaceEntriesById.values.toList(growable: false),
      shownEntries: [
        for (final entry in shownEntries)
          if (workspaceEntriesById[entry.itemId] != null)
            workspaceEntriesById[entry.itemId]!,
      ],
      selectedEntry: selectedEntry == null
          ? null
          : workspaceEntriesById[selectedEntry.itemId],
    );
    if (result == null || !context.mounted) {
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

  ShelfEntry? _selectedShelfEntry(List<ShelfEntry> entries) {
    final selectedId = pageState.selectedItemId;
    if (selectedId == null) {
      return entries.isEmpty ? null : entries.first;
    }
    for (final entry in entries) {
      if (entry.itemId == selectedId) {
        return entry;
      }
    }
    return entries.isEmpty ? null : entries.first;
  }

  LibraryWorkspaceEntry _workspaceEntryForShelf(ShelfEntry entry) {
    final item = entry.catalogItem ??
        CatalogItem(
          id: entry.itemId,
          kind: comicsLibraryConfig.workspace.kind,
          title: entry.title,
        );
    return comicWorkspaceEntry(item, entry.ownedItem, entry.wishlistItem);
  }

  Future<void> _loadViewPreferences() async {
    final preferences = await loadComicsWorkspaceViewState();
    if (!mounted) {
      return;
    }
    setState(
      () => pageState = pageState.copyWith(workspaceViewState: preferences),
    );
  }

  Future<void> _loadFilterPreferences() async {
    final filters = await const ComicsFilterPreferenceStore().read();
    if (!mounted) {
      return;
    }
    setState(
      () => pageState = pageState.copyWith(filterSelection: filters),
    );
  }

  void _setWorkspaceViewState(ComicsWorkspaceViewState next) {
    setState(
      () => pageState = pageState.copyWith(workspaceViewState: next),
    );
    saveComicsWorkspaceViewState(next);
  }

  void _clearFilters() {
    _setFilterSelection(ComicsFilterSelection.none);
  }

  void _handleQuickViewSelected(ComicsShelfQuickView view) {
    _setFilterSelection(view.filters);
  }

  void _setFilterSelection(ComicsFilterSelection next) {
    setState(() => pageState = pageState.withFilterSelection(next));
    const ComicsFilterPreferenceStore().write(next);
  }

  Future<void> _loadGroupingPreference() async {
    final mode = await const ComicsGroupingPreferenceStore().read();
    if (!mounted) {
      return;
    }
    setState(() => pageState = pageState.copyWith(groupMode: mode));
  }

  void _handleGroupModeChanged(ComicsShelfGroupMode mode) {
    setState(() => pageState = pageState.withGroupMode(mode));
    const ComicsGroupingPreferenceStore().write(mode);
    final shelfState = ref.read(shelfProvider).asData?.value;
    if (shelfState != null) {
      _ensureFacetBucketsLoaded(shelfState, mode);
    }
  }

  bool _usesExternalFacetBuckets(ComicsShelfGroupMode mode) {
    return mode == ComicsShelfGroupMode.storyArc ||
        mode == ComicsShelfGroupMode.character;
  }

  _ComicsFacetBuckets? _facetBucketsForMode(ComicsShelfGroupMode mode) {
    if (!_usesExternalFacetBuckets(mode)) {
      return null;
    }
    final state = ref.read(shelfProvider).asData?.value;
    if (state == null) {
      return null;
    }
    final cached = _facetBucketsByMode[mode];
    final signature = _shelfSignature(state);
    if (cached == null || cached.shelfSignature != signature) {
      return null;
    }
    return cached;
  }

  void _ensureFacetBucketsLoaded(
    ShelfState shelf,
    ComicsShelfGroupMode mode,
  ) {
    if (!_usesExternalFacetBuckets(mode) ||
        _facetLoadsInFlight.contains(mode)) {
      return;
    }
    final signature = _shelfSignature(shelf);
    final cached = _facetBucketsByMode[mode];
    if (cached != null && cached.shelfSignature == signature) {
      return;
    }
    _facetLoadsInFlight.add(mode);
    unawaited(_loadFacetBuckets(mode, shelf, signature));
  }

  Future<void> _loadFacetBuckets(
    ComicsShelfGroupMode mode,
    ShelfState shelf,
    String signature,
  ) async {
    try {
      final itemIds = {
        for (final entry in comicsShelfEntriesOnly(shelf.entries)) entry.itemId,
      };
      final rows = mode == ComicsShelfGroupMode.storyArc
          ? await ref.read(apiClientProvider).storyArcFacets(itemIds)
          : await ref.read(apiClientProvider).characterFacets(itemIds);
      final byBucket = <String, Set<String>>{};
      for (final row in rows) {
        final name = _rowText(row, 'name');
        if (name == null) {
          continue;
        }
        for (final itemId in _rowTextList(row, 'item_ids')) {
          if (itemIds.contains(itemId)) {
            byBucket.putIfAbsent(name, () => <String>{}).add(itemId);
          }
        }
      }
      final buckets = [
        for (final entry in byBucket.entries)
          LibrarySeriesBucket(title: entry.key, count: entry.value.length),
      ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      if (!mounted) {
        return;
      }
      final latestShelf = ref.read(shelfProvider).asData?.value;
      if (latestShelf == null || _shelfSignature(latestShelf) != signature) {
        return;
      }
      setState(() {
        _facetBucketsByMode[mode] = _ComicsFacetBuckets(
          shelfSignature: signature,
          buckets: buckets,
          itemIdsByBucket: byBucket,
        );
        if (pageState.groupMode == mode &&
            pageState.selectedGroup != null &&
            !buckets.any((bucket) => bucket.title == pageState.selectedGroup)) {
          pageState = pageState.withoutSelectedGroup();
        }
      });
    } catch (_) {
      // Keep the local shelf usable when optional metadata facets are unavailable.
    } finally {
      _facetLoadsInFlight.remove(mode);
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _shelfSignature(ShelfState shelf) {
    final ids = [
      for (final entry in comicsShelfEntriesOnly(shelf.entries)) entry.itemId,
    ]..sort();
    return ids.join('|');
  }

  String? _rowText(Map<String, dynamic> row, String key) =>
      LibraryPageUtilities.rowText(row, key);

  List<String> _rowTextList(Map<String, dynamic> row, String key) =>
      LibraryPageUtilities.rowTextList(row, key);
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _ComicsFacetBuckets {
  const _ComicsFacetBuckets({
    required this.shelfSignature,
    required this.buckets,
    required this.itemIdsByBucket,
  });

  final String shelfSignature;
  final List<LibrarySeriesBucket> buckets;
  final Map<String, Set<String>> itemIdsByBucket;
}
