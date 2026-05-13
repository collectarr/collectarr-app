import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_dialog.dart';
import 'package:collectarr_app/features/comics/comics_bulk_edit.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_stats.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kDesktopBreakpoint = 980;
const double _kMinCoverSize = 104;
const double _kDefaultCoverSize = 128;
const double _kMaxCoverSize = 188;
const double _kComicTableColumnSpacing = 10;
const double _kComicTableHorizontalMargin = 8;
const double _kComicTableHeaderHeight = 30;
const double _kComicTableRowHeight = 38;
const double _kComicTableSelectionRailWidth = 3;
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
const Color _kClzTableOddRow = Color(0xFF202428);
const Color _kClzTableEvenRow = Color(0xFF181B1E);
const Color _kClzTableBottomBorder = Color(0xFF2E2E2E);
const Color _kClzTableHover = Color(0xFF263940);

enum _BulkToolbarAction { edit, owned, wishlist, remove, clear }

final ThemeData _kClzComicsTheme = _buildClzComicsTheme();

ThemeData _buildClzComicsTheme() {
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
        (_formatNullableDate(item.releaseDate)?.contains(query) ?? false) ||
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
    setState(() {
      switch (preset) {
        case LibraryWorkspacePreset.cover:
          viewMode = LibraryViewMode.grid;
          detailsLayout = LibraryDetailsLayout.right;
          coverSize = _kDefaultCoverSize;
          visibleColumns = _defaultComicTableColumns();
          break;
        case LibraryWorkspacePreset.card:
          viewMode = LibraryViewMode.card;
          detailsLayout = LibraryDetailsLayout.bottom;
          coverSize = 150;
          visibleColumns = _defaultComicTableColumns();
          break;
        case LibraryWorkspacePreset.list:
          viewMode = LibraryViewMode.list;
          detailsLayout = LibraryDetailsLayout.bottom;
          coverSize = _kDefaultCoverSize;
          visibleColumns = {
            LibraryTableColumn.status,
            LibraryTableColumn.title,
            LibraryTableColumn.issue,
            LibraryTableColumn.variant,
            LibraryTableColumn.publisher,
            LibraryTableColumn.releaseDate,
            LibraryTableColumn.grade,
            LibraryTableColumn.condition,
            LibraryTableColumn.price,
            LibraryTableColumn.updated,
          };
          break;
        case LibraryWorkspacePreset.details:
          viewMode = LibraryViewMode.grid;
          detailsLayout = LibraryDetailsLayout.right;
          coverSize = 144;
          visibleColumns = _defaultComicTableColumns();
          break;
      }
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
        column: _clampComicTableColumnWidth(column, width),
      };
    });
    _saveViewPreferences();
  }

  Future<void> _showColumnChooser(BuildContext context) async {
    final selected = await showDialog<Set<LibraryTableColumn>>(
      context: context,
      builder: (context) => LibraryColumnChooserDialog(
        selectedColumns: visibleColumns,
        defaultColumns: _defaultComicTableColumns(),
        columnLabel: _comicTableColumnDisplayName,
        columnGroup: _comicTableColumnGroup,
        groupLabel: _comicTableColumnGroupLabel,
      ),
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
    required this.onViewPresetSelected,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
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
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
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
          onShowStats: () => showComicsStatsDashboardDialog(
            context,
            state: shelfState,
            selectedSeries: selectedSeries,
            missingIssues: missingIssues,
          ),
          onClearSeries: onClearSeries,
          onViewModeChanged: onViewModeChanged,
          onDetailsLayoutChanged: onDetailsLayoutChanged,
          onViewPresetSelected: onViewPresetSelected,
          onCoverSizeChanged: onCoverSizeChanged,
          onSelectionModeChanged: onSelectionModeChanged,
          onClearSelection: onClearSelection,
          onBulkEdit: onBulkEdit,
          onBulkMoveToOwned: onBulkMoveToOwned,
          onBulkMoveToWishlist: onBulkMoveToWishlist,
          onBulkRemove: onBulkRemove,
        ),
        ComicsStatsBar(
          state: shelfState,
          selectedSeries: selectedSeries,
          missingIssues: missingIssues,
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: LibrarySeriesSidebar(
                  series: series,
                  selectedSeries: selectedSeries,
                  onSelectSeries: onSelectSeries,
                  backgroundColor: _kClzPanel,
                  headerColor: const Color(0xFF303030),
                  dividerColor: _kClzDivider,
                  accentColor: _kClzAccent,
                  selectionColor: _kClzSelection,
                  selectedBadgeColor: _kClzYellow,
                  mutedTextColor: _kClzTextMuted,
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
                  inspector: LibraryAwareComicInspector(item: selectedItem),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<LibrarySeriesBucket> _seriesBuckets(List<CatalogItem> source) {
    final counts = <String, int>{};
    for (final item in source) {
      counts[item.title] = (counts[item.title] ?? 0) + 1;
    }
    final buckets = counts.entries
        .map(
          (entry) => LibrarySeriesBucket(
            title: entry.key,
            count: entry.value,
          ),
        )
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
    required this.onShowStats,
    required this.onClearSeries,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
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
  final VoidCallback onShowStats;
  final VoidCallback onClearSeries;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 30,
              child: FilledButton.icon(
                onPressed: onAddComic,
                style: FilledButton.styleFrom(
                  backgroundColor: _kClzYellow,
                  foregroundColor: const Color(0xFF151515),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add Comics'),
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Scan barcode',
              child: LibraryWorkspaceIconButton(
                icon: Icons.qr_code_scanner,
                onPressed: onScanBarcode,
              ),
            ),
            Tooltip(
              message: 'Refresh metadata',
              child: LibraryWorkspaceIconButton(
                icon: Icons.sync,
                onPressed: onRefreshMetadata,
              ),
            ),
            const LibraryWorkspaceSeparator(color: _kClzDivider),
            SizedBox(
              width: 320,
              child: SearchBar(
                controller: controller,
                constraints: const BoxConstraints.tightFor(height: 32),
                hintText: 'Search comics...',
                leading: const Icon(Icons.search),
                trailing: [
                  Tooltip(
                    message: 'Search',
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onSearch(controller.text),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ),
                ],
                onSubmitted: onSearch,
              ),
            ),
            if (selectedSeries != null) ...[
              const SizedBox(width: 6),
              InputChip(
                visualDensity: VisualDensity.compact,
                backgroundColor: _kClzSelection,
                label: Text(selectedSeries!),
                onDeleted: onClearSeries,
              ),
            ],
            const LibraryWorkspaceSeparator(color: _kClzDivider),
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
                        child: LibraryWorkspaceIconButton(
                          onPressed: () =>
                              onSelectionModeChanged(!selectionMode),
                          icon: selectionMode ? Icons.close : Icons.checklist,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (selectionMode) ...[
                        LibraryToolbarStat(
                          label: 'Selected',
                          value: selectedCount,
                        ),
                        const SizedBox(width: 6),
                        PopupMenuButton<_BulkToolbarAction>(
                          tooltip: 'Bulk actions',
                          enabled: selectedCount > 0,
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) {
                            if (action == _BulkToolbarAction.edit) {
                              onBulkEdit();
                            } else if (action == _BulkToolbarAction.owned) {
                              onBulkMoveToOwned();
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
                              value: _BulkToolbarAction.owned,
                              child: ListTile(
                                leading: Icon(Icons.inventory_2_outlined),
                                title: Text('Move to owned'),
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
                        const SizedBox(width: 6),
                      ],
                      Tooltip(
                        message: 'Local statistics',
                        child: LibraryWorkspaceIconButton(
                          onPressed: onShowStats,
                          icon: Icons.query_stats,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Missing issues',
                        child: Badge(
                          isLabelVisible: missingIssues.isNotEmpty,
                          label: Text(missingIssues.length.toString()),
                          child: LibraryWorkspaceIconButton(
                            onPressed: missingIssues.isEmpty
                                ? null
                                : () => showComicsMissingIssuesDialog(
                                      context,
                                      selectedSeries: selectedSeries,
                                      missingIssues: missingIssues,
                                    ),
                            icon: Icons.format_list_numbered,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Filters',
                        child: Badge(
                          isLabelVisible: hasActiveFilters,
                          child: LibraryWorkspaceIconButton(
                            onPressed: onEditFilters,
                            icon: Icons.filter_list,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Select columns',
                        child: LibraryWorkspaceIconButton(
                          onPressed: viewMode == LibraryViewMode.list
                              ? onEditColumns
                              : null,
                          icon: Icons.view_column,
                        ),
                      ),
                      const SizedBox(width: 6),
                      LibraryToolbarStat(label: 'Shown', value: itemCount),
                      const SizedBox(width: 6),
                      LibraryToolbarStat(label: 'Total', value: totalCount),
                      const SizedBox(width: 6),
                      LibraryViewControls(
                        viewMode: viewMode,
                        detailsLayout: detailsLayout,
                        coverSize: coverSize,
                        minCoverSize: _kMinCoverSize,
                        maxCoverSize: _kMaxCoverSize,
                        onViewModeChanged: onViewModeChanged,
                        onDetailsLayoutChanged: onDetailsLayoutChanged,
                        onCoverSizeChanged: onCoverSizeChanged,
                        onPresetSelected: onViewPresetSelected,
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
    return LibraryWorkspaceGrid<CatalogItem>(
      items: items,
      emptyBuilder: (_) => _EmptyState(onAddComic: onAddComic),
      maxCrossAxisExtent: coverSize,
      mainAxisExtent: coverSize * 1.53,
      backgroundColor: _kClzGridCanvas,
      itemBuilder: (context, item) {
        final ownedItem = ownedByItemId[item.id];
        return LibraryCoverTile(
          entry: _comicWorkspaceEntry(
            item,
            ownedItem,
            null,
            isWishlisted: wishlistIds.contains(item.id),
          ),
          selected:
              selectedItemIds.contains(item.id) || item.id == selectedItemId,
          onTap: () => onSelectItem(item),
          selectedColor: _kClzSelection,
          accentColor: _kClzAccent,
          selectionColor: _kClzYellow,
          mutedTextColor: _kClzTextMuted,
        );
      },
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
    final cardHeight = (coverSize * 1.12).clamp(138.0, 174.0).toDouble();
    return LibraryWorkspaceGrid<CatalogItem>(
      items: items,
      emptyBuilder: (_) => _EmptyState(onAddComic: onAddComic),
      maxCrossAxisExtent: 430,
      mainAxisExtent: cardHeight,
      backgroundColor: _kClzGridCanvas,
      itemBuilder: (context, item) {
        final ownedItem = ownedByItemId[item.id];
        return _ComicCard(
          entry: _comicWorkspaceEntry(
            item,
            ownedItem,
            null,
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

class _ComicCard extends StatelessWidget {
  const _ComicCard({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LibraryWorkspaceCard(
      entry: entry,
      selected: selected,
      onTap: onTap,
      dateFormatter: _formatDate,
      moneyFormatter: _formatOptionalMoney,
      selectedColor: _kClzSelection,
      accentColor: _kClzAccent,
      mutedTextColor: _kClzTextMuted,
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
    return LibraryWorkspaceTable<_ComicTableEntry>(
      entries: entries,
      columns: columns,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      columnWidthFor: (column) => _comicTableColumnWidth(
        column,
        columnWidths,
      ),
      defaultColumnWidthFor: _defaultComicTableColumnWidth,
      columnSortFor: _comicTableColumnSort,
      columnLabelFor: _comicTableColumnLabel,
      columnIsNumeric: _comicTableColumnIsNumeric,
      cellBuilder: _comicTableCellContent,
      isSelected: (entry) =>
          selectedItemIds.contains(entry.item.id) ||
          entry.item.id == selectedItemId,
      onEntryTap: (entry) => onSelectItem(entry.item),
      onSortChanged: onSortChanged,
      onColumnWidthChanged: onColumnWidthChanged,
      headerHeight: _kComicTableHeaderHeight,
      rowHeight: _kComicTableRowHeight,
      columnSpacing: _kComicTableColumnSpacing,
      horizontalMargin: _kComicTableHorizontalMargin,
      selectionRailWidth: _kComicTableSelectionRailWidth,
      headerColor: const Color(0xFF303030),
      dividerColor: _kClzDivider,
      selectedColor: _kClzSelection,
      oddColor: _kClzTableOddRow,
      evenColor: _kClzTableEvenRow,
      selectionRailColor: _kClzYellow,
      bottomBorderColor: _kClzTableBottomBorder,
      hoverColor: _kClzTableHover,
      accentColor: _kClzAccent,
    );
  }
}

List<LibraryTableColumn> _orderedVisibleColumns(
  Set<LibraryTableColumn> columns,
) =>
    orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: _defaultComicTableColumns(),
    );

Set<LibraryTableColumn> _defaultComicTableColumns() =>
    Set.of(comicsWorkspaceConfig.defaultVisibleColumns);

double _tableWidthForColumns(
  Set<LibraryTableColumn> columns,
  Map<LibraryTableColumn, double> customWidths,
) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: _defaultComicTableColumns(),
    customWidths: customWidths,
    sizing: _comicTableColumnSizing,
    columnSpacing: _kComicTableColumnSpacing,
    horizontalMargin: _kComicTableHorizontalMargin,
  );
}

double _comicTableColumnWidth(
  LibraryTableColumn column,
  Map<LibraryTableColumn, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: column,
    customWidths: customWidths,
    sizing: _comicTableColumnSizing,
  );
}

double _defaultComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 52.0,
    LibraryTableColumn.cover => 42.0,
    LibraryTableColumn.title => 260.0,
    LibraryTableColumn.issue => 64.0,
    LibraryTableColumn.variant => 170.0,
    LibraryTableColumn.publisher => 140.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.storageBox => 118.0,
    LibraryTableColumn.wishlist => 82.0,
    LibraryTableColumn.updated => 112.0,
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

LibraryTableColumnSizing _comicTableColumnSizing(LibraryTableColumn column) {
  return LibraryTableColumnSizing(
    defaultWidth: _defaultComicTableColumnWidth(column),
    minWidth: _minComicTableColumnWidth(column),
    maxWidth: _maxComicTableColumnWidth(column),
  );
}

double _clampComicTableColumnWidth(
  LibraryTableColumn column,
  double width,
) {
  return clampLibraryTableColumnWidth(width, _comicTableColumnSizing(column));
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

LibraryTableColumnGroup _comicTableColumnGroup(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status ||
    LibraryTableColumn.cover ||
    LibraryTableColumn.title ||
    LibraryTableColumn.issue ||
    LibraryTableColumn.publisher ||
    LibraryTableColumn.releaseDate ||
    LibraryTableColumn.updated =>
      LibraryTableColumnGroup.main,
    LibraryTableColumn.variant ||
    LibraryTableColumn.barcode =>
      LibraryTableColumnGroup.edition,
    LibraryTableColumn.grade ||
    LibraryTableColumn.condition ||
    LibraryTableColumn.price =>
      LibraryTableColumnGroup.value,
    LibraryTableColumn.storageBox ||
    LibraryTableColumn.wishlist =>
      LibraryTableColumnGroup.personal,
  };
}

String _comicTableColumnGroupLabel(LibraryTableColumnGroup group) {
  return switch (group) {
    LibraryTableColumnGroup.main => 'Main',
    LibraryTableColumnGroup.edition => 'Edition',
    LibraryTableColumnGroup.value => 'Value',
    LibraryTableColumnGroup.personal => 'Personal',
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
    LibraryTableColumn.status => LibraryItemStatusIcons(
        isOwned: entry.isOwned,
        isWishlisted: entry.isWishlisted,
      ),
    LibraryTableColumn.cover => SizedBox(
        width: 28,
        height: 36,
        child: _CoverImage(item: entry.item),
      ),
    LibraryTableColumn.title => SizedBox(
        width: 280,
        child: Text(
          entry.workspaceEntry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    LibraryTableColumn.issue => Text(
        entry.workspaceEntry.itemNumber ?? '',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    LibraryTableColumn.variant =>
      LibraryTableCellText(entry.workspaceEntry.variant),
    LibraryTableColumn.publisher =>
      LibraryTableCellText(entry.workspaceEntry.publisher),
    LibraryTableColumn.releaseDate => LibraryTableCellText(
        _formatNullableDate(entry.workspaceEntry.releaseDate)),
    LibraryTableColumn.barcode =>
      LibraryTableCellText(entry.workspaceEntry.barcode),
    LibraryTableColumn.grade =>
      LibraryTableCellText(entry.workspaceEntry.grade),
    LibraryTableColumn.condition =>
      LibraryTableCellText(entry.workspaceEntry.condition),
    LibraryTableColumn.price => Text(
        _formatOptionalMoney(
          entry.workspaceEntry.pricePaidCents,
          entry.workspaceEntry.currency,
        ),
      ),
    LibraryTableColumn.storageBox =>
      LibraryTableCellText(entry.workspaceEntry.storageBox),
    LibraryTableColumn.wishlist =>
      entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
    LibraryTableColumn.updated => Text(
        _formatDate(entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
  };
}

class _ComicTableEntry {
  _ComicTableEntry({
    required this.item,
    this.ownedItem,
    this.wishlistItem,
  }) : workspaceEntry = _comicWorkspaceEntry(item, ownedItem, wishlistItem);

  final CatalogItem item;
  final OwnedItem? ownedItem;
  final WishlistItem? wishlistItem;
  final LibraryWorkspaceEntry workspaceEntry;

  bool get isOwned => workspaceEntry.isOwned;
  bool get isWishlisted => workspaceEntry.isWishlisted;

  DateTime get updatedAt => workspaceEntry.updatedAt;
}

int _compareEntries(
  _ComicTableEntry a,
  _ComicTableEntry b,
  LibrarySortColumn column,
  bool ascending,
) {
  return compareLibraryWorkspaceEntries(
    a.workspaceEntry,
    b.workspaceEntry,
    column,
    ascending,
  );
}

LibraryWorkspaceEntry _comicWorkspaceEntry(
  CatalogItem item,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem, {
  bool? isWishlisted,
}) {
  return LibraryWorkspaceEntry(
    id: item.id,
    mediaType: item.kind,
    title: item.title,
    itemNumber: item.itemNumber,
    synopsis: item.synopsis,
    coverImageUrl: item.coverImageUrl,
    thumbnailImageUrl: item.thumbnailImageUrl,
    publisher: item.publisher,
    releaseDate: item.releaseDate,
    releaseYear: item.releaseYear,
    barcode: item.barcode,
    variant: item.variant,
    isOwned: ownedItem != null,
    isWishlisted: isWishlisted ?? wishlistItem != null,
    condition: ownedItem?.condition,
    grade: ownedItem?.grade,
    pricePaidCents: ownedItem?.pricePaidCents,
    currency: ownedItem?.currency,
    storageBox: ownedItem?.storageBox,
    updatedAt: _latestLibraryUpdate(ownedItem, wishlistItem),
  );
}

DateTime _latestLibraryUpdate(
    OwnedItem? ownedItem, WishlistItem? wishlistItem) {
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

int? _parseIssueNumber(String? value) {
  if (value == null) {
    return null;
  }
  return int.tryParse(value.trim());
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

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: item.title,
      itemNumber: item.itemNumber,
      imageUrl: item.displayCoverUrl,
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
                final ownedItem = ownedByItemId[item.id];
                return LibraryCoverTile(
                  entry: _comicWorkspaceEntry(
                    item,
                    ownedItem,
                    null,
                    isWishlisted: wishlistIds.contains(item.id),
                  ),
                  selected: item.id == selectedItem?.id,
                  onTap: () {
                    onSelectItem(item);
                    _showCompactInspector(context, item);
                  },
                  selectedColor: _kClzSelection,
                  accentColor: _kClzAccent,
                  selectionColor: _kClzYellow,
                  mutedTextColor: _kClzTextMuted,
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

void _showCompactInspector(BuildContext context, CatalogItem item) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: LibraryAwareComicInspector(item: item),
      );
    },
  );
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

Set<String> _watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String? _formatNullableDate(DateTime? value) {
  return value == null ? null : _formatDate(value);
}
