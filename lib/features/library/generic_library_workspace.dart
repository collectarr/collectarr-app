import 'dart:math' as math;

import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/generic_library_empty_state.dart';
import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/library_media_adapter.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_table.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class GenericLibraryWorkspace extends StatelessWidget {
  const GenericLibraryWorkspace({
    super.key,
    required this.type,
    required this.adapter,
    required this.items,
    required this.viewState,
    required this.selectedId,
    required this.groupMode,
    required this.selectedBucket,
    required this.accent,
    required this.hasActiveFilter,
    required this.onAdd,
    required this.onClearFilters,
    required this.onSelectItem,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final List<GenericLibraryItem> items;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final GenericLibraryGroupMode groupMode;
  final String? selectedBucket;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onSelectItem;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;

  bool get _showGrouped =>
      selectedBucket == null &&
      groupMode != GenericLibraryGroupMode.title &&
      groupMode != GenericLibraryGroupMode.ownership;

  @override
  Widget build(BuildContext context) {
    if (_showGrouped && items.isNotEmpty) {
      return switch (viewState.viewMode) {
        LibraryViewMode.grid => _GroupedGrid(
            items: items,
            type: type,
            groupMode: groupMode,
            selectedId: selectedId,
            accent: accent,
            maxCrossAxisExtent: viewState.coverSize,
            mainAxisExtent: viewState.coverSize * 1.53,
            itemBuilder: (context, item) => LibraryCoverTile(
              entry: item.entry,
              selected: item.entry.id == selectedId,
              onTap: () => onSelectItem(item.entry.id),
              selectedColor: kClzSelection,
              accentColor: accent,
              selectionColor: kClzYellow,
              mutedTextColor: kClzTextMuted,
            ),
          ),
        LibraryViewMode.card => _GroupedGrid(
            items: items,
            type: type,
            groupMode: groupMode,
            selectedId: selectedId,
            accent: accent,
            maxCrossAxisExtent: 430,
            mainAxisExtent:
                (viewState.coverSize * 1.12).clamp(138.0, 174.0).toDouble(),
            itemBuilder: (context, item) => LibraryWorkspaceCard(
              entry: item.entry,
              selected: item.entry.id == selectedId,
              onTap: () => onSelectItem(item.entry.id),
              dateFormatter: formatComicDate,
              moneyFormatter: formatComicMoney,
              selectedColor: kClzSelection,
              accentColor: accent,
              mutedTextColor: kClzTextMuted,
            ),
          ),
        LibraryViewMode.list => _buildTable(),
      };
    }
    return switch (viewState.viewMode) {
      LibraryViewMode.grid => LibraryWorkspaceGrid<GenericLibraryItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: viewState.coverSize,
          mainAxisExtent: viewState.coverSize * 1.53,
          backgroundColor: kClzGridCanvas,
          itemBuilder: (context, item) => LibraryCoverTile(
            entry: item.entry,
            selected: item.entry.id == selectedId,
            onTap: () => onSelectItem(item.entry.id),
            selectedColor: kClzSelection,
            accentColor: accent,
            selectionColor: kClzYellow,
            mutedTextColor: kClzTextMuted,
          ),
        ),
      LibraryViewMode.card => LibraryWorkspaceGrid<GenericLibraryItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: 430,
          mainAxisExtent:
              (viewState.coverSize * 1.12).clamp(138.0, 174.0).toDouble(),
          backgroundColor: kClzGridCanvas,
          itemBuilder: (context, item) => LibraryWorkspaceCard(
            entry: item.entry,
            selected: item.entry.id == selectedId,
            onTap: () => onSelectItem(item.entry.id),
            dateFormatter: formatComicDate,
            moneyFormatter: formatComicMoney,
            selectedColor: kClzSelection,
            accentColor: accent,
            mutedTextColor: kClzTextMuted,
          ),
        ),
      LibraryViewMode.list => _buildTable(),
    };
  }

  Widget _emptyBuilder(BuildContext context) {
    return GenericLibraryEmptyState(
      type: type,
      icon: type.workspace.icon,
      accent: accent,
      hasActiveFilter: hasActiveFilter,
      onAdd: onAdd,
      onClearFilter: onClearFilters,
    );
  }

  Widget _buildTable() {
    if (items.isEmpty) {
      return Builder(builder: _emptyBuilder);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = adapter.tableWidthForColumns(
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
                  child: LibraryWorkspaceTable<GenericLibraryItem>(
                    entries: items,
                    columns:
                        adapter.orderedTableColumns(viewState.visibleColumns),
                    sortColumn: viewState.sortColumn,
                    sortAscending: viewState.sortAscending,
                    columnWidthFor: (column) => adapter.tableColumnWidth(
                      column,
                      viewState.columnWidths,
                    ),
                    defaultColumnWidthFor: adapter.defaultTableColumnWidth,
                    columnSortFor: adapter.columnSort,
                    columnLabelFor: adapter.columnLabel,
                    columnIsNumeric: adapter.columnIsNumeric,
                    cellBuilder: _tableCell,
                    isSelected: (item) => item.entry.id == selectedId,
                    onEntryTap: (item) => onSelectItem(item.entry.id),
                    onSortChanged: onSortChanged,
                    onColumnWidthChanged: onColumnWidthChanged,
                    onColumnReordered: onColumnReordered,
                    headerColor: const Color(0xFF303030),
                    dividerColor: kClzDivider,
                    selectedColor: kClzSelection,
                    oddColor: kClzTableOddRow,
                    evenColor: kClzTableEvenRow,
                    selectionRailColor: kClzYellow,
                    bottomBorderColor: kClzTableBottomBorder,
                    hoverColor: kClzTableHover,
                    accentColor: accent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tableCell(GenericLibraryItem item, LibraryTableColumn column) {
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
}

class _GroupedGrid extends StatefulWidget {
  const _GroupedGrid({
    required this.items,
    required this.type,
    required this.groupMode,
    required this.selectedId,
    required this.accent,
    required this.maxCrossAxisExtent,
    required this.mainAxisExtent,
    required this.itemBuilder,
  });

  final List<GenericLibraryItem> items;
  final LibraryTypeConfig type;
  final GenericLibraryGroupMode groupMode;
  final String? selectedId;
  final Color accent;
  final double maxCrossAxisExtent;
  final double mainAxisExtent;
  final LibraryGridItemBuilder<GenericLibraryItem> itemBuilder;

  @override
  State<_GroupedGrid> createState() => _GroupedGridState();
}

class _GroupedGridState extends State<_GroupedGrid> {
  final _collapsed = <String>{};

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<GenericLibraryItem>>{};
    for (final item in widget.items) {
      final key =
          genericBucketForItemMode(item, widget.type, widget.groupMode);
      (groups[key] ??= []).add(item);
    }
    final sortedKeys = groups.keys.toList()..sort();

    return ColoredBox(
      color: kClzGridCanvas,
      child: CustomScrollView(
        slivers: [
          for (final key in sortedKeys) ...[
            SliverToBoxAdapter(
              child: _GroupHeader(
                title: key,
                count: groups[key]!.length,
                collapsed: _collapsed.contains(key),
                accent: widget.accent,
                onToggle: () => setState(() {
                  if (_collapsed.contains(key)) {
                    _collapsed.remove(key);
                  } else {
                    _collapsed.add(key);
                  }
                }),
              ),
            ),
            if (!_collapsed.contains(key))
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        widget.itemBuilder(context, groups[key]![index]),
                    childCount: groups[key]!.length,
                  ),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: widget.maxCrossAxisExtent,
                    mainAxisExtent: widget.mainAxisExtent,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.accent,
    required this.onToggle,
  });

  final String title;
  final int count;
  final bool collapsed;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Icon(
              collapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: accent,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 12,
                color: accent.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
