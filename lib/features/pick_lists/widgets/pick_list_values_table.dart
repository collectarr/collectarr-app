import 'pick_list_chrome.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import '../models/pick_list_value.dart';

enum PickListTableMode { manage, singleSelect, multiSelect, merge }

enum PickListTableSort { name, sortName, count }

/// Shared Name / Sort Name / Count table for selection and management.
class PickListValuesTable extends StatefulWidget {
  const PickListValuesTable(
      {super.key,
      required this.values,
      required this.usageCounts,
      this.mode = PickListTableMode.manage,
      this.selectedIds = const {},
      this.onSelect,
      this.onEdit,
      this.onDelete,
      this.enabled = true});
  final List<PickListValue> values;
  final Map<String, int> usageCounts;
  final PickListTableMode mode;
  final Set<String> selectedIds;
  final ValueChanged<PickListValue>? onSelect;
  final ValueChanged<PickListValue>? onEdit;
  final ValueChanged<PickListValue>? onDelete;
  final bool enabled;
  @override
  State<PickListValuesTable> createState() => _PickListValuesTableState();
}

class _PickListValuesTableState extends State<PickListValuesTable> {
  PickListTableSort _sort = PickListTableSort.name;
  bool _descending = false;
  void _sortBy(PickListTableSort sort) => setState(() {
        _descending = _sort == sort ? !_descending : false;
        _sort = sort;
      });

  Widget _heading(String text, PickListTableSort sort,
          {bool secondary = false}) =>
      InkWell(
        onTap: () => _sortBy(sort),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
              style: TextStyle(
                  fontSize: secondary ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: secondary ? appPalette(context).textMuted : null)),
          if (_sort == sort)
            Icon(_descending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                size: 16),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selecting = widget.mode != PickListTableMode.manage;
    final values = [...widget.values]..sort((a, b) {
        final comparison = switch (_sort) {
          PickListTableSort.name => a.effectiveLabel
              .toLowerCase()
              .compareTo(b.effectiveLabel.toLowerCase()),
          PickListTableSort.sortName => a.effectiveSortName
              .toLowerCase()
              .compareTo(b.effectiveSortName.toLowerCase()),
          PickListTableSort.count => (widget.usageCounts[a.id] ?? 0)
              .compareTo(widget.usageCounts[b.id] ?? 0),
        };
        final stable = comparison == 0
            ? a.effectiveLabel
                .toLowerCase()
                .compareTo(b.effectiveLabel.toLowerCase())
            : comparison;
        return _descending ? -stable : stable;
      });
    return Column(children: [
      CustomPaint(
          foregroundPainter: _PickListGrid(pickListDivider(context), selecting),
          child: Container(
              height: 48,
              decoration: BoxDecoration(
                  color: pickListToolbar(context),
                  border: Border(
                      bottom: BorderSide(color: pickListDivider(context)))),
              child: Row(children: [
                const SizedBox(width: 36),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _heading('Name', PickListTableSort.name),
                              _heading('Sort Name', PickListTableSort.sortName,
                                  secondary: true)
                            ]))),
                SizedBox(
                    width: 84,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: _heading('Count', PickListTableSort.count))),
                if (!selecting) const SizedBox(width: 36),
              ]))),
      Expanded(
          child: values.isEmpty
              ? const Center(child: Text('No Result'))
              : ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    final value = values[index];
                    final selected = widget.selectedIds.contains(value.id);
                    final onTap = widget.enabled
                        ? (selecting ? widget.onSelect : widget.onEdit)
                        : null;
                    return CustomPaint(
                        foregroundPainter:
                            _PickListGrid(pickListDivider(context), selecting),
                        child: Material(
                            color: selected
                                ? palette.selection.withValues(alpha: 0.32)
                                : pickListRow(context, index),
                            child: InkWell(
                                onTap:
                                    onTap == null ? null : () => onTap(value),
                                mouseCursor: WidgetStateMouseCursor.clickable,
                                child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minHeight: 48),
                                    child: Row(children: [
                                      SizedBox(
                                          width: 36,
                                          child: selecting
                                              ? (widget.mode ==
                                                      PickListTableMode
                                                          .singleSelect
                                                  ? Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                                      size: 18,
                                                      color: selected
                                                          ? palette.accent
                                                          : palette.textMuted)
                                                  : Checkbox(
                                                      value: selected,
                                                      onChanged: onTap == null
                                                          ? null
                                                          : (_) => onTap(value),
                                                      visualDensity: VisualDensity
                                                          .compact))
                                              : IconButton(
                                                  style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      disabledBackgroundColor:
                                                          Colors.transparent,
                                                      side: BorderSide.none),
                                                  tooltip:
                                                      'Edit ${value.effectiveLabel}',
                                                  onPressed: onTap == null
                                                      ? null
                                                      : () => onTap(value),
                                                  icon: const Icon(Icons.edit_outlined,
                                                      size: 16),
                                                  color: palette.textMuted,
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints.tightFor(
                                                          width: 36,
                                                          height: 36))),
                                      Expanded(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(value.effectiveLabel,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    Text(
                                                        value.effectiveSortName,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: palette
                                                                .textMuted)),
                                                  ]))),
                                      SizedBox(
                                          width: 84,
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5),
                                              child: Text(
                                                  '${widget.usageCounts[value.id] ?? 0}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)))),
                                      if (!selecting)
                                        SizedBox(
                                            width: 36,
                                            child: IconButton(
                                                style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    disabledBackgroundColor:
                                                        Colors.transparent,
                                                    side: BorderSide.none),
                                                tooltip:
                                                    'Remove ${value.effectiveLabel}',
                                                onPressed: widget.enabled &&
                                                        widget.onDelete != null
                                                    ? () =>
                                                        widget.onDelete!(value)
                                                    : null,
                                                icon: const Icon(Icons.close,
                                                    size: 18),
                                                color: palette.textMuted,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints
                                                    .tightFor(
                                                    width: 36, height: 36)))
                                    ])))));
                  })),
    ]);
  }
}

/// Paint the reference grid without changing cell widths or hit targets.
class _PickListGrid extends CustomPainter {
  const _PickListGrid(this.color, this.selecting);
  final Color color;
  final bool selecting;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final countEnd = size.width - (selecting ? 0 : 36);
    for (final x in [36.0, countEnd - 84, if (!selecting) countEnd]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    canvas.drawLine(Offset(0, size.height - .5),
        Offset(size.width, size.height - .5), paint);
  }

  @override
  bool shouldRepaint(_PickListGrid oldDelegate) =>
      oldDelegate.color != color || oldDelegate.selecting != selecting;
}
