import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryColumnChooserDialog extends StatefulWidget {
  const LibraryColumnChooserDialog({
    required this.availableColumns,
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

  final List<LibraryTableColumn> availableColumns;
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
    final columns = widget.availableColumns.where((column) {
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
            borderRadius: BorderRadius.zero,
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
              AccentDialogHeader(
                title: 'Select Column Fields',
                accent: accent,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compactHeight = constraints.maxHeight < 520;
                    final favoritesHeight = compactHeight ? 148.0 : 210.0;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        children: [
                          if (_allPresets.isNotEmpty ||
                              widget.onSavePreset != null)
                            SizedBox(
                              height: favoritesHeight,
                              child: _PresetShelf(
                                accent: accent,
                                presets: _allPresets,
                                activePreset: _activePreset,
                                pinnedFavoriteKeys: widget.pinnedFavoriteKeys,
                                columnLabel: widget.columnLabel,
                                nameController: _presetNameController,
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
                                onSave: widget.onSavePreset == null
                                    ? null
                                    : _savePreset,
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
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 12, 12, 8),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              isDense: true,
                                              prefixIcon:
                                                  const Icon(Icons.search),
                                              suffixIcon: _query.isEmpty
                                                  ? null
                                                  : _InlineClearButton(
                                                      onPressed: () => setState(
                                                          () => _query = ''),
                                                    ),
                                              hintText: 'Search fields',
                                              filled: true,
                                              fillColor: palette.field,
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4)),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
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
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 0, 12, 12),
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
                                    count: selectedColumns.length,
                                    accent: accent,
                                    expandChild: true,
                                    child: ReorderableListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 12),
                                      itemCount: selectedColumns.length,
                                      proxyDecorator:
                                          (child, index, animation) {
                                        return Material(
                                          color: Color.alphaBlend(
                                            accent.withValues(alpha: 0.18),
                                            palette.panel,
                                          ),
                                          elevation: 6,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: child,
                                        );
                                      },
                                      onReorderItem: (oldIndex, newIndex) {
                                        setState(() {
                                          final reordered = selectedColumns
                                              .toList(growable: true);
                                          final column =
                                              reordered.removeAt(oldIndex);
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
                                          removable: column !=
                                              LibraryTableColumn.title,
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
                          _presetNameController.text =
                              _activePreset?.label ?? '';
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
                      label: 'Save',
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
    final normalized = _presetNameController.text.trim();
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
            selectedCount: grouped[group]!.where(_selected.contains).length,
            onToggleAll: () => _toggleGroupColumns(grouped[group]!),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 16,
                color: locked
                    ? palette.textMuted
                    : selected
                        ? (widget.accent ??
                            Theme.of(context).colorScheme.primary)
                        : palette.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.columnLabel(column),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: locked
                            ? palette.textMuted
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleGroupColumns(List<LibraryTableColumn> columns) {
    final allSelected = columns.every(
      (column) =>
          column == LibraryTableColumn.title || _selected.contains(column),
    );
    setState(() {
      for (final column in columns) {
        if (column == LibraryTableColumn.title) {
          _selected.add(column);
          continue;
        }
        if (allSelected) {
          _selected.remove(column);
        } else {
          _selected.add(column);
        }
      }
    });
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
    required this.removable,
    required this.onRemove,
  });

  final String title;
  final bool removable;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 16, color: palette.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            removable
                ? InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child:
                          Icon(Icons.close, size: 14, color: palette.textMuted),
                    ),
                  )
                : Tooltip(
                    message: 'Title is always visible',
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.lock_outline,
                          size: 14, color: palette.textMuted),
                    ),
                  ),
          ],
        ),
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
    required this.nameController,
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
  final TextEditingController nameController;
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
        (preset) =>
            pinnedFavoriteKeys.contains(libraryColumnFavoriteKey(preset)),
      ),
      ...presets.where(
        (preset) =>
            !pinnedFavoriteKeys.contains(libraryColumnFavoriteKey(preset)),
      ),
    ];
    return _PaneFrame(
      title: 'Column Favorites',
      accent: accent,
      expandChild: true,
      trailing: onSave == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Preset name',
                      isDense: true,
                      filled: true,
                      fillColor: palette.field,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                LibraryDenseButton(
                  label: 'Save',
                  icon: Icons.save_outlined,
                  onPressed: onSave,
                  tone: LibraryDenseButtonTone.accent,
                ),
              ],
            ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        itemCount: orderedPresets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final preset = orderedPresets[index];
          final active = identical(activePreset, preset) ||
              (activePreset?.label == preset.label);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('column-preset-${preset.label}'),
              borderRadius: BorderRadius.circular(4),
              onTap: () => onApply(preset),
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
                decoration: BoxDecoration(
                  color: active
                      ? Color.alphaBlend(
                          accent.withValues(alpha: 0.10),
                          palette.surfaceSubtle,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: active
                        ? accent.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      active ? Icons.check : Icons.drag_indicator,
                      size: 16,
                      color: active ? accent : palette.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            preset.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: active
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              [
                                for (final column in preset.columns)
                                  columnLabel(column),
                              ].join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: palette.textMuted,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    LibraryDenseIconButton(
                      tooltip: 'Edit',
                      onPressed: () => onEdit(preset),
                      icon: Icons.edit_outlined,
                      tone: LibraryDenseButtonTone.subtle,
                    ),
                    if (preset.isSaved && onDelete != null)
                      LibraryDenseIconButton(
                        tooltip: 'Delete',
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

class _PaneFrame extends StatelessWidget {
  const _PaneFrame({
    required this.title,
    required this.child,
    required this.accent,
    this.count,
    this.expandChild = false,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Color accent;
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
              color: Color.alphaBlend(
                  accent.withValues(alpha: 0.08), palette.surface),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
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
                    ],
                  ),
                ),
                if (count != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    required this.selectedCount,
    required this.onToggleAll,
  });

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Color accent;
  final int count;
  final int selectedCount;
  final VoidCallback onToggleAll;

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      LibraryDenseButton(
                        label: widget.selectedCount == widget.count
                            ? 'Clear'
                            : 'All',
                        onPressed: widget.onToggleAll,
                        tone: LibraryDenseButtonTone.subtle,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.selectedCount}/${widget.count}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
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

class _InlineClearButton extends StatelessWidget {
  const _InlineClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(Icons.close, size: 14, color: palette.textMuted),
          ),
        ),
      ),
    );
  }
}
