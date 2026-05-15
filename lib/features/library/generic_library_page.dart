import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/generic_library_inspector.dart';
import 'package:collectarr_app/features/library/generic_library_toolbar.dart';
import 'package:collectarr_app/features/library/library_media_adapter.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_refresh_dialog.dart';
import 'package:collectarr_app/features/library/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  @override
  void initState() {
    super.initState();
    _viewState = _adapter.viewProfile.defaults();
    unawaited(_loadViewState());
  }

  @override
  void didUpdateWidget(covariant GenericLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.workspace.kind != widget.type.workspace.kind) {
      _selectedId = null;
      _selectedBucket = null;
      _quickView = null;
      _searchController.clear();
      _viewState = _adapter.viewProfile.defaults();
      unawaited(_loadViewState());
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
    final viewState = _viewState ?? _adapter.viewProfile.defaults();
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
                  shelf.asData?.value,
                  viewState,
                ),
                quickView: _quickView,
                onQuickViewSelected: (view) => setState(() {
                  _quickView = _quickView == view ? null : view;
                }),
                hasActiveFilters: _hasActiveFilter,
                onClearFilters: _clearFilters,
                counts: shelf.maybeWhen(
                  data: (state) => _toolbarCounts(state),
                  orElse: () => const GenericToolbarCounts(),
                ),
              ),
              Expanded(
                child: shelf.when(
                  data: (state) => _buildWorkspace(state, viewState),
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

  Widget _buildWorkspace(
    ShelfState shelf,
    LibraryWorkspaceViewState viewState,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final allItems = _itemsForShelf(shelf);
        final buckets = _bucketsForItems(allItems);
        final filtered = _filteredItems(allItems, viewState);
        final selected = _selectedItem(filtered);
        final compact = constraints.maxWidth < 860;
        final showSidebar = constraints.maxWidth >= 640;
        final detailsLayout =
            compact && viewState.detailsLayout == LibraryDetailsLayout.right
                ? LibraryDetailsLayout.bottom
                : viewState.detailsLayout;
        final workspace = _buildWorkspaceContent(filtered, viewState);
        final details = GenericLibraryInspector(
          type: widget.type,
          entry: selected?.entry,
          ownedItem: selected?.source.ownedItem,
          accent: widget.accent,
          onAddOwned: selected == null ? null : () => _addOwned(selected),
          onRemoveOwned: selected?.source.ownedItem == null
              ? null
              : () => _removeOwned(selected!),
          onAddWishlist: selected == null ? null : () => _addWishlist(selected),
          onRemoveWishlist: selected?.source.isWishlisted != true
              ? null
              : () => _removeWishlist(selected!),
        );

        final workspaceContent = Column(
          children: [
            if (!showSidebar && buckets.length > 1)
              _CompactBucketBar(
                type: widget.type,
                accent: widget.accent,
                buckets: buckets,
                selectedBucket: _selectedBucket ?? _allBucketLabel(widget.type),
                onSelected: (bucket) => setState(() {
                  _selectedBucket =
                      bucket == _allBucketLabel(widget.type) ? null : bucket;
                }),
              ),
            Expanded(child: workspace),
          ],
        );

        return ColoredBox(
          color: kClzCanvas,
          child: Row(
            children: [
              if (showSidebar) ...[
                SizedBox(
                  width: compact ? 210 : 250,
                  child: LibrarySeriesSidebar(
                    title: _sidebarTitle(widget.type),
                    icon: _sidebarIcon(widget.type),
                    series: buckets,
                    selectedSeries:
                        _selectedBucket ?? _allBucketLabel(widget.type),
                    onSelectSeries: (bucket) => setState(() {
                      _selectedBucket = bucket == _allBucketLabel(widget.type)
                          ? null
                          : bucket;
                    }),
                    accentColor: widget.accent,
                    selectionColor: widget.accent.withValues(alpha: 0.36),
                    backgroundColor: kClzPanel,
                    headerColor: const Color(0xFF303030),
                    dividerColor: kClzDivider,
                    selectedBadgeColor: kClzYellow,
                    mutedTextColor: kClzTextMuted,
                    trailing: IconButton(
                      tooltip: 'Clear library filter',
                      onPressed: _selectedBucket == null
                          ? null
                          : () => setState(() => _selectedBucket = null),
                      icon: const Icon(Icons.filter_alt_off, size: 18),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
              ],
              Expanded(
                child: LibraryDetailsAwareLayout(
                  content: workspaceContent,
                  detailsLayout: detailsLayout,
                  inspector: details,
                  bottomHeight: compact ? 220 : 250,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceContent(
    List<_GenericLibraryItem> items,
    LibraryWorkspaceViewState viewState,
  ) {
    return switch (viewState.viewMode) {
      LibraryViewMode.grid => LibraryWorkspaceGrid<_GenericLibraryItem>(
          items: items,
          emptyBuilder: (_) => _GenericEmptyState(
            type: widget.type,
            icon: widget.type.workspace.icon,
            accent: widget.accent,
            hasActiveFilter: _hasActiveFilter,
            onAdd: () => _showAddDialog(),
            onClearFilter: _clearFilters,
          ),
          maxCrossAxisExtent: viewState.coverSize,
          mainAxisExtent: viewState.coverSize * 1.53,
          backgroundColor: kClzGridCanvas,
          itemBuilder: (context, item) => LibraryCoverTile(
            entry: item.entry,
            selected: item.entry.id == _selectedId,
            onTap: () => setState(() => _selectedId = item.entry.id),
            selectedColor: kClzSelection,
            accentColor: widget.accent,
            selectionColor: kClzYellow,
            mutedTextColor: kClzTextMuted,
          ),
        ),
      LibraryViewMode.card => LibraryWorkspaceGrid<_GenericLibraryItem>(
          items: items,
          emptyBuilder: (_) => _GenericEmptyState(
            type: widget.type,
            icon: widget.type.workspace.icon,
            accent: widget.accent,
            hasActiveFilter: _hasActiveFilter,
            onAdd: () => _showAddDialog(),
            onClearFilter: _clearFilters,
          ),
          maxCrossAxisExtent: 430,
          mainAxisExtent:
              (viewState.coverSize * 1.12).clamp(138.0, 174.0).toDouble(),
          backgroundColor: kClzGridCanvas,
          itemBuilder: (context, item) => LibraryWorkspaceCard(
            entry: item.entry,
            selected: item.entry.id == _selectedId,
            onTap: () => setState(() => _selectedId = item.entry.id),
            dateFormatter: formatComicDate,
            moneyFormatter: formatComicMoney,
            selectedColor: kClzSelection,
            accentColor: widget.accent,
            mutedTextColor: kClzTextMuted,
          ),
        ),
      LibraryViewMode.list => _buildTable(items, viewState),
    };
  }

  Widget _buildTable(
    List<_GenericLibraryItem> items,
    LibraryWorkspaceViewState viewState,
  ) {
    if (items.isEmpty) {
      return _GenericEmptyState(
        type: widget.type,
        icon: widget.type.workspace.icon,
        accent: widget.accent,
        hasActiveFilter: _hasActiveFilter,
        onAdd: () => _showAddDialog(),
        onClearFilter: _clearFilters,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = _adapter.tableWidthForColumns(
          viewState.visibleColumns,
          viewState.columnWidths,
        );
        final contentWidth = math.max(tableWidth + 16, constraints.maxWidth);
        return ColoredBox(
          color: kClzCanvas,
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LibraryWorkspaceTable<_GenericLibraryItem>(
                    entries: items,
                    columns:
                        _adapter.orderedTableColumns(viewState.visibleColumns),
                    sortColumn: viewState.sortColumn,
                    sortAscending: viewState.sortAscending,
                    columnWidthFor: (column) => _adapter.tableColumnWidth(
                      column,
                      viewState.columnWidths,
                    ),
                    defaultColumnWidthFor: _adapter.defaultTableColumnWidth,
                    columnSortFor: _adapter.columnSort,
                    columnLabelFor: _adapter.columnLabel,
                    columnIsNumeric: _adapter.columnIsNumeric,
                    cellBuilder: _tableCell,
                    isSelected: (item) => item.entry.id == _selectedId,
                    onEntryTap: (item) =>
                        setState(() => _selectedId = item.entry.id),
                    onSortChanged: (column) => _updateViewState(
                      (state) =>
                          state.withSortColumn(column, _adapter.viewProfile),
                    ),
                    onColumnWidthChanged: (column, width) => _updateViewState(
                      (state) => state.withColumnWidth(
                        column,
                        width,
                        _adapter.viewProfile,
                      ),
                    ),
                    onColumnReordered: (column, beforeColumn) =>
                        _updateViewState(
                      (state) => state.withReorderedColumn(
                        column: column,
                        beforeColumn: beforeColumn,
                      ),
                    ),
                    headerColor: const Color(0xFF303030),
                    dividerColor: kClzDivider,
                    selectedColor: kClzSelection,
                    oddColor: kClzTableOddRow,
                    evenColor: kClzTableEvenRow,
                    selectionRailColor: kClzYellow,
                    bottomBorderColor: kClzTableBottomBorder,
                    hoverColor: kClzTableHover,
                    accentColor: widget.accent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tableCell(_GenericLibraryItem item, LibraryTableColumn column) {
    final entry = item.entry;
    return switch (column) {
      LibraryTableColumn.status => LibraryItemStatusIcons(
          isOwned: entry.isOwned,
          isWishlisted: entry.isWishlisted,
          hasMissingCover: entry.hasMissingCover,
          hasMissingMetadata: entry.hasMissingMetadata,
        ),
      LibraryTableColumn.cover => SizedBox(
          width: 28,
          height: 36,
          child: LibraryCoverImage(
            title: entry.title,
            itemNumber: entry.itemNumber,
            imageUrl: entry.displayCoverUrl,
          ),
        ),
      LibraryTableColumn.title => Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      LibraryTableColumn.issue => LibraryTableCellText(entry.itemNumber),
      LibraryTableColumn.variant => LibraryTableCellText(entry.variant),
      LibraryTableColumn.publisher => LibraryTableCellText(entry.publisher),
      LibraryTableColumn.releaseDate =>
        LibraryTableCellText(formatNullableComicDate(entry.releaseDate)),
      LibraryTableColumn.barcode => LibraryTableCellText(entry.barcode),
      LibraryTableColumn.grade => LibraryTableCellText(entry.grade),
      LibraryTableColumn.condition => LibraryTableCellText(entry.condition),
      LibraryTableColumn.price =>
        Text(formatComicMoney(entry.pricePaidCents, entry.currency)),
      LibraryTableColumn.storageBox => LibraryTableCellText(entry.storageBox),
      LibraryTableColumn.wishlist =>
        entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
      LibraryTableColumn.updated => Text(
          formatComicDate(entry.updatedAt),
          style: const TextStyle(fontSize: 12),
        ),
    };
  }

  List<_GenericLibraryItem> _itemsForShelf(ShelfState shelf) {
    final kind = widget.type.workspace.kind;
    return [
      for (final source in shelf.entries)
        if (source.catalogItem != null && source.catalogItem!.kind == kind)
          _GenericLibraryItem.fromShelf(source),
    ];
  }

  List<_GenericLibraryItem> _filteredItems(
    List<_GenericLibraryItem> items,
    LibraryWorkspaceViewState viewState,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = [
      for (final item in items)
        if (_matchesBucket(item) &&
            _matchesQuickView(item) &&
            _matchesQuery(item, query))
          item,
    ]..sort((a, b) => compareLibraryWorkspaceEntries(
          a.entry,
          b.entry,
          viewState.sortColumn,
          viewState.sortAscending,
        ));
    return filtered;
  }

  List<LibrarySeriesBucket> _bucketsForItems(List<_GenericLibraryItem> items) {
    final counts = <String, int>{_allBucketLabel(widget.type): items.length};
    for (final item in items) {
      final bucket = _bucketForItem(item);
      counts[bucket] = (counts[bucket] ?? 0) + 1;
    }
    final buckets = [
      for (final entry in counts.entries)
        LibrarySeriesBucket(title: entry.key, count: entry.value),
    ];
    buckets.sort((a, b) {
      if (a.title == _allBucketLabel(widget.type)) {
        return -1;
      }
      if (b.title == _allBucketLabel(widget.type)) {
        return 1;
      }
      return a.title.compareTo(b.title);
    });
    return buckets;
  }

  _GenericLibraryItem? _selectedItem(List<_GenericLibraryItem> items) {
    for (final item in items) {
      if (item.entry.id == _selectedId) {
        return item;
      }
    }
    return items.isEmpty ? null : items.first;
  }

  GenericToolbarCounts _toolbarCounts(ShelfState shelf) {
    final all = _itemsForShelf(shelf);
    final shown = _filteredItems(
      all,
      _viewState ?? _adapter.viewProfile.defaults(),
    ).length;
    return GenericToolbarCounts(
      shown: shown,
      total: all.length,
      owned: all.where((item) => item.entry.isOwned).length,
      wishlist: all.where((item) => item.entry.isWishlisted).length,
      missingCover: all.where((item) => item.entry.hasMissingCover).length,
      missingMetadata:
          all.where((item) => item.entry.hasMissingMetadata).length,
    );
  }

  bool _matchesBucket(_GenericLibraryItem item) {
    final bucket = _selectedBucket;
    return bucket == null || _bucketForItem(item) == bucket;
  }

  bool _matchesQuickView(_GenericLibraryItem item) {
    return switch (_quickView) {
      null => true,
      GenericQuickView.owned => item.entry.isOwned,
      GenericQuickView.wishlist => item.entry.isWishlisted,
      GenericQuickView.missingCovers => item.entry.hasMissingCover,
      GenericQuickView.missingMetadata => item.entry.hasMissingMetadata,
    };
  }

  bool _matchesQuery(_GenericLibraryItem item, String query) {
    if (query.isEmpty) {
      return true;
    }
    final entry = item.entry;
    return [
      entry.title,
      entry.itemNumber,
      entry.publisher,
      entry.variant,
      entry.barcode,
      entry.releaseYear?.toString(),
      entry.condition,
      entry.grade,
      entry.storageBox,
    ].whereType<String>().any((value) => value.toLowerCase().contains(query));
  }

  String _bucketForItem(_GenericLibraryItem item) {
    final entry = item.entry;
    final publisher = entry.publisher?.trim();
    if (widget.type.workspace.kind == 'movie' ||
        widget.type.workspace.kind == 'tv' ||
        widget.type.workspace.kind == 'anime') {
      return entry.releaseYear?.toString() ??
          (entry.releaseDate?.year.toString() ?? 'Unknown year');
    }
    if (widget.type.workspace.kind == 'music' &&
        publisher != null &&
        publisher.isNotEmpty) {
      return publisher;
    }
    if ((widget.type.workspace.kind == 'book' ||
            widget.type.workspace.kind == 'game' ||
            widget.type.workspace.kind == 'boardgame' ||
            widget.type.workspace.kind == 'manga') &&
        publisher != null &&
        publisher.isNotEmpty) {
      return publisher;
    }
    final title = entry.title.trim();
    return title.isEmpty ? 'Unknown' : title.characters.first.toUpperCase();
  }

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
    final store = LibraryColumnPresetStore(widget.type.workspace);
    final savedPresets = await store.read();
    if (!mounted) {
      return;
    }
    final selected = await showDialog<Set<LibraryTableColumn>>(
      context: context,
      builder: (context) => LibraryColumnChooserDialog(
        selectedColumns: viewState.visibleColumns,
        defaultColumns: _adapter.defaultTableColumns(),
        columnLabel: _adapter.columnDisplayName,
        columnGroup: _adapter.columnGroup,
        groupLabel: _adapter.columnGroupLabel,
        savedPresets: savedPresets,
        onSavePreset: (label, columns) => store.savePreset(
          label: label,
          columns: columns,
        ),
        onDeletePreset: store.deletePreset,
      ),
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
    ShelfState? shelf,
    LibraryWorkspaceViewState viewState,
  ) async {
    if (shelf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Library data is still loading')),
      );
      return;
    }
    final allItems = _itemsForShelf(shelf);
    final shownItems = _filteredItems(allItems, viewState);
    final selected = _selectedItem(shownItems);
    final result = await showLibraryMetadataRefreshDialog(
      context: context,
      type: widget.type,
      accent: widget.accent,
      allEntries: [for (final item in allItems) item.entry],
      shownEntries: [for (final item in shownItems) item.entry],
      selectedEntry: selected?.entry,
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

  Future<void> _addOwned(_GenericLibraryItem item) async {
    await ref.read(collectionMutationsProvider).addItem(item.entry.id);
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _removeOwned(_GenericLibraryItem item) async {
    final owned = item.source.ownedItem;
    if (owned == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).removeItem(owned);
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _addWishlist(_GenericLibraryItem item) async {
    await ref.read(collectionMutationsProvider).addToWishlist(item.entry.id);
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }

  Future<void> _removeWishlist(_GenericLibraryItem item) async {
    await ref.read(collectionMutationsProvider).removeFromWishlist(
          item.entry.id,
        );
    if (mounted) {
      ref.invalidate(shelfProvider);
    }
  }
}

class _GenericLibraryItem {
  const _GenericLibraryItem({
    required this.source,
    required this.entry,
  });

  factory _GenericLibraryItem.fromShelf(ShelfEntry source) {
    final item = source.catalogItem!;
    return _GenericLibraryItem(
      source: source,
      entry: LibraryWorkspaceEntry(
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
        isOwned: source.isOwned,
        isWishlisted: source.isWishlisted,
        hasMissingCover: item.displayCoverUrl == null,
        hasMissingMetadata: _hasMissingCoreMetadata(item),
        condition: source.ownedItem?.condition,
        grade: source.ownedItem?.grade,
        pricePaidCents: source.ownedItem?.pricePaidCents,
        currency: source.ownedItem?.currency,
        storageBox: source.ownedItem?.storageBox,
        updatedAt: source.updatedAt,
      ),
    );
  }

  final ShelfEntry source;
  final LibraryWorkspaceEntry entry;
}

class _CompactBucketBar extends StatelessWidget {
  const _CompactBucketBar({
    required this.type,
    required this.accent,
    required this.buckets,
    required this.selectedBucket,
    required this.onSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final String selectedBucket;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzPanel,
        border: Border(bottom: BorderSide(color: kClzDivider)),
      ),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          itemCount: buckets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final bucket = buckets[index];
            final selected = bucket.title == selectedBucket;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => onSelected(bucket.title),
              avatar: selected ? Icon(_sidebarIcon(type), size: 15) : null,
              label: Text('${bucket.title} ${bucket.count}'),
              selectedColor: accent.withValues(alpha: 0.42),
              side: BorderSide(color: selected ? accent : kClzDivider),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      ),
    );
  }
}

class _GenericEmptyState extends StatelessWidget {
  const _GenericEmptyState({
    required this.type,
    required this.icon,
    required this.accent,
    required this.hasActiveFilter,
    required this.onAdd,
    required this.onClearFilter,
  });

  final LibraryTypeConfig type;
  final IconData icon;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kClzCanvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: accent),
              const SizedBox(height: 14),
              Text(
                hasActiveFilter
                    ? 'No matching ${type.pluralLabel.toLowerCase()}'
                    : 'Your local ${type.pluralLabel.toLowerCase()} shelf is empty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                hasActiveFilter
                    ? 'Clear filters to return to your local shelf.'
                    : _emptyStateSummary(type),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kClzTextMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (hasActiveFilter)
                OutlinedButton.icon(
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Clear filter'),
                )
              else
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add from Collectarr Core'),
                ),
              if (!hasActiveFilter && type.supportedMetadataProviders.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Manual add is enabled even without provider search.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kClzTextMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _hasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.barcode == null &&
      item.variant == null;
}

String _allBucketLabel(LibraryTypeConfig type) => '[All ${type.pluralLabel}]';

String _sidebarTitle(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    'anime' || 'movie' || 'tv' => 'Years',
    'music' => 'Artists',
    'book' || 'game' || 'boardgame' || 'manga' => 'Publishers',
    _ => 'Titles',
  };
}

IconData _sidebarIcon(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    'music' => Icons.person_2_outlined,
    'movie' => Icons.movie_filter_outlined,
    _ => Icons.folder,
  };
}

String _emptyStateSummary(LibraryTypeConfig type) {
  if (type.supportedMetadataProviders.isEmpty) {
    return 'No providers are registered for this library yet.';
  }
  final providers =
      type.supportedMetadataProviders.map((p) => p.label).join(', ');
  final suffix = type.workspace.kind == 'movie' || type.workspace.kind == 'tv'
      ? ' Physical formats are tracked as editions.'
      : '';
  return 'Search Core via $providers, scan a barcode, or add a manual local item.$suffix';
}
