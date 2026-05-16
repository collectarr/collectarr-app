import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/comics/comics_barcode_add_workflow.dart';
import 'package:collectarr_app/features/comics/comics_bulk_actions.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_filter_store.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_grouping_store.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_page_bulk_actions.dart';
import 'package:collectarr_app/features/comics/comics_page_dialogs.dart';
import 'package:collectarr_app/features/comics/comics_page_state.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/comics/comics_shelf_projection.dart';
import 'package:collectarr_app/features/comics/comics_workspace.dart';
import 'package:collectarr_app/features/comics/comics_workspace_projection.dart';
import 'package:collectarr_app/features/comics/comics_workspace_state.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
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

class _ComicsPageState extends ConsumerState<ComicsPage> {
  ComicsPageUiState pageState = ComicsPageUiState.initial();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: pageState.query);
    _loadViewPreferences();
    _loadFilterPreferences();
    _loadGroupingPreference();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);

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
                  ),
                ),
              );
              final entries = shelfProjection.entries;
              return ComicsWorkspace(
                shelfState: state,
                entries: entries,
                queryController: _controller,
                selectedItemId: uiState.selectedItemId,
                selectedGroup: uiState.selectedGroup,
                groupMode: uiState.groupMode,
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
    await showAddComicsDialog(context);
    if (mounted) {
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

  Future<void> _showBulkEditDialog(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final changed = await showComicsBulkEditDialog(
      context: context,
      actions: _bulkActions(),
      visibleEntries: visibleEntries,
      selectedItemIds: pageState.selectionState.itemIds,
    );
    if (changed && mounted) {
      _clearSelection();
    }
  }

  Future<void> _bulkMoveToOwned(List<ShelfEntry> visibleEntries) async {
    final changed = await moveSelectedComicsToOwned(
      actions: _bulkActions(),
      visibleEntries: visibleEntries,
      selectedItemIds: pageState.selectionState.itemIds,
    );
    if (changed && mounted) {
      _clearSelection();
    }
  }

  Future<void> _bulkMoveToWishlist(List<ShelfEntry> visibleEntries) async {
    final changed = await moveSelectedComicsToWishlist(
      actions: _bulkActions(),
      visibleEntries: visibleEntries,
      selectedItemIds: pageState.selectionState.itemIds,
    );
    if (changed && mounted) {
      _clearSelection();
    }
  }

  Future<void> _bulkRemove(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final changed = await confirmAndRemoveSelectedComics(
      context: context,
      actions: _bulkActions(),
      visibleEntries: visibleEntries,
      selectedItemIds: pageState.selectionState.itemIds,
    );
    if (changed && mounted) {
      _clearSelection();
    }
  }

  ComicsBulkActions _bulkActions() {
    return ComicsBulkActions(ref.read(collectionMutationsProvider));
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
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
