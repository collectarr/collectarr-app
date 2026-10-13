import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_value_chip.dart';
import 'package:collectarr_app/features/pick_lists/widgets/multi_pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact managed tags for a secondary value inside an ordered list row.
class LibraryPickListTags extends ConsumerStatefulWidget {
  const LibraryPickListTags(
      {super.key,
      required this.label,
      required this.listName,
      required this.mediaKind,
      required this.values,
      required this.onChanged,
      this.loadOptions});
  final String label;
  final String listName;
  final String mediaKind;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final Future<List<String>> Function(LocalDatabase db)? loadOptions;
  @override
  ConsumerState<LibraryPickListTags> createState() =>
      _LibraryPickListTagsState();
}

class _LibraryPickListTagsState extends ConsumerState<LibraryPickListTags> {
  bool _picking = false;
  Future<void> _add() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final db = ref.read(localDatabaseProvider);
      final options = await widget.loadOptions?.call(db) ?? const <String>[];
      if (!mounted) return;
      final selected = await showMultiPickListSelectDialog(
          context: context,
          label: widget.label,
          listName: widget.listName,
          mediaKind: widget.mediaKind,
          options: [...options, ...widget.values],
          selectedValues: widget.values.toSet(),
          allowUserValues: true,
          db: db);
      if (!mounted || selected == null) return;
      widget.onChanged([
        ...{
          for (final value in widget.values)
            if (selected.contains(value)) value,
          ...selected
        },
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

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: LayoutBuilder(
                    builder: (context, constraints) =>
                        Wrap(spacing: 3, runSpacing: 3, children: [
                          for (final value in widget.values)
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth),
                                child: LibraryValueChip(
                                    label: value,
                                    onDeleted: () => widget.onChanged([
                                          for (final selected in widget.values)
                                            if (selected != value) selected
                                        ])))
                        ])))),
        SizedBox(
            width: 30,
            height: 34,
            child: IconButton(
                tooltip: 'Select ${widget.label}',
                padding: EdgeInsets.zero,
                onPressed: _picking ? null : _add,
                icon: const Icon(Icons.add, size: 17))),
      ]);
}
