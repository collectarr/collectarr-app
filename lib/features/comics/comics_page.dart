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
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kDesktopBreakpoint = 980;
const double _kMinCoverSize = 104;
const double _kDefaultCoverSize = 128;
const double _kMaxCoverSize = 188;
const double _kComicTableColumnSpacing = 14;
const double _kComicTableHorizontalMargin = 12;
const Color _kClzTopBar = Color(0xFF4DBBD5);
const Color _kClzToolbar = Color(0xFF2B2B2B);
const Color _kClzPanel = Color(0xFF1D1D1D);
const Color _kClzPanelRaised = Color(0xFF2F2F2F);
const Color _kClzCanvas = Color(0xFF141414);
const Color _kClzGridCanvas = Color(0xFF202020);
const Color _kClzAccent = Color(0xFF10A8D8);
const Color _kClzSelection = Color(0xFF075F75);
const Color _kClzYellow = Color(0xFFFFD400);
const Color _kClzDivider = Color(0xFF4A4A4A);
const Color _kClzTextMuted = Color(0xFFB8B8B8);

enum _OwnershipFilter { all, owned, wishlist, missingGrade }

enum _BulkToolbarAction { edit, wishlist, remove, clear }

enum _AddComicMode { search, barcode, pullList }

enum _AddComicTarget { owned, wishlist }

