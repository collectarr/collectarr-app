import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_row.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_reveal.dart';
import 'package:collectarr_app/ui/app_click_target.dart';
import 'package:collectarr_app/ui/app_press_tap.dart';
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
const double kLibraryTableCheckboxWidth = 28.0;
const double kLibraryTableStatusWidth = 28.0;
const double kLibraryTableEditWidth = 28.0;

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
    this.onColumnAutoSize,
    this.showCheckbox = false,
    this.showHeaderCheckbox = true,
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
    this.entryIdOf,
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
  final ValueChanged<String>? onColumnAutoSize;
  final bool showCheckbox;
  final bool showHeaderCheckbox;
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

  /// Identifies entries for reveal requests from [LibraryRevealScope].
  final String Function(T entry)? entryIdOf;
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

class _LibraryWorkspaceTableState<T> extends State<LibraryWorkspaceTable<T>>
    with LibraryRevealListener {
  final _scrollController = ScrollController();
  double _rowHeight = 0;

  @override
  void revealItem(String itemId) {
    final entryIdOf = widget.entryIdOf;
    if (entryIdOf == null) return;
    final index =
        widget.entries.indexWhere((entry) => entryIdOf(entry) == itemId);
    if (index < 0) return;
    double heightOf(T entry) => widget.rowHeightFor?.call(entry) ?? _rowHeight;
    var leading = 0.0;
    for (var i = 0; i < index; i++) {
      leading += heightOf(widget.entries[i]);
    }
    revealScrollExtent(_scrollController,
        leading: leading, extent: heightOf(widget.entries[index]));
  }

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
    _rowHeight = resolvedRowHeight;
    final resolvedColumnSpacing = widget.columnSpacing * densityScale;
    final resolvedHorizontalMargin = widget.horizontalMargin * densityScale;
    final palette = appPalette(context);
    final tableBorderRadius = BorderRadius.zero;
    final resolvedHeaderColor = widget.headerColor == kAppSurface
        ? libraryWorkspaceTableHeaderColor(context)
        : widget.headerColor;
    final resolvedDividerColor = widget.dividerColor == kAppDivider
        ? palette.divider
        : widget.dividerColor;
    final resolvedSelectedColor = widget.selectedColor == kAppSelection
        ? libraryWorkspaceSelectionBackground(context)
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
            ? palette.utilityAction
            : widget.selectionRailColor;
    final resolvedHoverColor = widget.hoverColor == kAppTableHover
        ? Color.alphaBlend(
            palette.utilityAction
                .withValues(alpha: palette.isDark ? 0.12 : 0.08),
            palette.surface,
          )
        : widget.hoverColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: tableBorderRadius,
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
              onColumnAutoSize: widget.onColumnAutoSize,
              showCheckbox: widget.showCheckbox,
              showHeaderCheckbox: widget.showHeaderCheckbox,
              allChecked: widget.allChecked,
              hasPartialCheck: widget.hasPartialCheck,
              onToggleAllChecked: widget.onToggleAllChecked,
              showStatus: widget.showStatus,
              showEdit: widget.showEdit,
              headerHeight: resolvedHeaderHeight,
              columnSpacing: resolvedColumnSpacing,
              horizontalMargin: resolvedHorizontalMargin,
              headerColor: resolvedHeaderColor,
              dividerColor: widget.dividerColor == kAppDivider
                  ? libraryWorkspacePaneDividerColor(context)
                  : resolvedDividerColor,
              accentColor: widget.accentColor,
            ),
            Expanded(
              child: ColoredBox(
                color: libraryViewBackgroundColor(context),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thickness: const WidgetStatePropertyAll<double>(6.0),
                    radius: const Radius.circular(3.0),
                    thumbColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.dragged)) {
                        return palette.utilityAction;
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return palette.utilityAction.withValues(alpha: 0.65);
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
                          dividerColor: widget.dividerColor == kAppDivider
                              ? libraryWorkspacePaneDividerColor(context)
                              : resolvedDividerColor,
                          hoverColor: resolvedHoverColor,
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
    required this.onColumnAutoSize,
    this.showCheckbox = false,
    this.showHeaderCheckbox = true,
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
  final ValueChanged<String>? onColumnAutoSize;
  final bool showCheckbox;
  final bool showHeaderCheckbox;
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
    return _LibraryTableColumnGrid(
      columns: columns,
      columnWidthFor: columnWidthFor,
      columnSpacing: columnSpacing,
      horizontalMargin: horizontalMargin,
      showCheckbox: showCheckbox,
      showStatus: showStatus,
      showEdit: showEdit,
      color: dividerColor,
      child: DecoratedBox(
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
                    child: showHeaderCheckbox
                        ? _LibraryTableCheckbox(
                            checked: allChecked,
                            indeterminate: !allChecked && hasPartialCheck,
                            accentColor: appPalette(context).utilityAction,
                            onTap: onToggleAllChecked == null
                                ? null
                                : () => onToggleAllChecked!(!allChecked),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
              if (showStatus) ...[
                SizedBox(
                  width: kLibraryTableStatusWidth,
                  height: headerHeight,
                ),
              ],
              if (showEdit) ...[
                SizedBox(
                  width: kLibraryTableEditWidth,
                  height: headerHeight,
                ),
              ],
              for (var index = 0; index < columns.length; index += 1) ...[
                _LibraryWorkspaceTableHeaderCell(
                  column: columns[index],
                  width: columnWidthFor(columns[index]),
                  defaultWidth: defaultColumnWidthFor(columns[index]),
                  onAutoSize: onColumnAutoSize,
                  sorted: columnSortFor(columns[index]) == sortColumn ||
                      _sortPriorityFor(columnSortFor(columns[index])) != null,
                  ascending: sortRules
                          .where((rule) =>
                              rule.column == columnSortFor(columns[index]))
                          .firstOrNull
                          ?.ascending ??
                      sortAscending,
                  sort: columnSortFor(columns[index]),
                  sortPriority: sortRules.length > 1
                      ? _sortPriorityFor(columnSortFor(columns[index]))
                      : null,
                  label: columnLabelFor(columns[index]),
                  onSortChanged: onSortChanged,
                  onColumnWidthChanged: onColumnWidthChanged,
                  height: headerHeight,
                  headerColor: headerColor,
                  accentColor: accentColor,
                ),
                if (index + 1 < columns.length) SizedBox(width: columnSpacing),
              ],
            ],
          ),
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

const _minResizedColumnWidth = 50.0;

class _LibraryWorkspaceTableHeaderCell extends StatefulWidget {
  const _LibraryWorkspaceTableHeaderCell({
    required this.column,
    required this.width,
    required this.defaultWidth,
    this.onAutoSize,
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
  });

  final String column;
  final double width;
  final double defaultWidth;
  final ValueChanged<String>? onAutoSize;
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

  @override
  State<_LibraryWorkspaceTableHeaderCell> createState() =>
      _LibraryWorkspaceTableHeaderCellState();
}

class _LibraryWorkspaceTableHeaderCellState
    extends State<_LibraryWorkspaceTableHeaderCell> {
  bool _dragging = false;
  bool _hovered = false;
  double _startX = 0;
  double _startWidth = 0;

  @override
  Widget build(BuildContext context) {
    final textColor = appContrastingTextColor(widget.headerColor);
    final showSort = widget.sorted && widget.width >= 64;
    final showPriority = widget.sortPriority != null && widget.width >= 80;
    // Icon columns are narrower than any resized column; as in the reference
    // they keep an empty header instead of a clipped label.
    final showLabel = widget.width >= _minResizedColumnWidth;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: widget.sorted
            ? libraryWorkspacePaneDividerColor(context)
            : widget.headerColor,
        child: Stack(children: [
          Positioned.fill(
              right: 5,
              child: InkWell(
                mouseCursor: _dragging
                    ? SystemMouseCursors.resizeColumn
                    : WidgetStateMouseCursor.clickable,
                onTap: _dragging || widget.sort == null
                    ? null
                    : () => widget.onSortChanged(widget.sort!),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(children: [
                    Expanded(
                        child: Text(showLabel ? widget.label : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0))),
                    if (showSort) ...[
                      const SizedBox(width: 2),
                      Icon(
                          widget.ascending
                              ? AppIcons.caretUp
                              : AppIcons.caretDown,
                          size: 14,
                          color: widget.accentColor),
                    ],
                    if (showPriority) ...[
                      const SizedBox(width: 1),
                      Text(widget.sortPriority.toString(),
                          key: ValueKey('sort-priority-${widget.column}'),
                          style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ]),
                ),
              )),
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: Semantics(
                    label: 'Resize column: ${widget.label}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      dragStartBehavior: DragStartBehavior.down,
                      onHorizontalDragStart: (details) {
                        _startX = details.globalPosition.dx;
                        _startWidth = widget.width;
                        setState(() => _dragging = true);
                      },
                      onHorizontalDragUpdate: (details) {
                        final width =
                            (_startWidth + details.globalPosition.dx - _startX)
                                .clamp(_minResizedColumnWidth, double.infinity);
                        widget.onColumnWidthChanged(
                            widget.column, width.toDouble());
                      },
                      onHorizontalDragEnd: (_) =>
                          setState(() => _dragging = false),
                      onHorizontalDragCancel: () =>
                          setState(() => _dragging = false),
                      onDoubleTap: () => widget.onAutoSize != null
                          ? widget.onAutoSize!(widget.column)
                          : widget.onColumnWidthChanged(
                              widget.column, widget.defaultWidth),
                      child: Container(
                          key: ValueKey('resize-column-${widget.column}'),
                          width: 5,
                          color: _dragging || _hovered
                              ? widget.accentColor
                              : Colors.transparent),
                    )),
              )),
        ]),
      ),
    );
  }
}

