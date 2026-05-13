import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_dialog.dart';
import 'package:collectarr_app/features/comics/comics_bulk_edit.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_shelf_views.dart';
import 'package:collectarr_app/features/comics/comics_workspace.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';
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
  LibraryViewMode viewMode = LibraryViewMode.grid;
  LibraryDetailsLayout detailsLayout = LibraryDetailsLayout.right;
  LibrarySortColumn sortColumn = comicsWorkspaceConfig.defaultSortColumn;
  bool sortAscending = true;
  double coverSize = kComicsDefaultCoverSize;
  Set<LibraryTableColumn> visibleColumns = defaultComicTableColumns();
  Map<LibraryTableColumn, double> columnWidths = const {};
  ComicsOwnershipFilter ownershipFilter = ComicsOwnershipFilter.all;
  String? gradeFilter;
  String? conditionFilter;
  String? publisherFilter;
  String? releaseYearFilter;
  bool selectionMode = false;
  final selectedItemIds = <String>{};
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
              final entries = _filterShelfEntries(state.entries);
              final items = _catalogItemsFromShelf(entries);
              final gradeOptions = _filterOptions(
                state.entries.map((entry) => entry.ownedItem?.grade),
              );
              final conditionOptions = _filterOptions(
                state.entries.map((entry) => entry.ownedItem?.condition),
              );
              final publisherOptions = _filterOptions(
                state.entries.map((entry) => entry.catalogItem?.publisher),
              );
              final releaseYearOptions = _filterOptions(
                state.entries
                    .map((entry) => entry.catalogItem?.releaseYear?.toString()),
              );
              return ComicsWorkspace(
                shelfState: state,
                items: items,
                queryController: _controller,
                selectedItemId: selectedItemId,
                selectedSeries: selectedSeries,
                viewMode: viewMode,
                detailsLayout: detailsLayout,
                sortColumn: sortColumn,
                sortAscending: sortAscending,
                coverSize: coverSize,
                visibleColumns: visibleColumns,
                columnWidths: columnWidths,
                selectionMode: selectionMode,
                selectedItemIds: selectedItemIds,
                hasActiveFilters: _hasActiveFilters,
                onEditFilters: () => _showFiltersDialog(
                  context,
                  gradeOptions: gradeOptions,
                  conditionOptions: conditionOptions,
                  publisherOptions: publisherOptions,
                  releaseYearOptions: releaseYearOptions,
                ),
                onSearch: (value) => setState(() {
                  query = value.trim();
                  selectedItemId = null;
                  selectedSeries = null;
                }),
                onAddComic: () => _showAddComicDialog(context),
                onSelectItem: (item) {
                  if (selectionMode) {
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

  List<CatalogItem> _catalogItemsFromShelf(List<ShelfEntry> entries) {
    return [
      for (final entry in entries)
        entry.catalogItem ??
            CatalogItem(
              id: entry.itemId,
              kind: comicsLibraryConfig.workspace.kind,
              title: entry.title,
            ),
    ];
  }

  List<ShelfEntry> _filterShelfEntries(List<ShelfEntry> entries) {
    final normalized = query.trim().toLowerCase();
    return [
      for (final entry in entries)
        if (_matchesOwnershipFilter(entry) &&
            _matchesValueFilter(entry.ownedItem?.grade, gradeFilter) &&
            _matchesValueFilter(entry.ownedItem?.condition, conditionFilter) &&
            _matchesValueFilter(
                entry.catalogItem?.publisher, publisherFilter) &&
            _matchesValueFilter(
              entry.catalogItem?.releaseYear?.toString(),
              releaseYearFilter,
            ) &&
            (normalized.isEmpty || _matchesEntryQuery(entry, normalized)))
          entry,
    ];
  }

  bool _matchesEntryQuery(ShelfEntry entry, String query) {
    final item = entry.catalogItem;
    if (entry.title.toLowerCase().contains(query)) {
      return true;
    }
    if (item == null) {
      return false;
    }
    return item.title.toLowerCase().contains(query) ||
        (item.itemNumber?.toLowerCase().contains(query) ?? false) ||
        (item.publisher?.toLowerCase().contains(query) ?? false) ||
        (item.variant?.toLowerCase().contains(query) ?? false) ||
        (item.barcode?.toLowerCase().contains(query) ?? false) ||
        (formatNullableComicDate(item.releaseDate)?.contains(query) ?? false) ||
        (item.releaseYear?.toString().contains(query) ?? false) ||
        (item.synopsis?.toLowerCase().contains(query) ?? false);
  }

  bool _matchesOwnershipFilter(ShelfEntry entry) {
    return switch (ownershipFilter) {
      ComicsOwnershipFilter.all => true,
      ComicsOwnershipFilter.owned => entry.isOwned,
      ComicsOwnershipFilter.wishlist => entry.isWishlisted,
      ComicsOwnershipFilter.missingGrade => entry.isMissingGrade,
    };
  }

  bool _matchesValueFilter(String? value, String? filter) {
    if (filter == null) {
      return true;
    }
    return value == filter;
  }

  List<String> _filterOptions(Iterable<String?> values) {
    final options = {
      for (final value in values)
        if (value != null && value.trim().isNotEmpty) value.trim(),
    }.toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return options;
  }

  bool get _hasActiveFilters {
    return ownershipFilter != ComicsOwnershipFilter.all ||
        gradeFilter != null ||
        conditionFilter != null ||
        publisherFilter != null ||
        releaseYearFilter != null;
  }

  Future<void> _showFiltersDialog(
    BuildContext context, {
    required List<String> gradeOptions,
    required List<String> conditionOptions,
    required List<String> publisherOptions,
    required List<String> releaseYearOptions,
  }) async {
    final selection = await showDialog<ComicsFilterSelection>(
      context: context,
      builder: (context) => ComicsFilterDialog(
        initialSelection: ComicsFilterSelection(
          ownershipFilter: ownershipFilter,
          grade: gradeFilter,
          condition: conditionFilter,
          publisher: publisherFilter,
          releaseYear: releaseYearFilter,
        ),
        gradeOptions: gradeOptions,
        conditionOptions: conditionOptions,
        publisherOptions: publisherOptions,
        releaseYearOptions: releaseYearOptions,
      ),
    );
    if (selection == null || !mounted) {
      return;
    }
    setState(() {
      ownershipFilter = selection.ownershipFilter;
      gradeFilter = selection.grade;
      conditionFilter = selection.condition;
      publisherFilter = selection.publisher;
      releaseYearFilter = selection.releaseYear;
      selectedItemId = null;
      selectedSeries = null;
      selectedItemIds.clear();
    });
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (!selectedItemIds.add(itemId)) {
        selectedItemIds.remove(itemId);
      }
      if (selectedItemIds.isEmpty) {
        selectionMode = false;
      }
    });
  }

  void _setSelectionMode(bool value) {
    setState(() {
      selectionMode = value;
      if (!value) {
        selectedItemIds.clear();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      selectedItemIds.clear();
      selectionMode = false;
    });
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
    final mutations = ref.read(collectionMutationsProvider);
    for (final entry in _selectedEntries(visibleEntries)) {
      final ownedItem = entry.ownedItem;
      if (ownedItem == null) {
        continue;
      }
      await mutations.updateItem(
        ownedItem,
        condition: selection.condition ?? ownedItem.condition,
        grade: selection.grade ?? ownedItem.grade,
        purchaseDate: ownedItem.purchaseDate,
        pricePaidCents: ownedItem.pricePaidCents,
        currency: ownedItem.currency,
        personalNotes: ownedItem.personalNotes,
        quantity: ownedItem.quantity,
        storageBox: selection.storageBox ?? ownedItem.storageBox,
        indexNumber: ownedItem.indexNumber,
        coverPriceCents: ownedItem.coverPriceCents,
        rawOrSlabbed: ownedItem.rawOrSlabbed,
        gradingCompany: ownedItem.gradingCompany,
        graderNotes: ownedItem.graderNotes,
        signedBy: ownedItem.signedBy,
        keyComic: ownedItem.keyComic,
        keyReason: ownedItem.keyReason,
        rating: ownedItem.rating,
        readStatus: selection.readStatus ?? ownedItem.readStatus,
        tags: selection.tags ?? ownedItem.tags,
      );
    }
    _clearSelection();
  }

  Future<void> _bulkMoveToOwned(List<ShelfEntry> visibleEntries) async {
    final mutations = ref.read(collectionMutationsProvider);
    for (final entry in _selectedEntries(visibleEntries)) {
      if (entry.ownedItem != null) {
        continue;
      }
      await mutations.addItem(
        entry.itemId,
        condition: 'Near Mint',
        grade: 'Ungraded',
      );
    }
    _clearSelection();
  }

  Future<void> _bulkMoveToWishlist(List<ShelfEntry> visibleEntries) async {
    final mutations = ref.read(collectionMutationsProvider);
    for (final entry in _selectedEntries(visibleEntries)) {
      await mutations.addToWishlist(entry.itemId);
      final ownedItem = entry.ownedItem;
      if (ownedItem != null) {
        await mutations.removeItem(ownedItem);
      }
    }
    _clearSelection();
  }

  Future<void> _bulkRemove(
    BuildContext context,
    List<ShelfEntry> visibleEntries,
  ) async {
    final entries = _selectedEntries(visibleEntries);
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
    final mutations = ref.read(collectionMutationsProvider);
    for (final entry in entries) {
      final ownedItem = entry.ownedItem;
      if (ownedItem != null) {
        await mutations.removeItem(ownedItem);
      }
      if (entry.isWishlisted) {
        await mutations.removeFromWishlist(entry.itemId);
      }
    }
    _clearSelection();
  }

  List<ShelfEntry> _selectedEntries(List<ShelfEntry> visibleEntries) {
    return [
      for (final entry in visibleEntries)
        if (selectedItemIds.contains(entry.itemId)) entry,
    ];
  }

  void _handleSortChanged(LibrarySortColumn column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = column == LibrarySortColumn.updated ? false : true;
      }
    });
    _saveViewPreferences();
  }

  void _handleViewModeChanged(LibraryViewMode value) {
    setState(() => viewMode = value);
    _saveViewPreferences();
  }

  void _handleDetailsLayoutChanged(LibraryDetailsLayout value) {
    setState(() => detailsLayout = value);
    _saveViewPreferences();
  }

  void _handleViewPresetSelected(LibraryWorkspacePreset preset) {
    final config = comicsViewPresetConfig(preset);
    setState(() {
      viewMode = config.viewMode;
      detailsLayout = config.detailsLayout;
      coverSize = config.coverSize;
      visibleColumns = Set.of(config.visibleColumns);
      columnWidths = const {};
    });
    _saveViewPreferences();
  }

  void _handleCoverSizeChanged(double value) {
    setState(() => coverSize = value);
    _saveViewPreferences();
  }

  void _handleVisibleColumnsChanged(Set<LibraryTableColumn> columns) {
    setState(() => visibleColumns = columns);
    _saveViewPreferences();
  }

  void _handleColumnWidthChanged(LibraryTableColumn column, double width) {
    setState(() {
      columnWidths = {
        ...columnWidths,
        column: clampComicTableColumnWidth(column, width),
      };
    });
    _saveViewPreferences();
  }

  Future<void> _showColumnChooser(BuildContext context) async {
    final selected = await showDialog<Set<LibraryTableColumn>>(
      context: context,
      builder: (context) => LibraryColumnChooserDialog(
        selectedColumns: visibleColumns,
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
    final preferences =
        await LibraryWorkspacePreferences(comicsWorkspaceConfig).read(
      defaultCoverSize: kComicsDefaultCoverSize,
      minCoverSize: kComicsMinCoverSize,
      maxCoverSize: kComicsMaxCoverSize,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      viewMode = preferences.viewMode;
      detailsLayout = preferences.detailsLayout;
      sortColumn = preferences.sortColumn;
      sortAscending = preferences.sortAscending;
      coverSize = preferences.coverSize;
      visibleColumns = preferences.visibleColumns;
      columnWidths = preferences.columnWidths.map(
        (column, width) =>
            MapEntry(column, clampComicTableColumnWidth(column, width)),
      );
    });
  }

  Future<void> _saveViewPreferences() async {
    await LibraryWorkspacePreferences(comicsWorkspaceConfig).write(
      LibraryWorkspacePreferenceSnapshot(
        viewMode: viewMode,
        detailsLayout: detailsLayout,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
        coverSize: coverSize,
        visibleColumns: visibleColumns,
        columnWidths: columnWidths,
      ),
    );
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
