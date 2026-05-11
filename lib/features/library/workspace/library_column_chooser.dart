import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class LibraryColumnChooserDialog extends StatefulWidget {
  const LibraryColumnChooserDialog({
    required this.selectedColumns,
    required this.defaultColumns,
    required this.columnLabel,
    super.key,
  });

  final Set<LibraryTableColumn> selectedColumns;
  final Set<LibraryTableColumn> defaultColumns;
  final String Function(LibraryTableColumn column) columnLabel;

  @override
  State<LibraryColumnChooserDialog> createState() =>
      _LibraryColumnChooserDialogState();
}

class _LibraryColumnChooserDialogState
    extends State<LibraryColumnChooserDialog> {
  late var _selected = Set<LibraryTableColumn>.of(widget.selectedColumns);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = LibraryTableColumn.values
        .where(
          (column) => widget
              .columnLabel(column)
              .toLowerCase()
              .contains(_query.trim().toLowerCase()),
        )
        .toList(growable: false);
    final selectedColumns = _orderedVisibleColumns(_selected);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select columns',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search columns...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 12),
                      children: [
                        for (final column in columns)
                          CheckboxListTile(
                            dense: true,
                            value: _selected.contains(column),
                            onChanged: column == LibraryTableColumn.title
                                ? null
                                : (value) => setState(() {
                                      if (value ?? false) {
                                        _selected.add(column);
                                      } else {
                                        _selected.remove(column);
                                      }
                                    }),
                            title: Text(widget.columnLabel(column)),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                      ],
                    ),
                  ),
                  VerticalDivider(color: colorScheme.outlineVariant),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                      itemCount: selectedColumns.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final reordered =
                              selectedColumns.toList(growable: true);
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final column = reordered.removeAt(oldIndex);
                          reordered.insert(newIndex, column);
                          _selected = {
                            for (final column in reordered) column,
                          };
                        });
                      },
                      itemBuilder: (context, index) {
                        final column = selectedColumns[index];
                        return ListTile(
                          key: ValueKey(column),
                          dense: true,
                          leading: const Icon(Icons.drag_indicator),
                          title: Text(widget.columnLabel(column)),
                          trailing: column == LibraryTableColumn.title
                              ? null
                              : IconButton(
                                  tooltip: 'Hide column',
                                  onPressed: () => setState(
                                    () => _selected.remove(column),
                                  ),
                                  icon: const Icon(Icons.close),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(
                      () => _selected = Set.of(widget.defaultColumns),
                    ),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final result = Set<LibraryTableColumn>.of(_selected)
                        ..add(LibraryTableColumn.title);
                      Navigator.of(context).pop(result);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LibraryTableColumn> _orderedVisibleColumns(
    Set<LibraryTableColumn> columns,
  ) {
    final effective = columns.isEmpty ? widget.defaultColumns : columns;
    return [
      for (final column in effective) column,
    ];
  }
}
