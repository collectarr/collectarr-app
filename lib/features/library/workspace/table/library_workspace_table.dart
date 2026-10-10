import 'package:collectarr_app/features/library/workspace/table/library_table_row.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryColumnWidthFor = double Function(String column);
typedef LibraryColumnSortFor = String? Function(
  String column,
);
typedef LibraryColumnLabelFor = String Function(String column);
typedef LibraryColumnNumericFor = bool Function(String column);
typedef LibraryColumnCellBuilder<T> = Widget Function(
  T entry,
  String column,
);
typedef LibraryColumnReordered = void Function(
  String column,
  String? beforeColumn,
);

const double kLibraryTableCheckboxWidth = 32.0;
const double kLibraryTableStatusWidth = 26.0;
const double kLibraryTableEditWidth = 26.0;

class LibraryWorkspaceTable<T> extends StatefulWidget {
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
    this.onEntryDoubleTap,
    this.onEntrySecondaryTapUp,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    this.onColumnReordered,
    this.showCheckbox = false,
    this.isEntryChecked,
    this.onToggleEntryCheck,
    this.allChecked = false,
    this.hasPartialCheck = false,
    this.onToggleAllChecked,
    this.showStatus = false,
    this.statusBuilder,
    this.showEdit = false,
    this.onEditEntry,
    this.headerHeight = 30,
    this.rowHeight = 38,
    this.rowHeightFor,
    this.columnSpacing = 10,
    this.horizontalMargin = 8,
    this.selectionRailWidth = 3,
    this.headerColor = kAppSurface,
    this.dividerColor = kAppDivider,
    this.selectedColor = kAppSelection,
    this.oddColor = kAppTableOddRow,
    this.evenColor = kAppTableEvenRow,
    this.selectionRailColor = kAppHighlight,
    this.bottomBorderColor = kAppTableBottomBorder,
    this.hoverColor = kAppTableHover,
    this.accentColor = kAppAccent,
    this.density,
    super.key,
  });

  final List<T> entries;
  final List<String> columns;
  final String sortColumn;
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
  final ValueChanged<T>? onEntryDoubleTap;
  final void Function(T entry, TapUpDetails details)? onEntrySecondaryTapUp;
  final ValueChanged<String> onSortChanged;
  final void Function(String column, double width) onColumnWidthChanged;
  final LibraryColumnReordered? onColumnReordered;
  final bool showCheckbox;
  final bool Function(T entry)? isEntryChecked;
  final ValueChanged<T>? onToggleEntryCheck;
  final bool allChecked;
  final bool hasPartialCheck;
  final ValueChanged<bool>? onToggleAllChecked;
  final bool showStatus;
  final Widget Function(T entry)? statusBuilder;
  final bool showEdit;
  final ValueChanged<T>? onEditEntry;
  final double headerHeight;
  final double rowHeight;
  final double Function(T entry)? rowHeightFor;
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
  final LibraryDensity? density;

  @override
  State<LibraryWorkspaceTable<T>> createState() =>
      _LibraryWorkspaceTableState<T>();
}

