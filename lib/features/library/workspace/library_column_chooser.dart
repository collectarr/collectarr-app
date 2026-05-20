import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class LibraryColumnChooserDialog extends StatefulWidget {
  const LibraryColumnChooserDialog({
    required this.selectedColumns,
    required this.defaultColumns,
    required this.columnLabel,
    this.columnDescription,
    this.columnGroup,
    this.groupLabel,
    this.presets = const [],
    this.savedPresets = const [],
    this.onSavePreset,
    this.onDeletePreset,
    super.key,
  });

  final Set<LibraryTableColumn> selectedColumns;
  final Set<LibraryTableColumn> defaultColumns;
  final String Function(LibraryTableColumn column) columnLabel;
  final String? Function(LibraryTableColumn column)? columnDescription;
  final LibraryTableColumnGroup Function(LibraryTableColumn column)?
      columnGroup;
  final String Function(LibraryTableColumnGroup group)? groupLabel;
  final List<LibraryTableColumnPreset> presets;
  final List<LibraryTableColumnPreset> savedPresets;
  final Future<List<LibraryTableColumnPreset>> Function(
    String label,
    Set<LibraryTableColumn> columns,
  )? onSavePreset;
  final Future<List<LibraryTableColumnPreset>> Function(String id)?
      onDeletePreset;

  @override
  State<LibraryColumnChooserDialog> createState() =>
      _LibraryColumnChooserDialogState();
}

class _LibraryColumnChooserDialogState
    extends State<LibraryColumnChooserDialog> {
  late var _selected = Set<LibraryTableColumn>.of(widget.selectedColumns);
  late var _savedPresets = List<LibraryTableColumnPreset>.of(
    widget.savedPresets,
  );
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = _query.trim().toLowerCase();
    final columns = LibraryTableColumn.values.where((column) {
      final label = widget.columnLabel(column).toLowerCase();
      final description =
          widget.columnDescription?.call(column)?.toLowerCase() ?? '';
      final group = widget.columnGroup?.call(column);
      final groupLabel = group == null ? '' : _groupLabel(group).toLowerCase();
      return label.contains(query) ||
          description.contains(query) ||
          groupLabel.contains(query);
    }).toList(growable: false);
    final selectedColumns = _orderedVisibleColumns(_selected);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search columns...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  if (widget.presets.isNotEmpty ||
                      _savedPresets.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final preset in widget.presets)
                          OutlinedButton(
                            onPressed: () => _applyPreset(preset),
                            child: Text(preset.label),
                          ),
                        for (final preset in _savedPresets)
                          InputChip(
                            avatar: const Icon(Icons.bookmark, size: 16),
                            label: Text(preset.label),
                            onPressed: () => _applyPreset(preset),
                            onDeleted: preset.id == null ||
                                    widget.onDeletePreset == null
                                ? null
                                : () => _deletePreset(preset.id!),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (widget.presets.isNotEmpty)
              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        border: Border(
                          right: BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 0, 8, 12),
                        children: _availableColumnTiles(columns),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                          child: Text(
                            'Visible columns',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                            itemCount: selectedColumns.length,
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: colorScheme.primaryContainer,
                                elevation: 4,
                                borderRadius: BorderRadius.circular(3),
                                child: child,
                              );
                            },
                            onReorderItem: (oldIndex, newIndex) {
                              setState(() {
                                final reordered =
                                    selectedColumns.toList(growable: true);
                                final column = reordered.removeAt(oldIndex);
                                reordered.insert(newIndex, column);
                                _selected = {
                                  for (final column in reordered) column,
                                };
                              });
                            },
                            itemBuilder: (context, index) {
                              final column = selectedColumns[index];
                              return _SelectedColumnTile(
                                key: ValueKey(column),
                                title: widget.columnLabel(column),
                                subtitle: _groupLabel(
                                    widget.columnGroup?.call(column)),
                                removable: column != LibraryTableColumn.title,
                                onRemove: () => setState(
                                  () => _selected.remove(column),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: widget.onSavePreset == null ? null : _savePreset,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('Save preset'),
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

  void _applyPreset(LibraryTableColumnPreset preset) {
    setState(
      () => _selected = {
        ...preset.columns,
        LibraryTableColumn.title,
      },
    );
  }

  Future<void> _savePreset() async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save preset'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Preset name'),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    final normalized = label?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }
    final updated = await widget.onSavePreset?.call(normalized, _selected);
    if (!mounted || updated == null) {
      return;
    }
    setState(() => _savedPresets = updated);
  }

  Future<void> _deletePreset(String id) async {
    final updated = await widget.onDeletePreset?.call(id);
    if (!mounted || updated == null) {
      return;
    }
    setState(() => _savedPresets = updated);
  }

  List<Widget> _availableColumnTiles(List<LibraryTableColumn> columns) {
    if (widget.columnGroup == null) {
      return [
        for (final column in columns) _columnCheckbox(column),
      ];
    }
    final grouped = <LibraryTableColumnGroup, List<LibraryTableColumn>>{};
    for (final column in columns) {
      final group = widget.columnGroup!(column);
      grouped.putIfAbsent(group, () => []).add(column);
    }
    return [
      for (final group in LibraryTableColumnGroup.values)
        if ((grouped[group] ?? const []).isNotEmpty)
          _ColumnGroupPanel(
            title: _groupLabel(group),
            initiallyExpanded:
                group == LibraryTableColumnGroup.main || _query.isNotEmpty,
            children: [
              for (final column in grouped[group]!) _columnCheckbox(column),
            ],
          ),
    ];
  }

  Widget _columnCheckbox(LibraryTableColumn column) {
    return CheckboxListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
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
      subtitle: _columnDescription(column),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget? _columnDescription(LibraryTableColumn column) {
    final description = widget.columnDescription?.call(column)?.trim();
    if (description == null || description.isEmpty) {
      return null;
    }
    return Text(description);
  }

  String _groupLabel(LibraryTableColumnGroup? group) {
    if (group == null) {
      return '';
    }
    return widget.groupLabel?.call(group) ??
        switch (group) {
          LibraryTableColumnGroup.main => 'Main',
          LibraryTableColumnGroup.edition => 'Edition',
          LibraryTableColumnGroup.value => 'Value',
          LibraryTableColumnGroup.personal => 'Personal',
        };
  }
}

class _ColumnGroupPanel extends StatelessWidget {
  const _ColumnGroupPanel({
    required this.title,
    required this.children,
    required this.initiallyExpanded,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(3),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _SelectedColumnTile extends StatelessWidget {
  const _SelectedColumnTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.removable,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final bool removable;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: const Icon(Icons.drag_indicator),
        title: Text(title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: removable
            ? IconButton(
                tooltip: 'Hide column',
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              )
            : null,
      ),
    );
  }
}
