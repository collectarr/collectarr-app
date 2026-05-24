import 'package:collectarr_app/features/library/workspace/library_table_row.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
typedef LibraryColumnReordered = void Function(
  LibraryTableColumn column,
  LibraryTableColumn? beforeColumn,
);

class LibraryWorkspaceTable<T> extends StatelessWidget {
  const LibraryWorkspaceTable({
    required this.entries,
    required this.columns,
    required this.sortColumn,
    required this.sortAscending,
    this.sortRules = const [],
    required this.columnWidthFor,
    required this.defaultColumnWidthFor,
    required this.columnSortFor,
    required this.columnLabelFor,
    required this.columnIsNumeric,
    required this.cellBuilder,
    required this.isSelected,
    required this.onEntryTap,
    this.onEntrySecondaryTapUp,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    this.onColumnReordered,
    this.headerHeight = 30,
    this.rowHeight = 38,
    this.columnSpacing = 10,
    this.horizontalMargin = 8,
    this.selectionRailWidth = 3,
    this.headerColor = const Color(0xFF303030),
    this.dividerColor = kAppDivider,
    this.selectedColor = kAppSelection,
    this.oddColor = kAppTableOddRow,
    this.evenColor = kAppTableEvenRow,
    this.selectionRailColor = kAppHighlight,
    this.bottomBorderColor = kAppTableBottomBorder,
    this.hoverColor = kAppTableHover,
    this.accentColor = kAppAccent,
    super.key,
  });

  final List<T> entries;
  final List<LibraryTableColumn> columns;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final List<LibrarySortRule> sortRules;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnWidthFor defaultColumnWidthFor;
  final LibraryColumnSortFor columnSortFor;
  final LibraryColumnLabelFor columnLabelFor;
  final LibraryColumnNumericFor columnIsNumeric;
  final LibraryColumnCellBuilder<T> cellBuilder;
  final bool Function(T entry) isSelected;
  final ValueChanged<T> onEntryTap;
  final void Function(T entry, TapUpDetails details)? onEntrySecondaryTapUp;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final LibraryColumnReordered? onColumnReordered;
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
          sortRules: sortRules,
          columnWidthFor: columnWidthFor,
          defaultColumnWidthFor: defaultColumnWidthFor,
          columnSortFor: columnSortFor,
          columnLabelFor: columnLabelFor,
          onSortChanged: onSortChanged,
          onColumnWidthChanged: onColumnWidthChanged,
          onColumnReordered: onColumnReordered,
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
                  onSecondaryTapUp: onEntrySecondaryTapUp == null
                      ? null
                      : (details) =>
                          onEntrySecondaryTapUp!(entry, details),
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
    required this.sortRules,
    required this.columnWidthFor,
    required this.defaultColumnWidthFor,
    required this.columnSortFor,
    required this.columnLabelFor,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
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
  final List<LibrarySortRule> sortRules;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnWidthFor defaultColumnWidthFor;
  final LibraryColumnSortFor columnSortFor;
  final LibraryColumnLabelFor columnLabelFor;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final LibraryColumnReordered? onColumnReordered;
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
            for (var index = 0; index < columns.length; index += 1) ...[
              _LibraryWorkspaceTableHeaderCell(
                column: columns[index],
                nextColumn:
                    index + 1 < columns.length ? columns[index + 1] : null,
                width: columnWidthFor(columns[index]),
                defaultWidth: defaultColumnWidthFor(columns[index]),
                sorted: columnSortFor(columns[index]) == sortColumn,
                ascending: sortAscending,
                sort: columnSortFor(columns[index]),
                sortPriority: _sortPriorityFor(columnSortFor(columns[index])),
                label: columnLabelFor(columns[index]),
                onSortChanged: onSortChanged,
                onColumnWidthChanged: onColumnWidthChanged,
                onColumnReordered: onColumnReordered,
                height: headerHeight,
                headerColor: headerColor,
                accentColor: accentColor,
                dividerColor: dividerColor,
              ),
              if (index + 1 < columns.length) SizedBox(width: columnSpacing),
            ],
          ],
        ),
      ),
    );
  }

  int? _sortPriorityFor(LibrarySortColumn? column) {
    if (column == null) {
      return null;
    }
    for (var index = 0; index < sortRules.length; index += 1) {
      if (sortRules[index].column == column) {
        return index + 1;
      }
    }
    return null;
  }
}

