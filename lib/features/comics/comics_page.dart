import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comic_detail_page.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double _kDesktopBreakpoint = 980;
const double _kMinCoverSize = 104;
const double _kDefaultCoverSize = 128;
const double _kMaxCoverSize = 188;
const String _kComicsViewModePreferenceKey = 'comics.view_mode';
const String _kComicsSortColumnPreferenceKey = 'comics.sort_column';
const String _kComicsSortAscendingPreferenceKey = 'comics.sort_ascending';
const String _kComicsCoverSizePreferenceKey = 'comics.cover_size';
const String _kComicsVisibleColumnsPreferenceKey = 'comics.visible_columns';

enum _ComicsViewMode { grid, list }

enum _ComicSortColumn {
  title,
  issue,
  grade,
  condition,
  price,
  wishlist,
  updated
}

enum _ComicTableColumn {
  cover,
  title,
  issue,
  grade,
  condition,
  price,
  wishlist,
  updated
}

enum _OwnershipFilter { all, owned, wishlist, missingGrade }

enum _BulkToolbarAction { edit, wishlist, remove, clear }

class ComicsPage extends ConsumerStatefulWidget {
  const ComicsPage({super.key});

  @override
  ConsumerState<ComicsPage> createState() => _ComicsPageState();
}

class _ComicsPageState extends ConsumerState<ComicsPage> {
  String query = '';
  String? selectedItemId;
  String? selectedSeries;
  _ComicsViewMode viewMode = _ComicsViewMode.grid;
  _ComicSortColumn sortColumn = _ComicSortColumn.title;
  bool sortAscending = true;
  double coverSize = _kDefaultCoverSize;
  Set<_ComicTableColumn> visibleColumns = _defaultComicTableColumns();
  _OwnershipFilter ownershipFilter = _OwnershipFilter.all;
  String? gradeFilter;
  String? conditionFilter;
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
      backgroundColor: const Color(0xFFF3F5F6),
      body: SafeArea(
        bottom: false,
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
            return _ComicsWorkspace(
              items: items,
              queryController: _controller,
              selectedItemId: selectedItemId,
              selectedSeries: selectedSeries,
              viewMode: viewMode,
              sortColumn: sortColumn,
              sortAscending: sortAscending,
              coverSize: coverSize,
              visibleColumns: visibleColumns,
              selectionMode: selectionMode,
              selectedItemIds: selectedItemIds,
              hasActiveFilters: _hasActiveFilters,
              onEditFilters: () => _showFiltersDialog(
                context,
                gradeOptions: gradeOptions,
                conditionOptions: conditionOptions,
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
              onSortChanged: _handleSortChanged,
              onCoverSizeChanged: _handleCoverSizeChanged,
              onSelectionModeChanged: _setSelectionMode,
              onClearSelection: _clearSelection,
              onBulkEdit: () => _showBulkEditDialog(context, entries),
              onBulkMoveToWishlist: () => _bulkMoveToWishlist(entries),
              onBulkRemove: () => _bulkRemove(entries),
            );
          },
          error: (error, stackTrace) => _ErrorState(message: error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
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
      final result =
          await ref.read(apiClientProvider).lookupBarcode(code, kind: 'comic');
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
      builder: (context) => const _AddComicDialog(),
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
              kind: 'comic',
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
        (item.synopsis?.toLowerCase().contains(query) ?? false);
  }

  bool _matchesOwnershipFilter(ShelfEntry entry) {
    return switch (ownershipFilter) {
      _OwnershipFilter.all => true,
      _OwnershipFilter.owned => entry.isOwned,
      _OwnershipFilter.wishlist => entry.isWishlisted,
      _OwnershipFilter.missingGrade => entry.isMissingGrade,
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
    return ownershipFilter != _OwnershipFilter.all ||
        gradeFilter != null ||
        conditionFilter != null;
  }

  Future<void> _showFiltersDialog(
    BuildContext context, {
    required List<String> gradeOptions,
    required List<String> conditionOptions,
  }) async {
    final selection = await showDialog<_ComicsFilterSelection>(
      context: context,
      builder: (context) => _ComicsFilterDialog(
        initialSelection: _ComicsFilterSelection(
          ownershipFilter: ownershipFilter,
          grade: gradeFilter,
          condition: conditionFilter,
        ),
        gradeOptions: gradeOptions,
        conditionOptions: conditionOptions,
      ),
    );
    if (selection == null || !mounted) {
      return;
    }
    setState(() {
      ownershipFilter = selection.ownershipFilter;
      gradeFilter = selection.grade;
      conditionFilter = selection.condition;
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
    final selection = await showDialog<_BulkEditSelection>(
      context: context,
      builder: (context) => const _BulkEditDialog(),
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
        storageBox: ownedItem.storageBox,
        indexNumber: ownedItem.indexNumber,
        coverPriceCents: ownedItem.coverPriceCents,
        rawOrSlabbed: ownedItem.rawOrSlabbed,
        gradingCompany: ownedItem.gradingCompany,
        graderNotes: ownedItem.graderNotes,
        signedBy: ownedItem.signedBy,
        keyComic: ownedItem.keyComic,
        keyReason: ownedItem.keyReason,
        rating: ownedItem.rating,
        readStatus: ownedItem.readStatus,
        tags: ownedItem.tags,
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

  Future<void> _bulkRemove(List<ShelfEntry> visibleEntries) async {
    final mutations = ref.read(collectionMutationsProvider);
    for (final entry in _selectedEntries(visibleEntries)) {
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

  void _handleSortChanged(_ComicSortColumn column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = column == _ComicSortColumn.updated ? false : true;
      }
    });
    _saveViewPreferences();
  }

  void _handleViewModeChanged(_ComicsViewMode value) {
    setState(() => viewMode = value);
    _saveViewPreferences();
  }

  void _handleCoverSizeChanged(double value) {
    setState(() => coverSize = value);
    _saveViewPreferences();
  }

  void _handleVisibleColumnsChanged(Set<_ComicTableColumn> columns) {
    setState(() => visibleColumns = columns);
    _saveViewPreferences();
  }

  Future<void> _showColumnChooser(BuildContext context) async {
    final selected = await showDialog<Set<_ComicTableColumn>>(
      context: context,
      builder: (context) =>
          _ColumnChooserDialog(selectedColumns: visibleColumns),
    );
    if (selected != null) {
      _handleVisibleColumnsChanged(selected);
    }
  }

  Future<void> _loadViewPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedViewMode = prefs.getString(_kComicsViewModePreferenceKey);
    final storedSortColumn = prefs.getString(_kComicsSortColumnPreferenceKey);
    final storedCoverSize = prefs.getDouble(_kComicsCoverSizePreferenceKey);
    final storedColumns =
        prefs.getStringList(_kComicsVisibleColumnsPreferenceKey);
    if (!mounted) {
      return;
    }
    setState(() {
      viewMode =
          _enumByName(_ComicsViewMode.values, storedViewMode) ?? viewMode;
      sortColumn =
          _enumByName(_ComicSortColumn.values, storedSortColumn) ?? sortColumn;
      sortAscending =
          prefs.getBool(_kComicsSortAscendingPreferenceKey) ?? sortAscending;
      coverSize = (storedCoverSize ?? coverSize)
          .clamp(_kMinCoverSize, _kMaxCoverSize)
          .toDouble();
      visibleColumns = _decodeVisibleColumns(storedColumns);
    });
  }

  Future<void> _saveViewPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kComicsViewModePreferenceKey, viewMode.name);
    await prefs.setString(_kComicsSortColumnPreferenceKey, sortColumn.name);
    await prefs.setBool(_kComicsSortAscendingPreferenceKey, sortAscending);
    await prefs.setDouble(_kComicsCoverSizePreferenceKey, coverSize);
    await prefs.setStringList(
      _kComicsVisibleColumnsPreferenceKey,
      visibleColumns.map((column) => column.name).toList(growable: false),
    );
  }
}

class _ComicsWorkspace extends StatelessWidget {
  const _ComicsWorkspace({
    required this.items,
    required this.queryController,
    required this.selectedItemId,
    required this.selectedSeries,
    required this.viewMode,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required this.visibleColumns,
    required this.selectionMode,
    required this.selectedItemIds,
    required this.hasActiveFilters,
    required this.onEditFilters,
    required this.onEditColumns,
    required this.onSearch,
    required this.onAddComic,
    required this.onSelectItem,
    required this.onSelectSeries,
    required this.onClearSeries,
    required this.onScanBarcode,
    required this.onViewModeChanged,
    required this.onSortChanged,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final List<CatalogItem> items;
  final TextEditingController queryController;
  final String? selectedItemId;
  final String? selectedSeries;
  final _ComicsViewMode viewMode;
  final _ComicSortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final Set<_ComicTableColumn> visibleColumns;
  final bool selectionMode;
  final Set<String> selectedItemIds;
  final bool hasActiveFilters;
  final VoidCallback onEditFilters;
  final VoidCallback onEditColumns;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;
  final ValueChanged<String> onSelectSeries;
  final VoidCallback onClearSeries;
  final VoidCallback onScanBarcode;
  final ValueChanged<_ComicsViewMode> onViewModeChanged;
  final ValueChanged<_ComicSortColumn> onSortChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _kDesktopBreakpoint;
    final series = _seriesBuckets(items);
    final visibleItems = selectedSeries == null
        ? items
        : items
            .where((item) => item.title == selectedSeries)
            .toList(growable: false);
    final selectedItem = _selectedItem(visibleItems, selectedItemId);
    final missingIssues = selectedSeries == null
        ? const <int>[]
        : _missingIssueNumbers(visibleItems);

    if (!isWide) {
      return _LibraryAwareCompactComicsView(
        items: visibleItems,
        selectedItem: selectedItem,
        selectedSeries: selectedSeries,
        queryController: queryController,
        onSearch: onSearch,
        onAddComic: onAddComic,
        onEditFilters: onEditFilters,
        hasActiveFilters: hasActiveFilters,
        coverSize: coverSize,
        onCoverSizeChanged: onCoverSizeChanged,
        onScanBarcode: onScanBarcode,
        onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
        onSelectItem: onSelectItem,
        onClearSeries: onClearSeries,
      );
    }

    return Column(
      children: [
        _ComicsToolbar(
          controller: queryController,
          itemCount: visibleItems.length,
          totalCount: items.length,
          selectedSeries: selectedSeries,
          viewMode: viewMode,
          coverSize: coverSize,
          hasActiveFilters: hasActiveFilters,
          missingIssues: missingIssues,
          selectionMode: selectionMode,
          selectedCount: selectedItemIds.length,
          onSearch: onSearch,
          onAddComic: onAddComic,
          onEditFilters: onEditFilters,
          onEditColumns: onEditColumns,
          onScanBarcode: onScanBarcode,
          onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
          onClearSeries: onClearSeries,
          onViewModeChanged: onViewModeChanged,
          onCoverSizeChanged: onCoverSizeChanged,
          onSelectionModeChanged: onSelectionModeChanged,
          onClearSelection: onClearSelection,
          onBulkEdit: onBulkEdit,
          onBulkMoveToWishlist: onBulkMoveToWishlist,
          onBulkRemove: onBulkRemove,
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: _SeriesSidebar(
                  series: series,
                  selectedSeries: selectedSeries,
                  onSelectSeries: onSelectSeries,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: viewMode == _ComicsViewMode.grid
                    ? _LibraryAwareCoverGrid(
                        items: visibleItems,
                        selectedItemId: selectedItem?.id,
                        selectedItemIds: selectedItemIds,
                        coverSize: coverSize,
                        onSelectItem: onSelectItem,
                      )
                    : _LibraryAwareComicList(
                        items: visibleItems,
                        selectedItemId: selectedItem?.id,
                        selectedItemIds: selectedItemIds,
                        sortColumn: sortColumn,
                        sortAscending: sortAscending,
                        visibleColumns: visibleColumns,
                        onSortChanged: onSortChanged,
                        onSelectItem: onSelectItem,
                      ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 340,
                child: _LibraryAwareComicInspector(item: selectedItem),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_SeriesBucket> _seriesBuckets(List<CatalogItem> source) {
    final counts = <String, int>{};
    for (final item in source) {
      counts[item.title] = (counts[item.title] ?? 0) + 1;
    }
    final buckets = counts.entries
        .map((entry) => _SeriesBucket(title: entry.key, count: entry.value))
        .toList(growable: false)
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    return buckets;
  }

  void _showMetadataRefreshPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Metadata refresh is not wired yet')),
    );
  }

  List<int> _missingIssueNumbers(List<CatalogItem> source) {
    final numbers = {
      for (final item in source)
        if (_parseIssueNumber(item.itemNumber) != null)
          _parseIssueNumber(item.itemNumber)!,
    }.toList(growable: false)
      ..sort();
    if (numbers.length < 2) {
      return const [];
    }
    final missing = <int>[];
    for (var number = numbers.first; number <= numbers.last; number++) {
      if (!numbers.contains(number)) {
        missing.add(number);
      }
    }
    return missing;
  }

  CatalogItem? _selectedItem(
      List<CatalogItem> visibleItems, String? selectedId) {
    if (visibleItems.isEmpty) {
      return null;
    }
    if (selectedId == null) {
      return visibleItems.first;
    }
    for (final item in visibleItems) {
      if (item.id == selectedId) {
        return item;
      }
    }
    return visibleItems.first;
  }
}

class _ComicsToolbar extends StatelessWidget {
  const _ComicsToolbar({
    required this.controller,
    required this.itemCount,
    required this.totalCount,
    required this.selectedSeries,
    required this.viewMode,
    required this.coverSize,
    required this.hasActiveFilters,
    required this.missingIssues,
    required this.selectionMode,
    required this.selectedCount,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.onEditColumns,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onClearSeries,
    required this.onViewModeChanged,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final TextEditingController controller;
  final int itemCount;
  final int totalCount;
  final String? selectedSeries;
  final _ComicsViewMode viewMode;
  final double coverSize;
  final bool hasActiveFilters;
  final List<int> missingIssues;
  final bool selectionMode;
  final int selectedCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final VoidCallback onEditColumns;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback onClearSeries;
  final ValueChanged<_ComicsViewMode> onViewModeChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: onAddComic,
              icon: const Icon(Icons.add),
              label: const Text('Add Comics'),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Scan barcode',
              child: IconButton.filledTonal(
                onPressed: onScanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
            Tooltip(
              message: 'Refresh metadata',
              child: IconButton.filledTonal(
                onPressed: onRefreshMetadata,
                icon: const Icon(Icons.sync),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SearchBar(
                  controller: controller,
                  hintText: 'Search comics...',
                  leading: const Icon(Icons.search),
                  trailing: [
                    Tooltip(
                      message: 'Search',
                      child: IconButton(
                        onPressed: () => onSearch(controller.text),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                  onSubmitted: onSearch,
                ),
              ),
            ),
            if (selectedSeries != null) ...[
              const SizedBox(width: 8),
              InputChip(
                label: Text(selectedSeries!),
                onDeleted: onClearSeries,
              ),
            ],
            const Spacer(),
            Tooltip(
              message: selectionMode ? 'Exit selection' : 'Select comics',
              child: IconButton.filledTonal(
                onPressed: () => onSelectionModeChanged(!selectionMode),
                icon: Icon(selectionMode ? Icons.close : Icons.checklist),
              ),
            ),
            const SizedBox(width: 8),
            if (selectionMode) ...[
              _ToolbarStat(label: 'Selected', value: selectedCount),
              const SizedBox(width: 8),
              PopupMenuButton<_BulkToolbarAction>(
                tooltip: 'Bulk actions',
                enabled: selectedCount > 0,
                icon: const Icon(Icons.more_vert),
                onSelected: (action) {
                  if (action == _BulkToolbarAction.edit) {
                    onBulkEdit();
                  } else if (action == _BulkToolbarAction.wishlist) {
                    onBulkMoveToWishlist();
                  } else if (action == _BulkToolbarAction.remove) {
                    onBulkRemove();
                  } else if (action == _BulkToolbarAction.clear) {
                    onClearSelection();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _BulkToolbarAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_note),
                      title: Text('Bulk edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _BulkToolbarAction.wishlist,
                    child: ListTile(
                      leading: Icon(Icons.star_border),
                      title: Text('Move to wishlist'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _BulkToolbarAction.remove,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Remove selected'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _BulkToolbarAction.clear,
                    child: ListTile(
                      leading: Icon(Icons.deselect),
                      title: Text('Clear selection'),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            Tooltip(
              message: 'Missing issues',
              child: Badge(
                isLabelVisible: missingIssues.isNotEmpty,
                label: Text(missingIssues.length.toString()),
                child: IconButton.filledTonal(
                  onPressed: missingIssues.isEmpty
                      ? null
                      : () => _showMissingIssuesDialog(context, missingIssues),
                  icon: const Icon(Icons.format_list_numbered),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Filters',
              child: Badge(
                isLabelVisible: hasActiveFilters,
                child: IconButton.filledTonal(
                  onPressed: onEditFilters,
                  icon: const Icon(Icons.filter_list),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Select columns',
              child: IconButton.filledTonal(
                onPressed:
                    viewMode == _ComicsViewMode.list ? onEditColumns : null,
                icon: const Icon(Icons.view_column),
              ),
            ),
            const SizedBox(width: 8),
            _ToolbarStat(label: 'Shown', value: itemCount),
            const SizedBox(width: 8),
            _ToolbarStat(label: 'Total', value: totalCount),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Cover size',
              child: SizedBox(
                width: 112,
                child: Slider(
                  min: _kMinCoverSize,
                  max: _kMaxCoverSize,
                  divisions: 7,
                  value: coverSize,
                  onChanged: onCoverSizeChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SegmentedButton<_ComicsViewMode>(
              segments: const [
                ButtonSegment(
                  value: _ComicsViewMode.grid,
                  icon: Tooltip(
                    message: 'Grid view',
                    child: Icon(Icons.grid_view),
                  ),
                ),
                ButtonSegment(
                  value: _ComicsViewMode.list,
                  icon: Tooltip(
                    message: 'List view',
                    child: Icon(Icons.view_list),
                  ),
                ),
              ],
              selected: {viewMode},
              onSelectionChanged: (selection) =>
                  onViewModeChanged(selection.first),
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnChooserDialog extends StatefulWidget {
  const _ColumnChooserDialog({required this.selectedColumns});

  final Set<_ComicTableColumn> selectedColumns;

  @override
  State<_ColumnChooserDialog> createState() => _ColumnChooserDialogState();
}

class _ColumnChooserDialogState extends State<_ColumnChooserDialog> {
  late var _selected = Set<_ComicTableColumn>.of(widget.selectedColumns);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = _ComicTableColumn.values
        .where((column) => _comicTableColumnDisplayName(column)
            .toLowerCase()
            .contains(_query.trim().toLowerCase()))
        .toList(growable: false);
    final selectedColumns = _orderedVisibleColumns(_selected);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select columns',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search columns...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 12),
                      children: [
                        for (final column in columns)
                          CheckboxListTile(
                            dense: true,
                            value: _selected.contains(column),
                            onChanged: column == _ComicTableColumn.title
                                ? null
                                : (value) => setState(() {
                                      if (value ?? false) {
                                        _selected.add(column);
                                      } else {
                                        _selected.remove(column);
                                      }
                                    }),
                            title: Text(_comicTableColumnDisplayName(column)),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                      ],
                    ),
                  ),
                  VerticalDivider(color: colorScheme.outlineVariant),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                      children: [
                        for (final column in selectedColumns)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.drag_indicator),
                            title: Text(_comicTableColumnDisplayName(column)),
                            trailing: column == _ComicTableColumn.title
                                ? null
                                : IconButton(
                                    tooltip: 'Hide column',
                                    onPressed: () => setState(
                                      () => _selected.remove(column),
                                    ),
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(
                      () => _selected = _defaultComicTableColumns(),
                    ),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final result = Set<_ComicTableColumn>.of(_selected)
                        ..add(_ComicTableColumn.title);
                      Navigator.of(context).pop(result);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarStat extends StatelessWidget {
  const _ToolbarStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.labelSmall),
        Text(value.toString(), style: textTheme.titleMedium),
      ],
    );
  }
}

class _SeriesSidebar extends StatelessWidget {
  const _SeriesSidebar({
    required this.series,
    required this.selectedSeries,
    required this.onSelectSeries,
  });

  final List<_SeriesBucket> series;
  final String? selectedSeries;
  final ValueChanged<String> onSelectSeries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLowest),
      child: Column(
        children: [
          Container(
            height: 42,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder, size: 18),
                const SizedBox(width: 8),
                Text('Series', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: series.length,
              itemBuilder: (context, index) {
                final bucket = series[index];
                final selected = bucket.title == selectedSeries;
                return _SeriesRow(
                  bucket: bucket,
                  selected: selected,
                  onTap: () => onSelectSeries(bucket.title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({
    required this.bucket,
    required this.selected,
    required this.onTap,
  });

  final _SeriesBucket bucket;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: selected ? colorScheme.primaryContainer : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                bucket.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            Badge(
              label: Text(bucket.count.toString()),
              backgroundColor: selected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              textColor: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAwareCoverGrid extends ConsumerWidget {
  const _LibraryAwareCoverGrid({
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _CoverGrid(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItemId: selectedItemId,
      selectedItemIds: selectedItemIds,
      coverSize: coverSize,
      onSelectItem: onSelectItem,
    );
  }
}

class _CoverGrid extends StatelessWidget {
  const _CoverGrid({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: coverSize,
        mainAxisExtent: coverSize * 1.53,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CoverTile(
          item: item,
          libraryState: _LibraryState(
            ownedItem: ownedByItemId[item.id],
            isWishlisted: wishlistIds.contains(item.id),
          ),
          selected:
              selectedItemIds.contains(item.id) || item.id == selectedItemId,
          onTap: () => onSelectItem(item),
        );
      },
    );
  }
}

class _LibraryAwareComicList extends ConsumerWidget {
  const _LibraryAwareComicList({
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.sortColumn,
    required this.sortAscending,
    required this.visibleColumns,
    required this.onSortChanged,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final _ComicSortColumn sortColumn;
  final bool sortAscending;
  final Set<_ComicTableColumn> visibleColumns;
  final ValueChanged<_ComicSortColumn> onSortChanged;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistByItemId = ref.watch(wishlistByCatalogItemProvider);
    return _ComicList(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistByItemId: wishlistByItemId,
      selectedItemId: selectedItemId,
      selectedItemIds: selectedItemIds,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      visibleColumns: visibleColumns,
      onSortChanged: onSortChanged,
      onSelectItem: onSelectItem,
    );
  }
}

class _ComicList extends StatelessWidget {
  const _ComicList({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistByItemId,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.sortColumn,
    required this.sortAscending,
    required this.visibleColumns,
    required this.onSortChanged,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Map<String, WishlistItem> wishlistByItemId;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final _ComicSortColumn sortColumn;
  final bool sortAscending;
  final Set<_ComicTableColumn> visibleColumns;
  final ValueChanged<_ComicSortColumn> onSortChanged;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
    final entries = [
      for (final item in items)
        _ComicTableEntry(
          item: item,
          ownedItem: ownedByItemId[item.id],
          wishlistItem: wishlistByItemId[item.id],
        ),
    ]..sort((a, b) => _compareEntries(a, b, sortColumn, sortAscending));

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = _tableWidthForColumns(visibleColumns);
        final contentWidth = tableWidth > constraints.maxWidth
            ? tableWidth
            : constraints.maxWidth;
        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _ComicDataTable(
                  entries: entries,
                  selectedItemId: selectedItemId,
                  selectedItemIds: selectedItemIds,
                  sortColumn: sortColumn,
                  sortAscending: sortAscending,
                  visibleColumns: visibleColumns,
                  onSortChanged: onSortChanged,
                  onSelectItem: onSelectItem,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ComicDataTable extends StatelessWidget {
  const _ComicDataTable({
    required this.entries,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.sortColumn,
    required this.sortAscending,
    required this.visibleColumns,
    required this.onSortChanged,
    required this.onSelectItem,
  });

  final List<_ComicTableEntry> entries;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final _ComicSortColumn sortColumn;
  final bool sortAscending;
  final Set<_ComicTableColumn> visibleColumns;
  final ValueChanged<_ComicSortColumn> onSortChanged;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = _orderedVisibleColumns(visibleColumns);
    return DataTable(
      sortColumnIndex: _sortColumnIndex(sortColumn, columns),
      sortAscending: sortAscending,
      headingRowColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
      dataRowMinHeight: 68,
      dataRowMaxHeight: 76,
      columnSpacing: 18,
      showCheckboxColumn: false,
      border: TableBorder(
        horizontalInside: BorderSide(color: colorScheme.outlineVariant),
      ),
      columns: [
        for (final column in columns)
          DataColumn(
            label: Text(_comicTableColumnLabel(column)),
            numeric: _comicTableColumnIsNumeric(column),
            onSort: _comicTableColumnSort(column) == null
                ? null
                : (_, __) => onSortChanged(_comicTableColumnSort(column)!),
          ),
      ],
      rows: [
        for (final entry in entries)
          DataRow(
            selected: selectedItemIds.contains(entry.item.id) ||
                entry.item.id == selectedItemId,
            color: WidgetStateProperty.resolveWith(
              (states) => selectedItemIds.contains(entry.item.id) ||
                      entry.item.id == selectedItemId
                  ? colorScheme.primaryContainer
                  : null,
            ),
            onSelectChanged: (_) => onSelectItem(entry.item),
            cells: [
              for (final column in columns) _comicTableCell(entry, column),
            ],
          ),
      ],
    );
  }
}

List<_ComicTableColumn> _orderedVisibleColumns(Set<_ComicTableColumn> columns) {
  final effective = columns.isEmpty ? _defaultComicTableColumns() : columns;
  return [
    for (final column in _ComicTableColumn.values)
      if (effective.contains(column)) column,
  ];
}

Set<_ComicTableColumn> _defaultComicTableColumns() => {
      _ComicTableColumn.cover,
      _ComicTableColumn.title,
      _ComicTableColumn.issue,
      _ComicTableColumn.grade,
      _ComicTableColumn.condition,
      _ComicTableColumn.price,
      _ComicTableColumn.wishlist,
      _ComicTableColumn.updated,
    };

Set<_ComicTableColumn> _decodeVisibleColumns(List<String>? values) {
  if (values == null || values.isEmpty) {
    return _defaultComicTableColumns();
  }
  final columns = {
    for (final value in values)
      if (_enumByName(_ComicTableColumn.values, value) != null)
        _enumByName(_ComicTableColumn.values, value)!,
  };
  if (!columns.contains(_ComicTableColumn.title)) {
    columns.add(_ComicTableColumn.title);
  }
  return columns.isEmpty ? _defaultComicTableColumns() : columns;
}

double _tableWidthForColumns(Set<_ComicTableColumn> columns) {
  return _orderedVisibleColumns(columns)
      .map((column) => switch (column) {
            _ComicTableColumn.cover => 76.0,
            _ComicTableColumn.title => 340.0,
            _ComicTableColumn.issue => 92.0,
            _ComicTableColumn.grade => 120.0,
            _ComicTableColumn.condition => 150.0,
            _ComicTableColumn.price => 120.0,
            _ComicTableColumn.wishlist => 112.0,
            _ComicTableColumn.updated => 132.0,
          })
      .fold<double>(0, (total, width) => total + width);
}

String _comicTableColumnLabel(_ComicTableColumn column) {
  return switch (column) {
    _ComicTableColumn.cover => '',
    _ComicTableColumn.title => 'Series',
    _ComicTableColumn.issue => 'Issue',
    _ComicTableColumn.grade => 'Grade',
    _ComicTableColumn.condition => 'Condition',
    _ComicTableColumn.price => 'Price',
    _ComicTableColumn.wishlist => 'Wishlist',
    _ComicTableColumn.updated => 'Updated',
  };
}

String _comicTableColumnDisplayName(_ComicTableColumn column) {
  return switch (column) {
    _ComicTableColumn.cover => 'Cover',
    _ComicTableColumn.title => 'Series',
    _ComicTableColumn.issue => 'Issue',
    _ComicTableColumn.grade => 'Grade',
    _ComicTableColumn.condition => 'Condition',
    _ComicTableColumn.price => 'Price',
    _ComicTableColumn.wishlist => 'Wishlist',
    _ComicTableColumn.updated => 'Updated',
  };
}

bool _comicTableColumnIsNumeric(_ComicTableColumn column) {
  return switch (column) {
    _ComicTableColumn.issue || _ComicTableColumn.price => true,
    _ => false,
  };
}

_ComicSortColumn? _comicTableColumnSort(_ComicTableColumn column) {
  return switch (column) {
    _ComicTableColumn.cover => null,
    _ComicTableColumn.title => _ComicSortColumn.title,
    _ComicTableColumn.issue => _ComicSortColumn.issue,
    _ComicTableColumn.grade => _ComicSortColumn.grade,
    _ComicTableColumn.condition => _ComicSortColumn.condition,
    _ComicTableColumn.price => _ComicSortColumn.price,
    _ComicTableColumn.wishlist => _ComicSortColumn.wishlist,
    _ComicTableColumn.updated => _ComicSortColumn.updated,
  };
}

DataCell _comicTableCell(_ComicTableEntry entry, _ComicTableColumn column) {
  return switch (column) {
    _ComicTableColumn.cover => DataCell(
        SizedBox(
          width: 36,
          height: 54,
          child: _CoverImage(item: entry.item),
        ),
      ),
    _ComicTableColumn.title => DataCell(
        SizedBox(
          width: 280,
          child: Text(
            entry.item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    _ComicTableColumn.issue => DataCell(Text(entry.item.itemNumber ?? '')),
    _ComicTableColumn.grade => DataCell(_CellText(entry.ownedItem?.grade)),
    _ComicTableColumn.condition =>
      DataCell(_CellText(entry.ownedItem?.condition)),
    _ComicTableColumn.price => DataCell(
        Text(
          _formatOptionalMoney(
            entry.ownedItem?.pricePaidCents,
            entry.ownedItem?.currency,
          ),
        ),
      ),
    _ComicTableColumn.wishlist => DataCell(
        entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
      ),
    _ComicTableColumn.updated => DataCell(Text(_formatDate(entry.updatedAt))),
  };
}

class _CellText extends StatelessWidget {
  const _CellText(this.value);

  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value == null || value!.isEmpty ? '-' : value!;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: value == null || value!.isEmpty
          ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
          : null,
    );
  }
}

class _ComicTableEntry {
  const _ComicTableEntry({
    required this.item,
    this.ownedItem,
    this.wishlistItem,
  });

  final CatalogItem item;
  final OwnedItem? ownedItem;
  final WishlistItem? wishlistItem;

  bool get isWishlisted => wishlistItem != null;

  DateTime get updatedAt {
    final ownedUpdated = ownedItem?.updatedAt;
    final wishUpdated = wishlistItem?.updatedAt;
    if (ownedUpdated == null) {
      return wishUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (wishUpdated == null) {
      return ownedUpdated;
    }
    return ownedUpdated.isAfter(wishUpdated) ? ownedUpdated : wishUpdated;
  }
}

int _compareEntries(
  _ComicTableEntry a,
  _ComicTableEntry b,
  _ComicSortColumn column,
  bool ascending,
) {
  final result = switch (column) {
    _ComicSortColumn.title =>
      _compareNullableStrings(a.item.title, b.item.title),
    _ComicSortColumn.issue => _compareIssueNumbers(
        a.item.itemNumber,
        b.item.itemNumber,
      ),
    _ComicSortColumn.grade => _compareNullableStrings(
        a.ownedItem?.grade,
        b.ownedItem?.grade,
      ),
    _ComicSortColumn.condition => _compareNullableStrings(
        a.ownedItem?.condition,
        b.ownedItem?.condition,
      ),
    _ComicSortColumn.price => _compareNullableInts(
        a.ownedItem?.pricePaidCents,
        b.ownedItem?.pricePaidCents,
      ),
    _ComicSortColumn.wishlist => _compareBools(a.isWishlisted, b.isWishlisted),
    _ComicSortColumn.updated => a.updatedAt.compareTo(b.updatedAt),
  };
  if (result != 0) {
    return ascending ? result : -result;
  }
  return _compareNullableStrings(a.item.title, b.item.title);
}

int? _sortColumnIndex(
  _ComicSortColumn column,
  List<_ComicTableColumn> visibleColumns,
) {
  for (var index = 0; index < visibleColumns.length; index++) {
    if (_comicTableColumnSort(visibleColumns[index]) == column) {
      return index;
    }
  }
  return null;
}

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = double.tryParse(left ?? '');
  final rightNumber = double.tryParse(right ?? '');
  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }
  return _compareNullableStrings(left, right);
}

int? _parseIssueNumber(String? value) {
  if (value == null) {
    return null;
  }
  return int.tryParse(value.trim());
}

int _compareNullableStrings(String? left, String? right) {
  final leftValue = left?.toLowerCase() ?? '';
  final rightValue = right?.toLowerCase() ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.compareTo(rightValue);
}

int _compareNullableInts(int? left, int? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? 0).compareTo(right ?? 0);
}

int _compareBools(bool left, bool right) {
  if (left == right) {
    return 0;
  }
  return left ? -1 : 1;
}

String _formatOptionalMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}

int? _parseMoneyCents(String value, {int? fallback}) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) {
    return null;
  }
  final parsed = double.tryParse(normalized);
  if (parsed == null) {
    return fallback;
  }
  return (parsed * 100).round();
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({
    required this.item,
    required this.libraryState,
    required this.selected,
    required this.onTap,
  });

  final CatalogItem item;
  final _LibraryState libraryState;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverImage(item: item),
                  Positioned(
                    left: 4,
                    top: 4,
                    child: _CoverBadges(libraryState: libraryState),
                  ),
                  if (selected)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.check_circle,
                            color: colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.itemNumber == null
                  ? item.title
                  : '${item.title} #${item.itemNumber}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverBadges extends StatelessWidget {
  const _CoverBadges({required this.libraryState});

  final _LibraryState libraryState;

  @override
  Widget build(BuildContext context) {
    if (!libraryState.isOwned && !libraryState.isWishlisted) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 4,
      children: [
        if (libraryState.isOwned)
          const _CoverBadge(icon: Icons.inventory_2, label: 'Owned'),
        if (libraryState.isWishlisted)
          const _CoverBadge(icon: Icons.star, label: 'Wishlist'),
      ],
    );
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 13, color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final placeholder = _GeneratedCover(item: item);
    final url = item.displayCoverUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _GeneratedCover extends StatelessWidget {
  const _GeneratedCover({required this.item});

  final CatalogItem item;

  static const _palettes = [
    (Color(0xFF145DA0), Color(0xFFB1D4E0), Color(0xFFFFFFFF)),
    (Color(0xFFB22222), Color(0xFFFFD166), Color(0xFFFFFFFF)),
    (Color(0xFF2D6A4F), Color(0xFF95D5B2), Color(0xFFFFFFFF)),
    (Color(0xFF3D348B), Color(0xFFF7B801), Color(0xFFFFFFFF)),
    (Color(0xFF22223B), Color(0xFFC9ADA7), Color(0xFFFFFFFF)),
    (Color(0xFF7F5539), Color(0xFFE6CCB2), Color(0xFF201A16)),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[item.title.hashCode.abs() % _palettes.length];
    final title = item.title.replaceAll(', Vol.', '\nVol.');
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: BoxDecoration(color: palette.$1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(height: 18, color: palette.$2),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 28, color: const Color(0x33000000)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 34),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 86,
                  child: Text(
                    title,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.$3,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                    ),
                  ),
                ),
              ),
            ),
            if (item.itemNumber != null)
              Positioned(
                right: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.$2,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      '#${item.itemNumber}',
                      style: TextStyle(
                        color: palette.$3 == const Color(0xFFFFFFFF)
                            ? const Color(0xFF1D1D1D)
                            : palette.$3,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAwareComicInspector extends ConsumerWidget {
  const _LibraryAwareComicInspector({required this.item});

  final CatalogItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _ComicInspector(
      item: item,
      libraryState: _libraryStateFor(item, ownedByItemId, wishlistIds),
    );
  }
}

class _ComicInspector extends ConsumerWidget {
  const _ComicInspector({
    required this.item,
    required this.libraryState,
  });

  final CatalogItem? item;
  final _LibraryState libraryState;

  static const _conditions = [
    'Near Mint',
    'Very Fine',
    'Fine',
    'Good',
    'Poor',
  ];

  static const _grades = [
    'Ungraded',
    '10.0',
    '9.8',
    '9.6',
    '9.4',
    '9.0',
    '8.0',
    '7.0',
    '6.0',
    '5.0',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final ownedItem = libraryState.ownedItem;
    final isOwned = ownedItem != null;
    final detail =
        item == null ? null : ref.watch(comicDetailProvider(item!.id));
    if (item == null) {
      return const _EmptyInspector();
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surface),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item!.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Tooltip(
                message:
                    isOwned ? 'Remove from collection' : 'Add to collection',
                child: IconButton.filled(
                  onPressed: isOwned
                      ? () => _removeFromCollection(context, ref, ownedItem)
                      : () => _addToCollection(context, ref, item!),
                  icon: Icon(isOwned ? Icons.remove : Icons.add),
                ),
              ),
              if (ownedItem != null) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Edit comic',
                  child: IconButton.filledTonal(
                    onPressed: () =>
                        _showEditDialog(context, ref, item!, ownedItem),
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ],
            ],
          ),
          Text(
            item!.itemNumber == null ? item!.kind : '#${item!.itemNumber}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 2 / 3,
            child: _CoverImage(item: item!),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.inventory_2,
                label: isOwned ? 'Owned' : 'Not owned',
              ),
              _MetaChip(
                icon:
                    libraryState.isWishlisted ? Icons.star : Icons.star_border,
                label: libraryState.isWishlisted ? 'Wishlisted' : 'Wishlist',
              ),
              _MetaChip(
                icon: Icons.verified_outlined,
                label: ownedItem?.grade ?? 'Ungraded',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CollectionFields(
            enabled: isOwned,
            condition: ownedItem?.condition,
            grade: ownedItem?.grade,
            conditions: _conditions,
            grades: _grades,
            onConditionChanged: ownedItem == null
                ? null
                : (value) => _updateCollection(
                      context,
                      ref,
                      ownedItem,
                      condition: value,
                      grade: ownedItem.grade,
                    ),
            onGradeChanged: ownedItem == null
                ? null
                : (value) => _updateCollection(
                      context,
                      ref,
                      ownedItem,
                      condition: ownedItem.condition,
                      grade: value,
                    ),
          ),
          if (ownedItem != null) ...[
            const SizedBox(height: 12),
            _PersonalDetailsEditor(ownedItem: ownedItem),
          ],
          if (item!.synopsis != null)
            Text(item!.synopsis!,
                style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ComicDetailPage(item: item!),
              ),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open comic details'),
          ),
          const SizedBox(height: 8),
          if (isOwned)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      _showEditDialog(context, ref, item!, ownedItem),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _moveToWishlist(
                    context,
                    ref,
                    item!,
                    ownedItem,
                  ),
                  icon: const Icon(Icons.star_border),
                  label: const Text('Move to wishlist'),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _removeFromCollection(context, ref, ownedItem),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove'),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () => _addToCollection(context, ref, item!),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add to collection'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _toggleWishlist(context, ref, item!),
                  icon: Icon(
                    libraryState.isWishlisted ? Icons.star : Icons.star_border,
                  ),
                  label: Text(
                    libraryState.isWishlisted
                        ? 'Remove from wishlist'
                        : 'Move to wishlist',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _RichMetadataInspector(
            item: item!,
            detail: detail,
            libraryState: libraryState,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
    OwnedItem ownedItem,
  ) async {
    final selection = await showDialog<_OwnedComicEditSelection>(
      context: context,
      builder: (context) => _OwnedComicEditDialog(
        item: item,
        ownedItem: ownedItem,
        conditions: _conditions,
        grades: _grades,
      ),
    );
    if (selection == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).updateItem(
          ownedItem,
          condition: selection.condition,
          grade: selection.grade,
          purchaseDate: selection.purchaseDate,
          pricePaidCents: selection.pricePaidCents,
          currency: selection.currency,
          personalNotes: selection.personalNotes,
          quantity: selection.quantity,
          storageBox: selection.storageBox,
          indexNumber: selection.indexNumber,
          coverPriceCents: selection.coverPriceCents,
          rawOrSlabbed: selection.rawOrSlabbed,
          gradingCompany: selection.gradingCompany,
          graderNotes: selection.graderNotes,
          signedBy: selection.signedBy,
          keyComic: selection.keyComic,
          keyReason: selection.keyReason,
          rating: selection.rating,
          readStatus: selection.readStatus,
          tags: selection.tags,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comic details updated')),
      );
    }
  }

  Future<void> _addToCollection(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    await ref.read(collectionMutationsProvider).addItem(
          item.id,
          condition: 'Near Mint',
          grade: 'Ungraded',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to local collection')),
      );
    }
  }

  Future<void> _updateCollection(
    BuildContext context,
    WidgetRef ref,
    OwnedItem ownedItem, {
    required String? condition,
    required String? grade,
  }) async {
    await ref.read(collectionMutationsProvider).updateItem(
          ownedItem,
          condition: condition,
          grade: grade,
          purchaseDate: ownedItem.purchaseDate,
          pricePaidCents: ownedItem.pricePaidCents,
          currency: ownedItem.currency,
          personalNotes: ownedItem.personalNotes,
          quantity: ownedItem.quantity,
          storageBox: ownedItem.storageBox,
          indexNumber: ownedItem.indexNumber,
          coverPriceCents: ownedItem.coverPriceCents,
          rawOrSlabbed: ownedItem.rawOrSlabbed,
          gradingCompany: ownedItem.gradingCompany,
          graderNotes: ownedItem.graderNotes,
          signedBy: ownedItem.signedBy,
          keyComic: ownedItem.keyComic,
          keyReason: ownedItem.keyReason,
          rating: ownedItem.rating,
          readStatus: ownedItem.readStatus,
          tags: ownedItem.tags,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection details updated')),
      );
    }
  }

  Future<void> _removeFromCollection(
      BuildContext context, WidgetRef ref, OwnedItem ownedItem) async {
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from local collection')),
      );
    }
  }

  Future<void> _moveToWishlist(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
    OwnedItem ownedItem,
  ) async {
    await ref.read(collectionMutationsProvider).addToWishlist(item.id);
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moved to local wishlist')),
      );
    }
  }

  Future<void> _toggleWishlist(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    await ref.read(collectionMutationsProvider).toggleWishlist(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            libraryState.isWishlisted
                ? 'Removed from local wishlist'
                : 'Saved to local wishlist',
          ),
        ),
      );
    }
  }
}

class _RichMetadataInspector extends StatelessWidget {
  const _RichMetadataInspector({
    required this.item,
    required this.detail,
    required this.libraryState,
  });

  final CatalogItem item;
  final AsyncValue<ComicDetail>? detail;
  final _LibraryState libraryState;

  @override
  Widget build(BuildContext context) {
    final owned = libraryState.ownedItem;
    final detailValue = detail?.valueOrNull;
    final edition = detailValue?.primaryEdition;
    final variant = detailValue?.primaryVariant;
    final source = edition?.sourceMetadata;
    final creators = _metadataNames(source, 'person_credits');
    final characters = _metadataNames(source, 'character_credits');
    final arcs = _metadataNames(source, 'story_arc_credits');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InspectorSection(
          title: 'Metadata',
          children: [
            _InspectorFact('Publisher', edition?.publisher ?? '-'),
            _InspectorFact(
              'Release',
              edition?.releaseDate == null
                  ? '-'
                  : _formatDate(edition!.releaseDate!),
            ),
            _InspectorFact('Format', edition?.format ?? item.kind),
            _InspectorFact('Barcode', edition?.upc ?? edition?.isbn ?? '-'),
            _InspectorFact('Variant', variant?.name ?? '-'),
          ],
        ),
        _InspectorSection(
          title: 'Personal',
          children: [
            _InspectorFact('Quantity', owned?.quantity.toString() ?? '-'),
            _InspectorFact('Storage box', owned?.storageBox ?? '-'),
            _InspectorFact('Index', owned?.indexNumber?.toString() ?? '-'),
            _InspectorFact('Read status', owned?.readStatus ?? '-'),
            _InspectorFact('Tags', owned?.tags ?? '-'),
          ],
        ),
        _InspectorSection(
          title: 'Market',
          children: [
            _InspectorFact(
              'Purchase',
              _formatOptionalMoney(
                owned?.pricePaidCents,
                owned?.currency,
              ).ifEmpty('-'),
            ),
            _InspectorFact(
              'Cover price',
              _formatOptionalMoney(
                owned?.coverPriceCents,
                owned?.currency,
              ).ifEmpty('-'),
            ),
            _InspectorFact('Grade status', owned?.rawOrSlabbed ?? '-'),
            _InspectorFact('Grading company', owned?.gradingCompany ?? '-'),
            _InspectorFact('Key comic', owned?.keyComic == true ? 'Yes' : 'No'),
          ],
        ),
        if (creators.isNotEmpty)
          _InspectorChipSection(title: 'Creators', values: creators),
        if (characters.isNotEmpty)
          _InspectorChipSection(title: 'Characters', values: characters),
        if (arcs.isNotEmpty)
          _InspectorChipSection(title: 'Story arcs', values: arcs),
        if (detail?.isLoading ?? false)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  List<String> _metadataNames(Map<String, dynamic>? source, String key) {
    final values = source?[key];
    if (values is! List) {
      return const [];
    }
    return [
      for (final value in values)
        if (value is Map && value['name'] != null) value['name'].toString(),
    ];
  }
}

class _InspectorSection extends StatelessWidget {
  const _InspectorSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectorFact extends StatelessWidget {
  const _InspectorFact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _InspectorChipSection extends StatelessWidget {
  const _InspectorChipSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return _InspectorSection(
      title: title,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final value in values.take(8))
              Chip(label: Text(value), visualDensity: VisualDensity.compact),
          ],
        ),
      ],
    );
  }
}

class _CollectionFields extends StatelessWidget {
  const _CollectionFields({
    required this.enabled,
    required this.condition,
    required this.grade,
    required this.conditions,
    required this.grades,
    required this.onConditionChanged,
    required this.onGradeChanged,
  });

  final bool enabled;
  final String? condition;
  final String? grade;
  final List<String> conditions;
  final List<String> grades;
  final ValueChanged<String?>? onConditionChanged;
  final ValueChanged<String?>? onGradeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: conditions.contains(condition) ? condition : null,
            decoration: const InputDecoration(
              labelText: 'Condition',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in conditions)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onConditionChanged : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: grades.contains(grade) ? grade : null,
            decoration: const InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in grades)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onGradeChanged : null,
          ),
        ),
      ],
    );
  }
}

class _PersonalDetailsEditor extends ConsumerStatefulWidget {
  const _PersonalDetailsEditor({required this.ownedItem});

  final OwnedItem ownedItem;

  @override
  ConsumerState<_PersonalDetailsEditor> createState() =>
      _PersonalDetailsEditorState();
}

class _PersonalDetailsEditorState
    extends ConsumerState<_PersonalDetailsEditor> {
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  DateTime? _purchaseDate;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _currencyController = TextEditingController();
    _notesController = TextEditingController();
    _syncFromItem(widget.ownedItem);
  }

  @override
  void didUpdateWidget(covariant _PersonalDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownedItem.id != widget.ownedItem.id ||
        oldWidget.ownedItem.updatedAt != widget.ownedItem.updatedAt) {
      _syncFromItem(widget.ownedItem);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickPurchaseDate,
              icon: const Icon(Icons.event),
              label: Text(
                _purchaseDate == null
                    ? 'Set purchase date'
                    : 'Purchased ${_formatDate(_purchaseDate!)}',
              ),
            ),
            if (_purchaseDate != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _purchaseDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear purchase date'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price paid',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _currencyController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save personal details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFromItem(OwnedItem item) {
    _purchaseDate = item.purchaseDate;
    _priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    _currencyController.text = item.currency ?? 'USD';
    _notesController.text = item.personalNotes ?? '';
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _save() async {
    final price = _parsePriceCents(_priceController.text);
    final currency = _currencyController.text.trim().toUpperCase();
    await ref.read(collectionMutationsProvider).updateItem(
          widget.ownedItem,
          condition: widget.ownedItem.condition,
          grade: widget.ownedItem.grade,
          purchaseDate: _purchaseDate,
          pricePaidCents: price,
          currency: currency.isEmpty ? null : currency,
          personalNotes: _emptyToNull(_notesController.text),
          quantity: widget.ownedItem.quantity,
          storageBox: widget.ownedItem.storageBox,
          indexNumber: widget.ownedItem.indexNumber,
          coverPriceCents: widget.ownedItem.coverPriceCents,
          rawOrSlabbed: widget.ownedItem.rawOrSlabbed,
          gradingCompany: widget.ownedItem.gradingCompany,
          graderNotes: widget.ownedItem.graderNotes,
          signedBy: widget.ownedItem.signedBy,
          keyComic: widget.ownedItem.keyComic,
          keyReason: widget.ownedItem.keyReason,
          rating: widget.ownedItem.rating,
          readStatus: widget.ownedItem.readStatus,
          tags: widget.ownedItem.tags,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details saved')),
      );
    }
  }

  int? _parsePriceCents(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return widget.ownedItem.pricePaidCents;
    }
    return (parsed * 100).round();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _OwnedComicEditDialog extends StatefulWidget {
  const _OwnedComicEditDialog({
    required this.item,
    required this.ownedItem,
    required this.conditions,
    required this.grades,
  });

  final CatalogItem item;
  final OwnedItem ownedItem;
  final List<String> conditions;
  final List<String> grades;

  @override
  State<_OwnedComicEditDialog> createState() => _OwnedComicEditDialogState();
}

class _OwnedComicEditDialogState extends State<_OwnedComicEditDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  late final TextEditingController _quantityController;
  late final TextEditingController _storageBoxController;
  late final TextEditingController _indexNumberController;
  late final TextEditingController _coverPriceController;
  late final TextEditingController _gradingCompanyController;
  late final TextEditingController _graderNotesController;
  late final TextEditingController _signedByController;
  late final TextEditingController _keyReasonController;
  late final TextEditingController _ratingController;
  late final TextEditingController _readStatusController;
  late final TextEditingController _tagsController;
  late String? _condition = widget.ownedItem.condition;
  late String? _grade = widget.ownedItem.grade;
  late String? _rawOrSlabbed = widget.ownedItem.rawOrSlabbed ?? 'Raw';
  late bool _keyComic = widget.ownedItem.keyComic;
  late DateTime? _purchaseDate = widget.ownedItem.purchaseDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _priceController = TextEditingController(
      text: widget.ownedItem.pricePaidCents == null
          ? ''
          : (widget.ownedItem.pricePaidCents! / 100).toStringAsFixed(2),
    );
    _currencyController =
        TextEditingController(text: widget.ownedItem.currency ?? 'USD');
    _notesController =
        TextEditingController(text: widget.ownedItem.personalNotes ?? '');
    _quantityController =
        TextEditingController(text: widget.ownedItem.quantity.toString());
    _storageBoxController =
        TextEditingController(text: widget.ownedItem.storageBox ?? '');
    _indexNumberController = TextEditingController(
      text: widget.ownedItem.indexNumber?.toString() ?? '',
    );
    _coverPriceController = TextEditingController(
      text: widget.ownedItem.coverPriceCents == null
          ? ''
          : (widget.ownedItem.coverPriceCents! / 100).toStringAsFixed(2),
    );
    _gradingCompanyController =
        TextEditingController(text: widget.ownedItem.gradingCompany ?? '');
    _graderNotesController =
        TextEditingController(text: widget.ownedItem.graderNotes ?? '');
    _signedByController =
        TextEditingController(text: widget.ownedItem.signedBy ?? '');
    _keyReasonController =
        TextEditingController(text: widget.ownedItem.keyReason ?? '');
    _ratingController =
        TextEditingController(text: widget.ownedItem.rating?.toString() ?? '');
    _readStatusController =
        TextEditingController(text: widget.ownedItem.readStatus ?? '');
    _tagsController = TextEditingController(text: widget.ownedItem.tags ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _storageBoxController.dispose();
    _indexNumberController.dispose();
    _coverPriceController.dispose();
    _gradingCompanyController.dispose();
    _graderNotesController.dispose();
    _signedByController.dispose();
    _keyReasonController.dispose();
    _ratingController.dispose();
    _readStatusController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 720),
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit - ${widget.item.title} ${widget.item.itemNumber == null ? '' : '#${widget.item.itemNumber}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.article), text: 'Main'),
                Tab(icon: Icon(Icons.search), text: 'Details'),
                Tab(icon: Icon(Icons.attach_money), text: 'Value'),
                Tab(icon: Icon(Icons.person), text: 'Personal'),
                Tab(icon: Icon(Icons.image), text: 'Cover'),
                Tab(icon: Icon(Icons.notes), text: 'Plot'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _editMainTab(),
                  _editDetailsTab(),
                  _editValueTab(),
                  _editPersonalTab(),
                  _editCoverTab(),
                  _editPlotTab(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickPurchaseDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _purchaseDate == null
                          ? 'Set purchase date'
                          : _formatDate(_purchaseDate!),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editMainTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          initialValue: widget.item.title,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Series',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.item.itemNumber ?? '',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Issue No.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue:
                    widget.conditions.contains(_condition) ? _condition : null,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final option in widget.conditions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) => setState(() => _condition = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: widget.grades.contains(_grade) ? _grade : null,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final option in widget.grades)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) => setState(() => _grade = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 5,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Personal notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _editDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          initialValue: widget.item.id,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Collectarr Item ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.item.kind,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Format',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _editValueTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Purchase price',
                  prefixText: r'$ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _currencyController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _coverPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cover price',
                  prefixText: r'$ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _gradingCompanyController,
                decoration: const InputDecoration(
                  labelText: 'Grading company',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _graderNotesController,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Grader notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _editPersonalTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _storageBoxController,
                decoration: const InputDecoration(
                  labelText: 'Storage box',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: _indexNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Index',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Raw', label: Text('Raw')),
                  ButtonSegment(value: 'Slabbed', label: Text('Slabbed')),
                ],
                selected: {_rawOrSlabbed ?? 'Raw'},
                onSelectionChanged: (selection) =>
                    setState(() => _rawOrSlabbed = selection.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _signedByController,
                decoration: const InputDecoration(
                  labelText: 'Signed by',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _keyComic,
          onChanged: (value) => setState(() => _keyComic = value),
          title: const Text('Key comic'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keyReasonController,
          decoration: const InputDecoration(
            labelText: 'Key reason',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _readStatusController,
                decoration: const InputDecoration(
                  labelText: 'Read status',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _editCoverTab() {
    return Center(
      child: SizedBox(
        width: 220,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: _CoverImage(item: widget.item),
        ),
      ),
    );
  }

  Widget _editPlotTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.item.synopsis ?? 'No plot metadata available yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  void _submit() {
    final currency = _currencyController.text.trim().toUpperCase();
    Navigator.of(context).pop(
      _OwnedComicEditSelection(
        condition: _condition,
        grade: _grade,
        purchaseDate: _purchaseDate,
        pricePaidCents: _parseMoneyCents(
          _priceController.text,
          fallback: widget.ownedItem.pricePaidCents,
        ),
        currency: currency.isEmpty ? null : currency,
        personalNotes: _emptyToNull(_notesController.text),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        storageBox: _emptyToNull(_storageBoxController.text),
        indexNumber: int.tryParse(_indexNumberController.text.trim()),
        coverPriceCents: _parseMoneyCents(
          _coverPriceController.text,
          fallback: widget.ownedItem.coverPriceCents,
        ),
        rawOrSlabbed: _rawOrSlabbed,
        gradingCompany: _emptyToNull(_gradingCompanyController.text),
        graderNotes: _emptyToNull(_graderNotesController.text),
        signedBy: _emptyToNull(_signedByController.text),
        keyComic: _keyComic,
        keyReason: _emptyToNull(_keyReasonController.text),
        rating: int.tryParse(_ratingController.text.trim()),
        readStatus: _emptyToNull(_readStatusController.text),
        tags: _emptyToNull(_tagsController.text),
      ),
    );
  }
}

class _OwnedComicEditSelection {
  const _OwnedComicEditSelection({
    required this.condition,
    required this.grade,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    required this.quantity,
    required this.storageBox,
    required this.indexNumber,
    required this.coverPriceCents,
    required this.rawOrSlabbed,
    required this.gradingCompany,
    required this.graderNotes,
    required this.signedBy,
    required this.keyComic,
    required this.keyReason,
    required this.rating,
    required this.readStatus,
    required this.tags,
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? storageBox;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final String? tags;
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LibraryAwareCompactComicsView extends ConsumerWidget {
  const _LibraryAwareCompactComicsView({
    required this.items,
    required this.selectedItem,
    required this.selectedSeries,
    required this.queryController,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.hasActiveFilters,
    required this.coverSize,
    required this.onCoverSizeChanged,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onSelectItem,
    required this.onClearSeries,
  });

  final List<CatalogItem> items;
  final CatalogItem? selectedItem;
  final String? selectedSeries;
  final TextEditingController queryController;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final bool hasActiveFilters;
  final double coverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<CatalogItem> onSelectItem;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _CompactComicsView(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItem: selectedItem,
      selectedSeries: selectedSeries,
      queryController: queryController,
      onSearch: onSearch,
      onAddComic: onAddComic,
      onEditFilters: onEditFilters,
      hasActiveFilters: hasActiveFilters,
      coverSize: coverSize,
      onCoverSizeChanged: onCoverSizeChanged,
      onScanBarcode: onScanBarcode,
      onRefreshMetadata: onRefreshMetadata,
      onSelectItem: onSelectItem,
      onClearSeries: onClearSeries,
    );
  }
}

class _CompactComicsView extends StatelessWidget {
  const _CompactComicsView({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItem,
    required this.selectedSeries,
    required this.queryController,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.hasActiveFilters,
    required this.coverSize,
    required this.onCoverSizeChanged,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onSelectItem,
    required this.onClearSeries,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final CatalogItem? selectedItem;
  final String? selectedSeries;
  final TextEditingController queryController;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final bool hasActiveFilters;
  final double coverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<CatalogItem> onSelectItem;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Tooltip(
                  message: 'Add comics',
                  child: IconButton.filled(
                    onPressed: onAddComic,
                    icon: const Icon(Icons.add),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchBar(
                    controller: queryController,
                    hintText: 'Search comics...',
                    leading: const Icon(Icons.search),
                    onSubmitted: onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Filters',
                  child: Badge(
                    isLabelVisible: hasActiveFilters,
                    child: IconButton.filledTonal(
                      onPressed: onEditFilters,
                      icon: const Icon(Icons.filter_list),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Cover size',
                  child: IconButton.filledTonal(
                    onPressed: () => _showCompactCoverSizeSheet(
                      context,
                      coverSize,
                      onCoverSizeChanged,
                    ),
                    icon: const Icon(Icons.photo_size_select_large_outlined),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Scan barcode',
                  child: IconButton.filledTonal(
                    onPressed: onScanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Refresh metadata',
                  child: IconButton.filledTonal(
                    onPressed: onRefreshMetadata,
                    icon: const Icon(Icons.sync),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedSeries != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InputChip(
                  label: Text(selectedSeries!), onDeleted: onClearSeries),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: coverSize,
              mainAxisExtent: coverSize * 1.53,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _CoverTile(
                item: item,
                libraryState: _LibraryState(
                  ownedItem: ownedByItemId[item.id],
                  isWishlisted: wishlistIds.contains(item.id),
                ),
                selected: item.id == selectedItem?.id,
                onTap: () {
                  onSelectItem(item);
                  _showCompactInspector(context, item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

void _showCompactCoverSizeSheet(
  BuildContext context,
  double coverSize,
  ValueChanged<double> onCoverSizeChanged,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      var draftSize = coverSize;
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cover size',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  min: _kMinCoverSize,
                  max: _kMaxCoverSize,
                  divisions: 7,
                  value: draftSize,
                  onChanged: (value) {
                    setSheetState(() => draftSize = value);
                    onCoverSizeChanged(value);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showMissingIssuesDialog(BuildContext context, List<int> missingIssues) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Missing issues'),
        content: SizedBox(
          width: 360,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final issue in missingIssues) Chip(label: Text('#$issue')),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

void _showCompactInspector(BuildContext context, CatalogItem item) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: _LibraryAwareComicInspector(item: item),
      );
    },
  );
}

class _BulkEditDialog extends StatefulWidget {
  const _BulkEditDialog();

  @override
  State<_BulkEditDialog> createState() => _BulkEditDialogState();
}

class _BulkEditDialogState extends State<_BulkEditDialog> {
  String? _condition;
  String? _grade;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk edit'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Keep current')),
                for (final option in _ComicInspector._conditions)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (value) {
                setState(
                  () => _condition =
                      value == null || value.isEmpty ? null : value,
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _grade,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Keep current')),
                for (final option in _ComicInspector._grades)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (value) {
                setState(() =>
                    _grade = value == null || value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _BulkEditSelection(condition: _condition, grade: _grade),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _BulkEditSelection {
  const _BulkEditSelection({this.condition, this.grade});

  final String? condition;
  final String? grade;
}

class _ComicsFilterDialog extends StatefulWidget {
  const _ComicsFilterDialog({
    required this.initialSelection,
    required this.gradeOptions,
    required this.conditionOptions,
  });

  final _ComicsFilterSelection initialSelection;
  final List<String> gradeOptions;
  final List<String> conditionOptions;

  @override
  State<_ComicsFilterDialog> createState() => _ComicsFilterDialogState();
}

class _ComicsFilterDialogState extends State<_ComicsFilterDialog> {
  late _OwnershipFilter _ownershipFilter;
  String? _grade;
  String? _condition;

  @override
  void initState() {
    super.initState();
    _ownershipFilter = widget.initialSelection.ownershipFilter;
    _grade = widget.initialSelection.grade;
    _condition = widget.initialSelection.condition;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filters'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<_OwnershipFilter>(
              initialValue: _ownershipFilter,
              decoration: const InputDecoration(
                labelText: 'Shelf',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final filter in _OwnershipFilter.values)
                  DropdownMenuItem(
                    value: filter,
                    child: Text(_ownershipFilterLabel(filter)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _ownershipFilter = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue:
                  widget.gradeOptions.contains(_grade) ? _grade : null,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Any grade')),
                for (final grade in widget.gradeOptions)
                  DropdownMenuItem(value: grade, child: Text(grade)),
              ],
              onChanged: (value) {
                setState(() =>
                    _grade = value == null || value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: widget.conditionOptions.contains(_condition)
                  ? _condition
                  : null,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Any condition')),
                for (final condition in widget.conditionOptions)
                  DropdownMenuItem(value: condition, child: Text(condition)),
              ],
              onChanged: (value) {
                setState(
                  () => _condition =
                      value == null || value.isEmpty ? null : value,
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              const _ComicsFilterSelection(
                ownershipFilter: _OwnershipFilter.all,
              ),
            );
          },
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _ComicsFilterSelection(
                ownershipFilter: _ownershipFilter,
                grade: _grade,
                condition: _condition,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ComicsFilterSelection {
  const _ComicsFilterSelection({
    required this.ownershipFilter,
    this.grade,
    this.condition,
  });

  final _OwnershipFilter ownershipFilter;
  final String? grade;
  final String? condition;
}

String _ownershipFilterLabel(_OwnershipFilter filter) {
  return switch (filter) {
    _OwnershipFilter.all => 'All comics',
    _OwnershipFilter.owned => 'Owned',
    _OwnershipFilter.wishlist => 'Wishlist',
    _OwnershipFilter.missingGrade => 'Missing grade',
  };
}

class _AddComicDialog extends ConsumerStatefulWidget {
  const _AddComicDialog();

  @override
  ConsumerState<_AddComicDialog> createState() => _AddComicDialogState();
}

class _AddComicDialogState extends ConsumerState<_AddComicDialog> {
  final _controller = TextEditingController();
  final _seriesController = TextEditingController();
  final _issueController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _barcodeController = TextEditingController();
  var _serverResults = const <CatalogItem>[];
  var _providerResults = const <_ProviderCandidate>[];
  String? _selectedServerId;
  String? _selectedProviderId;
  final _checkedServerIds = <String>{};
  bool _searchedServer = false;
  bool _searchedProvider = false;
  bool _isSearchingServer = false;
  bool _isSearchingProvider = false;
  bool _isSubmitting = false;
  bool _includeVariants = true;
  bool _hideOwned = true;
  bool _showAdvancedFilters = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _seriesController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final shelf = ref.watch(shelfProvider).valueOrNull;
    final ownedItemIds = shelf == null
        ? const <String>{}
        : {
            for (final entry in shelf.entries)
              if (entry.ownedItem != null) entry.itemId,
          };
    final wishlistItemIds = shelf == null
        ? const <String>{}
        : {
            for (final entry in shelf.entries)
              if (entry.wishlistItem != null) entry.itemId,
          };
    final selectedItem = _selectedServerItem;
    final selectedCandidate = _selectedProviderCandidate;
    final selectedIsOwned =
        selectedItem != null && ownedItemIds.contains(selectedItem.id);
    final selectedIsWishlisted =
        selectedItem != null && wishlistItemIds.contains(selectedItem.id);
    final checkedItems = [
      for (final item in _serverResults)
        if (_checkedServerIds.contains(item.id) &&
            !ownedItemIds.contains(item.id) &&
            !wishlistItemIds.contains(item.id))
          item,
    ];
    final addItems = checkedItems.isNotEmpty
        ? checkedItems
        : [
            if (selectedItem != null &&
                !selectedIsOwned &&
                !selectedIsWishlisted)
              selectedItem,
          ];
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10A8D8),
          brightness: Brightness.dark,
          surface: const Color(0xFF1D1D1D),
        ),
      ),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 780),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              border: Border.all(color: const Color(0xFF5A5A5A)),
            ),
            child: Column(
              children: [
                _AddComicTitleBar(onClose: () => Navigator.of(context).pop()),
                _AddComicModeBar(
                  queryController: _controller,
                  seriesController: _seriesController,
                  issueController: _issueController,
                  publisherController: _publisherController,
                  yearController: _yearController,
                  barcodeController: _barcodeController,
                  showAdvancedFilters: _showAdvancedFilters,
                  isSearching: _isSearchingServer,
                  onAdvancedChanged: (value) =>
                      setState(() => _showAdvancedFilters = value),
                  onSearch: _searchServer,
                  onScanBarcode: _scanBarcode,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                    child: _DialogMessage(
                      icon: Icons.error_outline,
                      text: _error!,
                    ),
                  ),
                Expanded(
                  child: compact
                      ? Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: _AddComicResultPane(
                                serverResults: _serverResults,
                                providerResults: _providerResults,
                                ownedItemIds: ownedItemIds,
                                wishlistItemIds: wishlistItemIds,
                                selectedServerId: _selectedServerId,
                                selectedProviderId: _selectedProviderId,
                                checkedServerIds: _checkedServerIds,
                                includeVariants: _includeVariants,
                                hideOwned: _hideOwned,
                                searchedServer: _searchedServer,
                                searchedProvider: _searchedProvider,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: _isSearchingProvider,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideOwnedChanged: (value) =>
                                    setState(() => _hideOwned = value),
                                onSelectServer: (id) => setState(() {
                                  _selectedServerId = id;
                                  _selectedProviderId = null;
                                }),
                                onToggleServerCheck: _toggleServerCheck,
                                onCheckAllVisible: _checkServerItems,
                                onClearServerChecks: () =>
                                    setState(_checkedServerIds.clear),
                                onSelectProvider: (id) => setState(() {
                                  _selectedProviderId = id;
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchComicVine,
                              ),
                            ),
                            Expanded(
                              child: _AddComicPreviewPane(
                                item: selectedItem,
                                candidate: selectedCandidate,
                                selectedIsOwned: selectedIsOwned,
                                selectedIsWishlisted: selectedIsWishlisted,
                                searchedServer: _searchedServer,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: 320,
                              child: _AddComicResultPane(
                                serverResults: _serverResults,
                                providerResults: _providerResults,
                                ownedItemIds: ownedItemIds,
                                wishlistItemIds: wishlistItemIds,
                                selectedServerId: _selectedServerId,
                                selectedProviderId: _selectedProviderId,
                                checkedServerIds: _checkedServerIds,
                                includeVariants: _includeVariants,
                                hideOwned: _hideOwned,
                                searchedServer: _searchedServer,
                                searchedProvider: _searchedProvider,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: _isSearchingProvider,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideOwnedChanged: (value) =>
                                    setState(() => _hideOwned = value),
                                onSelectServer: (id) => setState(() {
                                  _selectedServerId = id;
                                  _selectedProviderId = null;
                                }),
                                onToggleServerCheck: _toggleServerCheck,
                                onCheckAllVisible: _checkServerItems,
                                onClearServerChecks: () =>
                                    setState(_checkedServerIds.clear),
                                onSelectProvider: (id) => setState(() {
                                  _selectedProviderId = id;
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchComicVine,
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: _AddComicPreviewPane(
                                item: selectedItem,
                                candidate: selectedCandidate,
                                selectedIsOwned: selectedIsOwned,
                                selectedIsWishlisted: selectedIsWishlisted,
                                searchedServer: _searchedServer,
                              ),
                            ),
                          ],
                        ),
                ),
                _AddComicBottomBar(
                  selectedItem: selectedItem,
                  selectedCandidate: selectedCandidate,
                  selectedIsOwned: selectedIsOwned,
                  selectedIsWishlisted: selectedIsWishlisted,
                  addCount: addItems.length,
                  isSubmitting: _isSubmitting,
                  onAddOwned: addItems.isEmpty
                      ? null
                      : () => _addServerComics(addItems, wishlist: false),
                  onAddWishlist: addItems.isEmpty
                      ? null
                      : () => _addServerComics(addItems, wishlist: true),
                  onPropose: selectedCandidate == null
                      ? null
                      : () => _proposeCandidate(selectedCandidate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CatalogItem? get _selectedServerItem {
    final id = _selectedServerId;
    if (id == null) {
      return null;
    }
    for (final item in _serverResults) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  _ProviderCandidate? get _selectedProviderCandidate {
    final id = _selectedProviderId;
    if (id == null) {
      return null;
    }
    for (final item in _providerResults) {
      if (item.providerItemId == id) {
        return item;
      }
    }
    return null;
  }

  Future<void> _searchServer() async {
    final query = _controller.text.trim();
    final series = _seriesController.text.trim();
    final issueNumber = _issueController.text.trim();
    final publisher = _publisherController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final barcode = _barcodeController.text.trim();
    if (query.isEmpty &&
        series.isEmpty &&
        issueNumber.isEmpty &&
        publisher.isEmpty &&
        barcode.isEmpty &&
        year == null) {
      return;
    }
    setState(() {
      _isSearchingServer = true;
      _searchedServer = true;
      _searchedProvider = false;
      _serverResults = const [];
      _providerResults = const [];
      _selectedServerId = null;
      _selectedProviderId = null;
      _checkedServerIds.clear();
      _error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).search(
            query,
            kind: 'comic',
            series: series,
            issueNumber: issueNumber,
            publisher: publisher,
            year: year,
            barcode: barcode,
            limit: 50,
          );
      final items = rows.map(CatalogItem.fromJson).toList(growable: false);
      await CatalogCacheRepository(ref.read(localDatabaseProvider))
          .upsertAll(items);
      if (!mounted) {
        return;
      }
      setState(() {
        _serverResults = items;
        _selectedServerId = items.isEmpty ? null : items.first.id;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Server metadata search failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSearchingServer = false);
      }
    }
  }

  Future<void> _searchComicVine() async {
    final query = _providerQuery;
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _isSearchingProvider = true;
      _searchedProvider = true;
      _providerResults = const [];
      _selectedProviderId = null;
      _error = null;
    });
    try {
      final rows = await ref
          .read(apiClientProvider)
          .searchProvider(provider: 'comicvine', query: query);
      final results =
          rows.map(_ProviderCandidate.fromJson).toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _providerResults = results;
        _selectedProviderId =
            results.isEmpty ? null : results.first.providerItemId;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'ComicVine search failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSearchingProvider = false);
      }
    }
  }

  String get _providerQuery {
    return [
      _controller.text.trim(),
      _seriesController.text.trim(),
      _issueController.text.trim(),
      _publisherController.text.trim(),
      _yearController.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  Future<void> _scanBarcode() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BarcodeScanSheet(),
    );
    if (code == null || !mounted) {
      return;
    }
    _barcodeController.text = code;
    await _lookupBarcode(code);
  }

  Future<void> _lookupBarcode(String code) async {
    setState(() {
      _isSearchingServer = true;
      _searchedServer = true;
      _searchedProvider = false;
      _serverResults = const [];
      _providerResults = const [];
      _selectedServerId = null;
      _selectedProviderId = null;
      _checkedServerIds.clear();
      _error = null;
    });
    try {
      final result =
          await ref.read(apiClientProvider).lookupBarcode(code, kind: 'comic');
      final item = CatalogItem.fromJson(result);
      await CatalogCacheRepository(ref.read(localDatabaseProvider))
          .upsertAll([item]);
      if (!mounted) {
        return;
      }
      setState(() {
        _serverResults = [item];
        _selectedServerId = item.id;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(
          () => _error = 'No Collectarr Core comic found for barcode $code');
    } finally {
      if (mounted) {
        setState(() => _isSearchingServer = false);
      }
    }
  }

  void _toggleServerCheck(String id) {
    setState(() {
      _selectedServerId = id;
      _selectedProviderId = null;
      if (_checkedServerIds.contains(id)) {
        _checkedServerIds.remove(id);
      } else {
        _checkedServerIds.add(id);
      }
    });
  }

  void _checkServerItems(Iterable<CatalogItem> items) {
    setState(() {
      _checkedServerIds
        ..clear()
        ..addAll(items.map((item) => item.id));
      if (items.isNotEmpty) {
        _selectedServerId = items.first.id;
        _selectedProviderId = null;
      }
    });
  }

  Future<void> _addServerComics(
    List<CatalogItem> items, {
    required bool wishlist,
  }) async {
    setState(() => _isSubmitting = true);
    await CatalogCacheRepository(ref.read(localDatabaseProvider))
        .upsertAll(items);
    final mutations = ref.read(collectionMutationsProvider);
    for (final item in items) {
      if (wishlist) {
        await mutations.addToWishlist(item.id);
      } else {
        await mutations.addItem(
          item.id,
          condition: 'Near Mint',
          grade: 'Ungraded',
        );
      }
    }
    ref.invalidate(shelfProvider);
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wishlist
              ? 'Saved ${items.length} comic${items.length == 1 ? '' : 's'} to local wishlist'
              : 'Added ${items.length} comic${items.length == 1 ? '' : 's'} to local collection',
        ),
      ),
    );
  }

  Future<void> _proposeCandidate(_ProviderCandidate candidate) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).createMetadataProposal(
            provider: candidate.provider,
            providerItemId: candidate.providerItemId,
            query: _providerQuery,
            title: candidate.title,
            summary: candidate.summary,
            imageUrl: candidate.imageUrl,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metadata proposal sent for review')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Metadata proposal failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _AddComicTitleBar extends StatelessWidget {
  const _AddComicTitleBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B5B5B), Color(0xFF2E2E2E)],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.public, color: Color(0xFF03A9DE), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Add Comics from Collectarr Core',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AddComicModeBar extends StatelessWidget {
  const _AddComicModeBar({
    required this.queryController,
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.showAdvancedFilters,
    required this.isSearching,
    required this.onAdvancedChanged,
    required this.onSearch,
    required this.onScanBarcode,
  });

  final TextEditingController queryController;
  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final bool showAdvancedFilters;
  final bool isSearching;
  final ValueChanged<bool> onAdvancedChanged;
  final VoidCallback onSearch;
  final VoidCallback onScanBarcode;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF333333),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _AddModeTab(
                          icon: Icons.view_list,
                          label: 'Add Comics',
                          selected: true,
                        ),
                        _AddModeTab(
                            icon: Icons.star_border, label: 'Pull List'),
                        _AddModeTab(
                          icon: Icons.calendar_month,
                          label: 'Daily Updates',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onScanBarcode,
                  icon: const Icon(Icons.barcode_reader, size: 18),
                  label: const Text('Scan barcode'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.menu, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: queryController,
                      onSubmitted: (_) => onSearch(),
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFF4A4A4A),
                        border: OutlineInputBorder(),
                        hintText: 'Search title, series, issue, publisher...',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  selected: showAdvancedFilters,
                  onSelected: onAdvancedChanged,
                  avatar: const Icon(Icons.tune, size: 18),
                  label: const Text('Filters'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: isSearching ? null : onSearch,
                  child: isSearching
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search Collectarr Core'),
                ),
              ],
            ),
            if (showAdvancedFilters) ...[
              const SizedBox(height: 8),
              _AdvancedSearchFilters(
                seriesController: seriesController,
                issueController: issueController,
                publisherController: publisherController,
                yearController: yearController,
                barcodeController: barcodeController,
                onSubmitted: onSearch,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdvancedSearchFilters extends StatelessWidget {
  const _AdvancedSearchFilters({
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.onSubmitted,
  });

  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterField(
          width: 210,
          controller: seriesController,
          label: 'Series',
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 92,
          controller: issueController,
          label: 'Issue #',
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 150,
          controller: publisherController,
          label: 'Publisher',
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 92,
          controller: yearController,
          label: 'Year',
          keyboardType: TextInputType.number,
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 210,
          controller: barcodeController,
          label: 'Barcode / UPC',
          keyboardType: TextInputType.number,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.width,
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.keyboardType,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF4A4A4A),
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

class _AddModeTab extends StatelessWidget {
  const _AddModeTab({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF202020) : const Color(0xFF444444),
        border: const Border(
          right: BorderSide(color: Color(0xFF1A1A1A)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF18B7EB)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AddComicResultPane extends StatelessWidget {
  const _AddComicResultPane({
    required this.serverResults,
    required this.providerResults,
    required this.ownedItemIds,
    required this.wishlistItemIds,
    required this.selectedServerId,
    required this.selectedProviderId,
    required this.checkedServerIds,
    required this.includeVariants,
    required this.hideOwned,
    required this.searchedServer,
    required this.searchedProvider,
    required this.isSearchingServer,
    required this.isSearchingProvider,
    required this.onIncludeVariantsChanged,
    required this.onHideOwnedChanged,
    required this.onSelectServer,
    required this.onToggleServerCheck,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onSelectProvider,
    required this.onSearchProvider,
  });

  final List<CatalogItem> serverResults;
  final List<_ProviderCandidate> providerResults;
  final Set<String> ownedItemIds;
  final Set<String> wishlistItemIds;
  final String? selectedServerId;
  final String? selectedProviderId;
  final Set<String> checkedServerIds;
  final bool includeVariants;
  final bool hideOwned;
  final bool searchedServer;
  final bool searchedProvider;
  final bool isSearchingServer;
  final bool isSearchingProvider;
  final ValueChanged<bool> onIncludeVariantsChanged;
  final ValueChanged<bool> onHideOwnedChanged;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onSelectProvider;
  final VoidCallback onSearchProvider;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF2E2E2E),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TinyCheckbox(
                    value: includeVariants,
                    label: 'Variants',
                    onChanged: onIncludeVariantsChanged,
                  ),
                  const SizedBox(width: 10),
                  _TinyCheckbox(
                    value: hideOwned,
                    label: 'Hide owned',
                    onChanged: onHideOwnedChanged,
                  ),
                  const SizedBox(width: 10),
                  const Text('Issues:'),
                  const SizedBox(width: 4),
                  const _IssueSortButton(label: 'III', selected: true),
                  const _IssueSortButton(label: 'Asc'),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Collectarr Core results',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: _buildResults(),
          ),
          if (serverResults.isEmpty && searchedServer)
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton.icon(
                onPressed: isSearchingProvider ? null : onSearchProvider,
                icon: const Icon(Icons.manage_search),
                label: Text(
                  searchedProvider
                      ? 'Search ComicVine again'
                      : 'Search ComicVine',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (isSearchingServer || isSearchingProvider) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!searchedServer) {
      return const Center(
        child: Text(
          'Search Collectarr Core to add comics to your local collection.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (serverResults.isNotEmpty) {
      final visibleResults = hideOwned
          ? serverResults
              .where((item) => !ownedItemIds.contains(item.id))
              .toList(growable: false)
          : serverResults;
      if (visibleResults.isEmpty) {
        return const Center(
          child: Text(
            'All matching comics are already in your local collection.',
            textAlign: TextAlign.center,
          ),
        );
      }
      final addable = visibleResults
          .where((item) =>
              !ownedItemIds.contains(item.id) &&
              !wishlistItemIds.contains(item.id))
          .toList(growable: false);
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Row(
              children: [
                Text('${checkedServerIds.length} selected'),
                const Spacer(),
                TextButton(
                  onPressed:
                      addable.isEmpty ? null : () => onCheckAllVisible(addable),
                  child: const Text('Select all'),
                ),
                TextButton(
                  onPressed:
                      checkedServerIds.isEmpty ? null : onClearServerChecks,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: visibleResults.length,
              itemBuilder: (context, index) {
                final item = visibleResults[index];
                final disabled = ownedItemIds.contains(item.id) ||
                    wishlistItemIds.contains(item.id);
                return _AddResultRow(
                  selected: item.id == selectedServerId,
                  checked: checkedServerIds.contains(item.id),
                  checkDisabled: disabled,
                  cover: SizedBox(
                    width: 42,
                    height: 62,
                    child: _CoverImage(item: item),
                  ),
                  title: item.itemNumber == null
                      ? item.title
                      : '${item.title} #${item.itemNumber}',
                  subtitle: item.synopsis ?? 'Metadata in Collectarr Core',
                  badges: [
                    if (ownedItemIds.contains(item.id)) 'Owned',
                    if (wishlistItemIds.contains(item.id)) 'Wishlist',
                  ],
                  trailing:
                      item.itemNumber == null ? '' : '#${item.itemNumber}',
                  onTap: () => onSelectServer(item.id),
                  onToggleCheck:
                      disabled ? null : () => onToggleServerCheck(item.id),
                );
              },
            ),
          ),
        ],
      );
    }
    if (providerResults.isNotEmpty) {
      return ListView.builder(
        itemCount: providerResults.length,
        itemBuilder: (context, index) {
          final item = providerResults[index];
          return _AddResultRow(
            selected: item.providerItemId == selectedProviderId,
            checked: false,
            checkDisabled: true,
            cover: SizedBox(
              width: 42,
              height: 62,
              child: _ProviderCandidateImage(candidate: item),
            ),
            title: item.title,
            subtitle: item.summary ?? 'ComicVine candidate',
            badges: const ['ComicVine'],
            trailing: 'propose',
            onTap: () => onSelectProvider(item.providerItemId),
            onToggleCheck: null,
          );
        },
      );
    }
    return const Center(
      child: Text(
        'No Collectarr Core matches yet. Try ComicVine to propose metadata.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TinyCheckbox extends StatelessWidget {
  const _TinyCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _IssueSortButton extends StatelessWidget {
  const _IssueSortButton({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      color: selected ? const Color(0xFF159AC8) : const Color(0xFF555555),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _AddResultRow extends StatelessWidget {
  const _AddResultRow({
    required this.selected,
    required this.checked,
    required this.checkDisabled,
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.trailing,
    required this.onTap,
    required this.onToggleCheck,
  });

  final bool selected;
  final bool checked;
  final bool checkDisabled;
  final Widget cover;
  final String title;
  final String subtitle;
  final List<String> badges;
  final String trailing;
  final VoidCallback onTap;
  final VoidCallback? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? const Color(0xFF214B55) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: checkDisabled ? null : (_) => onToggleCheck?.call(),
              visualDensity: VisualDensity.compact,
            ),
            cover,
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFFDDDDDD)),
                  ),
                  if (badges.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final badge in badges) _AddResultBadge(badge),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing.isNotEmpty)
              Text(trailing, style: const TextStyle(color: Color(0xFFBFEFFF))),
          ],
        ),
      ),
    );
  }
}

class _AddResultBadge extends StatelessWidget {
  const _AddResultBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0E81A6),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AddComicPreviewPane extends StatelessWidget {
  const _AddComicPreviewPane({
    required this.item,
    required this.candidate,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.searchedServer,
  });

  final CatalogItem? item;
  final _ProviderCandidate? candidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final bool searchedServer;

  @override
  Widget build(BuildContext context) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(
            searchedServer
                ? 'Select a result or search ComicVine.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final title = selectedItem?.title ?? selectedCandidate!.title;
    final issue = selectedItem?.itemNumber;
    final synopsis = selectedItem?.synopsis ?? selectedCandidate?.summary;
    final localStatus = selectedIsOwned
        ? 'In local collection'
        : selectedIsWishlisted
            ? 'In local wishlist'
            : 'Not in local shelf';
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF05AEEF),
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedItem == null
                            ? 'ComicVine candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                if (issue != null)
                  Text(
                    '# $issue',
                    style: const TextStyle(
                      color: Color(0xFF05AEEF),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const Divider(height: 28),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Plot',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        Text(synopsis ?? 'No plot metadata available yet.'),
                        const SizedBox(height: 22),
                        const Text(
                          'Details',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          selectedItem == null
                              ? 'Provider ID: ${selectedCandidate!.providerItemId}'
                              : 'Status: $localStatus\nLocal catalog ID: ${selectedItem.id}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 210,
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: selectedItem == null
                          ? _ProviderCandidateImage(
                              candidate: selectedCandidate!,
                            )
                          : _CoverImage(item: selectedItem),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddComicBottomBar extends StatelessWidget {
  const _AddComicBottomBar({
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.addCount,
    required this.isSubmitting,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onPropose,
  });

  final CatalogItem? selectedItem;
  final _ProviderCandidate? selectedCandidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final int addCount;
  final bool isSubmitting;
  final VoidCallback? onAddOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final isProposal = selectedItem == null && selectedCandidate != null;
    final label = selectedIsOwned
        ? 'Already in Collection'
        : isProposal
            ? 'Propose ComicVine Metadata'
            : 'Add ${addCount <= 1 ? 1 : addCount} Comic${addCount <= 1 ? '' : 's'} to Collection';
    return ColoredBox(
      color: const Color(0xFF262626),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: isSubmitting
                    ? null
                    : isProposal
                        ? onPropose
                        : onAddOwned,
                child: Text(label),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: selectedIsWishlisted
                  ? 'Already in wishlist'
                  : 'Add to wishlist',
              onPressed:
                  isSubmitting || selectedIsWishlisted ? null : onAddWishlist,
              icon: const Icon(Icons.star_border),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCandidateImage extends StatelessWidget {
  const _ProviderCandidateImage({required this.candidate});

  final _ProviderCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final imageUrl = candidate.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _GeneratedCover(
        item: CatalogItem(
          id: candidate.providerItemId,
          kind: 'comic',
          title: candidate.title,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _GeneratedCover(
          item: CatalogItem(
            id: candidate.providerItemId,
            kind: 'comic',
            title: candidate.title,
          ),
        ),
      ),
    );
  }
}

class _DialogMessage extends StatelessWidget {
  const _DialogMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _ProviderCandidate {
  const _ProviderCandidate({
    required this.provider,
    required this.providerItemId,
    required this.title,
    this.summary,
    this.imageUrl,
  });

  factory _ProviderCandidate.fromJson(Map<String, dynamic> json) {
    return _ProviderCandidate(
      provider: json['provider'] as String,
      providerItemId: json['provider_item_id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  final String provider;
  final String providerItemId;
  final String title;
  final String? summary;
  final String? imageUrl;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No comics found'));
  }
}

class _EmptyInspector extends StatelessWidget {
  const _EmptyInspector();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No comic selected'));
  }
}

class _SeriesBucket {
  const _SeriesBucket({required this.title, required this.count});

  final String title;
  final int count;
}

class _LibraryState {
  const _LibraryState({this.ownedItem, this.isWishlisted = false});

  final OwnedItem? ownedItem;
  final bool isWishlisted;

  bool get isOwned => ownedItem != null;
}

Set<String> _watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}

_LibraryState _libraryStateFor(
  CatalogItem? item,
  Map<String, OwnedItem> ownedByItemId,
  Set<String> wishlistIds,
) {
  if (item == null) {
    return const _LibraryState();
  }
  return _LibraryState(
    ownedItem: ownedByItemId[item.id],
    isWishlisted: wishlistIds.contains(item.id),
  );
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

T? _enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) {
    return null;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

extension _BlankStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
