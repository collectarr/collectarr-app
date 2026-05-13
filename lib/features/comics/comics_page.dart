import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
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
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_stats.dart';
import 'package:collectarr_app/features/comics/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/comics/owned_comic_edit_dialog.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
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

enum _OwnershipFilter { all, owned, wishlist, missingGrade }

enum _BulkToolbarAction { edit, owned, wishlist, remove, clear }

final ThemeData _kClzComicsTheme = _buildClzComicsTheme();
final ThemeData _kClzAddComicDialogTheme = _kClzComicsTheme.copyWith(
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF111111),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
);

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
                  inspector: _LibraryAwareComicInspector(item: selectedItem),
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
      oddColor: const Color(0xFF202428),
      evenColor: const Color(0xFF181B1E),
      selectionRailColor: _kClzYellow,
      bottomBorderColor: const Color(0xFF2E2E2E),
      hoverColor: const Color(0xFF263940),
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

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = _issueNumberSortValue(left);
  final rightNumber = _issueNumberSortValue(right);
  if (leftNumber != null && rightNumber != null) {
    final numeric = leftNumber.compareTo(rightNumber);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftNumber != null) {
    return -1;
  }
  if (rightNumber != null) {
    return 1;
  }
  return _compareNullableStrings(left, right);
}

double? _issueNumberSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
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

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
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

class _LibraryAwareComicInspector extends ConsumerWidget {
  const _LibraryAwareComicInspector({required this.item});

  final CatalogItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _ComicInspector(
      item: item,
      libraryState: libraryItemStateFor(
        item: item,
        ownedByItemId: ownedByItemId,
        wishlistIds: wishlistIds,
      ),
    );
  }
}

class _ComicInspector extends ConsumerWidget {
  const _ComicInspector({
    required this.item,
    required this.libraryState,
  });

