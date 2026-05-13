import 'package:collectarr_app/features/library/workspace/library_table_row.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

typedef LibraryColumnWidthFor = double Function(LibraryTableColumn column);
typedef LibraryColumnSortFor = LibrarySortColumn? Function(
  LibraryTableColumn column,
);
typedef LibraryColumnLabelFor = String Function(LibraryTableColumn column);
typedef LibraryColumnNumericFor = bool Function(LibraryTableColumn column);
typedef LibraryColumnCellBuilder<T> = Widget Function(
  T entry,
  LibraryTableColumn column,
);

class LibraryWorkspaceTable<T> extends StatelessWidget {
  const LibraryWorkspaceTable({
    required this.entries,
    required this.columns,
    required this.sortColumn,
    required this.sortAscending,
    required this.columnWidthFor,
    required this.defaultColumnWidthFor,
    required this.columnSortFor,
    required this.columnLabelFor,
    required this.columnIsNumeric,
    required this.cellBuilder,
    required this.isSelected,
    required this.onEntryTap,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    this.headerHeight = 30,
    this.rowHeight = 38,
    this.columnSpacing = 10,
    this.horizontalMargin = 8,
    this.selectionRailWidth = 3,
    this.headerColor = const Color(0xFF303030),
    this.dividerColor = const Color(0xFF4A4A4A),
    this.selectedColor = const Color(0xFF075F75),
    this.oddColor = const Color(0xFF202428),
    this.evenColor = const Color(0xFF181B1E),
    this.selectionRailColor = const Color(0xFFFFD400),
    this.bottomBorderColor = const Color(0xFF2E2E2E),
    this.hoverColor = const Color(0xFF263940),
    this.accentColor = const Color(0xFF10A8D8),
    super.key,
  });

