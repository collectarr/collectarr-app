import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final class LibraryNamedValue {
  const LibraryNamedValue(
      {required this.id, required this.name, this.sortName});
  final String id;
  final String name;
  final String? sortName;
}

/// Reusable compact, ordered name/sort-name list for artists and credits.
class LibraryOrderedNamesField extends StatefulWidget {
  const LibraryOrderedNamesField(
      {super.key,
      required this.label,
      required this.values,
      required this.onChanged});
  final String label;
  final List<LibraryNamedValue> values;
  final ValueChanged<List<LibraryNamedValue>> onChanged;
  @override
  State<LibraryOrderedNamesField> createState() =>
      _LibraryOrderedNamesFieldState();
}

class _LibraryOrderedNamesFieldState extends State<LibraryOrderedNamesField> {
  void _add() => widget.onChanged(
      [...widget.values, LibraryNamedValue(id: const Uuid().v4(), name: '')]);
  void _remove(String id) => widget.onChanged([
        for (final value in widget.values)
          if (value.id != id) value
      ]);
  void _update(String id, String name, String? sortName) => widget.onChanged([
        for (final value in widget.values)
          value.id == id
              ? LibraryNamedValue(id: id, name: name, sortName: sortName)
              : value,
      ]);

  @override
  Widget build(BuildContext context) => LibraryFormField(
        label: widget.label,
        action: SizedBox(
            width: 24,
            height: 20,
            child: IconButton(
              tooltip: 'Add ${widget.label}',
              padding: EdgeInsets.zero,
              onPressed: _add,
              icon: const Icon(Icons.add, size: 18),
            )),
        child: widget.values.isEmpty
            ? SizedBox(
                height: 34,
                child: OutlinedButton(
                    onPressed: _add, child: const SizedBox.expand()))
            : ReorderableListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: widget.values.length,
                onReorderItem: (oldIndex, newIndex) {
                  final values = [...widget.values];
                  values.insert(newIndex, values.removeAt(oldIndex));
                  widget.onChanged(values);
                },
                itemBuilder: (context, index) {
                  final value = widget.values[index];
                  return Padding(
                      key: ValueKey(value.id),
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_indicator, size: 16)),
                        Expanded(
                            child: LibraryTextFormControl(
                          key: ValueKey('name-${value.id}'),
                          initialValue: value.name,
                          validator: (name) => name?.trim().isEmpty == true
                              ? 'Enter a name or remove this row'
                              : null,
                          onChanged: (name) =>
                              _update(value.id, name, value.sortName),
                        )),
                        IconButton(
                            tooltip: 'Sort name',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.sort_by_alpha, size: 17),
                            onPressed: () async {
                              final controller = TextEditingController(
                                  text: value.sortName ?? value.name);
                              final result = await showDialog<String>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: const Text('Sort Name'),
                                        content: LibraryTextFormControl(
                                            controller: controller,
                                            autofocus: true),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Cancel')),
                                          FilledButton(
                                              onPressed: () => Navigator.pop(
                                                  ctx, controller.text.trim()),
                                              child: const Text('Save'))
                                        ],
                                      ));
                              controller.dispose();
                              if (result != null && mounted) {
                                _update(value.id, value.name, result);
                              }
                            }),
                        IconButton(
                            tooltip: 'Remove ${widget.label}',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.close, size: 17),
                            onPressed: () => _remove(value.id)),
                      ]));
                },
              ),
      );
}