class _LibraryWorkspaceTableState<T> extends State<LibraryWorkspaceTable<T>> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedDensity = widget.density ?? LibraryDensityScope.of(context);
    final densityMetrics = resolvedDensity.metrics;
    final densityScale = densityMetrics.scale;
    final resolvedHeaderHeight = widget.headerHeight * densityScale;
    final resolvedRowHeight = widget.rowHeight * densityScale;
    final resolvedColumnSpacing = widget.columnSpacing * densityScale;
    final resolvedHorizontalMargin = widget.horizontalMargin * densityScale;
    final palette = appPalette(context);
    final tableBorderRadius = BorderRadius.circular(2);
    final resolvedHeaderColor = widget.headerColor == kAppSurface
        ? libraryWorkspaceTableHeaderColor(context)
        : widget.headerColor;
    final resolvedDividerColor = widget.dividerColor == kAppDivider
        ? palette.divider
        : widget.dividerColor;
    final resolvedSelectedColor = widget.selectedColor == kAppSelection
        ? libraryWorkspaceSelectionBackground(
            context,
            accentColor: widget.accentColor,
            baseColor: palette.surface,
          )
        : widget.selectedColor;
    final resolvedOddColor = widget.oddColor == kAppTableOddRow
        ? palette.tableOddRow
        : widget.oddColor;
    final resolvedEvenColor = widget.evenColor == kAppTableEvenRow
        ? palette.tableEvenRow
        : widget.evenColor;
    final resolvedBottomBorderColor =
        widget.bottomBorderColor == kAppTableBottomBorder
            ? palette.tableBottomBorder
            : widget.bottomBorderColor;
    final resolvedSelectionRailColor =
        widget.selectionRailColor == kAppHighlight
            ? widget.accentColor
            : widget.selectionRailColor;
    final resolvedHoverColor = widget.hoverColor == kAppTableHover
        ? Color.alphaBlend(
            widget.accentColor.withValues(alpha: palette.isDark ? 0.12 : 0.08),
            palette.surface,
          )
        : widget.hoverColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: tableBorderRadius,
        border: Border.all(color: resolvedDividerColor.withValues(alpha: 0.92)),
      ),
      child: ClipRRect(
        borderRadius: tableBorderRadius,
        child: Column(
          children: [
            _LibraryWorkspaceTableHeader(
              columns: widget.columns,
              sortColumn: widget.sortColumn,
              sortAscending: widget.sortAscending,
              sortRules: widget.sortRules,
              columnWidthFor: widget.columnWidthFor,
              defaultColumnWidthFor: widget.defaultColumnWidthFor,
              columnSortFor: widget.columnSortFor,
              columnLabelFor: widget.columnLabelFor,
              onSortChanged: widget.onSortChanged,
              onColumnWidthChanged: widget.onColumnWidthChanged,
              onColumnReordered: widget.onColumnReordered,
              showCheckbox: widget.showCheckbox,
              allChecked: widget.allChecked,
              hasPartialCheck: widget.hasPartialCheck,
              onToggleAllChecked: widget.onToggleAllChecked,
              showStatus: widget.showStatus,
              showEdit: widget.showEdit,
              headerHeight: resolvedHeaderHeight,
              columnSpacing: resolvedColumnSpacing,
              horizontalMargin: resolvedHorizontalMargin,
              headerColor: resolvedHeaderColor,
              dividerColor: resolvedDividerColor,
              accentColor: widget.accentColor,
            ),
            Expanded(
              child: ColoredBox(
                color: libraryWorkspaceBackgroundColor(context),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thickness: const WidgetStatePropertyAll<double>(6.0),
                    radius: const Radius.circular(3.0),
                    thumbColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.dragged)) {
                        return widget.accentColor.withValues(alpha: 0.85);
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return widget.accentColor.withValues(alpha: 0.65);
                      }
                      return Colors.white24;
                    }),
                    trackVisibility: const WidgetStatePropertyAll<bool>(false),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      primary: false,
                      itemCount: widget.entries.length,
                      itemExtent: widget.rowHeightFor == null
                          ? resolvedRowHeight
                          : null,
                      itemBuilder: (context, index) {
                        final entry = widget.entries[index];
                        return _LibraryWorkspaceTableRow<T>(
                          entry: entry,
                          columns: widget.columns,
                          selected: widget.isSelected(entry),
                          odd: index.isOdd,
                          onTap: () => widget.onEntryTap(entry),
                          onDoubleTap: widget.onEntryDoubleTap == null
                              ? null
                              : () => widget.onEntryDoubleTap!(entry),
                          onSecondaryTapUp: widget.onEntrySecondaryTapUp == null
                              ? null
                              : (details) =>
                                  widget.onEntrySecondaryTapUp!(entry, details),
                          columnWidthFor: widget.columnWidthFor,
                          columnIsNumeric: widget.columnIsNumeric,
                          cellBuilder: widget.cellBuilder,
                          showCheckbox: widget.showCheckbox,
                          isEntryChecked: widget.isEntryChecked,
                          onToggleEntryCheck: widget.onToggleEntryCheck,
                          showStatus: widget.showStatus,
                          statusBuilder: widget.statusBuilder,
                          showEdit: widget.showEdit,
                          onEditEntry: widget.onEditEntry,
                          rowHeight: widget.rowHeightFor?.call(entry) ??
                              resolvedRowHeight,
                          columnSpacing: resolvedColumnSpacing,
                          horizontalMargin: resolvedHorizontalMargin,
                          selectionRailWidth: widget.selectionRailWidth,
                          selectedColor: resolvedSelectedColor,
                          oddColor: resolvedOddColor,
                          evenColor: resolvedEvenColor,
                          selectionRailColor: resolvedSelectionRailColor,
                          bottomBorderColor: resolvedBottomBorderColor,
                          hoverColor: resolvedHoverColor,
                          accentColor: widget.accentColor,
                        );
                      },
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
    this.showCheckbox = false,
    this.allChecked = false,
    this.hasPartialCheck = false,
    this.onToggleAllChecked,
    this.showStatus = false,
    this.showEdit = false,
    required this.headerHeight,
    required this.columnSpacing,
    required this.horizontalMargin,
    required this.headerColor,
    required this.dividerColor,
    required this.accentColor,
  });

  final List<String> columns;
  final String sortColumn;
  final bool sortAscending;
  final List<LibrarySortRule> sortRules;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnWidthFor defaultColumnWidthFor;
  final LibraryColumnSortFor columnSortFor;
  final LibraryColumnLabelFor columnLabelFor;
  final ValueChanged<String> onSortChanged;
  final void Function(String column, double width) onColumnWidthChanged;
  final LibraryColumnReordered? onColumnReordered;
  final bool showCheckbox;
  final bool allChecked;
  final bool hasPartialCheck;
  final ValueChanged<bool>? onToggleAllChecked;
  final bool showStatus;
  final bool showEdit;
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
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Row(
          children: [
            if (showCheckbox) ...[
              SizedBox(
                width: kLibraryTableCheckboxWidth,
                height: headerHeight,
                child: Center(
                  child: _LibraryTableCheckbox(
                    checked: allChecked,
                    indeterminate: !allChecked && hasPartialCheck,
                    accentColor: accentColor,
                    onTap: onToggleAllChecked == null
                        ? null
                        : () => onToggleAllChecked!(!allChecked),
                  ),
                ),
              ),
              SizedBox(width: columnSpacing),
            ],
            if (showStatus) ...[
              SizedBox(
                width: kLibraryTableStatusWidth,
                height: headerHeight,
              ),
              SizedBox(width: columnSpacing),
            ],
            if (showEdit) ...[
              SizedBox(
                width: kLibraryTableEditWidth,
                height: headerHeight,
              ),
              SizedBox(width: columnSpacing),
            ],
            for (var index = 0; index < columns.length; index += 1) ...[
              _LibraryWorkspaceTableHeaderCell(
                column: columns[index],
                width: columnWidthFor(columns[index]),
                defaultWidth: defaultColumnWidthFor(columns[index]),
                sorted: columnSortFor(columns[index]) == sortColumn ||
                    _sortPriorityFor(columnSortFor(columns[index])) != null,
                ascending: sortAscending,
                sort: columnSortFor(columns[index]),
                sortPriority: _sortPriorityFor(columnSortFor(columns[index])),
                label: columnLabelFor(columns[index]),
                onSortChanged: onSortChanged,
                onColumnWidthChanged: onColumnWidthChanged,
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

  int? _sortPriorityFor(Object? column) {
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
    required this.width,
    required this.defaultWidth,
    required this.sorted,
    required this.ascending,
    required this.sort,
    required this.sortPriority,
    required this.label,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.height,
    required this.headerColor,
    required this.accentColor,
    required this.dividerColor,
  });

  final String column;
  final double width;
  final double defaultWidth;
  final bool sorted;
  final bool ascending;
  final String? sort;
  final int? sortPriority;
  final String label;
  final ValueChanged<String> onSortChanged;
  final void Function(String column, double width) onColumnWidthChanged;
  final double height;
  final Color headerColor;
  final Color accentColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final headerTextColor = appContrastingTextColor(headerColor);
    final headerMutedTextColor = headerTextColor.withValues(alpha: 0.72);
    final showSortIcon = sorted && width >= 64;
    final showSortPriority = sortPriority != null && width >= 80;
    return Container(
      width: width,
      height: height,
      color: sorted ? libraryWorkspacePaneDividerColor(context) : headerColor,
      child: Stack(
        children: [
          Positioned.fill(
            right: 8,
            child: InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              onTap: sort == null ? null : () => onSortChanged(sort!),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: headerTextColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  if (showSortIcon) ...[
                    const SizedBox(width: 2),
                    Icon(
                      ascending
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: sorted ? accentColor : headerMutedTextColor,
                    ),
                  ],
                  if (showSortPriority) ...[
                    const SizedBox(width: 1),
                    Text(
                      sortPriority.toString(),
                      key: ValueKey('sort-priority-$column'),
                      style: TextStyle(
                        color: sorted ? accentColor : headerMutedTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
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
              child: Semantics(
                label: 'Resize column',
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
          ),
        ],
      ),
    );
  }
}

class _LibraryTableCheckbox extends StatelessWidget {
  const _LibraryTableCheckbox({
    required this.checked,
    this.indeterminate = false,
    required this.accentColor,
    this.onTap,
  });

  final bool checked;
  final bool indeterminate;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = checked || indeterminate;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: active ? accentColor : Colors.white38,
            width: 1.2,
          ),
        ),
        child: active
            ? Icon(
                indeterminate ? Icons.remove : Icons.check,
                size: 11,
                color: Colors.white,
              )
            : null,
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
    this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.columnWidthFor,
    required this.columnIsNumeric,
    required this.cellBuilder,
    this.showCheckbox = false,
    this.isEntryChecked,
    this.onToggleEntryCheck,
    this.showStatus = false,
    this.statusBuilder,
    this.showEdit = false,
    this.onEditEntry,
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
    required this.accentColor,
  });

  final T entry;
  final List<String> columns;
  final bool selected;
  final bool odd;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final LibraryColumnWidthFor columnWidthFor;
  final LibraryColumnNumericFor columnIsNumeric;
  final LibraryColumnCellBuilder<T> cellBuilder;
  final bool showCheckbox;
  final bool Function(T entry)? isEntryChecked;
  final ValueChanged<T>? onToggleEntryCheck;
  final bool showStatus;
  final Widget Function(T entry)? statusBuilder;
  final bool showEdit;
  final ValueChanged<T>? onEditEntry;
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
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isChecked = isEntryChecked?.call(entry) ?? false;
    return LibraryTableInkRow(
      selected: selected,
      odd: odd,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
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
          if (showCheckbox) ...[
            SizedBox(
              width: kLibraryTableCheckboxWidth,
              height: rowHeight,
              child: Center(
                child: _LibraryTableCheckbox(
                  checked: isChecked,
                  accentColor: accentColor,
                  onTap: onToggleEntryCheck == null
                      ? null
                      : () => onToggleEntryCheck!(entry),
                ),
              ),
            ),
            SizedBox(width: columnSpacing),
          ],
          if (showStatus) ...[
            SizedBox(
              width: kLibraryTableStatusWidth,
              height: rowHeight,
              child: Center(
                child: statusBuilder?.call(entry) ?? const SizedBox.shrink(),
              ),
            ),
            SizedBox(width: columnSpacing),
          ],
          if (showEdit) ...[
            SizedBox(
              width: kLibraryTableEditWidth,
              height: rowHeight,
              child: Center(
                child: Tooltip(
                  message: 'Edit',
                  child: InkResponse(
                    onTap:
                        onEditEntry == null ? null : () => onEditEntry!(entry),
                    radius: 12,
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: columnSpacing),
          ],
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