  final CatalogItem? item;
  final LibraryItemState libraryState;

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
          decoration: const BoxDecoration(color: Color(0xBA111111)),
          child: ListView(
            padding: const EdgeInsets.all(10),
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
              const SizedBox(height: 7),
              _InspectorHero(item: item!, libraryState: libraryState),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ComicDetailPage(item: item!),
                  ),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open comic details'),
              ),
              const SizedBox(height: 7),
              if (isOwned)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
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
                const SizedBox(height: 10),
                _PersonalDetailsEditor(ownedItem: ownedItem),
              ],
              if (item!.synopsis != null) ...[
                const SizedBox(height: 10),
                LibraryInspectorSection(
                  title: 'Plot',
                  children: [
                    Text(
                      item!.synopsis!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
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
    final selection = await showDialog<OwnedComicEditSelection>(
      context: context,
      builder: (context) => OwnedComicEditDialog(
        item: item,
        ownedItem: ownedItem,
        conditions: _conditions,
        grades: _grades,
        cover: _CoverImage(item: item),
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
          opacity: 0.42,
          child: _CoverImage(item: item),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x66111111),
                Color(0xE0121212),
                Color(0xFA111111),
              ],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xF0101010),
                Color(0xC0101010),
                Color(0xE8101010),
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
        color: const Color(0xD51D1D1D),
        border: Border.all(color: _kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          children: [
            _InspectorActionButton(
              tooltip: 'Edit comic',
              onPressed: onEdit,
              icon: Icons.edit,
            ),
            const SizedBox(width: 4),
            _InspectorActionButton(
              tooltip: 'Wishlist',
              onPressed: onWishlist,
              icon: isWishlisted ? Icons.star : Icons.star_border,
            ),
            const SizedBox(width: 4),
            _InspectorActionButton(
              tooltip: 'Open details',
              onPressed: onOpenDetails,
              icon: Icons.open_in_new,
            ),
            const SizedBox(width: 4),
            _InspectorActionButton(
              tooltip: 'Correct metadata',
              onPressed: onCorrectMetadata,
              icon: Icons.fact_check_outlined,
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: isOwned ? _kClzYellow : const Color(0xFF2A2A2A),
                border: Border.all(
                  color: isOwned ? _kClzYellow : _kClzDivider,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isOwned ? Icons.check : Icons.check_box_outline_blank,
                      size: 15,
                      color: isOwned ? const Color(0xFF141414) : _kClzTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOwned ? 'OWNED' : 'LOCAL',
                      style: TextStyle(
                        color:
                            isOwned ? const Color(0xFF141414) : _kClzTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectorActionButton extends StatelessWidget {
  const _InspectorActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 28,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _InspectorHero extends StatelessWidget {
  const _InspectorHero({required this.item, required this.libraryState});

  final CatalogItem item;
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final cover = SizedBox(
          width: wide ? 146 : 174,
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
            border: Border.all(color: const Color(0x884DBBD5)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xD70A0A0A),
                Color(0xB3132830),
                Color(0xE80A0A0A),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 14),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cover,
                      const SizedBox(height: 10),
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
  final LibraryItemState libraryState;

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
              const SizedBox(width: 7),
              _IssuePill(label: '#${item.itemNumber}'),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          [
            if (item.variant != null && item.variant!.isNotEmpty) item.variant,
            if (item.publisher != null && item.publisher!.isNotEmpty)
              item.publisher,
            if (item.releaseDate != null) _formatDate(item.releaseDate!),
          ].whereType<String>().join('  |  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
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
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xAA151515),
              border: Border.all(color: const Color(0x4437C7E8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.view_week_outlined, size: 16),
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
            ),
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
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    final owned = libraryState.ownedItem;
    final detailValue = detail?.value;
    final edition = detailValue?.primaryEdition;
    final variant = detailValue?.primaryVariant;
    final source = edition?.sourceMetadata;
    final creators = _creditFacts(
      detailValue?.creators ?? const [],
      fallbackValues: _metadataNames(source, 'person_credits'),
    );
    final characters = _creditNames(
      detailValue?.characters ?? const [],
      fallbackValues: _metadataNames(source, 'character_credits'),
    );
    final arcs = _creditNames(
      detailValue?.storyArcs ?? const [],
      fallbackValues: _metadataNames(source, 'story_arc_credits'),
    );
    final providerFacts = _providerFacts(detailValue, edition);
    final releaseFacts = _releaseFacts(edition);
    final variantFacts = _variantFacts(variant);
    final tracking = owned?.mediaTracking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LibraryInspectorSection(
          title: 'Product Details',
          children: [
            LibraryInspectorFact(
              'Series',
              detailValue?.seriesTitle ?? detailValue?.volumeName ?? item.title,
            ),
            LibraryInspectorFact(
                'Publisher', edition?.publisher ?? item.publisher ?? '-'),
            LibraryInspectorFact(
              'Release',
              _formatNullableDate(
                    edition?.releaseDate ??
                        detailValue?.storeDate ??
                        item.releaseDate,
                  ) ??
                  '-',
            ),
            LibraryInspectorFact(
              'Cover date',
              _formatNullableDate(detailValue?.coverDate) ?? '-',
            ),
            LibraryInspectorFact('Format', edition?.format ?? item.kind),
            LibraryInspectorFact(
                'UPC / ISBN', edition?.upc ?? edition?.isbn ?? '-'),
            LibraryInspectorFact(
              'Pages / Price',
              [
                if (detailValue?.pageCount != null)
                  '${detailValue!.pageCount} pages',
                _formatOptionalMoney(
                  detailValue?.coverPriceCents ?? variant?.coverPriceCents,
                  detailValue?.currency ?? variant?.currency,
                ),
              ].where((value) => value.isNotEmpty).join(' | ').ifEmpty('-'),
            ),
          ],
        ),
        if (variantFacts.isNotEmpty || releaseFacts.isNotEmpty)
          LibraryInspectorSection(
            title: 'Edition',
            children: [
              for (final fact in variantFacts)
                LibraryInspectorFact(fact.label, fact.value),
              if (releaseFacts.isNotEmpty) ...[
                const SizedBox(height: 4),
                LibraryInspectorChipWrap(values: releaseFacts),
              ],
            ],
          ),
        LibraryInspectorSection(
          title: 'Personal',
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData(
                    'Quantity', owned?.quantity.toString() ?? '-'),
                LibraryInspectorFactData(
                    'Storage box', owned?.storageBox ?? '-'),
                LibraryInspectorFactData(
                    'Index', owned?.indexNumber?.toString() ?? '-'),
                LibraryInspectorFactData(
                    'Tracking', tracking?.statusLabel ?? '-'),
                LibraryInspectorFactData(
                    'Rating', tracking?.rating?.toString() ?? '-'),
                LibraryInspectorFactData(
                    'Read status', owned?.readStatus ?? '-'),
                LibraryInspectorFactData('Tags', owned?.tags ?? '-'),
              ],
            ),
            if (owned?.signedBy != null && owned!.signedBy!.isNotEmpty)
              LibraryInspectorFact('Signed by', owned.signedBy!),
          ],
        ),
        LibraryInspectorSection(
          title: 'Value',
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData(
                  'Purchase',
                  _formatOptionalMoney(
                    owned?.pricePaidCents,
                    owned?.currency,
                  ).ifEmpty('-'),
                ),
                LibraryInspectorFactData(
                  'Cover price',
                  _formatOptionalMoney(
                    owned?.coverPriceCents,
                    owned?.currency,
                  ).ifEmpty('-'),
                ),
                LibraryInspectorFactData(
                    'Grade status', owned?.rawOrSlabbed ?? '-'),
                LibraryInspectorFactData(
                  'Grading company',
                  owned?.gradingCompany ?? '-',
                ),
                LibraryInspectorFactData(
                  'Key issue',
                  owned?.keyComic == true ? 'Yes' : 'No',
                ),
              ],
            ),
            if (owned?.keyReason != null && owned!.keyReason!.isNotEmpty)
              LibraryInspectorFact('Key reason', owned.keyReason!),
          ],
        ),
        if (creators.isNotEmpty)
          LibraryInspectorSection(
            title: 'Creators',
            children: [
              for (final fact in creators.take(8))
                LibraryInspectorFact(fact.label, fact.value),
            ],
          ),
        if (characters.isNotEmpty)
          LibraryInspectorChipSection(title: 'Characters', values: characters),
        if (arcs.isNotEmpty)
          LibraryInspectorChipSection(title: 'Story arcs', values: arcs),
        if (providerFacts.isNotEmpty)
          LibraryInspectorSection(
            title: 'Provider Links',
            children: [
              for (final fact in providerFacts)
                LibraryInspectorFact(fact.label, fact.value),
            ],
          ),
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

  List<LibraryInspectorFactData> _creditFacts(
    List<ComicCredit> credits, {
    required List<String> fallbackValues,
  }) {
    if (credits.isEmpty) {
      return [
        for (final value in fallbackValues)
          LibraryInspectorFactData('Creator', value),
      ];
    }
    final byRole = <String, List<String>>{};
    for (final credit in credits) {
      final role = (credit.role == null || credit.role!.isEmpty)
          ? 'Creator'
          : credit.role!;
      byRole.putIfAbsent(role, () => []).add(credit.name);
    }
    return [
      for (final entry in byRole.entries)
        LibraryInspectorFactData(entry.key, entry.value.take(4).join(', ')),
    ];
  }

  List<String> _creditNames(
    List<ComicCredit> credits, {
    required List<String> fallbackValues,
  }) {
    if (credits.isEmpty) {
      return fallbackValues;
    }
    return [
      for (final credit in credits) credit.name,
    ];
  }

  List<LibraryInspectorFactData> _variantFacts(ComicVariant? variant) {
    if (variant == null) {
      return const [];
    }
    return [
      LibraryInspectorFactData('Variant cover', variant.name),
      if (variant.variantType != null)
        LibraryInspectorFactData('Variant type', variant.variantType!),
      if (variant.region != null)
        LibraryInspectorFactData('Region', variant.region!),
      if (variant.barcode != null)
        LibraryInspectorFactData('Barcode', variant.barcode!),
      if (variant.description != null && variant.description!.isNotEmpty)
        LibraryInspectorFactData('Description', variant.description!),
    ];
  }

  List<String> _releaseFacts(ComicEdition? edition) {
    final releases = edition?.releases ?? const [];
    return [
      for (final release in releases.take(6))
        [
          release.region,
          if (release.publisher != null && release.publisher!.isNotEmpty)
            release.publisher,
          if (release.releaseDate != null) _formatDate(release.releaseDate!),
        ].whereType<String>().join(' | '),
    ];
  }

  List<LibraryInspectorFactData> _providerFacts(
    ComicDetail? detail,
    ComicEdition? edition,
  ) {
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
      for (final link in detail?.providerLinks ?? const <ComicProviderLink>[])
        LibraryInspectorFactData(
          link.provider,
          [
            '${link.entityType}: ${link.providerItemId}',
            if (link.siteUrl != null) link.siteUrl,
          ].whereType<String>().join(' | '),
        ),
      if (metadata?['provider'] != null)
        LibraryInspectorFactData('Provider', metadata!['provider'].toString()),
      if (metadata?['provider_item_id'] != null)
        LibraryInspectorFactData(
          'Provider ID',
          metadata!['provider_item_id'].toString(),
        ),
      if (source?['site_detail_url'] != null)
        LibraryInspectorFactData(
            'Source URL', source!['site_detail_url'].toString()),
      if (source?['api_detail_url'] != null)
        LibraryInspectorFactData(
            'API URL', source!['api_detail_url'].toString()),
      if (releaseIds.isNotEmpty)
        LibraryInspectorFactData('Release IDs', releaseIds),
    ];
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
        color: const Color(0xD51C1F21),
        border: Border.all(color: const Color(0x554DBBD5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, size: 17, color: _kClzAccent),
                const SizedBox(width: 7),
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _kClzAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 9),
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
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _purchaseDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear purchase date'),
                ),
              ),
            ],
            const SizedBox(height: 9),
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
            const SizedBox(height: 9),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 9),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC172E35),
        border: Border.all(color: const Color(0x664DBBD5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _kClzAccent),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
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
  String? _readStatus;
  final _storageBoxController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _storageBoxController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk edit'),
      content: SizedBox(
        width: 460,
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
            const SizedBox(height: 12),
            TextField(
              controller: _storageBoxController,
              decoration: const InputDecoration(
                labelText: 'Storage box',
                hintText: 'Leave blank to keep current',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Leave blank to keep current',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _readStatus,
              decoration: const InputDecoration(
                labelText: 'Read status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('Keep current')),
                DropdownMenuItem(value: 'Unread', child: Text('Unread')),
                DropdownMenuItem(value: 'Reading', child: Text('Reading')),
                DropdownMenuItem(value: 'Read', child: Text('Read')),
              ],
              onChanged: (value) {
                setState(() => _readStatus =
                    value == null || value.isEmpty ? null : value);
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
            _BulkEditSelection(
              condition: _condition,
              grade: _grade,
              storageBox: _emptyToNull(_storageBoxController.text),
              tags: _emptyToNull(_tagsController.text),
              readStatus: _readStatus,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _BulkEditSelection {
  const _BulkEditSelection({
    this.condition,
    this.grade,
    this.storageBox,
    this.tags,
    this.readStatus,
  });

  final String? condition;
  final String? grade;
  final String? storageBox;
  final String? tags;
  final String? readStatus;
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

enum _BarcodeLookupStatus {
  pending,
  lookingUp,
  found,
  missing;

  String get label => switch (this) {
        _BarcodeLookupStatus.pending => 'Pending',
        _BarcodeLookupStatus.lookingUp => 'Looking up',
        _BarcodeLookupStatus.found => 'Found',
        _BarcodeLookupStatus.missing => 'Not found',
      };

  IconData get icon => switch (this) {
        _BarcodeLookupStatus.pending => Icons.schedule,
        _BarcodeLookupStatus.lookingUp => Icons.sync,
        _BarcodeLookupStatus.found => Icons.check_circle,
        _BarcodeLookupStatus.missing => Icons.error_outline,
      };

  Color get color => switch (this) {
        _BarcodeLookupStatus.pending => const Color(0xFFB8B8B8),
        _BarcodeLookupStatus.lookingUp => const Color(0xFF18B7EB),
        _BarcodeLookupStatus.found => const Color(0xFF59D17D),
        _BarcodeLookupStatus.missing => const Color(0xFFFFC857),
      };
}

class _BarcodeLookupEntry {
  const _BarcodeLookupEntry({
    required this.code,
    required this.status,
    this.item,
    this.error,
  });

  factory _BarcodeLookupEntry.pending(String code) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.pending,
    );
  }

  factory _BarcodeLookupEntry.lookingUp(String code) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.lookingUp,
    );
  }

  factory _BarcodeLookupEntry.found({
    required String code,
    required CatalogItem item,
  }) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.found,
      item: item,
    );
  }

  factory _BarcodeLookupEntry.missing(String code) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.missing,
      error: 'No match',
    );
  }

  final String code;
  final _BarcodeLookupStatus status;
  final CatalogItem? item;
  final String? error;

  _BarcodeLookupEntry copyWith({
    _BarcodeLookupStatus? status,
    CatalogItem? item,
    String? error,
  }) {
    return _BarcodeLookupEntry(
      code: code,
      status: status ?? this.status,
      item: item ?? this.item,
      error: error,
    );
  }
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
  var _providerResults = const <ProviderCandidate>[];
  String? _selectedServerId;
  String? _selectedProviderId;
  final _checkedServerIds = <String>{};
  final _collapsedAddSeries = <String>{};
  final _barcodeBatch = <_BarcodeLookupEntry>[];
  final _barcodeHistory = <String>[];
  bool _searchedServer = false;
  bool _searchedProvider = false;
  bool _isSearchingServer = false;
  bool _isSearchingProvider = false;
  bool _isSubmitting = false;
  bool _includeVariants = true;
  bool _hideInShelf = true;
  bool _showAdvancedFilters = false;
  LibraryAddMode _mode = LibraryAddMode.search;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
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
    final shelf = ref.watch(shelfProvider).value;
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
    final pullListRows = _pullListCandidates(shelf);
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
      data: _kClzAddComicDialogTheme,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 780),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _kClzPanel,
              border: Border.all(color: const Color(0xFF636363)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
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
                  barcodeBatch: _barcodeBatch,
                  barcodeHistory: _barcodeHistory,
                  showAdvancedFilters: _showAdvancedFilters,
                  isSearching: _isSearchingServer,
                  onModeChanged: (value) => setState(() => _mode = value),
                  onAdvancedChanged: (value) =>
                      setState(() => _showAdvancedFilters = value),
                  onSearch: _searchServer,
                  onLookupBarcode: () =>
                      _lookupBarcode(_barcodeController.text.trim()),
                  onLookupBarcodeBatch: _lookupBarcodeBatch,
                  onRemoveBarcodeBatchEntry: _removeBarcodeBatchEntry,
                  onClearBarcodeBatch: _clearBarcodeBatch,
                  onUseBarcodeHistory: _lookupBarcode,
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
                                pullListRows: pullListRows,
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
                                collapsedSeries: _collapsedAddSeries,
                                onToggleSeriesCollapsed:
                                    _toggleAddSeriesCollapsed,
                                onToggleSeriesCheck: _toggleAddSeriesCheck,
                                onCheckAllVisible: _checkServerItems,
                                onClearServerChecks: () =>
                                    setState(_checkedServerIds.clear),
                                onSelectProvider: (id) => setState(() {
                                  _selectedProviderId = id;
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchComicVine,
                                onSearchPullListRow: _searchPullListRow,
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
                                pullListRows: pullListRows,
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
                                collapsedSeries: _collapsedAddSeries,
                                onToggleSeriesCollapsed:
                                    _toggleAddSeriesCollapsed,
                                onToggleSeriesCheck: _toggleAddSeriesCheck,
                                onCheckAllVisible: _checkServerItems,
                                onClearServerChecks: () =>
                                    setState(_checkedServerIds.clear),
                                onSelectProvider: (id) => setState(() {
                                  _selectedProviderId = id;
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchComicVine,
                                onSearchPullListRow: _searchPullListRow,
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
                            wishlist: _addTarget == LibraryAddTarget.wishlist,
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

  ProviderCandidate? get _selectedProviderCandidate {
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
    var query = _controller.text.trim();
    final series = _seriesController.text.trim();
    final issueNumber = _issueController.text.trim();
    final publisher = _publisherController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    var barcode = _barcodeController.text.trim();
    if (barcode.isEmpty && _looksLikeBarcode(query)) {
      barcode = query;
      _barcodeController.text = query;
      query = '';
    }
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
      _collapsedAddSeries.clear();
      _error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).searchMetadata(
            libraryMetadataSearchQuery(
              comicsLibraryConfig,
              query: query,
              series: series,
              issueNumber: issueNumber,
              publisher: publisher,
              year: year,
              barcode: barcode,
              limit: 50,
            ),
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

  Future<void> _searchPullListRow(_PullListCandidate row) async {
    setState(() {
      _mode = LibraryAddMode.search;
      _controller.clear();
      _seriesController.text = row.series;
      _issueController.text = row.issue;
      _publisherController.text = row.publisher ?? '';
      _showAdvancedFilters = true;
    });
    await _searchServer();
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
      final rows = await ref.read(apiClientProvider).searchProvider(
            provider: comicsLibraryConfig.defaultMetadataProvider,
            query: query,
          );
      final results =
          rows.map(ProviderCandidate.fromJson).toList(growable: false);
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

  bool _looksLikeBarcode(String value) {
    final trimmed = value.trim();
    final normalized = MetadataSearchQuery.normalizeBarcode(value);
    return normalized.length >= 8 &&
        RegExp(r'^[0-9Xx\-\s]+$').hasMatch(trimmed);
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
    final normalized = MetadataSearchQuery.normalizeBarcode(code);
    if (normalized.isEmpty) {
      return;
    }
    final added = _ensureBarcodeBatchEntry(normalized);
    if (!added) {
      setState(() => _error = 'Barcode already scanned: $normalized');
      return;
    }
    _recordBarcodeHistory(normalized);
    await _lookupBarcodeBatch(codes: [normalized]);
  }

  bool _ensureBarcodeBatchEntry(String code) {
    if (_barcodeBatch.any((entry) => entry.code == code)) {
      return false;
    }
    setState(() {
      _barcodeBatch.add(_BarcodeLookupEntry.pending(code));
    });
    return true;
  }

  void _recordBarcodeHistory(String code) {
    setState(() {
      _barcodeHistory
        ..remove(code)
        ..insert(0, code);
      if (_barcodeHistory.length > 8) {
        _barcodeHistory.removeRange(8, _barcodeHistory.length);
      }
    });
  }

  Future<void> _lookupBarcodeBatch({Iterable<String>? codes}) async {
    final normalizedCodes = (codes ?? _barcodeBatch.map((entry) => entry.code))
        .map(MetadataSearchQuery.normalizeBarcode)
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedCodes.isEmpty) {
      return;
    }
    try {
      setState(() {
        _isSearchingServer = true;
        _searchedServer = true;
        _searchedProvider = false;
        _providerResults = const [];
        _selectedProviderId = null;
        _error = null;
        for (final code in normalizedCodes) {
          final index = _barcodeBatch.indexWhere((entry) => entry.code == code);
          if (index == -1) {
            _barcodeBatch.add(_BarcodeLookupEntry.lookingUp(code));
          } else {
            _barcodeBatch[index] = _barcodeBatch[index].copyWith(
              status: _BarcodeLookupStatus.lookingUp,
              error: null,
            );
          }
        }
      });
      final found = <CatalogItem>[];
      for (final code in normalizedCodes) {
        try {
          final result = await ref.read(apiClientProvider).lookupBarcode(
                code,
                kind: comicsLibraryConfig.workspace.kind,
              );
          final item = CatalogItem.fromJson(result);
          found.add(item);
          if (!mounted) {
            return;
          }
          _updateBarcodeBatchEntry(
            code,
            _BarcodeLookupEntry.found(code: code, item: item),
          );
        } catch (_) {
          if (!mounted) {
            return;
          }
          _updateBarcodeBatchEntry(
            code,
            _BarcodeLookupEntry.missing(code),
          );
        }
      }
      if (found.isNotEmpty) {
        await CatalogCacheRepository(ref.read(localDatabaseProvider))
            .upsertAll(found);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        final merged = <String, CatalogItem>{
          for (final item in _serverResults) item.id: item,
          for (final item in found) item.id: item,
        };
        _serverResults = merged.values.toList(growable: false);
        if (found.isNotEmpty) {
          _selectedServerId = found.first.id;
          _checkedServerIds.addAll(found.map((item) => item.id));
        }
        if (found.isEmpty) {
          _error = 'No Collectarr Core comics found for selected barcodes';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isSearchingServer = false);
      }
    }
  }

  void _updateBarcodeBatchEntry(String code, _BarcodeLookupEntry entry) {
    setState(() {
      final index = _barcodeBatch.indexWhere((row) => row.code == code);
      if (index == -1) {
        _barcodeBatch.add(entry);
      } else {
        _barcodeBatch[index] = entry;
      }
    });
  }

  void _removeBarcodeBatchEntry(String code) {
    setState(() {
      final removedIds = _barcodeBatch
          .where((entry) => entry.code == code)
          .map((entry) => entry.item?.id)
          .whereType<String>()
          .toSet();
      _barcodeBatch.removeWhere((entry) => entry.code == code);
      final remainingIds = _barcodeBatch
          .map((entry) => entry.item?.id)
          .whereType<String>()
          .toSet();
      _serverResults = _serverResults
          .where((item) =>
              !removedIds.contains(item.id) || remainingIds.contains(item.id))
          .toList(growable: false);
      _checkedServerIds.removeAll(removedIds.difference(remainingIds));
    });
  }

  void _clearBarcodeBatch() {
    setState(() {
      _barcodeBatch.clear();
      _barcodeController.clear();
      _checkedServerIds.clear();
      _serverResults = const [];
      _selectedServerId = null;
      _error = null;
    });
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

  void _toggleAddSeriesCollapsed(String seriesTitle) {
    setState(() {
      if (_collapsedAddSeries.contains(seriesTitle)) {
        _collapsedAddSeries.remove(seriesTitle);
      } else {
        _collapsedAddSeries.add(seriesTitle);
      }
    });
  }

  void _toggleAddSeriesCheck(Iterable<CatalogItem> items) {
    final addable = items
        .where((item) => !_checkedServerIds.contains(item.id))
        .map((item) => item.id)
        .toList(growable: false);
    setState(() {
      if (addable.isEmpty) {
        _checkedServerIds.removeAll(items.map((item) => item.id));
      } else {
        _checkedServerIds.addAll(addable);
        if (items.isNotEmpty) {
          _selectedServerId = items.first.id;
          _selectedProviderId = null;
        }
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

  Future<void> _proposeCandidate(ProviderCandidate candidate) async {
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
      _mode = LibraryAddMode.search;
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
            provider: comicsLibraryConfig.defaultMetadataProvider,
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
      height: 34,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A4A4A), Color(0xFF1B1B1B)],
        ),
        border: Border(bottom: BorderSide(color: _kClzAccent)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.public, color: Color(0xFF03A9DE), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Add Comics from Collectarr Core',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
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
    required this.barcodeBatch,
    required this.barcodeHistory,
    required this.showAdvancedFilters,
    required this.isSearching,
    required this.onModeChanged,
    required this.onAdvancedChanged,
    required this.onSearch,
    required this.onLookupBarcode,
    required this.onLookupBarcodeBatch,
    required this.onRemoveBarcodeBatchEntry,
    required this.onClearBarcodeBatch,
    required this.onUseBarcodeHistory,
    required this.onScanBarcode,
    required this.onAddManual,
    required this.onProposeManual,
  });

  final LibraryAddMode mode;
  final TextEditingController queryController;
  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final List<_BarcodeLookupEntry> barcodeBatch;
  final List<String> barcodeHistory;
  final bool showAdvancedFilters;
  final bool isSearching;
  final ValueChanged<LibraryAddMode> onModeChanged;
  final ValueChanged<bool> onAdvancedChanged;
  final VoidCallback onSearch;
  final VoidCallback onLookupBarcode;
  final VoidCallback onLookupBarcodeBatch;
  final ValueChanged<String> onRemoveBarcodeBatchEntry;
  final VoidCallback onClearBarcodeBatch;
  final ValueChanged<String> onUseBarcodeHistory;
  final VoidCallback onScanBarcode;
  final VoidCallback onAddManual;
  final VoidCallback onProposeManual;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kClzToolbar,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 4, 7, 7),
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
                        LibraryAddModeTab(
                          key: const ValueKey('add-comics-search-tab'),
                          icon: Icons.menu_book,
                          label: 'Search',
                          selected: mode == LibraryAddMode.search,
                          onTap: () => onModeChanged(LibraryAddMode.search),
                        ),
                        LibraryAddModeTab(
                          key: const ValueKey('add-comics-barcode-tab'),
                          icon: Icons.qr_code_2,
                          label: 'Barcode',
                          selected: mode == LibraryAddMode.barcode,
                          onTap: () => onModeChanged(LibraryAddMode.barcode),
                        ),
                        LibraryAddModeTab(
                          key: const ValueKey('add-comics-pull-list-tab'),
                          icon: Icons.star,
                          label: 'Pull List',
                          selected: mode == LibraryAddMode.pullList,
                          onTap: () => onModeChanged(LibraryAddMode.pullList),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onAddManual,
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Manual'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onProposeManual,
                  icon: const Icon(Icons.outbox, size: 18),
                  label: const Text('Propose'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onScanBarcode,
                  icon: const Icon(Icons.barcode_reader, size: 18),
                  label: const Text('Scan'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.menu, size: 28),
              ],
            ),
            const SizedBox(height: 7),
            switch (mode) {
              LibraryAddMode.search => Column(
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
              LibraryAddMode.barcode => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
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
                          const SizedBox(height: 8),
                          const _BarcodeLookupStrip(),
                          if (barcodeHistory.isNotEmpty &&
                              barcodeBatch.isEmpty) ...[
                            const SizedBox(height: 8),
                            _BarcodeHistoryStrip(
                              codes: barcodeHistory,
                              onUse: onUseBarcodeHistory,
                            ),
                          ],
                          if (barcodeBatch.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _BarcodeBatchPanel(
                              entries: barcodeBatch,
                              isLookingUp: isSearching,
                              onLookupAll: onLookupBarcodeBatch,
                              onRemove: onRemoveBarcodeBatchEntry,
                              onClear: onClearBarcodeBatch,
                            ),
                          ],
                        ],
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
              LibraryAddMode.pullList => const _PullListModePanel(),
            },
          ],
        ),
      ),
    );
  }
}

class _BarcodeLookupStrip extends StatelessWidget {
  const _BarcodeLookupStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AddInfoChip(icon: Icons.radio_button_checked, label: 'Connected'),
          _AddInfoChip(icon: Icons.center_focus_strong, label: 'Camera scan'),
          _AddInfoChip(icon: Icons.keyboard, label: 'Manual UPC/EAN'),
          _AddInfoChip(icon: Icons.cleaning_services, label: 'Auto-normalize'),
        ],
      ),
    );
  }
}

