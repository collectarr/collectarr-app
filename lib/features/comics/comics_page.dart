import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_dialog.dart';
import 'package:collectarr_app/features/comics/comics_bulk_actions.dart';
import 'package:collectarr_app/features/comics/comics_bulk_edit.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_page_selection_state.dart';
import 'package:collectarr_app/features/comics/comics_shelf_projection.dart';
import 'package:collectarr_app/features/comics/comics_workspace.dart';
import 'package:collectarr_app/features/comics/comics_workspace_state.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzCanvas = kClzCanvas;

final ThemeData _kClzComicsTheme = kClzComicsTheme;

class ComicsPage extends ConsumerStatefulWidget {
  const ComicsPage({super.key});

  @override
  ConsumerState<ComicsPage> createState() => _ComicsPageState();
}

class _ComicsPageState extends ConsumerState<ComicsPage> {
  String query = '';
  String? selectedItemId;
  String? selectedSeries;
  ComicsWorkspaceViewState workspaceViewState =
      comicsWorkspaceViewProfile.defaults();
  ComicsFilterSelection filterSelection = ComicsFilterSelection.none;
  ComicsPageSelectionState selectionState = ComicsPageSelectionState.empty();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: query);
    _loadViewPreferences();
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
              final viewState = workspaceViewState;
              final shelfProjection = projectComicsShelf(
                state: state,
                query: query,
                filters: filterSelection,
              );
              final entries = shelfProjection.entries;
              return ComicsWorkspace(
                shelfState: state,
                items: shelfProjection.items,
                queryController: _controller,
                selectedItemId: selectedItemId,
                selectedSeries: selectedSeries,
                viewMode: viewState.viewMode,
                detailsLayout: viewState.detailsLayout,
                sortColumn: viewState.sortColumn,
                sortAscending: viewState.sortAscending,
                coverSize: viewState.coverSize,
                visibleColumns: viewState.visibleColumns,
                columnWidths: viewState.columnWidths,
                selectionMode: selectionState.enabled,
                selectedItemIds: selectionState.itemIds,
                hasActiveFilters: shelfProjection.hasActiveFilters,
                onEditFilters: () => _showFiltersDialog(
                  context,
                  options: shelfProjection.filterOptions,
                ),
                onSearch: (value) => setState(() {
                  query = value.trim();
                  selectedItemId = null;
                  selectedSeries = null;
                }),
                onAddComic: () => _showAddComicDialog(context),
                onSelectItem: (item) {
                  if (selectionState.enabled) {
                    _toggleSelection(item.id);
                  } else {
                    setState(() => selectedItemId = item.id);
                  }
                },
                onSelectSeries: (series) => setState(() {
                  selectedSeries = series;
                  selectedItemId = null;
                }),
                onClearSeries: () => setState(() => selectedSeries = null),
                onScanBarcode: () => _handleBarcodeScan(context),
                onEditColumns: () => _showColumnChooser(context),
                onViewModeChanged: _handleViewModeChanged,
                onDetailsLayoutChanged: _handleDetailsLayoutChanged,
                onViewPresetSelected: _handleViewPresetSelected,
                onSortChanged: _handleSortChanged,
                onColumnWidthChanged: _handleColumnWidthChanged,
                onCoverSizeChanged: _handleCoverSizeChanged,
                onSelectionModeChanged: _setSelectionMode,
                onClearSelection: _clearSelection,
                onBulkEdit: () => _showBulkEditDialog(context, entries),
                onBulkMoveToOwned: () => _bulkMoveToOwned(entries),
                onBulkMoveToWishlist: () => _bulkMoveToWishlist(entries),
                onBulkRemove: () => _bulkRemove(context, entries),
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
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BarcodeScanSheet(),
    );
    if (code == null || !context.mounted) {
      return;
    }

    try {
      final result = await ref.read(apiClientProvider).lookupBarcode(
            code,
            kind: comicsLibraryConfig.workspace.kind,
          );
      final item = CatalogItem.fromJson(result);
      await CatalogCacheRepository(ref.read(localDatabaseProvider))
          .upsertAll([item]);
      await ref.read(collectionMutationsProvider).addItem(
            item.id,
            condition: 'Near Mint',
            grade: 'Ungraded',
          );
      ref.invalidate(shelfProvider);
      setState(() {
        query = '';
        selectedSeries = null;
        selectedItemId = item.id;
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
    await showDialog<void>(
      context: context,
      builder: (context) => const AddComicDialog(),
    );
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _showFiltersDialog(
    BuildContext context, {
    required ComicsFilterOptions options,
  }) async {
    final selection = await showDialog<ComicsFilterSelection>(
      context: context,
      builder: (context) => ComicsFilterDialog(
        initialSelection: filterSelection,
        gradeOptions: options.grades,
        conditionOptions: options.conditions,
        publisherOptions: options.publishers,
        releaseYearOptions: options.releaseYears,
      ),
    );
    if (selection == null || !mounted) {
      return;
    }
    setState(() {
      filterSelection = selection;
      selectedItemId = null;
      selectedSeries = null;
      selectionState = selectionState.clear();
    });
  }

  void _toggleSelection(String itemId) {
    setState(() => selectionState = selectionState.toggle(itemId));
  }

  void _setSelectionMode(bool value) {
    setState(() => selectionState = selectionState.setEnabled(value));
  }

  void _clearSelection() {
    setState(() => selectionState = selectionState.clear());
  }

  Future<void> _showBulkEditDialog(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final selection = await showDialog<ComicsBulkEditSelection>(
      context: context,
      builder: (context) => ComicsBulkEditDialog(
        conditions: ComicInspector.conditions,
        grades: ComicInspector.grades,
      ),
    );
    if (selection == null) {
      return;
    }
    await ComicsBulkActions(ref.read(collectionMutationsProvider)).editSelected(
      entries: selectedComicsShelfEntries(
        visibleEntries,
        selectionState.itemIds,
      ),
      selection: selection,
    );
    _clearSelection();
  }

  Future<void> _bulkMoveToOwned(List<ShelfEntry> visibleEntries) async {
    await ComicsBulkActions(ref.read(collectionMutationsProvider))
        .moveSelectedToOwned(
      selectedComicsShelfEntries(visibleEntries, selectionState.itemIds),
    );
    _clearSelection();
  }

  Future<void> _bulkMoveToWishlist(List<ShelfEntry> visibleEntries) async {
    await ComicsBulkActions(ref.read(collectionMutationsProvider))
        .moveSelectedToWishlist(
      selectedComicsShelfEntries(visibleEntries, selectionState.itemIds),
    );
    _clearSelection();
  }

  Future<void> _bulkRemove(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final entries = selectedComicsShelfEntries(
      visibleEntries,
      selectionState.itemIds,
    );
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
    if (confirmed != true) {
      return;
    }
    await ComicsBulkActions(ref.read(collectionMutationsProvider))
        .removeSelected(entries);
    _clearSelection();
  }

  void _handleSortChanged(LibrarySortColumn column) {
    _setWorkspaceViewState(
      workspaceViewState.withSortColumn(column, comicsWorkspaceViewProfile),
    );
  }

  void _handleViewModeChanged(LibraryViewMode value) {
    _setWorkspaceViewState(workspaceViewState.copyWith(viewMode: value));
  }

  void _handleDetailsLayoutChanged(LibraryDetailsLayout value) {
    _setWorkspaceViewState(
      workspaceViewState.copyWith(detailsLayout: value),
    );
  }

  void _handleViewPresetSelected(LibraryWorkspacePreset preset) {
    _setWorkspaceViewState(
      workspaceViewState.withPreset(preset, comicsWorkspaceViewProfile),
    );
  }

  void _handleCoverSizeChanged(double value) {
    _setWorkspaceViewState(workspaceViewState.copyWith(coverSize: value));
  }

  void _handleVisibleColumnsChanged(Set<LibraryTableColumn> columns) {
    _setWorkspaceViewState(
      workspaceViewState.copyWith(visibleColumns: columns),
    );
  }

  void _handleColumnWidthChanged(LibraryTableColumn column, double width) {
    _setWorkspaceViewState(
      workspaceViewState.withColumnWidth(
        column,
        width,
        comicsWorkspaceViewProfile,
      ),
    );
  }

  Future<void> _showColumnChooser(BuildContext context) async {
    final selected = await showDialog<Set<LibraryTableColumn>>(
      context: context,
      builder: (context) => LibraryColumnChooserDialog(
        selectedColumns: workspaceViewState.visibleColumns,
        defaultColumns: defaultComicTableColumns(),
        columnLabel: comicTableColumnDisplayName,
        columnGroup: comicTableColumnGroup,
        groupLabel: comicTableColumnGroupLabel,
      ),
    );
    if (selected != null) {
      _handleVisibleColumnsChanged(selected);
    }
  }

  Future<void> _loadViewPreferences() async {
    final preferences = await loadComicsWorkspaceViewState();
    if (!mounted) {
      return;
    }
    setState(() => workspaceViewState = preferences);
  }

  void _setWorkspaceViewState(ComicsWorkspaceViewState next) {
    setState(() => workspaceViewState = next);
    saveComicsWorkspaceViewState(next);
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