  final List<T> entries;
  final List<LibraryTableColumn> columns;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnWidthFor defaultColumnWidthFor;
  final LibraryColumnSortFor columnSortFor;
  final LibraryColumnLabelFor columnLabelFor;
  final LibraryColumnNumericFor columnIsNumeric;
  final LibraryColumnCellBuilder<T> cellBuilder;
  final bool Function(T entry) isSelected;
  final ValueChanged<T> onEntryTap;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final double headerHeight;
  final double rowHeight;
  final double columnSpacing;
  final double horizontalMargin;
  final double selectionRailWidth;
  final Color headerColor;
  final Color dividerColor;
  final Color selectedColor;
  final Color oddColor;
  final Color evenColor;
  final Color selectionRailColor;
  final Color bottomBorderColor;
  final Color hoverColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LibraryWorkspaceTableHeader(
          columns: columns,
          sortColumn: sortColumn,
          sortAscending: sortAscending,
          columnWidthFor: columnWidthFor,
          defaultColumnWidthFor: defaultColumnWidthFor,
          columnSortFor: columnSortFor,
          columnLabelFor: columnLabelFor,
          onSortChanged: onSortChanged,
          onColumnWidthChanged: onColumnWidthChanged,
          headerHeight: headerHeight,
          columnSpacing: columnSpacing,
          horizontalMargin: horizontalMargin,
          headerColor: headerColor,
          dividerColor: dividerColor,
          accentColor: accentColor,
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              primary: false,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _LibraryWorkspaceTableRow<T>(
                  entry: entry,
                  columns: columns,
                  selected: isSelected(entry),
                  odd: index.isOdd,
                  onTap: () => onEntryTap(entry),
                  columnWidthFor: columnWidthFor,
                  columnIsNumeric: columnIsNumeric,
                  cellBuilder: cellBuilder,
                  rowHeight: rowHeight,
                  columnSpacing: columnSpacing,
                  horizontalMargin: horizontalMargin,
                  selectionRailWidth: selectionRailWidth,
                  selectedColor: selectedColor,
                  oddColor: oddColor,
                  evenColor: evenColor,
                  selectionRailColor: selectionRailColor,
                  bottomBorderColor: bottomBorderColor,
                  hoverColor: hoverColor,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LibraryWorkspaceTableHeader extends StatelessWidget {
  const _LibraryWorkspaceTableHeader({
    required this.columns,
    required this.sortColumn,
    required this.sortAscending,
    required this.columnWidthFor,
    required this.defaultColumnWidthFor,
    required this.columnSortFor,
    required this.columnLabelFor,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.headerHeight,
    required this.columnSpacing,
    required this.horizontalMargin,
    required this.headerColor,
    required this.dividerColor,
    required this.accentColor,
  });

  final List<LibraryTableColumn> columns;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnWidthFor defaultColumnWidthFor;
  final LibraryColumnSortFor columnSortFor;
  final LibraryColumnLabelFor columnLabelFor;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final double headerHeight;
  final double columnSpacing;
  final double horizontalMargin;
  final Color headerColor;
  final Color dividerColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(color: dividerColor),
          top: BorderSide(color: dividerColor),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Row(
          children: [
            for (final column in columns) ...[
              _LibraryWorkspaceTableHeaderCell(
                column: column,
                width: columnWidthFor(column),
                defaultWidth: defaultColumnWidthFor(column),
                sorted: columnSortFor(column) == sortColumn,
                ascending: sortAscending,
                sort: columnSortFor(column),
                label: columnLabelFor(column),
                onSortChanged: onSortChanged,
                onColumnWidthChanged: onColumnWidthChanged,
                height: headerHeight,
                accentColor: accentColor,
                dividerColor: dividerColor,
              ),
              if (column != columns.last) SizedBox(width: columnSpacing),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryWorkspaceTableHeaderCell extends StatelessWidget {
  const _LibraryWorkspaceTableHeaderCell({
    required this.column,
    required this.width,
    required this.defaultWidth,
    required this.sorted,
    required this.ascending,
    required this.sort,
    required this.label,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.height,
    required this.accentColor,
    required this.dividerColor,
  });

  final LibraryTableColumn column;
  final double width;
  final double defaultWidth;
  final bool sorted;
  final bool ascending;
  final LibrarySortColumn? sort;
  final String label;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final double height;
  final Color accentColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            right: 8,
            child: InkWell(
              onTap: sort == null ? null : () => onSortChanged(sort!),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (sorted)
                    Icon(
                      ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 18,
                      color: accentColor,
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
                  final nextWidth =
                      (width + details.delta.dx).clamp(40.0, double.infinity);
                  onColumnWidthChanged(column, nextWidth.toDouble());
                },
                onDoubleTap: () => onColumnWidthChanged(column, defaultWidth),
                child: SizedBox(
                  width: 10,
                  child: Center(
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: dividerColor,
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

class _LibraryWorkspaceTableRow<T> extends StatelessWidget {
  const _LibraryWorkspaceTableRow({
    required this.entry,
    required this.columns,
    required this.selected,
    required this.odd,
    required this.onTap,
    required this.columnWidthFor,
    required this.columnIsNumeric,
    required this.cellBuilder,
    required this.rowHeight,
    required this.columnSpacing,
    required this.horizontalMargin,
    required this.selectionRailWidth,
    required this.selectedColor,
    required this.oddColor,
    required this.evenColor,
    required this.selectionRailColor,
    required this.bottomBorderColor,
    required this.hoverColor,
  });

  final T entry;
  final List<LibraryTableColumn> columns;
  final bool selected;
  final bool odd;
  final VoidCallback onTap;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnNumericFor columnIsNumeric;
  final LibraryColumnCellBuilder<T> cellBuilder;
  final double rowHeight;
  final double columnSpacing;
  final double horizontalMargin;
  final double selectionRailWidth;
  final Color selectedColor;
  final Color oddColor;
  final Color evenColor;
  final Color selectionRailColor;
  final Color bottomBorderColor;
  final Color hoverColor;

  @override
  Widget build(BuildContext context) {
    return LibraryTableInkRow(
      selected: selected,
      odd: odd,
      onTap: onTap,
      selectedColor: selectedColor,
      oddColor: oddColor,
      evenColor: evenColor,
      selectionRailColor: selectionRailColor,
      bottomBorderColor: bottomBorderColor,
      hoverColor: hoverColor,
      selectionRailWidth: selectionRailWidth,
      horizontalMargin: horizontalMargin,
      child: Row(
        children: [
          for (final column in columns) ...[
            SizedBox(
              width: columnWidthFor(column),
              height: rowHeight,
              child: Align(
                alignment: columnIsNumeric(column)
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cellBuilder(entry, column),
              ),
            ),
            if (column != columns.last) SizedBox(width: columnSpacing),
          ],
        ],
      ),
    );
  }
}