class _LibraryWorkspaceTableHeaderCell extends StatelessWidget {
  const _LibraryWorkspaceTableHeaderCell({
    required this.column,
    required this.nextColumn,
    required this.width,
    required this.defaultWidth,
    required this.sorted,
    required this.ascending,
    required this.sort,
    required this.sortPriority,
    required this.label,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
    required this.height,
    required this.headerColor,
    required this.accentColor,
    required this.dividerColor,
  });

  final LibraryTableColumn column;
  final LibraryTableColumn? nextColumn;
  final double width;
  final double defaultWidth;
  final bool sorted;
  final bool ascending;
  final LibrarySortColumn? sort;
  final int? sortPriority;
  final String label;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final LibraryColumnReordered? onColumnReordered;
  final double height;
  final Color headerColor;
  final Color accentColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return DragTarget<LibraryTableColumn>(
      onWillAcceptWithDetails: (details) {
        return onColumnReordered != null && details.data != column;
      },
      onAcceptWithDetails: (details) {
        onColumnReordered?.call(
            details.data,
            _dropTargetColumn(
              context,
              details.offset,
            ));
      },
      builder: (context, candidateColumns, rejectedColumns) {
        final highlighted = candidateColumns.isNotEmpty;
        return SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: highlighted
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(color: accentColor, width: 2),
                    ),
                  )
                : const BoxDecoration(),
            child: Stack(
              children: [
                Positioned.fill(
                  right: 8,
                  child: InkWell(
                    onTap: sort == null ? null : () => onSortChanged(sort!),
                    child: Row(
                      children: [
                        if (onColumnReordered != null)
                          _LibraryColumnDragHandle(
                            column: column,
                            label: label,
                            headerColor: headerColor,
                            accentColor: accentColor,
                          ),
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
                            ascending
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 18,
                            color: accentColor,
                          ),
                        if (sortPriority != null)
                          Container(
                            key: ValueKey('sort-priority-${column.name}'),
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              sortPriority.toString(),
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
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
                        final nextWidth = (width + details.delta.dx)
                            .clamp(40.0, double.infinity);
                        onColumnWidthChanged(column, nextWidth.toDouble());
                      },
                      onDoubleTap: () =>
                          onColumnWidthChanged(column, defaultWidth),
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
          ),
        );
      },
    );
  }

  LibraryTableColumn? _dropTargetColumn(BuildContext context, Offset offset) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return column;
    }
    final localOffset = box.globalToLocal(offset);
    return localOffset.dx > width / 2 ? nextColumn : column;
  }
}

class _LibraryColumnDragHandle extends StatelessWidget {
  const _LibraryColumnDragHandle({
    required this.column,
    required this.label,
    required this.headerColor,
    required this.accentColor,
  });

  final LibraryTableColumn column;
  final String label;
  final Color headerColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final feedbackLabel =
        label.trim().isEmpty ? _humanizeEnumName(column.name) : label;
    const icon = Icon(
      Icons.drag_indicator,
      size: 14,
      color: Colors.white70,
    );
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Tooltip(
        message: 'Reorder column',
        child: Draggable<LibraryTableColumn>(
          data: column,
          feedback: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: headerColor,
                border: Border.all(color: accentColor),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                child: Text(
                  feedbackLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          childWhenDragging: const Opacity(opacity: 0.35, child: icon),
          child: icon,
        ),
      ),
    );
  }
}

String _humanizeEnumName(String name) {
  final buffer = StringBuffer();
  for (var index = 0; index < name.length; index += 1) {
    final character = name[index];
    final isUppercase = character.toUpperCase() == character &&
        character.toLowerCase() != character;
    if (index == 0) {
      buffer.write(character.toUpperCase());
    } else if (isUppercase) {
      buffer.write(' ');
      buffer.write(character);
    } else {
      buffer.write(character);
    }
  }
  return buffer.toString();
}

class _LibraryWorkspaceTableRow<T> extends StatelessWidget {
  const _LibraryWorkspaceTableRow({
    required this.entry,
    required this.columns,
    required this.selected,
    required this.odd,
    required this.onTap,
    this.onSecondaryTapUp,
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
  final GestureTapUpCallback? onSecondaryTapUp;
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
      onSecondaryTapUp: onSecondaryTapUp,
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
