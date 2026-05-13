import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicsShelfContent extends StatelessWidget {
  const ComicsShelfContent({
    super.key,
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
    final wishlistIds = watchComicWishlistIds(ref);
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
      emptyBuilder: (_) => ComicsEmptyState(onAddComic: onAddComic),
      maxCrossAxisExtent: coverSize,
      mainAxisExtent: coverSize * 1.53,
      backgroundColor: kClzGridCanvas,
      itemBuilder: (context, item) {
        final ownedItem = ownedByItemId[item.id];
        return LibraryCoverTile(
          entry: comicWorkspaceEntry(
            item,
            ownedItem,
            null,
            isWishlisted: wishlistIds.contains(item.id),
          ),
          selected:
              selectedItemIds.contains(item.id) || item.id == selectedItemId,
          onTap: () => onSelectItem(item),
          selectedColor: kClzSelection,
          accentColor: kClzAccent,
          selectionColor: kClzYellow,
          mutedTextColor: kClzTextMuted,
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
    final wishlistIds = watchComicWishlistIds(ref);
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
      emptyBuilder: (_) => ComicsEmptyState(onAddComic: onAddComic),
      maxCrossAxisExtent: 430,
      mainAxisExtent: cardHeight,
      backgroundColor: kClzGridCanvas,
      itemBuilder: (context, item) {
        final ownedItem = ownedByItemId[item.id];
        return _ComicCard(
          entry: comicWorkspaceEntry(
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
      dateFormatter: formatComicDate,
      moneyFormatter: formatComicMoney,
      selectedColor: kClzSelection,
      accentColor: kClzAccent,
      mutedTextColor: kClzTextMuted,
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
      return ComicsEmptyState(onAddComic: onAddComic);
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
        final tableWidth = comicTableWidthForColumns(
          visibleColumns,
          columnWidths,
        );
        final contentWidth = tableWidth > constraints.maxWidth
            ? tableWidth + 16
            : constraints.maxWidth;
        return ColoredBox(
          color: kClzCanvas,
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
    final columns = orderedComicTableColumns(visibleColumns);
    return LibraryWorkspaceTable<_ComicTableEntry>(
      entries: entries,
      columns: columns,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      columnWidthFor: (column) => comicTableColumnWidth(
        column,
        columnWidths,
      ),
      defaultColumnWidthFor: defaultComicTableColumnWidth,
      columnSortFor: comicTableColumnSort,
      columnLabelFor: comicTableColumnLabel,
      columnIsNumeric: comicTableColumnIsNumeric,
      cellBuilder: _comicTableCellContent,
      isSelected: (entry) =>
          selectedItemIds.contains(entry.item.id) ||
          entry.item.id == selectedItemId,
      onEntryTap: (entry) => onSelectItem(entry.item),
      onSortChanged: onSortChanged,
      onColumnWidthChanged: onColumnWidthChanged,
      headerHeight: kComicTableHeaderHeight,
      rowHeight: kComicTableRowHeight,
      columnSpacing: kComicTableColumnSpacing,
      horizontalMargin: kComicTableHorizontalMargin,
      selectionRailWidth: kComicTableSelectionRailWidth,
      headerColor: const Color(0xFF303030),
      dividerColor: kClzDivider,
      selectedColor: kClzSelection,
      oddColor: kClzTableOddRow,
      evenColor: kClzTableEvenRow,
      selectionRailColor: kClzYellow,
      bottomBorderColor: kClzTableBottomBorder,
      hoverColor: kClzTableHover,
      accentColor: kClzAccent,
    );
  }
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
        formatNullableComicDate(entry.workspaceEntry.releaseDate)),
    LibraryTableColumn.barcode =>
      LibraryTableCellText(entry.workspaceEntry.barcode),
    LibraryTableColumn.grade =>
      LibraryTableCellText(entry.workspaceEntry.grade),
    LibraryTableColumn.condition =>
      LibraryTableCellText(entry.workspaceEntry.condition),
    LibraryTableColumn.price => Text(
        formatComicMoney(
          entry.workspaceEntry.pricePaidCents,
          entry.workspaceEntry.currency,
        ),
      ),
    LibraryTableColumn.storageBox =>
      LibraryTableCellText(entry.workspaceEntry.storageBox),
    LibraryTableColumn.wishlist =>
      entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
    LibraryTableColumn.updated => Text(
        formatComicDate(entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
  };
}

class _ComicTableEntry {
  _ComicTableEntry({
    required this.item,
    this.ownedItem,
    this.wishlistItem,
  }) : workspaceEntry = comicWorkspaceEntry(item, ownedItem, wishlistItem);

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

LibraryWorkspaceEntry comicWorkspaceEntry(
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

String formatComicMoney(int? cents, String? currency) {
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

class ComicsEmptyState extends StatelessWidget {
  const ComicsEmptyState({super.key, required this.onAddComic});

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

Set<String> watchComicWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}

String formatComicDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String? formatNullableComicDate(DateTime? value) {
  return value == null ? null : formatComicDate(value);
}