ThemeData _clzComicsTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: _kClzAccent,
    brightness: Brightness.dark,
    surface: _kClzPanel,
  );
  return base.copyWith(
    colorScheme: scheme.copyWith(
      primary: _kClzAccent,
      secondary: _kClzYellow,
      surface: _kClzPanel,
      surfaceContainerLowest: _kClzCanvas,
      surfaceContainerLow: _kClzPanel,
      surfaceContainer: _kClzToolbar,
      surfaceContainerHigh: _kClzPanelRaised,
      surfaceContainerHighest: const Color(0xFF3A3A3A),
      outline: _kClzDivider,
      outlineVariant: const Color(0xFF373737),
    ),
    scaffoldBackgroundColor: _kClzCanvas,
    dividerTheme: const DividerThemeData(
      color: _kClzDivider,
      thickness: 1,
      space: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF343434),
        disabledForegroundColor: const Color(0xFF777777),
        disabledBackgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _kClzAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: _kClzDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF101010),
      isDense: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: _kClzDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kClzDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kClzAccent),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF101010)),
      hintStyle: const WidgetStatePropertyAll(
        TextStyle(color: _kClzTextMuted),
      ),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          side: const BorderSide(color: _kClzDivider),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 10),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF343434),
      selectedColor: _kClzSelection,
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: _kClzDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _kClzPanel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: _kClzDivider),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: _kClzPanelRaised,
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(color: Colors.white),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF101010),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: _kClzDivider),
        ),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}

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
  double coverSize = _kDefaultCoverSize;
  Set<LibraryTableColumn> visibleColumns = _defaultComicTableColumns();
  Map<LibraryTableColumn, double> columnWidths = const {};
  _OwnershipFilter ownershipFilter = _OwnershipFilter.all;
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
          data: _clzComicsTheme(),
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
              return _ComicsWorkspace(
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
                onSortChanged: _handleSortChanged,
                onColumnWidthChanged: _handleColumnWidthChanged,
                onCoverSizeChanged: _handleCoverSizeChanged,
                onSelectionModeChanged: _setSelectionMode,
                onClearSelection: _clearSelection,
                onBulkEdit: () => _showBulkEditDialog(context, entries),
                onBulkMoveToWishlist: () => _bulkMoveToWishlist(entries),
                onBulkRemove: () => _bulkRemove(entries),
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
        (_formatNullableDate(item.releaseDate)?.contains(query) ?? false) ||
        (item.releaseYear?.toString().contains(query) ?? false) ||
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
    final selection = await showDialog<_ComicsFilterSelection>(
      context: context,
      builder: (context) => _ComicsFilterDialog(
        initialSelection: _ComicsFilterSelection(
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
        column: _clampComicTableColumnWidth(column, width),
      };
    });
    _saveViewPreferences();
  }

  Future<void> _showColumnChooser(BuildContext context) async {
    final selected = await showDialog<Set<LibraryTableColumn>>(
      context: context,
      builder: (context) =>
          _ColumnChooserDialog(selectedColumns: visibleColumns),
    );
    if (selected != null) {
      _handleVisibleColumnsChanged(selected);
    }
  }

  Future<void> _loadViewPreferences() async {
    final preferences =
        await LibraryWorkspacePreferences(comicsWorkspaceConfig).read(
      defaultCoverSize: _kDefaultCoverSize,
      minCoverSize: _kMinCoverSize,
      maxCoverSize: _kMaxCoverSize,
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
            MapEntry(column, _clampComicTableColumnWidth(column, width)),
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

class _ComicsWorkspace extends StatelessWidget {
  const _ComicsWorkspace({
    required this.items,
    required this.shelfState,
    required this.queryController,
    required this.selectedItemId,
    required this.selectedSeries,
    required this.viewMode,
    required this.detailsLayout,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required this.visibleColumns,
    required this.columnWidths,
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
    required this.onDetailsLayoutChanged,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final List<CatalogItem> items;
  final ShelfState shelfState;
  final TextEditingController queryController;
  final String? selectedItemId;
  final String? selectedSeries;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
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
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
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
        _ComicsTopBar(totalCount: items.length),
        _ComicsToolbar(
          controller: queryController,
          itemCount: visibleItems.length,
          totalCount: items.length,
          selectedSeries: selectedSeries,
          viewMode: viewMode,
          detailsLayout: detailsLayout,
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
          onDetailsLayoutChanged: onDetailsLayoutChanged,
          onCoverSizeChanged: onCoverSizeChanged,
          onSelectionModeChanged: onSelectionModeChanged,
          onClearSelection: onClearSelection,
          onBulkEdit: onBulkEdit,
          onBulkMoveToWishlist: onBulkMoveToWishlist,
          onBulkRemove: onBulkRemove,
        ),
        _ComicsStatsBar(
          state: shelfState,
          selectedSeries: selectedSeries,
          missingIssues: missingIssues,
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
                child: _DetailsAwareComicsLayout(
                  content: _LibraryAwareShelfContent(
                    viewMode: viewMode,
                    items: visibleItems,
                    selectedItemId: selectedItem?.id,
                    selectedItemIds: selectedItemIds,
                    coverSize: coverSize,
                    sortColumn: sortColumn,
                    sortAscending: sortAscending,
                    visibleColumns: visibleColumns,
                    columnWidths: columnWidths,
                    onSortChanged: onSortChanged,
                    onColumnWidthChanged: onColumnWidthChanged,
                    onAddComic: onAddComic,
                    onSelectItem: onSelectItem,
                  ),
                  detailsLayout: detailsLayout,
                  inspector: _LibraryAwareComicInspector(item: selectedItem),
                ),
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

class _LibraryAwareShelfContent extends StatelessWidget {
  const _LibraryAwareShelfContent({
    required this.viewMode,
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.sortColumn,
    required this.sortAscending,
    required this.visibleColumns,
    required this.columnWidths,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final LibraryViewMode viewMode;
  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return switch (viewMode) {
      LibraryViewMode.grid => _LibraryAwareCoverGrid(
          items: items,
          selectedItemId: selectedItemId,
          selectedItemIds: selectedItemIds,
          coverSize: coverSize,
          onAddComic: onAddComic,
          onSelectItem: onSelectItem,
        ),
      LibraryViewMode.card => _LibraryAwareCardGrid(
          items: items,
          selectedItemId: selectedItemId,
          selectedItemIds: selectedItemIds,
          coverSize: coverSize,
          onAddComic: onAddComic,
          onSelectItem: onSelectItem,
        ),
      LibraryViewMode.list => _LibraryAwareComicList(
          items: items,
          selectedItemId: selectedItemId,
          selectedItemIds: selectedItemIds,
          sortColumn: sortColumn,
          sortAscending: sortAscending,
          visibleColumns: visibleColumns,
          columnWidths: columnWidths,
          onSortChanged: onSortChanged,
          onColumnWidthChanged: onColumnWidthChanged,
          onAddComic: onAddComic,
          onSelectItem: onSelectItem,
        ),
    };
  }
}

class _DetailsAwareComicsLayout extends StatelessWidget {
  const _DetailsAwareComicsLayout({
    required this.content,
    required this.detailsLayout,
    required this.inspector,
  });

  final Widget content;
  final LibraryDetailsLayout detailsLayout;
  final Widget inspector;

  @override
  Widget build(BuildContext context) {
    return switch (detailsLayout) {
      LibraryDetailsLayout.right => Row(
          children: [
            Expanded(child: content),
            const VerticalDivider(width: 1),
            SizedBox(width: 340, child: inspector),
          ],
        ),
      LibraryDetailsLayout.bottom => Column(
          children: [
            Expanded(child: content),
            const Divider(height: 1),
            SizedBox(height: 310, child: inspector),
          ],
        ),
      LibraryDetailsLayout.hidden => content,
    };
  }
}

class _ComicsTopBar extends StatelessWidget {
  const _ComicsTopBar({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        color: _kClzTopBar,
        border: Border(bottom: BorderSide(color: Color(0xFF1B6F80))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_queue, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Collectarr Comics',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Text(
            '$totalCount local comics',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.grid_view, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          const Icon(Icons.person, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}

class _ComicsToolbar extends StatelessWidget {
  const _ComicsToolbar({
    required this.controller,
    required this.itemCount,
    required this.totalCount,
    required this.selectedSeries,
    required this.viewMode,
    required this.detailsLayout,
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
    required this.onDetailsLayoutChanged,
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
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
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
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kClzToolbar,
        border: Border(bottom: BorderSide(color: _kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              height: 32,
              child: FilledButton.icon(
                onPressed: onAddComic,
                style: FilledButton.styleFrom(
                  backgroundColor: _kClzYellow,
                  foregroundColor: const Color(0xFF151515),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Comics'),
              ),
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
            SizedBox(
              width: 320,
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
            if (selectedSeries != null) ...[
              const SizedBox(width: 8),
              InputChip(
                backgroundColor: _kClzSelection,
                label: Text(selectedSeries!),
                onDeleted: onClearSeries,
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message:
                            selectionMode ? 'Exit selection' : 'Select comics',
                        child: IconButton.filledTonal(
                          onPressed: () =>
                              onSelectionModeChanged(!selectionMode),
                          icon: Icon(
                              selectionMode ? Icons.close : Icons.checklist),
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
                                : () => _showMissingIssuesDialog(
                                      context,
                                      missingIssues,
                                    ),
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
                          onPressed: viewMode == LibraryViewMode.list
                              ? onEditColumns
                              : null,
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
                      SegmentedButton<LibraryViewMode>(
                        segments: const [
                          ButtonSegment(
                            value: LibraryViewMode.grid,
                            icon: Tooltip(
                              message: 'Cover view',
                              child: Icon(Icons.grid_view),
                            ),
                          ),
                          ButtonSegment(
                            value: LibraryViewMode.card,
                            icon: Tooltip(
                              message: 'Card view',
                              child: Icon(Icons.view_module),
                            ),
                          ),
                          ButtonSegment(
                            value: LibraryViewMode.list,
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
                      const SizedBox(width: 8),
                      SegmentedButton<LibraryDetailsLayout>(
                        segments: const [
                          ButtonSegment(
                            value: LibraryDetailsLayout.right,
                            icon: Tooltip(
                              message: 'Details right',
                              child: Icon(Icons.view_sidebar),
                            ),
                          ),
                          ButtonSegment(
                            value: LibraryDetailsLayout.bottom,
                            icon: Tooltip(
                              message: 'Details bottom',
                              child: Icon(Icons.vertical_split),
                            ),
                          ),
                          ButtonSegment(
                            value: LibraryDetailsLayout.hidden,
                            icon: Tooltip(
                              message: 'Hide details',
                              child: Icon(Icons.visibility_off),
                            ),
                          ),
                        ],
                        selected: {detailsLayout},
                        onSelectionChanged: (selection) =>
                            onDetailsLayoutChanged(selection.first),
                        showSelectedIcon: false,
                      ),
                    ],
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

class _ComicsStatsBar extends StatelessWidget {
  const _ComicsStatsBar({
    required this.state,
    required this.selectedSeries,
    required this.missingIssues,
  });

  final ShelfState state;
  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    final value = state.totalPaidCents == null
        ? '-'
        : _formatOptionalMoney(state.totalPaidCents, state.primaryCurrency);
    final missingMetadataCount = _missingMetadataCount(state.entries);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF181818),
        border: Border(bottom: BorderSide(color: _kClzDivider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    _StatsTile(
                      icon: Icons.menu_book,
                      label: 'Local comics',
                      value: state.entries.length.toString(),
                    ),
                    _StatsTile(
                      icon: Icons.check_box,
                      label: 'Owned',
                      value: state.ownedCount.toString(),
                    ),
                    _StatsTile(
                      icon: Icons.star,
                      label: 'Wishlist',
                      value: state.wishlistCount.toString(),
                    ),
                    _StatsTile(
                      icon: Icons.attach_money,
                      label: 'Value',
                      value: state.hasMixedCurrencies ? '$value +' : value,
                    ),
                    _StatsTile(
                      icon: Icons.workspace_premium,
                      label: 'Graded',
                      value: '${state.ownedCount - state.missingGradeCount}',
                    ),
                    _StatsTile(
                      icon: Icons.report_gmailerrorred,
                      label: 'Missing grade',
                      value: state.missingGradeCount.toString(),
                    ),
                    _StatsTile(
                      icon: Icons.cloud_off,
                      label: 'Missing metadata',
                      value: missingMetadataCount.toString(),
                    ),
                    _StatsTile(
                      icon: Icons.format_list_numbered,
                      label: selectedSeries == null
                          ? 'Missing issues'
                          : 'Missing in series',
                      value: missingIssues.length.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _StatsDistributionCard(
                      title: 'Grades',
                      values: state.gradeCounts,
                    ),
                    const SizedBox(width: 8),
                    _StatsDistributionCard(
                      title: 'Conditions',
                      values: state.conditionCounts,
                    ),
                    const SizedBox(width: 8),
                    _MissingIssuesCard(
                      selectedSeries: selectedSeries,
                      missingIssues: missingIssues,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  const _StatsTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF383838)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _kClzAccent),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: _kClzTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsDistributionCard extends StatelessWidget {
  const _StatsDistributionCard({
    required this.title,
    required this.values,
  });

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    return Container(
      width: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF383838)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _kClzAccent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            const Text(
              '-',
              style: TextStyle(color: _kClzTextMuted),
            )
          else
            for (final entry in entries.take(4))
              _DistributionRow(
                label: entry.key,
                count: entry.value,
                fraction: total == 0 ? 0 : entry.value / total,
              ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.label,
    required this.count,
    required this.fraction,
  });

  final String label;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction.clamp(0, 1),
                minHeight: 7,
                backgroundColor: const Color(0xFF151515),
                valueColor: const AlwaysStoppedAnimation(_kClzAccent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              count.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _kClzTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingIssuesCard extends StatelessWidget {
  const _MissingIssuesCard({
    required this.selectedSeries,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF383838)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedSeries == null ? 'Series gaps' : 'Gaps: $selectedSeries',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _kClzAccent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (selectedSeries == null)
            const Text(
              'Select a series',
              style: TextStyle(color: _kClzTextMuted, fontSize: 12),
            )
          else if (missingIssues.isEmpty)
            const Text(
              'No gaps',
              style: TextStyle(color: _kClzTextMuted, fontSize: 12),
            )
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final issue in missingIssues.take(10))
                  _MissingIssuePill(issue: issue),
                if (missingIssues.length > 10)
                  _MissingIssuePill(
                      issue: missingIssues.length - 10, more: true),
              ],
            ),
        ],
      ),
    );
  }
}

class _MissingIssuePill extends StatelessWidget {
  const _MissingIssuePill({required this.issue, this.more = false});

  final int issue;
  final bool more;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: _kClzAccent),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          more ? '+$issue' : '#$issue',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

int _missingMetadataCount(List<ShelfEntry> entries) {
  var count = 0;
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null ||
        item.displayCoverUrl == null ||
        item.publisher == null ||
        item.releaseDate == null ||
        item.synopsis == null) {
      count++;
    }
  }
  return count;
}

class _ColumnChooserDialog extends StatefulWidget {
  const _ColumnChooserDialog({required this.selectedColumns});

  final Set<LibraryTableColumn> selectedColumns;

  @override
  State<_ColumnChooserDialog> createState() => _ColumnChooserDialogState();
}

class _ColumnChooserDialogState extends State<_ColumnChooserDialog> {
  late var _selected = Set<LibraryTableColumn>.of(widget.selectedColumns);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = LibraryTableColumn.values
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
                            onChanged: column == LibraryTableColumn.title
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
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                      itemCount: selectedColumns.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final reordered =
                              selectedColumns.toList(growable: true);
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final column = reordered.removeAt(oldIndex);
                          reordered.insert(newIndex, column);
                          _selected = {
                            for (final column in reordered) column,
                          };
                        });
                      },
                      itemBuilder: (context, index) {
                        final column = selectedColumns[index];
                        return ListTile(
                          key: ValueKey(column),
                          dense: true,
                          leading: const Icon(Icons.drag_indicator),
                          title: Text(_comicTableColumnDisplayName(column)),
                          trailing: column == LibraryTableColumn.title
                              ? null
                              : IconButton(
                                  tooltip: 'Hide column',
                                  onPressed: () => setState(
                                    () => _selected.remove(column),
                                  ),
                                  icon: const Icon(Icons.close),
                                ),
                        );
                      },
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
                      final result = Set<LibraryTableColumn>.of(_selected)
                        ..add(LibraryTableColumn.title);
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
    return DecoratedBox(
      decoration: const BoxDecoration(color: _kClzPanel),
      child: Column(
        children: [
          Container(
            height: 42,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              border: Border(bottom: BorderSide(color: _kClzDivider)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder, size: 18, color: _kClzAccent),
                const SizedBox(width: 8),
                Text(
                  'Series',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: selected ? _kClzSelection : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                bucket.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white : _kClzTextMuted,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Badge(
              label: Text(bucket.count.toString()),
              backgroundColor: selected ? _kClzYellow : const Color(0xFF444444),
              textColor: selected ? const Color(0xFF171717) : Colors.white,
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
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
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
      onAddComic: onAddComic,
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
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(onAddComic: onAddComic);
    }
    return ColoredBox(
      color: _kClzGridCanvas,
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: coverSize,
          mainAxisExtent: coverSize * 1.53,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
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
      ),
    );
  }
}

class _LibraryAwareCardGrid extends ConsumerWidget {
  const _LibraryAwareCardGrid({
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _CardGrid(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItemId: selectedItemId,
      selectedItemIds: selectedItemIds,
      coverSize: coverSize,
      onAddComic: onAddComic,
      onSelectItem: onSelectItem,
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(onAddComic: onAddComic);
    }
    final cardHeight = (coverSize * 1.12).clamp(138.0, 174.0).toDouble();
    return ColoredBox(
      color: _kClzGridCanvas,
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 430,
          mainAxisExtent: cardHeight,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _ComicCard(
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
      ),
    );
  }
}

class _ComicCard extends StatelessWidget {
  const _ComicCard({
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
    final ownedItem = libraryState.ownedItem;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? _kClzSelection : const Color(0xFF181818),
          border: Border.all(
            color: selected ? _kClzAccent : const Color(0xFF363636),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverImage(item: item),
                  Positioned(
                    left: 4,
                    top: 4,
                    child: _CoverBadges(libraryState: libraryState),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF82DDF2),
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      if (item.itemNumber != null)
                        _IssuePill(label: '#${item.itemNumber}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (item.variant != null && item.variant!.isNotEmpty)
                        item.variant,
                      if (item.releaseDate != null)
                        _formatDate(item.releaseDate!),
                      if (item.publisher != null && item.publisher!.isNotEmpty)
                        item.publisher,
                    ].whereType<String>().join('  |  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _kClzTextMuted,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (ownedItem?.grade != null)
                        _CompactMetaPill(
                          icon: Icons.workspace_premium,
                          label: ownedItem!.grade!,
                        ),
                      if (ownedItem?.condition != null)
                        _CompactMetaPill(
                          icon: Icons.fact_check_outlined,
                          label: ownedItem!.condition!,
                        ),
                      if (ownedItem?.storageBox != null)
                        _CompactMetaPill(
                          icon: Icons.inventory_2_outlined,
                          label: ownedItem!.storageBox!,
                        ),
                      if (ownedItem?.pricePaidCents != null)
                        _CompactMetaPill(
                          icon: Icons.attach_money,
                          label: _formatOptionalMoney(
                            ownedItem!.pricePaidCents,
                            ownedItem.currency,
                          ),
                        ),
                      if (libraryState.isWishlisted)
                        const _CompactMetaPill(
                          icon: Icons.star,
                          label: 'Wishlist',
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.barcode == null || item.barcode!.isEmpty
                        ? 'No barcode'
                        : item.barcode!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF9A9A9A),
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

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kClzYellow,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CompactMetaPill extends StatelessWidget {
  const _CompactMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF4B4B4B)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: _kClzAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
    required this.columnWidths,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final VoidCallback onAddComic;
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
      columnWidths: columnWidths,
      onSortChanged: onSortChanged,
      onColumnWidthChanged: onColumnWidthChanged,
      onAddComic: onAddComic,
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
    required this.columnWidths,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Map<String, WishlistItem> wishlistByItemId;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(onAddComic: onAddComic);
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
        final tableWidth = _tableWidthForColumns(
          visibleColumns,
          columnWidths,
        );
        final contentWidth = tableWidth > constraints.maxWidth
            ? tableWidth + 16
            : constraints.maxWidth;
        return ColoredBox(
          color: _kClzCanvas,
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _ComicTableView(
                    entries: entries,
                    selectedItemId: selectedItemId,
                    selectedItemIds: selectedItemIds,
                    sortColumn: sortColumn,
                    sortAscending: sortAscending,
                    visibleColumns: visibleColumns,
                    columnWidths: columnWidths,
                    onSortChanged: onSortChanged,
                    onColumnWidthChanged: onColumnWidthChanged,
                    onSelectItem: onSelectItem,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ComicTableView extends StatelessWidget {
  const _ComicTableView({
    required this.entries,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.sortColumn,
    required this.sortAscending,
    required this.visibleColumns,
    required this.columnWidths,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onSelectItem,
  });

  final List<_ComicTableEntry> entries;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final columns = _orderedVisibleColumns(visibleColumns);
    return Column(
      children: [
        _ComicTableHeader(
          columns: columns,
          sortColumn: sortColumn,
          sortAscending: sortAscending,
          columnWidths: columnWidths,
          onSortChanged: onSortChanged,
          onColumnWidthChanged: onColumnWidthChanged,
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              primary: false,
              itemCount: entries.length,
              itemBuilder: (context, index) => _ComicTableRow(
                entry: entries[index],
                columns: columns,
                columnWidths: columnWidths,
                selected: selectedItemIds.contains(entries[index].item.id) ||
                    entries[index].item.id == selectedItemId,
                odd: index.isOdd,
                onTap: () => onSelectItem(entries[index].item),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ComicTableHeader extends StatelessWidget {
  const _ComicTableHeader({
    required this.columns,
    required this.sortColumn,
    required this.sortAscending,
    required this.columnWidths,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
  });

  final List<LibraryTableColumn> columns;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final Map<LibraryTableColumn, double> columnWidths;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF363636),
        border: Border(
          bottom: BorderSide(color: Color(0xFF4A4A4A)),
          top: BorderSide(color: Color(0xFF4A4A4A)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kComicTableHorizontalMargin,
        ),
        child: Row(
          children: [
            for (final column in columns) ...[
              _ComicTableHeaderCell(
                column: column,
                width: _comicTableColumnWidth(column, columnWidths),
                sorted: _comicTableColumnSort(column) == sortColumn,
                ascending: sortAscending,
                onSortChanged: onSortChanged,
                onColumnWidthChanged: onColumnWidthChanged,
              ),
              if (column != columns.last)
                const SizedBox(width: _kComicTableColumnSpacing),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComicTableHeaderCell extends StatelessWidget {
  const _ComicTableHeaderCell({
    required this.column,
    required this.width,
    required this.sorted,
    required this.ascending,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
  });

  final LibraryTableColumn column;
  final double width;
  final bool sorted;
  final bool ascending;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;

  @override
  Widget build(BuildContext context) {
    final sort = _comicTableColumnSort(column);
    return SizedBox(
      width: width,
      height: 34,
      child: Stack(
        children: [
          Positioned.fill(
            right: 8,
            child: InkWell(
              onTap: sort == null ? null : () => onSortChanged(sort),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _comicTableColumnLabel(column),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (sorted)
                    Icon(
                      ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 18,
                      color: _kClzAccent,
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  onColumnWidthChanged(column, width + details.delta.dx);
                },
                onDoubleTap: () => onColumnWidthChanged(
                  column,
                  _defaultComicTableColumnWidth(column),
                ),
                child: const SizedBox(
                  width: 10,
                  child: Center(
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFF6A6A6A),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicTableRow extends StatelessWidget {
  const _ComicTableRow({
    required this.entry,
    required this.columns,
    required this.columnWidths,
    required this.selected,
    required this.odd,
    required this.onTap,
  });

  final _ComicTableEntry entry;
  final List<LibraryTableColumn> columns;
  final Map<LibraryTableColumn, double> columnWidths;
  final bool selected;
  final bool odd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? _kClzSelection
              : odd
                  ? const Color(0xFF202020)
                  : const Color(0xFF181818),
          border: const Border(
            bottom: BorderSide(color: Color(0xFF2E2E2E)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kComicTableHorizontalMargin,
            vertical: 4,
          ),
          child: Row(
            children: [
              for (final column in columns) ...[
                SizedBox(
                  width: _comicTableColumnWidth(column, columnWidths),
                  height: 46,
                  child: Align(
                    alignment: _comicTableColumnIsNumeric(column)
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: _comicTableCellContent(entry, column),
                  ),
                ),
                if (column != columns.last)
                  const SizedBox(width: _kComicTableColumnSpacing),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

List<LibraryTableColumn> _orderedVisibleColumns(
    Set<LibraryTableColumn> columns) {
  final effective = columns.isEmpty ? _defaultComicTableColumns() : columns;
  return [
    for (final column in effective) column,
  ];
}

Set<LibraryTableColumn> _defaultComicTableColumns() =>
    Set.of(comicsWorkspaceConfig.defaultVisibleColumns);

double _tableWidthForColumns(
  Set<LibraryTableColumn> columns,
  Map<LibraryTableColumn, double> customWidths,
) {
  final orderedColumns = _orderedVisibleColumns(columns);
  final contentWidth = orderedColumns
      .map((column) => _comicTableColumnWidth(column, customWidths))
      .fold<double>(0, (total, width) => total + width);
  final spacing = orderedColumns.isEmpty
      ? 0.0
      : (orderedColumns.length - 1) * _kComicTableColumnSpacing;
  return contentWidth + spacing + (_kComicTableHorizontalMargin * 2);
}

double _comicTableColumnWidth(
  LibraryTableColumn column,
  Map<LibraryTableColumn, double> customWidths,
) {
  final customWidth = customWidths[column];
  if (customWidth != null) {
    return _clampComicTableColumnWidth(column, customWidth);
  }
  return _defaultComicTableColumnWidth(column);
}

double _defaultComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 58.0,
    LibraryTableColumn.cover => 52.0,
    LibraryTableColumn.title => 280.0,
    LibraryTableColumn.issue => 72.0,
    LibraryTableColumn.variant => 180.0,
    LibraryTableColumn.publisher => 150.0,
    LibraryTableColumn.releaseDate => 132.0,
    LibraryTableColumn.barcode => 170.0,
    LibraryTableColumn.grade => 104.0,
    LibraryTableColumn.condition => 138.0,
    LibraryTableColumn.price => 104.0,
    LibraryTableColumn.storageBox => 132.0,
    LibraryTableColumn.wishlist => 96.0,
    LibraryTableColumn.updated => 124.0,
  };
}

double _minComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 44.0,
    LibraryTableColumn.cover => 44.0,
    LibraryTableColumn.issue => 54.0,
    LibraryTableColumn.price => 78.0,
    LibraryTableColumn.wishlist => 70.0,
    _ => 86.0,
  };
}

double _maxComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 520.0,
    LibraryTableColumn.variant => 420.0,
    LibraryTableColumn.barcode => 260.0,
    _ => 260.0,
  };
}

double _clampComicTableColumnWidth(
  LibraryTableColumn column,
  double width,
) {
  return width
      .clamp(
        _minComicTableColumnWidth(column),
        _maxComicTableColumnWidth(column),
      )
      .toDouble();
}

String _comicTableColumnLabel(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => '',
    LibraryTableColumn.cover => '',
    LibraryTableColumn.title => 'Series',
    LibraryTableColumn.issue => 'Issue',
    LibraryTableColumn.variant => 'Variant',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.storageBox => 'Storage Box',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.updated => 'Updated',
  };
}

String _comicTableColumnDisplayName(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 'Status',
    LibraryTableColumn.cover => 'Cover',
    LibraryTableColumn.title => 'Series',
    LibraryTableColumn.issue => 'Issue',
    LibraryTableColumn.variant => 'Variant',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.storageBox => 'Storage Box',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.updated => 'Updated',
  };
}

bool _comicTableColumnIsNumeric(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.issue || LibraryTableColumn.price => true,
    _ => false,
  };
}

LibrarySortColumn? _comicTableColumnSort(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.cover => null,
    LibraryTableColumn.status => LibrarySortColumn.status,
    LibraryTableColumn.title => LibrarySortColumn.title,
    LibraryTableColumn.issue => LibrarySortColumn.issue,
    LibraryTableColumn.variant => LibrarySortColumn.variant,
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.storageBox => LibrarySortColumn.storageBox,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
    LibraryTableColumn.updated => LibrarySortColumn.updated,
  };
}

Widget _comicTableCellContent(
  _ComicTableEntry entry,
  LibraryTableColumn column,
) {
  return switch (column) {
    LibraryTableColumn.status => _StatusCell(entry: entry),
    LibraryTableColumn.cover => SizedBox(
        width: 36,
        height: 54,
        child: _CoverImage(item: entry.item),
      ),
    LibraryTableColumn.title => SizedBox(
        width: 280,
        child: Text(
          entry.item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    LibraryTableColumn.issue => Text(entry.item.itemNumber ?? ''),
    LibraryTableColumn.variant => _CellText(entry.item.variant),
    LibraryTableColumn.publisher => _CellText(entry.item.publisher),
    LibraryTableColumn.releaseDate =>
      _CellText(_formatNullableDate(entry.item.releaseDate)),
    LibraryTableColumn.barcode => _CellText(entry.item.barcode),
    LibraryTableColumn.grade => _CellText(entry.ownedItem?.grade),
    LibraryTableColumn.condition => _CellText(entry.ownedItem?.condition),
    LibraryTableColumn.price => Text(
        _formatOptionalMoney(
          entry.ownedItem?.pricePaidCents,
          entry.ownedItem?.currency,
        ),
      ),
    LibraryTableColumn.storageBox => _CellText(entry.ownedItem?.storageBox),
    LibraryTableColumn.wishlist =>
      entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
    LibraryTableColumn.updated => Text(_formatDate(entry.updatedAt)),
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

class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.entry});

  final _ComicTableEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          entry.isOwned ? Icons.check_box : Icons.check_box_outline_blank,
          size: 18,
          color: entry.isOwned ? colorScheme.primary : colorScheme.outline,
        ),
        if (entry.isWishlisted) ...[
          const SizedBox(width: 4),
          Icon(Icons.star, size: 17, color: colorScheme.tertiary),
        ],
      ],
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

  bool get isOwned => ownedItem != null;
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
  LibrarySortColumn column,
  bool ascending,
) {
  final result = switch (column) {
    LibrarySortColumn.status => _compareBools(a.isOwned, b.isOwned),
    LibrarySortColumn.title =>
      _compareNullableStrings(a.item.title, b.item.title),
    LibrarySortColumn.issue => _compareIssueNumbers(
        a.item.itemNumber,
        b.item.itemNumber,
      ),
    LibrarySortColumn.variant => _compareNullableStrings(
        a.item.variant,
        b.item.variant,
      ),
    LibrarySortColumn.publisher => _compareNullableStrings(
        a.item.publisher,
        b.item.publisher,
      ),
    LibrarySortColumn.releaseDate => _compareNullableDates(
        a.item.releaseDate,
        b.item.releaseDate,
      ),
    LibrarySortColumn.barcode => _compareNullableStrings(
        a.item.barcode,
        b.item.barcode,
      ),
    LibrarySortColumn.grade => _compareNullableStrings(
        a.ownedItem?.grade,
        b.ownedItem?.grade,
      ),
    LibrarySortColumn.condition => _compareNullableStrings(
        a.ownedItem?.condition,
        b.ownedItem?.condition,
      ),
    LibrarySortColumn.price => _compareNullableInts(
        a.ownedItem?.pricePaidCents,
        b.ownedItem?.pricePaidCents,
      ),
    LibrarySortColumn.storageBox => _compareNullableStrings(
        a.ownedItem?.storageBox,
        b.ownedItem?.storageBox,
      ),
    LibrarySortColumn.wishlist => _compareBools(a.isWishlisted, b.isWishlisted),
    LibrarySortColumn.updated => a.updatedAt.compareTo(b.updatedAt),
  };
  if (result != 0) {
    return ascending ? result : -result;
  }
  return _compareNullableStrings(a.item.title, b.item.title);
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

int _compareNullableDates(DateTime? left, DateTime? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
    right ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: selected ? _kClzSelection : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: selected ? _kClzAccent : const Color(0xFF3C3C3C),
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
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
                        child: Icon(Icons.check_circle, color: _kClzYellow),
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? Colors.white : _kClzTextMuted,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
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
    final ownedItem = libraryState.ownedItem;
    final isOwned = ownedItem != null;
    final detail =
        item == null ? null : ref.watch(comicDetailProvider(item!.id));
    if (item == null) {
      return const _EmptyInspector();
    }
    return Stack(
      children: [
        Positioned.fill(child: _InspectorBackdrop(item: item!)),
        DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xC91D1D1D)),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _InspectorActionBar(
                isOwned: isOwned,
                isWishlisted: libraryState.isWishlisted,
                onEdit: ownedItem == null
                    ? null
                    : () => _showEditDialog(context, ref, item!, ownedItem),
                onWishlist: () => _toggleWishlist(context, ref, item!),
                onOpenDetails: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ComicDetailPage(item: item!),
                  ),
                ),
                onCorrectMetadata: () => showMetadataCorrectionDialog(
                  context: context,
                  ref: ref,
                  item: item!,
                ),
              ),
              const SizedBox(height: 8),
              _InspectorHero(item: item!, libraryState: libraryState),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
                        libraryState.isWishlisted
                            ? Icons.star
                            : Icons.star_border,
                      ),
                      label: Text(
                        libraryState.isWishlisted
                            ? 'Remove from wishlist'
                            : 'Move to wishlist',
                      ),
                    ),
                  ],
                ),
              if (ownedItem != null) ...[
                const SizedBox(height: 12),
                _PersonalDetailsEditor(ownedItem: ownedItem),
              ],
              if (item!.synopsis != null) ...[
                const SizedBox(height: 12),
                _InspectorSection(
                  title: 'Plot',
                  children: [
                    Text(
                      item!.synopsis!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _RichMetadataInspector(
                item: item!,
                detail: detail,
                libraryState: libraryState,
              ),
            ],
          ),
        ),
      ],
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

class _InspectorBackdrop extends StatelessWidget {
  const _InspectorBackdrop({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.34,
          child: _CoverImage(item: item),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xAA101010),
                Color(0xE4181818),
                Color(0xF5181818),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InspectorActionBar extends StatelessWidget {
  const _InspectorActionBar({
    required this.isOwned,
    required this.isWishlisted,
    required this.onEdit,
    required this.onWishlist,
    required this.onOpenDetails,
    required this.onCorrectMetadata,
  });

  final bool isOwned;
  final bool isWishlisted;
  final VoidCallback? onEdit;
  final VoidCallback onWishlist;
  final VoidCallback onOpenDetails;
  final VoidCallback onCorrectMetadata;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB5242424),
        border: Border.all(color: const Color(0x663C3C3C)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Edit comic',
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
            ),
            IconButton(
              tooltip: 'Wishlist',
              onPressed: onWishlist,
              icon: Icon(
                isWishlisted ? Icons.star : Icons.star_border,
                size: 18,
              ),
            ),
            IconButton(
              tooltip: 'Open details',
              onPressed: onOpenDetails,
              icon: const Icon(Icons.open_in_new, size: 18),
            ),
            IconButton(
              tooltip: 'Correct metadata',
              onPressed: onCorrectMetadata,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
            ),
            const Spacer(),
            Icon(
              isOwned ? Icons.check_box : Icons.check_box_outline_blank,
              color: isOwned ? _kClzAccent : _kClzTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectorHero extends StatelessWidget {
  const _InspectorHero({required this.item, required this.libraryState});

  final CatalogItem item;
  final _LibraryState libraryState;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final cover = SizedBox(
          width: wide ? 150 : 178,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xAAFFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 16,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: _CoverImage(item: item),
            ),
          ),
        );
        final info = _InspectorHeroInfo(
          item: item,
          libraryState: libraryState,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xBA0D0D0D),
            border: Border.all(color: const Color(0x664DBBD5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 16),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cover,
                      const SizedBox(height: 12),
                      info,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _InspectorHeroInfo extends StatelessWidget {
  const _InspectorHeroInfo({required this.item, required this.libraryState});

  final CatalogItem item;
  final _LibraryState libraryState;

  @override
  Widget build(BuildContext context) {
    final ownedItem = libraryState.ownedItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _kClzAccent,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
              ),
            ),
            if (item.itemNumber != null) ...[
              const SizedBox(width: 8),
              _IssuePill(label: '#${item.itemNumber}'),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          [
            if (item.variant != null && item.variant!.isNotEmpty) item.variant,
            if (item.publisher != null && item.publisher!.isNotEmpty)
              item.publisher,
            if (item.releaseDate != null) _formatDate(item.releaseDate!),
          ].whereType<String>().join('  |  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _MetaChip(
              icon: Icons.inventory_2,
              label: libraryState.isOwned ? 'Owned' : 'Not owned',
            ),
            _MetaChip(
              icon: libraryState.isWishlisted ? Icons.star : Icons.star_border,
              label: libraryState.isWishlisted ? 'Wishlisted' : 'Wishlist',
            ),
            _MetaChip(
              icon: Icons.workspace_premium,
              label: ownedItem?.grade ?? 'Ungraded',
            ),
            if (ownedItem?.condition != null)
              _MetaChip(
                icon: Icons.fact_check_outlined,
                label: ownedItem!.condition!,
              ),
            if (ownedItem?.pricePaidCents != null)
              _MetaChip(
                icon: Icons.attach_money,
                label: _formatOptionalMoney(
                  ownedItem!.pricePaidCents,
                  ownedItem.currency,
                ),
              ),
          ],
        ),
        if (item.barcode != null && item.barcode!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.view_week_outlined, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.barcode!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.1,
                        color: _kClzTextMuted,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
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
    final providerFacts = _providerFacts(edition);
    final tracking = owned?.mediaTracking;
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
            _InspectorFact('UPC / ISBN', edition?.upc ?? edition?.isbn ?? '-'),
            _InspectorFact('Variant cover', variant?.name ?? '-'),
          ],
        ),
        if (providerFacts.isNotEmpty)
          _InspectorSection(
            title: 'Provider links',
            children: [
              for (final fact in providerFacts)
                _InspectorFact(fact.label, fact.value),
            ],
          ),
        _InspectorSection(
          title: 'Local details',
          children: [
            _InspectorFact('Quantity', owned?.quantity.toString() ?? '-'),
            _InspectorFact('Storage box', owned?.storageBox ?? '-'),
            _InspectorFact('Index', owned?.indexNumber?.toString() ?? '-'),
            _InspectorFact('Tracking', tracking?.statusLabel ?? '-'),
            _InspectorFact('Rating', tracking?.rating?.toString() ?? '-'),
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
            _InspectorFact('Key issue', owned?.keyComic == true ? 'Yes' : 'No'),
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

  List<_InspectorFactData> _providerFacts(ComicEdition? edition) {
    final metadata = edition?.metadataJson;
    final source = edition?.sourceMetadata;
    final releaseIds = edition?.releases
            .map((release) => release.externalIds)
            .whereType<Map<String, dynamic>>()
            .expand((ids) => ids.entries)
            .map((entry) => '${entry.key}: ${entry.value}')
            .toSet()
            .join(', ') ??
        '';
    return [
      if (metadata?['provider'] != null)
        _InspectorFactData('Provider', metadata!['provider'].toString()),
      if (metadata?['provider_item_id'] != null)
        _InspectorFactData(
          'Provider ID',
          metadata!['provider_item_id'].toString(),
        ),
      if (source?['site_detail_url'] != null)
        _InspectorFactData('Source URL', source!['site_detail_url'].toString()),
      if (source?['api_detail_url'] != null)
        _InspectorFactData('API URL', source!['api_detail_url'].toString()),
      if (releaseIds.isNotEmpty) _InspectorFactData('Release IDs', releaseIds),
    ];
  }
}

class _InspectorFactData {
  const _InspectorFactData(this.label, this.value);

  final String label;
  final String value;
}

class _InspectorSection extends StatelessWidget {
  const _InspectorSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFF363636)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _kClzAccent,
                      fontWeight: FontWeight.w900,
                    ),
              ),
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _kClzTextMuted,
                    fontWeight: FontWeight.w800,
                  ),
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
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: Theme.of(context).dialogTheme.copyWith(
                backgroundColor: _kClzPanel,
                surfaceTintColor: Colors.transparent,
              ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF101010),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            labelStyle: TextStyle(color: _kClzTextMuted),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: _kClzDivider),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _kClzDivider),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _kClzAccent),
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
          child: Column(
            children: [
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: _kClzToolbar,
                child: Row(
                  children: [
                    const Icon(Icons.edit_note, color: _kClzAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit - ${widget.item.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            widget.item.itemNumber == null
                                ? 'Personal local copy'
                                : 'Issue #${widget.item.itemNumber} - local copy',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _kClzTextMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.item.itemNumber != null)
                      _IssuePill(label: '#${widget.item.itemNumber}'),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              ColoredBox(
                color: _kClzPanelRaised,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: _kClzTextMuted,
                  indicatorColor: _kClzAccent,
                  dividerColor: _kClzDivider,
                  tabs: const [
                    Tab(icon: Icon(Icons.article), text: 'Main'),
                    Tab(icon: Icon(Icons.search), text: 'Details'),
                    Tab(icon: Icon(Icons.attach_money), text: 'Value'),
                    Tab(icon: Icon(Icons.person), text: 'Personal'),
                    Tab(icon: Icon(Icons.image), text: 'Cover'),
                    Tab(icon: Icon(Icons.notes), text: 'Plot'),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: colorScheme.surfaceContainerLowest,
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
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          _tabController.index == 0 ? null : _previousTab,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed:
                          _tabController.index == _tabController.length - 1
                              ? null
                              : _nextTab,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                    ),
                    const SizedBox(width: 12),
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

  void _previousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  void _nextTab() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
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
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(onAddComic: onAddComic),
          )
        else
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
    required this.publisherOptions,
    required this.releaseYearOptions,
  });

  final _ComicsFilterSelection initialSelection;
  final List<String> gradeOptions;
  final List<String> conditionOptions;
  final List<String> publisherOptions;
  final List<String> releaseYearOptions;

  @override
  State<_ComicsFilterDialog> createState() => _ComicsFilterDialogState();
}

class _ComicsFilterDialogState extends State<_ComicsFilterDialog> {
  late _OwnershipFilter _ownershipFilter;
  String? _grade;
  String? _condition;
  String? _publisher;
  String? _releaseYear;

  @override
  void initState() {
    super.initState();
    _ownershipFilter = widget.initialSelection.ownershipFilter;
    _grade = widget.initialSelection.grade;
    _condition = widget.initialSelection.condition;
    _publisher = widget.initialSelection.publisher;
    _releaseYear = widget.initialSelection.releaseYear;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filters'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
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
              _StringFilterDropdown(
                label: 'Publisher',
                emptyLabel: 'Any publisher',
                value: _publisher,
                options: widget.publisherOptions,
                onChanged: (value) => setState(() => _publisher = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Year',
                emptyLabel: 'Any year',
                value: _releaseYear,
                options: widget.releaseYearOptions,
                onChanged: (value) => setState(() => _releaseYear = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Grade',
                emptyLabel: 'Any grade',
                value: _grade,
                options: widget.gradeOptions,
                onChanged: (value) => setState(() => _grade = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Condition',
                emptyLabel: 'Any condition',
                value: _condition,
                options: widget.conditionOptions,
                onChanged: (value) => setState(() => _condition = value),
              ),
            ],
          ),
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
                publisher: _publisher,
                releaseYear: _releaseYear,
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
    this.publisher,
    this.releaseYear,
  });

  final _OwnershipFilter ownershipFilter;
  final String? grade;
  final String? condition;
  final String? publisher;
  final String? releaseYear;
}

class _StringFilterDropdown extends StatelessWidget {
  const _StringFilterDropdown({
    required this.label,
    required this.emptyLabel,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String emptyLabel;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: '', child: Text(emptyLabel)),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) {
        onChanged(value == null || value.isEmpty ? null : value);
      },
    );
  }
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
  final _defaultStorageBoxController = TextEditingController();
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
  bool _hideInShelf = true;
  bool _showAdvancedFilters = false;
  _AddComicMode _mode = _AddComicMode.search;
  _AddComicTarget _addTarget = _AddComicTarget.owned;
  String? _defaultCondition = 'Near Mint';
  String? _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _seriesController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    _defaultStorageBoxController.dispose();
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
                  mode: _mode,
                  queryController: _controller,
                  seriesController: _seriesController,
                  issueController: _issueController,
                  publisherController: _publisherController,
                  yearController: _yearController,
                  barcodeController: _barcodeController,
                  showAdvancedFilters: _showAdvancedFilters,
                  isSearching: _isSearchingServer,
                  onModeChanged: (value) => setState(() => _mode = value),
                  onAdvancedChanged: (value) =>
                      setState(() => _showAdvancedFilters = value),
                  onSearch: _searchServer,
                  onLookupBarcode: () =>
                      _lookupBarcode(_barcodeController.text.trim()),
                  onScanBarcode: _scanBarcode,
                  onAddManual: _addManualComic,
                  onProposeManual: _proposeManualComic,
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
                                mode: _mode,
                                serverResults: _serverResults,
                                providerResults: _providerResults,
                                ownedItemIds: ownedItemIds,
                                wishlistItemIds: wishlistItemIds,
                                selectedServerId: _selectedServerId,
                                selectedProviderId: _selectedProviderId,
                                checkedServerIds: _checkedServerIds,
                                includeVariants: _includeVariants,
                                hideInShelf: _hideInShelf,
                                searchedServer: _searchedServer,
                                searchedProvider: _searchedProvider,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: _isSearchingProvider,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideInShelfChanged: (value) =>
                                    setState(() => _hideInShelf = value),
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
                                mode: _mode,
                                serverResults: _serverResults,
                                providerResults: _providerResults,
                                ownedItemIds: ownedItemIds,
                                wishlistItemIds: wishlistItemIds,
                                selectedServerId: _selectedServerId,
                                selectedProviderId: _selectedProviderId,
                                checkedServerIds: _checkedServerIds,
                                includeVariants: _includeVariants,
                                hideInShelf: _hideInShelf,
                                searchedServer: _searchedServer,
                                searchedProvider: _searchedProvider,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: _isSearchingProvider,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideInShelfChanged: (value) =>
                                    setState(() => _hideInShelf = value),
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
                  addTarget: _addTarget,
                  addCount: addItems.length,
                  isSubmitting: _isSubmitting,
                  defaultCondition: _defaultCondition,
                  defaultGrade: _defaultGrade,
                  defaultStorageBoxController: _defaultStorageBoxController,
                  defaultPurchaseDate: _defaultPurchaseDate,
                  onAddTargetChanged: (value) =>
                      setState(() => _addTarget = value),
                  onDefaultConditionChanged: (value) =>
                      setState(() => _defaultCondition = value),
                  onDefaultGradeChanged: (value) =>
                      setState(() => _defaultGrade = value),
                  onDefaultPurchaseDateChanged: (value) =>
                      setState(() => _defaultPurchaseDate = value),
                  onAdd: addItems.isEmpty
                      ? null
                      : () => _addServerComics(
                            addItems,
                            wishlist: _addTarget == _AddComicTarget.wishlist,
                          ),
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
    if (code.isEmpty) {
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
          condition: _defaultCondition,
          grade: _defaultGrade,
          purchaseDate: _defaultPurchaseDate,
          storageBox: _defaultStorageBoxController.text.trim().isEmpty
              ? null
              : _defaultStorageBoxController.text.trim(),
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

  Future<void> _addManualComic() async {
    final item = await showDialog<CatalogItem>(
      context: context,
      builder: (context) => const _ManualComicDialog(),
    );
    if (item == null || !mounted) {
      return;
    }
    await CatalogCacheRepository(ref.read(localDatabaseProvider))
        .upsertAll([item]);
    setState(() {
      _mode = _AddComicMode.search;
      _searchedServer = true;
      _serverResults = [
        item,
        ..._serverResults.where((row) => row.id != item.id)
      ];
      _selectedServerId = item.id;
      _selectedProviderId = null;
      _checkedServerIds
        ..clear()
        ..add(item.id);
      _error = null;
    });
  }

  Future<void> _proposeManualComic() async {
    final proposal = await showDialog<_ManualProposalDraft>(
      context: context,
      builder: (context) => const _ManualProposalDialog(),
    );
    if (proposal == null || !mounted) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).createMetadataProposal(
            provider: 'comicvine',
            query: proposal.title,
            title: proposal.title,
            summary: proposal.notes,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Manual metadata proposal sent for review')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Manual metadata proposal failed: $error');
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
    required this.mode,
    required this.queryController,
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.showAdvancedFilters,
    required this.isSearching,
    required this.onModeChanged,
    required this.onAdvancedChanged,
    required this.onSearch,
    required this.onLookupBarcode,
    required this.onScanBarcode,
    required this.onAddManual,
    required this.onProposeManual,
  });

  final _AddComicMode mode;
  final TextEditingController queryController;
  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final bool showAdvancedFilters;
  final bool isSearching;
  final ValueChanged<_AddComicMode> onModeChanged;
  final ValueChanged<bool> onAdvancedChanged;
  final VoidCallback onSearch;
  final VoidCallback onLookupBarcode;
  final VoidCallback onScanBarcode;
  final VoidCallback onAddManual;
  final VoidCallback onProposeManual;

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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          'Search by',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEDEDED),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _AddModeTab(
                          icon: Icons.menu_book,
                          label: 'Series',
                          selected: mode == _AddComicMode.search,
                          onTap: () => onModeChanged(_AddComicMode.search),
                        ),
                        _AddModeTab(
                          icon: Icons.qr_code_2,
                          label: 'Barcode',
                          selected: mode == _AddComicMode.barcode,
                          onTap: () => onModeChanged(_AddComicMode.barcode),
                        ),
                        _AddModeTab(
                          icon: Icons.star,
                          label: 'Pull List',
                          selected: mode == _AddComicMode.pullList,
                          onTap: () => onModeChanged(_AddComicMode.pullList),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onAddManual,
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Add manually'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onProposeManual,
                  icon: const Icon(Icons.outbox, size: 18),
                  label: const Text('Propose manually'),
                ),
                const SizedBox(width: 4),
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
            switch (mode) {
              _AddComicMode.search => Column(
                  children: [
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
                                hintText:
                                    'Search title, series, issue, publisher...',
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
              _AddComicMode.barcode => Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: TextField(
                          controller: barcodeController,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => onLookupBarcode(),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Color(0xFF4A4A4A),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.qr_code_2),
                            hintText: 'Scan or enter barcode / UPC...',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: isSearching ? null : onScanBarcode,
                      icon: const Icon(Icons.barcode_reader, size: 18),
                      label: const Text('Scan barcode'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: isSearching ? null : onLookupBarcode,
                      child: isSearching
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Lookup barcode'),
                    ),
                  ],
                ),
              _AddComicMode.pullList => const _PullListModePanel(),
            },
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
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _PullListModePanel extends StatelessWidget {
  const _PullListModePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available, color: Color(0xFF18B7EB), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pull List will track upcoming issues from Collectarr Core and provider feeds. For now, use Series or Barcode search to add comics.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddComicResultPane extends StatelessWidget {
  const _AddComicResultPane({
    required this.mode,
    required this.serverResults,
    required this.providerResults,
    required this.ownedItemIds,
    required this.wishlistItemIds,
    required this.selectedServerId,
    required this.selectedProviderId,
    required this.checkedServerIds,
    required this.includeVariants,
    required this.hideInShelf,
    required this.searchedServer,
    required this.searchedProvider,
    required this.isSearchingServer,
    required this.isSearchingProvider,
    required this.onIncludeVariantsChanged,
    required this.onHideInShelfChanged,
    required this.onSelectServer,
    required this.onToggleServerCheck,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onSelectProvider,
    required this.onSearchProvider,
  });

  final _AddComicMode mode;
  final List<CatalogItem> serverResults;
  final List<_ProviderCandidate> providerResults;
  final Set<String> ownedItemIds;
  final Set<String> wishlistItemIds;
  final String? selectedServerId;
  final String? selectedProviderId;
  final Set<String> checkedServerIds;
  final bool includeVariants;
  final bool hideInShelf;
  final bool searchedServer;
  final bool searchedProvider;
  final bool isSearchingServer;
  final bool isSearchingProvider;
  final ValueChanged<bool> onIncludeVariantsChanged;
  final ValueChanged<bool> onHideInShelfChanged;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onSelectProvider;
  final VoidCallback onSearchProvider;

  @override
  Widget build(BuildContext context) {
    if (mode == _AddComicMode.pullList) {
      return const _PullListResultsPane();
    }
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
                    value: hideInShelf,
                    label: 'Hide in shelf',
                    onChanged: onHideInShelfChanged,
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
      final visibleResults = hideInShelf
          ? serverResults
              .where((item) =>
                  !ownedItemIds.contains(item.id) &&
                  !wishlistItemIds.contains(item.id))
              .toList(growable: false)
          : serverResults;
      if (visibleResults.isEmpty) {
        return const Center(
          child: Text(
            'All matching comics are already in your local shelf.',
            textAlign: TextAlign.center,
          ),
        );
      }
      final addable = visibleResults
          .where((item) =>
              !ownedItemIds.contains(item.id) &&
              !wishlistItemIds.contains(item.id))
          .toList(growable: false);
      final groupedResults = _groupAddResultsBySeries(visibleResults);
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
            child: ListView(
              children: [
                for (final group in groupedResults.entries) ...[
                  _AddSeriesHeader(
                    title: group.key,
                    count: group.value.length,
                  ),
                  for (final item in group.value)
                    _AddResultRow(
                      selected: item.id == selectedServerId,
                      checked: checkedServerIds.contains(item.id),
                      checkDisabled: ownedItemIds.contains(item.id) ||
                          wishlistItemIds.contains(item.id),
                      cover: SizedBox(
                        width: 42,
                        height: 62,
                        child: _CoverImage(item: item),
                      ),
                      title: item.itemNumber == null
                          ? item.title
                          : '#${item.itemNumber}',
                      subtitle: _addResultSubtitle(item),
                      badges: [
                        ..._addResultBadges(item),
                        if (ownedItemIds.contains(item.id)) 'Owned',
                        if (wishlistItemIds.contains(item.id)) 'Wishlist',
                      ],
                      trailing:
                          item.itemNumber == null ? '' : '#${item.itemNumber}',
                      onTap: () => onSelectServer(item.id),
                      onToggleCheck: ownedItemIds.contains(item.id) ||
                              wishlistItemIds.contains(item.id)
                          ? null
                          : () => onToggleServerCheck(item.id),
                    ),
                ],
              ],
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

class _PullListResultsPane extends StatelessWidget {
  const _PullListResultsPane();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF2E2E2E),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pull List is reserved for upcoming comics. It will combine your watched series, wishlist, and provider release feeds without storing personal library data on the metadata server.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Map<String, List<CatalogItem>> _groupAddResultsBySeries(
  List<CatalogItem> items,
) {
  final grouped = <String, List<CatalogItem>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.title, () => []).add(item);
  }
  return grouped;
}

String _addResultSubtitle(CatalogItem item) {
  final parts = [
    if (item.variant != null && item.variant!.isNotEmpty) item.variant,
    if (item.releaseDate != null) _formatDate(item.releaseDate!),
    if (item.publisher != null && item.publisher!.isNotEmpty) item.publisher,
    if (item.barcode != null && item.barcode!.isNotEmpty) item.barcode,
  ].whereType<String>().toList(growable: false);
  if (parts.isNotEmpty) {
    return parts.join('  |  ');
  }
  return item.synopsis ?? 'Metadata in Collectarr Core';
}

List<String> _addResultBadges(CatalogItem item) {
  return [
    if (item.publisher != null && item.publisher!.isNotEmpty) item.publisher!,
    if (item.releaseYear != null) item.releaseYear!.toString(),
  ];
}

class _AddSeriesHeader extends StatelessWidget {
  const _AddSeriesHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF232323)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 6),
        child: Row(
          children: [
            const Icon(Icons.folder, size: 15, color: Color(0xFF18B7EB)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            _AddResultBadge('$count issue${count == 1 ? '' : 's'}'),
          ],
        ),
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
    required this.addTarget,
    required this.addCount,
    required this.isSubmitting,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultStorageBoxController,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onDefaultGradeChanged,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onPropose,
  });

  final CatalogItem? selectedItem;
  final _ProviderCandidate? selectedCandidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final _AddComicTarget addTarget;
  final int addCount;
  final bool isSubmitting;
  final String? defaultCondition;
  final String? defaultGrade;
  final TextEditingController defaultStorageBoxController;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<_AddComicTarget> onAddTargetChanged;
  final ValueChanged<String?> onDefaultConditionChanged;
  final ValueChanged<String?> onDefaultGradeChanged;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final isProposal = selectedItem == null && selectedCandidate != null;
    final disabledByLocalStatus = addTarget == _AddComicTarget.owned
        ? selectedIsOwned
        : selectedIsWishlisted;
    final label = isProposal
        ? 'Propose ComicVine Metadata'
        : disabledByLocalStatus
            ? addTarget == _AddComicTarget.owned
                ? 'Already in Collection'
                : 'Already in Wishlist'
            : 'Add ${addCount <= 1 ? 1 : addCount} Comic${addCount <= 1 ? '' : 's'} to ${_addComicTargetLabel(addTarget)}';
    return ColoredBox(
      color: const Color(0xFF262626),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isProposal && addTarget == _AddComicTarget.owned) ...[
              _AddOwnedDefaultsBar(
                condition: defaultCondition,
                grade: defaultGrade,
                storageBoxController: defaultStorageBoxController,
                purchaseDate: defaultPurchaseDate,
                onConditionChanged: onDefaultConditionChanged,
                onGradeChanged: onDefaultGradeChanged,
                onPurchaseDateChanged: onDefaultPurchaseDateChanged,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (!isProposal) ...[
                  SizedBox(
                    width: 190,
                    height: 40,
                    child: DropdownButtonFormField<_AddComicTarget>(
                      initialValue: addTarget,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: _AddComicTarget.owned,
                          child: Text('Add as owned'),
                        ),
                        DropdownMenuItem(
                          value: _AddComicTarget.wishlist,
                          child: Text('Add to wishlist'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                onAddTargetChanged(value);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : isProposal
                            ? onPropose
                            : disabledByLocalStatus
                                ? null
                                : onAdd,
                    child: Text(label),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOwnedDefaultsBar extends StatelessWidget {
  const _AddOwnedDefaultsBar({
    required this.condition,
    required this.grade,
    required this.storageBoxController,
    required this.purchaseDate,
    required this.onConditionChanged,
    required this.onGradeChanged,
    required this.onPurchaseDateChanged,
  });

  final String? condition;
  final String? grade;
  final TextEditingController storageBoxController;
  final DateTime? purchaseDate;
  final ValueChanged<String?> onConditionChanged;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<DateTime?> onPurchaseDateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Owned defaults',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        _SmallDropdown(
          width: 140,
          value: condition,
          items: _ComicInspector._conditions,
          label: 'Condition',
          onChanged: onConditionChanged,
        ),
        _SmallDropdown(
          width: 120,
          value: grade,
          items: _ComicInspector._grades,
          label: 'Grade',
          onChanged: onGradeChanged,
        ),
        SizedBox(
          width: 150,
          height: 38,
          child: TextField(
            controller: storageBoxController,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: 'Storage box',
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: purchaseDate ?? DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            );
            onPurchaseDateChanged(picked);
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
            purchaseDate == null ? 'Purchase date' : _formatDate(purchaseDate!),
          ),
        ),
        if (purchaseDate != null)
          IconButton(
            tooltip: 'Clear purchase date',
            onPressed: () => onPurchaseDateChanged(null),
            icon: const Icon(Icons.clear, size: 18),
          ),
      ],
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  const _SmallDropdown({
    required this.width,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  final double width;
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 38,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('None')),
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ManualComicDialog extends StatefulWidget {
  const _ManualComicDialog();

  @override
  State<_ManualComicDialog> createState() => _ManualComicDialogState();
}

class _ManualComicDialogState extends State<_ManualComicDialog> {
  final _titleController = TextEditingController();
  final _issueController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _variantController = TextEditingController();
  final _synopsisController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add manual comic'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DialogTextField(
                width: 320,
                controller: _titleController,
                label: 'Series / title',
              ),
              _DialogTextField(
                width: 110,
                controller: _issueController,
                label: 'Issue #',
              ),
              _DialogTextField(
                width: 220,
                controller: _publisherController,
                label: 'Publisher',
              ),
              _DialogTextField(
                width: 100,
                controller: _yearController,
                label: 'Year',
                keyboardType: TextInputType.number,
              ),
              _DialogTextField(
                width: 220,
                controller: _barcodeController,
                label: 'Barcode / UPC',
                keyboardType: TextInputType.number,
              ),
              _DialogTextField(
                width: 220,
                controller: _variantController,
                label: 'Variant',
              ),
              _DialogTextField(
                width: 500,
                controller: _synopsisController,
                label: 'Plot / notes',
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              CatalogItem(
                id: 'manual-comic-${DateTime.now().microsecondsSinceEpoch}',
                kind: 'comic',
                title: title,
                itemNumber: _emptyToNull(_issueController.text),
                synopsis: _emptyToNull(_synopsisController.text),
                publisher: _emptyToNull(_publisherController.text),
                releaseYear: int.tryParse(_yearController.text.trim()),
                barcode: _emptyToNull(_barcodeController.text),
                variant: _emptyToNull(_variantController.text),
              ),
            );
          },
          child: const Text('Add to results'),
        ),
      ],
    );
  }
}

class _ManualProposalDialog extends StatefulWidget {
  const _ManualProposalDialog();

  @override
  State<_ManualProposalDialog> createState() => _ManualProposalDialogState();
}

class _ManualProposalDialogState extends State<_ManualProposalDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Propose manual metadata'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comic title / issue',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Source notes',
              ),
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
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _ManualProposalDraft(
                title: title,
                notes: _emptyToNull(_notesController.text),
              ),
            );
          },
          child: const Text('Send proposal'),
        ),
      ],
    );
  }
}

class _ManualProposalDraft {
  const _ManualProposalDraft({required this.title, required this.notes});

  final String title;
  final String? notes;
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.width,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

String _addComicTargetLabel(_AddComicTarget target) {
  return switch (target) {
    _AddComicTarget.owned => 'Collection',
    _AddComicTarget.wishlist => 'Wishlist',
  };
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
  const _EmptyState({required this.onAddComic});

  final VoidCallback onAddComic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Your local comics shelf is empty',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add comics from Collectarr Core or scan a barcode to save them in this device database.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAddComic,
                icon: const Icon(Icons.add),
                label: const Text('Add from Collectarr Core'),
              ),
            ],
          ),
        ),
      ),
    );
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

String? _formatNullableDate(DateTime? value) {
  return value == null ? null : _formatDate(value);
}

extension _BlankStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
