import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';

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
      required this.onChanged,
      this.rowTrailingBuilder,
      this.pickValue});
  final Widget Function(LibraryNamedValue value)? rowTrailingBuilder;

  /// When supplied, names are selected from a list rather than typed inline.
  final Future<String?> Function()? pickValue;
  final String label;
  final List<LibraryNamedValue> values;
  final ValueChanged<List<LibraryNamedValue>> onChanged;
  @override
  State<LibraryOrderedNamesField> createState() =>
      _LibraryOrderedNamesFieldState();
}

class _LibraryOrderedNamesFieldState extends State<LibraryOrderedNamesField> {
  bool _picking = false;

  Future<void> _add() async {
    if (_picking) return;
    final picker = widget.pickValue;
    if (picker == null) {
      widget.onChanged([
        ...widget.values,
        LibraryNamedValue(id: const Uuid().v4(), name: '')
      ]);
      return;
    }
    setState(() => _picking = true);
    try {
      final name = await picker();
      if (!mounted || name == null || name.trim().isEmpty) return;
      if (widget.values.any((value) =>
          normalizePickListValue(value.name) == normalizePickListValue(name))) {
        return;
      }
      widget.onChanged([
        ...widget.values,
        LibraryNamedValue(id: const Uuid().v4(), name: name.trim())
      ]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
            content: Text('Could not open saved choices. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Widget _pickedRow(LibraryNamedValue value, int index) {
    final palette = appPalette(context);
    final name = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Text(value.name,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, height: 20 / 14)),
    );
    return Container(
      key: ValueKey(value.id),
      constraints: const BoxConstraints(minHeight: kLibraryFormControlHeight),
      decoration: BoxDecoration(
        color: palette.field,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.vertical(
            top: index == 0 ? const Radius.circular(4) : Radius.zero,
            bottom: index == widget.values.length - 1
                ? const Radius.circular(4)
                : Radius.zero),
      ),
      child: Row(children: [
        Expanded(
            child: MouseRegion(
          cursor: widget.values.length > 1
              ? SystemMouseCursors.grab
              : SystemMouseCursors.basic,
          child: widget.values.length > 1
              ? ReorderableDragStartListener(
                  index: index,
                  child: SizedBox(
                      height: kLibraryFormControlHeight,
                      child:
                          Align(alignment: Alignment.centerLeft, child: name)))
              : SizedBox(
                  height: kLibraryFormControlHeight,
                  child: Align(alignment: Alignment.centerLeft, child: name)),
        )),
        SizedBox(
            width: 30,
            height: kLibraryFormControlHeight,
            child: IconButton(
                tooltip: 'Remove ${widget.label}',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, size: 17),
                onPressed: () => _remove(value.id))),
        if (widget.rowTrailingBuilder != null)
          widget.rowTrailingBuilder!(value),
      ]),
    );
  }

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
              onPressed: _picking ? null : _add,
              icon: const Icon(Icons.add, size: 18),
            )),
        child: widget.values.isEmpty
            ? SizedBox(
                height: kLibraryFormControlHeight,
                child: OutlinedButton(
                    onPressed: _picking ? null : _add,
                    style: widget.pickValue == null
                        ? null
                        : OutlinedButton.styleFrom(
                            backgroundColor: appPalette(context).field,
                            side:
                                BorderSide(color: appPalette(context).divider),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                    child: const SizedBox.expand()))
            : ReorderableListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: widget.values.length,
                proxyDecorator: widget.pickValue == null
                    ? null
                    : (child, index, animation) => AnimatedBuilder(
                        animation: animation,
                        child: child,
                        builder: (context, child) => Transform.rotate(
                            angle: animation.value * 0.0174533,
                            child: Transform.scale(
                                scale: 1 + animation.value * 0.025,
                                child: Material(elevation: 2, child: child)))),
                onReorderItem: (oldIndex, newIndex) {
                  final values = [...widget.values];
                  values.insert(newIndex, values.removeAt(oldIndex));
                  widget.onChanged(values);
                },
                itemBuilder: (context, index) {
                  final value = widget.values[index];
                  if (widget.pickValue != null) return _pickedRow(value, index);
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
                        if (widget.rowTrailingBuilder != null) ...[
                          const SizedBox(width: 8),
                          widget.rowTrailingBuilder!(value),
                        ],
                        IconButton(
                            tooltip: 'Sort name',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.sort_by_alpha, size: 17),
                            onPressed: () async {
                              final controller = TextEditingController(
                                  text: value.sortName ?? value.name);
                              String? result;
                              try {
                                result = await showDialog<String>(
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
                                                    ctx,
                                                    controller.text.trim()),
                                                child: const Text('Save'))
                                          ],
                                        ));
                              } finally {
                                controller.dispose();
                              }
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