class _LibraryTableCheckbox extends StatelessWidget {
  const _LibraryTableCheckbox({
    required this.checked,
    this.indeterminate = false,
    required this.accentColor,
    this.outlineColor = Colors.white70,
    this.checkColor = Colors.white,
    this.onTap,
  });

  final bool checked;
  final bool indeterminate;
  final Color accentColor;
  final Color outlineColor;
  final Color checkColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = checked || indeterminate;
    return AppPressClaim(
        child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: active ? accentColor : outlineColor,
            width: 1.2,
          ),
        ),
        child: active
            ? Icon(
                indeterminate ? AppIcons.minus : AppIcons.check,
                size: 11,
                color: checkColor,
              )
            : null,
      ),
    ));
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
    required this.dividerColor,
    required this.hoverColor,
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
  final Color dividerColor;
  final Color hoverColor;

  @override
  Widget build(BuildContext context) {
    final isChecked = isEntryChecked?.call(entry) ?? false;
    final palette = appPalette(context);
    final rowControlColor = selected ? Colors.white : palette.utilityAction;
    return _LibraryTableColumnGrid(
      columns: columns,
      columnWidthFor: columnWidthFor,
      columnSpacing: columnSpacing,
      horizontalMargin: horizontalMargin,
      showCheckbox: showCheckbox,
      showStatus: showStatus,
      showEdit: showEdit,
      color: dividerColor,
      child: LibraryTableInkRow(
        // Table dimensions have already been scaled together with the header.
        density: LibraryDensity.comfortable,
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
        verticalPadding: 0,
        child: Row(
          children: [
            if (showCheckbox) ...[
              SizedBox(
                width: kLibraryTableCheckboxWidth,
                height: rowHeight,
                child: Center(
                  // Row controls use the shared blue, white on the blue
                  // selected row, as in the reference list.
                  child: _LibraryTableCheckbox(
                    checked: isChecked,
                    accentColor: rowControlColor,
                    outlineColor: rowControlColor,
                    checkColor: selected ? palette.utilityAction : Colors.white,
                    onTap: onToggleEntryCheck == null
                        ? null
                        : () => onToggleEntryCheck!(entry),
                  ),
                ),
              ),
            ],
            if (showStatus) ...[
              SizedBox(
                width: kLibraryTableStatusWidth,
                height: rowHeight,
                child: Center(
                  child: statusBuilder?.call(entry) ?? const SizedBox.shrink(),
                ),
              ),
            ],
            if (showEdit) ...[
              SizedBox(
                width: kLibraryTableEditWidth,
                height: rowHeight,
                child: Center(
                  child: Tooltip(
                    message: 'Edit',
                    child: AppClickTarget(
                      onClick: onEditEntry == null
                          ? null
                          : () => onEditEntry!(entry),
                      builder: (context, _) => SizedBox.square(
                        dimension: 24,
                        child: Icon(
                          AppIcons.inlineEdit,
                          size: 14,
                          color: rowControlColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            for (final column in columns) ...[
              SizedBox(
                width: columnWidthFor(column),
                height: rowHeight,
                child: Align(
                  alignment: columnIsNumeric(column)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: cellBuilder(entry, column)),
                ),
              ),
              if (column != columns.last) SizedBox(width: columnSpacing),
            ],
          ],
        ),
      ),
    );
  }
}

/// Paints column edges above selection/hover without changing cell geometry.
class _LibraryTableColumnGrid extends StatelessWidget {
  const _LibraryTableColumnGrid({
    required this.columns,
    required this.columnWidthFor,
    required this.columnSpacing,
    required this.horizontalMargin,
    required this.showCheckbox,
    required this.showStatus,
    required this.showEdit,
    required this.color,
    required this.child,
  });

  final List<String> columns;
  final LibraryColumnWidthFor columnWidthFor;
  final double columnSpacing;
  final double horizontalMargin;
  final bool showCheckbox;
  final bool showStatus;
  final bool showEdit;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var edge = horizontalMargin;
    final edges = <double>[];
    for (final width in [
      if (showCheckbox) kLibraryTableCheckboxWidth,
      if (showStatus) kLibraryTableStatusWidth,
      if (showEdit) kLibraryTableEditWidth,
    ]) {
      edge += width;
      edges.add(edge);
    }
    for (final column in columns) {
      edge += columnWidthFor(column);
      edges.add(edge);
      edge += columnSpacing;
    }
    return CustomPaint(
      foregroundPainter: _LibraryTableColumnGridPainter(edges, color),
      child: child,
    );
  }
}

class _LibraryTableColumnGridPainter extends CustomPainter {
  const _LibraryTableColumnGridPainter(this.edges, this.color);

  final List<double> edges;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final edge in edges) {
      canvas.drawRect(Rect.fromLTWH(edge - 1, 0, 1, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_LibraryTableColumnGridPainter oldDelegate) =>
      color != oldDelegate.color ||
      edges.length != oldDelegate.edges.length ||
      Iterable<int>.generate(edges.length)
          .any((index) => edges[index] != oldDelegate.edges[index]);
}
