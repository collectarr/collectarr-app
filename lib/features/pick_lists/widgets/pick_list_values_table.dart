import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
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
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: values.length,
      onReorderItem: (oldIndex, newIndex) {
        final ids = [...values.map((value) => value.id)];
        final moved = ids.removeAt(oldIndex);
        ids.insert(newIndex, moved);
        onReorder(ids);
      },
      itemBuilder: (context, index) {
        final value = values[index];
        final count = usageCounts[value.id] ?? 0;
        return Material(
          key: ValueKey(value.id),
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_indicator, size: 18),
            ),
            title: Text(value.effectiveLabel),
            subtitle: Text(
              [
                if (value.isGlobal) 'Global' else value.mediaKind ?? 'Kind',
                'Used $count',
              ].join(' · '),
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit',
                  onPressed: () => onEdit(value),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Delete',
                  onPressed: () => onDelete(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
