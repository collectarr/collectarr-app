import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PickListValuesTable extends StatelessWidget {
  const PickListValuesTable({
    super.key,
    required this.values,
    required this.usageCounts,
    required this.onReorder,
    required this.onEdit,
    required this.onDelete,
  });

  final List<PickListValue> values;
  final Map<String, int> usageCounts;
  final ValueChanged<List<String>> onReorder;
  final ValueChanged<PickListValue> onEdit;
  final ValueChanged<PickListValue> onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      children: [
        _buildHeader(context, palette),
        Expanded(
          child: values.isEmpty
              ? const Center(child: Text('No Result'))
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: values.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = [...values.map((value) => value.id)];
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    onReorder(ids);
                  },
                  itemBuilder: (context, index) => _buildValueRow(
                    context,
                    palette,
                    values[index],
                    index,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppThemePalette palette) {
    final border = BorderSide(color: palette.divider);
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          _headerCell(
            width: 38,
            border: border,
            child: const SizedBox.shrink(),
          ),
          Expanded(
            child: _headerCell(
              border: border,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text('Name', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: palette.textMuted,
                  ),
                ],
              ),
            ),
          ),
          _headerCell(
            width: 76,
            border: border,
            alignment: Alignment.centerRight,
            child: Text('Count', style: Theme.of(context).textTheme.labelLarge),
          ),
          _headerCell(
              width: 44, border: border, child: const SizedBox.shrink()),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _headerCell({
    double? width,
    required BorderSide border,
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border(right: border)),
      alignment: alignment,
      child: child,
    );
  }

  Widget _buildValueRow(
    BuildContext context,
    AppThemePalette palette,
    PickListValue value,
    int index,
  ) {
    final count = usageCounts[value.id] ?? 0;
    final border = BorderSide(color: palette.divider);
    return Material(
      key: ValueKey(value.id),
      color: index.isEven ? palette.tableEvenRow : palette.tableOddRow,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(border: Border(bottom: border)),
        child: Row(
          children: [
            Container(
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border(right: border)),
              child: ReorderableDragStartListener(
                index: index,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: palette.textMuted,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(border: Border(right: border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value.effectiveLabel),
                    const SizedBox(height: 2),
                    Text(
                      value.isGlobal ? 'Global' : value.mediaKind ?? 'Kind',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 76,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(border: Border(right: border)),
              child: Text('$count'),
            ),
            Container(
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border(right: border)),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
                onPressed: () => onEdit(value),
              ),
            ),
            SizedBox(
              width: 44,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
                onPressed: () => onDelete(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
