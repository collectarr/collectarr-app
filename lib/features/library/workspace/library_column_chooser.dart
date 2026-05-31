import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_dense_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryColumnChooserDialog extends StatefulWidget {
  const LibraryColumnChooserDialog({
    required this.selectedColumns,
    required this.defaultColumns,
    required this.columnLabel,
    this.accent,
    this.columnDescription,
    this.columnGroup,
    this.groupLabel,
    this.presets = const [],
    this.savedPresets = const [],
    this.pinnedFavoriteKeys = const {},
    this.onTogglePinnedFavorite,
    this.onSavePreset,
    this.onDeletePreset,
    super.key,
  });

  final Set<LibraryTableColumn> selectedColumns;
  final Set<LibraryTableColumn> defaultColumns;
  final String Function(LibraryTableColumn column) columnLabel;
  final Color? accent;
  final String? Function(LibraryTableColumn column)? columnDescription;
  final LibraryTableColumnGroup Function(LibraryTableColumn column)?
      columnGroup;
  final String Function(LibraryTableColumnGroup group)? groupLabel;
  final List<LibraryTableColumnPreset> presets;
  final List<LibraryTableColumnPreset> savedPresets;
  final Set<String> pinnedFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedFavorite;
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
  late final TextEditingController _presetNameController =
      TextEditingController(text: _activePreset?.label ?? '');
  String _query = '';

  LibraryTableColumnPreset? get _activePreset {
    final selected = {..._selected, LibraryTableColumn.title};
    for (final preset in _allPresets) {
      if (_sameColumnSet(preset.columns, selected)) {
        return preset;
      }
    }
    return null;
  }

  List<LibraryTableColumnPreset> get _allPresets {
    final merged = <LibraryTableColumnPreset>[];
    final seen = <String>{};
    for (final preset in [...widget.presets, ..._savedPresets]) {
      final normalized = preset.label.trim().toLowerCase();
      if (normalized.isEmpty || !seen.add(normalized)) {
        continue;
      }
      merged.add(preset);
    }
    return merged;
  }

  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    final accent = widget.accent ?? colorScheme.primary;
    final viewport = MediaQuery.sizeOf(context);
    final dialogWidth = (viewport.width - 48).clamp(0.0, 1020.0);
    final dialogHeight = (viewport.height - 36).clamp(0.0, 820.0);
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.divider),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _DialogHeader(accent: accent),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compactHeight = constraints.maxHeight < 520;
                    final favoritesHeight = compactHeight ? 124.0 : 190.0;
                    final editorHeight = compactHeight ? 124.0 : 106.0;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        children: [
                          if (_allPresets.isNotEmpty || widget.onSavePreset != null)
                            SizedBox(
                              height: favoritesHeight,
                              child: _PresetShelf(
                                accent: accent,
                                presets: _allPresets,
                                activePreset: _activePreset,
                                pinnedFavoriteKeys: widget.pinnedFavoriteKeys,
                                columnLabel: widget.columnLabel,
                                onApply: _applyPreset,
                                onEdit: (preset) {
                                  _presetNameController.text = preset.label;
                                  _applyPreset(preset);
                                },
                                onTogglePin: widget.onTogglePinnedFavorite,
                                onDelete: widget.onDeletePreset == null
                                    ? null
                                    : (preset) {
                                        if (preset.id != null) {
                                          _deletePreset(preset.id!);
                                        }
                                      },
                                onSave:
                                    widget.onSavePreset == null ? null : _savePreset,
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: editorHeight,
                            child: _PresetEditor(
                              controller: _presetNameController,
                              accent: accent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _PaneFrame(
                                    title: 'Available fields',
                                    count: columns.length,
                                    accent: accent,
                                    expandChild: true,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              isDense: true,
                                              prefixIcon: const Icon(Icons.search),
                                              hintText: 'Search fields',
                                              filled: true,
                                              fillColor: palette.field,
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 10,
                                              ),
                                            ),
                                            onChanged: (value) =>
                                                setState(() => _query = value),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView(
                                            padding:
                                                const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                            children: _availableColumnTiles(
                                              columns,
                                              accent: accent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 4,
                                  child: _PaneFrame(
                                    title: 'Selected columns',
                                    subtitle: 'Drag to reorder',
                                    count: selectedColumns.length,
                                    accent: accent,
                                    expandChild: true,
                                    child: ReorderableListView.builder(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                      itemCount: selectedColumns.length,
                                      proxyDecorator: (child, index, animation) {
                                        return Material(
                                          color: Color.alphaBlend(
                                            accent.withValues(alpha: 0.18),
                                            palette.panel,
                                          ),
                                          elevation: 6,
                                          borderRadius: BorderRadius.circular(6),
                                          child: child,
                                        );
                                      },
                                      onReorderItem: (oldIndex, newIndex) {
                                        setState(() {
                                          final reordered =
                                              selectedColumns.toList(growable: true);
                                          final column = reordered.removeAt(oldIndex);
                                          if (oldIndex < newIndex) {
                                            newIndex -= 1;
                                          }
                                          reordered.insert(newIndex, column);
                                          _selected = {
                                            for (final item in reordered) item,
                                          };
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final column = selectedColumns[index];
                                        return _SelectedColumnTile(
                                          key: ValueKey(
                                            'selected-column-${column.name}',
                                          ),
                                          title: widget.columnLabel(column),
                                          subtitle: _groupLabel(
                                            widget.columnGroup?.call(column),
                                          ),
                                          removable:
                                              column != LibraryTableColumn.title,
                                          onRemove: () => setState(
                                            () => _selected.remove(column),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    LibraryDenseButton(
                      onPressed: () {
                        setState(() {
                          _selected = Set.of(widget.defaultColumns);
                          _presetNameController.text = _activePreset?.label ?? '';
                        });
                      },
                      label: 'Reset',
                      icon: Icons.restart_alt,
                      tone: LibraryDenseButtonTone.subtle,
                    ),
                    const Spacer(),
                    LibraryDenseButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: 'Cancel',
                      tone: LibraryDenseButtonTone.subtle,
                    ),
                    const SizedBox(width: 8),
                    LibraryDenseButton(
                      onPressed: () {
                        final result = Set<LibraryTableColumn>.of(_selected)
                          ..add(LibraryTableColumn.title);
                        Navigator.of(context).pop(result);
                      },
                      label: 'Apply Columns',
                      icon: Icons.check,
                      tone: LibraryDenseButtonTone.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    setState(() {
      _selected = {
        ...preset.columns,
        LibraryTableColumn.title,
      };
      _presetNameController.text = preset.label;
    });
  }

  Future<void> _savePreset() async {
    var normalized = _presetNameController.text.trim();
    if (normalized.isEmpty) {
      final controller = TextEditingController();
      final label = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save favorite'),
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
      normalized = label?.trim() ?? '';
    }
    if (normalized.isEmpty) {
      return;
    }
    final updated = await widget.onSavePreset?.call(normalized, _selected);
    if (!mounted || updated == null) {
      return;
    }
    setState(() {
      _savedPresets = updated;
      _presetNameController.text = normalized;
    });
  }

  Future<void> _deletePreset(String id) async {
    final updated = await widget.onDeletePreset?.call(id);
    if (!mounted || updated == null) {
      return;
    }
    setState(() => _savedPresets = updated);
  }

  List<Widget> _availableColumnTiles(
    List<LibraryTableColumn> columns, {
    required Color accent,
  }) {
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
            accent: accent,
            count: grouped[group]!.length,
            initiallyExpanded:
                group == LibraryTableColumnGroup.main || _query.isNotEmpty,
            children: [
              for (final column in grouped[group]!) _columnCheckbox(column),
            ],
          ),
    ];
  }

  Widget _columnCheckbox(LibraryTableColumn column) {
    final palette = appPalette(context);
    final selected = _selected.contains(column);
    final locked = column == LibraryTableColumn.title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('available-column-${column.name}'),
        onTap: locked
            ? null
            : () => setState(() {
                  if (selected) {
                    _selected.remove(column);
                  } else {
                    _selected.add(column);
                  }
                }),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: locked
                    ? palette.textMuted
                    : selected
                        ? (widget.accent ?? Theme.of(context).colorScheme.primary)
                        : palette.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.columnLabel(column),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: locked
                                ? palette.textMuted
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                    ),
                    if (_columnDescription(column) case final description?) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: palette.textMuted,
                            ),
                        child: description,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  bool _sameColumnSet(
    Set<LibraryTableColumn> first,
    Set<LibraryTableColumn> second,
  ) {
    return first.length == second.length && first.containsAll(second);
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
    final palette = appPalette(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 18, color: palette.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            removable
                ? LibraryDenseIconButton(
                    tooltip: 'Hide column',
                    onPressed: onRemove,
                    icon: Icons.close,
                    tone: LibraryDenseButtonTone.subtle,
                  )
                : Tooltip(
                    message: 'Title is always visible',
                    child: Icon(Icons.lock_outline, size: 18, color: palette.textMuted),
                  ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.12), palette.toolbar),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Text(
            'Select Column Fields',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Spacer(),
          LibraryDenseIconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.close,
            tone: LibraryDenseButtonTone.subtle,
          ),
        ],
      ),
    );
  }
}

class _PresetShelf extends StatelessWidget {
  const _PresetShelf({
    required this.accent,
    required this.presets,
    required this.activePreset,
    required this.pinnedFavoriteKeys,
    required this.columnLabel,
    required this.onApply,
    required this.onEdit,
    required this.onSave,
    this.onTogglePin,
    this.onDelete,
  });

  final Color accent;
  final List<LibraryTableColumnPreset> presets;
  final LibraryTableColumnPreset? activePreset;
  final Set<String> pinnedFavoriteKeys;
  final String Function(LibraryTableColumn column) columnLabel;
  final ValueChanged<LibraryTableColumnPreset> onApply;
  final ValueChanged<LibraryTableColumnPreset> onEdit;
  final VoidCallback? onSave;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePin;
  final ValueChanged<LibraryTableColumnPreset>? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final orderedPresets = [
      ...presets.where(
        (preset) => pinnedFavoriteKeys.contains(libraryColumnFavoriteKey(preset)),
      ),
      ...presets.where(
        (preset) => !pinnedFavoriteKeys.contains(libraryColumnFavoriteKey(preset)),
      ),
    ];
    return _PaneFrame(
      title: 'Column Favorites',
      subtitle: 'Quick layouts and saved combinations',
      accent: accent,
      expandChild: true,
      trailing: onSave == null
          ? null
          : LibraryDenseIconButton(
              tooltip: 'Save current selection as favorite',
              onPressed: onSave,
              icon: Icons.add,
              tone: LibraryDenseButtonTone.accent,
            ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        itemCount: orderedPresets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final preset = orderedPresets[index];
          final active = identical(activePreset, preset) ||
              (activePreset?.label == preset.label);
          final pinned = pinnedFavoriteKeys.contains(libraryColumnFavoriteKey(preset));
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('column-preset-${preset.label}'),
              borderRadius: BorderRadius.circular(6),
              onTap: () => onApply(preset),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: active
                      ? Color.alphaBlend(
                          accent.withValues(alpha: 0.14),
                          palette.surfaceSubtle,
                        )
                      : palette.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: active
                        ? accent.withValues(alpha: 0.7)
                        : palette.divider,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      active ? Icons.check_circle : Icons.bookmark_border,
                      size: 18,
                      color: active ? accent : palette.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.label,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              for (final column in preset.columns)
                                columnLabel(column),
                            ].join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: palette.textMuted,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    LibraryDenseButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      onPressed: () => onEdit(preset),
                      tone: LibraryDenseButtonTone.subtle,
                    ),
                    if (onTogglePin != null) ...[
                      const SizedBox(width: 6),
                      LibraryDenseIconButton(
                        tooltip: pinned ? 'Unpin favorite' : 'Pin favorite',
                        onPressed: () => onTogglePin!(preset),
                        icon: pinned ? Icons.star : Icons.star_border,
                        tone: pinned
                            ? LibraryDenseButtonTone.accent
                            : LibraryDenseButtonTone.subtle,
                      ),
                    ],
                    if (preset.isSaved && onDelete != null)
                      LibraryDenseIconButton(
                        tooltip: 'Delete favorite',
                        onPressed: () => onDelete!(preset),
                        icon: Icons.delete_outline,
                        tone: LibraryDenseButtonTone.subtle,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PresetEditor extends StatelessWidget {
  const _PresetEditor({
    required this.controller,
    required this.accent,
  });

  final TextEditingController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return _PaneFrame(
      title: 'Preset details',
      subtitle: 'Optional favorite name for the current layout',
      accent: accent,
      expandChild: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Align(
          alignment: Alignment.topLeft,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Preset name',
              hintText: 'My List View columns',
              filled: true,
              fillColor: palette.field,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaneFrame extends StatelessWidget {
  const _PaneFrame({
    required this.title,
    required this.child,
    required this.accent,
    this.subtitle,
    this.count,
    this.expandChild = false,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Color accent;
  final String? subtitle;
  final int? count;
  final bool expandChild;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Color.alphaBlend(accent.withValues(alpha: 0.08), palette.surface),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border(bottom: BorderSide(color: palette.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.textMuted,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (count != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.badgeBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

class _ColumnGroupPanel extends StatefulWidget {
  const _ColumnGroupPanel({
    required this.title,
    required this.children,
    required this.initiallyExpanded,
    required this.accent,
    required this.count,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Color accent;
  final int count;

  @override
  State<_ColumnGroupPanel> createState() => _ColumnGroupPanelState();
}

class _ColumnGroupPanelState extends State<_ColumnGroupPanel> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surfaceSubtle,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: palette.divider),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  child: Row(
                    children: [
                      Icon(
                        _expanded ? Icons.expand_more : Icons.chevron_right,
                        size: 16,
                        color: _expanded ? widget.accent : palette.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      Text(
                        '${widget.count}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: palette.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(children: widget.children),
              ),
          ],
        ),
      ),
    );
  }
}