class _BarcodeHistoryStrip extends StatelessWidget {
  const _BarcodeHistoryStrip({
    required this.codes,
    required this.onUse,
  });

  final List<String> codes;
  final ValueChanged<String> onUse;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Recent',
            style: TextStyle(
              color: Color(0xFFB8B8B8),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final code in codes)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(code),
                  avatar: const Icon(Icons.history, size: 16),
                  onPressed: () => onUse(code),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarcodeBatchPanel extends StatelessWidget {
  const _BarcodeBatchPanel({
    required this.entries,
    required this.isLookingUp,
    required this.onLookupAll,
    required this.onRemove,
    required this.onClear,
  });

  final List<_BarcodeLookupEntry> entries;
  final bool isLookingUp;
  final VoidCallback onLookupAll;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final found = entries.where((entry) => entry.item != null).length;
    final missing = entries
        .where((entry) => entry.status == _BarcodeLookupStatus.missing)
        .length;
    return Container(
      constraints: const BoxConstraints(maxHeight: 168),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
            decoration: const BoxDecoration(
              color: Color(0xFF282828),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      LibraryAddResultBadge('${entries.length} scanned'),
                      LibraryAddResultBadge('$found found'),
                      if (missing > 0)
                        LibraryAddResultBadge('$missing missing'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: isLookingUp ? null : onLookupAll,
                  child: const Text('Lookup all'),
                ),
                TextButton(
                  onPressed: isLookingUp ? null : onClear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _BarcodeBatchRow(
                  entry: entry,
                  onRemove: () => onRemove(entry.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeBatchRow extends StatelessWidget {
  const _BarcodeBatchRow({required this.entry, required this.onRemove});

  final _BarcodeLookupEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    final label = item == null
        ? entry.status.label
        : item.itemNumber == null
            ? item.title
            : '${item.title} #${item.itemNumber}';
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: [
          Icon(entry.status.icon, size: 16, color: entry.status.color),
          const SizedBox(width: 7),
          SizedBox(
            width: 128,
            child: Text(
              entry.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFeatures: []),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: item == null ? const Color(0xFFCCCCCC) : Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove barcode',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
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

class _PullListModePanel extends StatelessWidget {
  const _PullListModePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AddInfoChip(icon: Icons.event_available, label: 'Upcoming issues'),
          _AddInfoChip(icon: Icons.bookmark_added, label: 'Watched series'),
          _AddInfoChip(icon: Icons.sync, label: 'Provider feeds'),
          _AddInfoChip(icon: Icons.lock_person, label: 'Local preferences'),
        ],
      ),
    );
  }
}

class _AddInfoChip extends StatelessWidget {
  const _AddInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        border: Border.all(color: const Color(0xFF555555)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF18B7EB)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
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
    required this.pullListRows,
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
    required this.collapsedSeries,
    required this.onToggleSeriesCollapsed,
    required this.onToggleSeriesCheck,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onSelectProvider,
    required this.onSearchProvider,
    required this.onSearchPullListRow,
  });

  final LibraryAddMode mode;
  final List<CatalogItem> serverResults;
  final List<ProviderCandidate> providerResults;
  final List<_PullListCandidate> pullListRows;
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
  final Set<String> collapsedSeries;
  final ValueChanged<String> onToggleSeriesCollapsed;
  final ValueChanged<Iterable<CatalogItem>> onToggleSeriesCheck;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onSelectProvider;
  final VoidCallback onSearchProvider;
  final ValueChanged<_PullListCandidate> onSearchPullListRow;

  @override
  Widget build(BuildContext context) {
    if (mode == LibraryAddMode.pullList) {
      return _PullListResultsPane(
        rows: pullListRows,
        onSearchRow: onSearchPullListRow,
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF1D2022),
        border: Border(right: BorderSide(color: _kClzDivider)),
      ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
            ),
            child: const Text(
              'Collectarr Core results',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
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
          _AddResultsSummaryBar(
            visibleCount: visibleResults.length,
            addableCount: addable.length,
            selectedCount: checkedServerIds.length,
            seriesCount: groupedResults.length,
            onSelectAll:
                addable.isEmpty ? null : () => onCheckAllVisible(addable),
            onClear: checkedServerIds.isEmpty ? null : onClearServerChecks,
          ),
          Expanded(
            child: ListView(
              children: [
                for (final group in groupedResults.entries) ...[
                  Builder(
                    builder: (context) {
                      final groupAddable = group.value
                          .where((item) =>
                              !ownedItemIds.contains(item.id) &&
                              !wishlistItemIds.contains(item.id))
                          .toList(growable: false);
                      final selectedInGroup = group.value
                          .where((item) => checkedServerIds.contains(item.id))
                          .length;
                      final collapsed = collapsedSeries.contains(group.key);
                      return _AddSeriesHeader(
                        title: group.key,
                        subtitle: _addSeriesSubtitle(group.value),
                        count: group.value.length,
                        selectableCount: groupAddable.length,
                        selectedCount: selectedInGroup,
                        isCollapsed: collapsed,
                        canCheck: groupAddable.isNotEmpty,
                        onToggleCollapsed: () =>
                            onToggleSeriesCollapsed(group.key),
                        onToggleCheck: groupAddable.isEmpty
                            ? null
                            : () => onToggleSeriesCheck(groupAddable),
                      );
                    },
                  ),
                  if (!collapsedSeries.contains(group.key))
                    for (final item in group.value)
                      _AddResultRow(
                        selected: item.id == selectedServerId,
                        checked: checkedServerIds.contains(item.id),
                        checkDisabled: ownedItemIds.contains(item.id) ||
                            wishlistItemIds.contains(item.id),
                        cover: SizedBox(
                          width: 38,
                          height: 56,
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
                        trailing: _addResultTrailing(item),
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
  const _PullListResultsPane({
    required this.rows,
    required this.onSearchRow,
  });

  final List<_PullListCandidate> rows;
  final ValueChanged<_PullListCandidate> onSearchRow;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.isEmpty ? _pullListPlaceholderRows : rows;
    return ColoredBox(
      color: const Color(0xFF2E2E2E),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF18B7EB), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Local Pull List',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                LibraryAddResultBadge(
                  rows.isEmpty
                      ? 'needs local shelf'
                      : '${rows.length} suggestion${rows.length == 1 ? '' : 's'}',
                ),
              ],
            ),
          ),
          const _PullListPreviewHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: visibleRows.length,
              itemBuilder: (context, index) {
                final row = visibleRows[index];
                return _PullListPreviewRow(
                  row: row,
                  onSearch: rows.isEmpty ? null : () => onSearchRow(row),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              rows.isEmpty
                  ? 'Add a few owned or wishlist comics first. Pull List will use local series and wishlist gaps to search Collectarr Core for likely next issues.'
                  : 'Pull List is generated from the local shelf only. Use Search Core on a row to query server metadata for that next issue.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PullListCandidate {
  const _PullListCandidate({
    required this.series,
    required this.issue,
    required this.release,
    required this.status,
    this.publisher,
  });

  final String series;
  final String issue;
  final String release;
  final String status;
  final String? publisher;
}

List<_PullListCandidate> _pullListCandidates(ShelfState? shelf) {
  final entries = shelf?.entries ?? const <ShelfEntry>[];
  final bySeries = <String, List<ShelfEntry>>{};
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null || (!entry.isOwned && !entry.isWishlisted)) {
      continue;
    }
    bySeries.putIfAbsent(item.title, () => []).add(entry);
  }
  final rows = <_PullListCandidate>[];
  for (final group in bySeries.entries) {
    final numbered = [
      for (final entry in group.value)
        if (_issueNumberSortValue(entry.catalogItem?.itemNumber) != null)
          (
            entry: entry,
            number: _issueNumberSortValue(entry.catalogItem?.itemNumber)!,
          ),
    ]..sort((a, b) => a.number.compareTo(b.number));
    if (numbered.isEmpty) {
      continue;
    }
    final last = numbered.last;
    final nextIssue = _formatIssueNumber(last.number + 1);
    final publisher = last.entry.catalogItem?.publisher;
    rows.add(
      _PullListCandidate(
        series: group.key,
        issue: nextIssue,
        release: publisher ?? 'Collectarr Core',
        status: group.value.any((entry) => entry.isWishlisted)
            ? 'wishlist gap'
            : 'next issue',
        publisher: publisher,
      ),
    );
  }
  rows.sort((a, b) => a.series.toLowerCase().compareTo(b.series.toLowerCase()));
  return rows.take(25).toList(growable: false);
}

String _formatIssueNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

const _pullListPlaceholderRows = [
  _PullListCandidate(
    series: 'Watched series',
    issue: 'next',
    release: 'local shelf',
    status: 'waiting',
  ),
  _PullListCandidate(
    series: 'Wishlist gaps',
    issue: 'missing',
    release: 'Collectarr Core',
    status: 'planned',
  ),
  _PullListCandidate(
    series: 'New releases',
    issue: 'weekly',
    release: 'ComicVine',
    status: 'planned',
  ),
];

class _PullListPreviewHeader extends StatelessWidget {
  const _PullListPreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: const Color(0xFF383838),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('Series')),
          Expanded(flex: 2, child: Text('Issue')),
          Expanded(flex: 3, child: Text('Release')),
          Expanded(flex: 3, child: Text('Status')),
          SizedBox(width: 96, child: Text('Action')),
        ],
      ),
    );
  }
}

class _PullListPreviewRow extends StatelessWidget {
  const _PullListPreviewRow({
    required this.row,
    required this.onSearch,
  });

  final _PullListCandidate row;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3B3B3B))),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(row.series)),
          Expanded(flex: 2, child: Text('#${row.issue}')),
          Expanded(flex: 3, child: Text(row.release)),
          Expanded(
            flex: 3,
            child: Text(
              row.status,
              style: const TextStyle(color: Color(0xFFBFEFFF)),
            ),
          ),
          SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: onSearch,
              child: const Text('Search Core'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddResultsSummaryBar extends StatelessWidget {
  const _AddResultsSummaryBar({
    required this.visibleCount,
    required this.addableCount,
    required this.selectedCount,
    required this.seriesCount,
    required this.onSelectAll,
    required this.onClear,
  });

  final int visibleCount;
  final int addableCount;
  final int selectedCount;
  final int seriesCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: const BoxDecoration(
        color: Color(0xFF252525),
        border: Border(bottom: BorderSide(color: Color(0xFF444444))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddResultBadge(
                    '$visibleCount result${visibleCount == 1 ? '' : 's'}',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge(
                    '$seriesCount series',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge(
                    '$selectedCount selected',
                  ),
                  if (addableCount != visibleCount) ...[
                    const SizedBox(width: 6),
                    LibraryAddResultBadge(
                      '$addableCount addable',
                    ),
                  ],
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: onSelectAll,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Map<String, List<CatalogItem>> _groupAddResultsBySeries(
  List<CatalogItem> items,
) {
  final grouped = <String, List<CatalogItem>>{};
  final sortedItems = items.toList(growable: false)
    ..sort((a, b) {
      final series = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (series != 0) {
        return series;
      }
      return _compareIssueNumbers(a.itemNumber, b.itemNumber);
    });
  for (final item in sortedItems) {
    grouped.putIfAbsent(item.title, () => []).add(item);
  }
  return grouped;
}

String _addSeriesSubtitle(List<CatalogItem> items) {
  final issues = items
      .map((item) => item.itemNumber)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  final publishers = items
      .map((item) => item.publisher)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  final publisher = publishers.isEmpty ? null : publishers.first;
  final years = items
      .map((item) => item.releaseYear)
      .whereType<int>()
      .toList(growable: false);
  final range = issues.isEmpty
      ? null
      : issues.length == 1
          ? '#${issues.first}'
          : '#${issues.first} - #${issues.last}';
  final yearRange = years.isEmpty
      ? null
      : years.length == 1 || years.toSet().length == 1
          ? years.first.toString()
          : '${years.reduce((a, b) => a < b ? a : b)}-${years.reduce((a, b) => a > b ? a : b)}';
  return [
    if (range != null) range,
    if (publisher != null) publisher,
    if (yearRange != null) yearRange,
  ].join(' | ');
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

String _addResultTrailing(CatalogItem item) {
  if (item.releaseDate != null) {
    return _formatDate(item.releaseDate!);
  }
  if (item.releaseYear != null) {
    return item.releaseYear!.toString();
  }
  return item.itemNumber == null ? '' : '#${item.itemNumber}';
}

class _AddSeriesHeader extends StatelessWidget {
  const _AddSeriesHeader({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.selectableCount,
    required this.selectedCount,
    required this.isCollapsed,
    required this.canCheck,
    required this.onToggleCollapsed,
    required this.onToggleCheck,
  });

  final String title;
  final String subtitle;
  final int count;
  final int selectableCount;
  final int selectedCount;
  final bool isCollapsed;
  final bool canCheck;
  final VoidCallback onToggleCollapsed;
  final VoidCallback? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleCollapsed,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF232323),
          border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 5, 6, 5),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: isCollapsed ? 'Expand series' : 'Collapse series',
                  onPressed: onToggleCollapsed,
                  icon: Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                ),
              ),
              Checkbox(
                value: selectedCount == 0
                    ? false
                    : selectedCount >= selectableCount
                        ? true
                        : null,
                tristate: true,
                onChanged: canCheck ? (_) => onToggleCheck?.call() : null,
                visualDensity: VisualDensity.compact,
              ),
              const Icon(Icons.folder, size: 15, color: Color(0xFF18B7EB)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (selectedCount > 0) ...[
                LibraryAddResultBadge('$selectedCount selected'),
                const SizedBox(width: 6),
              ],
              LibraryAddResultBadge('$count issue${count == 1 ? '' : 's'}'),
            ],
          ),
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
    return Ink(
      decoration: BoxDecoration(
        color: selected ? _kClzSelection : const Color(0xFF242729),
        border: Border(
          left: BorderSide(
            color: selected ? _kClzYellow : Colors.transparent,
            width: 3,
          ),
          bottom: const BorderSide(color: Color(0xFF36393B)),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFDDDDDD)),
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final badge in badges)
                            LibraryAddResultBadge(badge),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing.isNotEmpty)
                Text(trailing,
                    style: const TextStyle(color: Color(0xFFBFEFFF))),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddComicPreviewPane extends ConsumerWidget {
  const _AddComicPreviewPane({
    required this.item,
    required this.candidate,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.searchedServer,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final bool searchedServer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: const Color(0xFF060606),
        child: Center(
          child: Text(
            searchedServer
                ? 'Select a result or search ComicVine.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final detail = selectedItem == null
        ? null
        : ref.watch(comicDetailProvider(selectedItem.id)).value;
    final title = selectedItem?.title ?? selectedCandidate!.title;
    final issue = selectedItem?.itemNumber;
    final synopsis = selectedItem?.synopsis ?? selectedCandidate?.summary;
    final localStatus = selectedIsOwned
        ? 'In local collection'
        : selectedIsWishlisted
            ? 'In local wishlist'
            : 'Not in local shelf';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020202),
            Color(0xFF082531),
            Color(0xFF050505),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedItem == null
                            ? 'ComicVine candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 9),
                      _AddPreviewChips(
                        labels: [
                          localStatus,
                          if (selectedItem?.publisher != null)
                            selectedItem!.publisher!,
                          if (selectedItem?.releaseYear != null)
                            selectedItem!.releaseYear!.toString(),
                          if (selectedItem?.barcode != null)
                            'UPC ${selectedItem!.barcode}',
                          if (selectedCandidate != null)
                            selectedCandidate.provider,
                        ],
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
            const Divider(height: 22, color: Color(0x664DBBD5)),
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
                        _AddPreviewMetadata(
                          item: selectedItem,
                          candidate: selectedCandidate,
                          detail: detail,
                          localStatus: localStatus,
                        ),
                        if (detail?.creators.isNotEmpty ?? false) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Creators',
                            style: TextStyle(color: Color(0xFF05AEEF)),
                          ),
                          const SizedBox(height: 6),
                          _AddPreviewChips(
                            labels: [
                              for (final credit in detail!.creators)
                                credit.role == null
                                    ? credit.name
                                    : '${credit.name} - ${credit.role}',
                            ],
                          ),
                        ],
                        if (detail?.characters.isNotEmpty ?? false) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Characters',
                            style: TextStyle(color: Color(0xFF05AEEF)),
                          ),
                          const SizedBox(height: 6),
                          _AddPreviewChips(
                            labels: [
                              for (final credit in detail!.characters)
                                credit.name,
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x99FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: selectedItem == null
                            ? _ProviderCandidateImage(
                                candidate: selectedCandidate!,
                              )
                            : _CoverImage(item: selectedItem),
                      ),
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

class _AddPreviewMetadata extends StatelessWidget {
  const _AddPreviewMetadata({
    required this.item,
    required this.candidate,
    required this.detail,
    required this.localStatus,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final ComicDetail? detail;
  final String localStatus;

  @override
  Widget build(BuildContext context) {
    final selectedItem = item;
    final rows = selectedItem == null
        ? [
            ('Provider', candidate?.provider),
            ('Provider ID', candidate?.providerItemId),
          ]
        : [
            ('Status', localStatus),
            ('Catalog ID', selectedItem.id),
            ('Series', detail?.seriesTitle ?? selectedItem.title),
            ('Issue', selectedItem.itemNumber),
            ('Publisher', detail?.publisher ?? selectedItem.publisher),
            ('Cover Date', _formatOptionalDate(detail?.coverDate)),
            ('Release', _formatOptionalDate(selectedItem.releaseDate)),
            ('Pages', detail?.pageCount?.toString()),
            ('Barcode', detail?.barcode ?? selectedItem.barcode),
            ('Price', _moneyLabel(detail?.coverPriceCents, detail?.currency)),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          if (row.$2 != null && row.$2!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        color: Color(0xFFB8B8B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Text(row.$2!)),
                ],
              ),
            ),
      ],
    );
  }

  String? _formatOptionalDate(DateTime? value) {
    return value == null ? null : _formatDate(value);
  }

  String? _moneyLabel(int? cents, String? currency) {
    if (cents == null) {
      return null;
    }
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${currency ?? ''} $sign$whole.$fraction'.trim();
  }
}

class _AddPreviewChips extends StatelessWidget {
  const _AddPreviewChips({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final label in labels.take(12))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              border: Border.all(color: const Color(0xFF555555)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
      ],
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
  final ProviderCandidate? selectedCandidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isSubmitting;
  final String? defaultCondition;
  final String? defaultGrade;
  final TextEditingController defaultStorageBoxController;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String?> onDefaultConditionChanged;
  final ValueChanged<String?> onDefaultGradeChanged;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final isProposal = selectedItem == null && selectedCandidate != null;
    final disabledByLocalStatus = addTarget == LibraryAddTarget.owned
        ? selectedIsOwned
        : selectedIsWishlisted;
    final label = isProposal
        ? 'Propose ComicVine Metadata'
        : disabledByLocalStatus
            ? addTarget == LibraryAddTarget.owned
                ? 'Already in Collection'
                : 'Already in Wishlist'
            : LibraryAddCopy.addToTargetLabel(
                count: addCount,
                type: comicsLibraryConfig,
                target: addTarget,
              );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kClzToolbar,
        border: Border(top: BorderSide(color: _kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isProposal && addTarget == LibraryAddTarget.owned) ...[
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
                  LibraryAddResultBadge(
                    '$addCount selected',
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 190,
                    height: 40,
                    child: DropdownButtonFormField<LibraryAddTarget>(
                      initialValue: addTarget,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: LibraryAddTarget.owned,
                          child: Text(LibraryAddTarget.owned.actionLabel),
                        ),
                        DropdownMenuItem(
                          value: LibraryAddTarget.wishlist,
                          child: Text(LibraryAddTarget.wishlist.actionLabel),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: _kClzAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
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
                kind: comicsLibraryConfig.workspace.kind,
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

class _ProviderCandidateImage extends StatelessWidget {
  const _ProviderCandidateImage({required this.candidate});

  final ProviderCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: candidate.title,
      imageUrl: candidate.imageUrl,
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

extension _BlankStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
