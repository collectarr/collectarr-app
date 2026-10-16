import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/features/library/generic/library_folder_reorder_list.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.primaryColumn,
    this.onTogglePinnedFavorite,
    this.onSavePreset,
    this.onDeletePreset,
    super.key,
  });

  final List<String> availableColumns;
  final Set<String> selectedColumns;
  final Set<String> defaultColumns;
  final String Function(String column) columnLabel;
  final Color? accent;
  final String? primaryColumn;
  final String? Function(String column)? columnDescription;
  final LibraryTableColumnGroup Function(String column)? columnGroup;
  final String Function(LibraryTableColumnGroup group)? groupLabel;
  final List<LibraryTableColumnPreset> presets;
  final List<LibraryTableColumnPreset> savedPresets;
  final Set<String> pinnedFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedFavorite;
  final Future<List<LibraryTableColumnPreset>> Function(
    String label,
    Set<String> columns,
  )? onSavePreset;
  final Future<List<LibraryTableColumnPreset>> Function(String id)?
      onDeletePreset;

  @override
  State<LibraryColumnChooserDialog> createState() =>
      _LibraryColumnChooserDialogState();
}

class _LibraryColumnChooserDialogState
    extends State<LibraryColumnChooserDialog> {
  late var _selected = Set<String>.of(widget.selectedColumns);
  late var _savedPresets = List<LibraryTableColumnPreset>.of(
    widget.savedPresets,
  );
  late final TextEditingController _presetNameController =
      TextEditingController(
          text: _activePreset?.label ?? 'My List View columns');
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showFavorites = false;
  bool _nameEdited = false;
  final Map<LibraryTableColumnGroup, bool> _expandedGroups = {};

  String? get _effectivePrimaryColumn => widget.primaryColumn;

  LibraryTableColumnPreset? get _activePreset {
    final primary = _effectivePrimaryColumn;
    final selected = {..._selected, if (primary != null) primary};
    for (final preset in _allPresets) {
      if (_sameColumnOrder(preset.columns, selected)) {
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
    _searchController.dispose();
    _presetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kindAccent = widget.accent ?? Theme.of(context).colorScheme.primary;
    final accent = appPalette(context).utilityAction;
    final query = _query.trim().toLowerCase();
    final columns = widget.availableColumns
        .where((column) =>
            widget.columnLabel(column).toLowerCase().contains(query) ||
            (widget.columnDescription
                    ?.call(column)
                    ?.toLowerCase()
                    .contains(query) ??
                false) ||
            _groupLabel(widget.columnGroup?.call(column))
                .toLowerCase()
                .contains(query))
        .toList();
    final selectedColumns = _selected.toList();
    return LibraryFieldSelectionDialog(
        icon: AppIcons.columns,
        title: 'Select Column Fields',
        accent: kindAccent,
        headerAction: IconButton(
            tooltip: 'Manage Favorites',
            icon: const Icon(Icons.settings, color: Colors.white, size: 16),
            onPressed: () => setState(() => _showFavorites = !_showFavorites)),
        onSave: _selected.isEmpty
            ? null
            : () async {
                if (_nameEdited && widget.onSavePreset != null) {
                  await _savePreset();
                }
                if (context.mounted) {
                  Navigator.of(context).pop(Set<String>.of(_selected));
                }
              },
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
              height: 34,
              child: Builder(
                  // The preset name fills the 34 px field at 18/700, as in
                  // the reference.
                  builder: (context) => TextField(
                      controller: _presetNameController,
                      style: librarySelectionFieldStyle.copyWith(fontSize: 18),
                      cursorColor: appPalette(context).utilityAction,
                      onChanged: (_) => _nameEdited = true,
                      // Expanding fills the 34 px box; the name stays one
                      // line.
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'[\r\n]')),
                      ],
                      decoration: pickListInputDecoration(context,
                              hintText: 'My List View columns')
                          .copyWith(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 0))))),
          const SizedBox(height: 15),
          const Text('Columns', style: TextStyle(height: 20 / 14)),
          const SizedBox(height: 5),
          if (_showFavorites &&
              (_allPresets.isNotEmpty || widget.onSavePreset != null))
            SizedBox(
                height: 148,
                child: _PresetShelf(
                    accent: accent,
                    presets: _allPresets,
                    activePreset: _activePreset,
                    pinnedFavoriteKeys: widget.pinnedFavoriteKeys,
                    columnLabel: widget.columnLabel,
                    nameController: _presetNameController,
                    onApply: _applyPreset,
                    onEdit: _applyPreset,
                    onTogglePin: widget.onTogglePinnedFavorite,
                    onDelete: widget.onDeletePreset == null
                        ? null
                        : (preset) {
                            if (preset.id != null) _deletePreset(preset.id!);
                          },
                    onSave: widget.onSavePreset == null ? null : _savePreset)),
          Expanded(
              child: LibraryFieldSelectionPanes(
            available: Column(children: [
              LibraryFieldSelectionSearch(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value)),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView(
                      children:
                          _availableColumnTiles(columns, accent: accent))),
            ]),
            selected: LibraryFolderReorderList(
                padding: const EdgeInsets.all(10),
                rowSpacing: 3,
                placeholderColor: const Color(0xff808080),
                itemCount: selectedColumns.length,
                onReorder: (oldIndex, newIndex) => setState(() {
                      final reordered = selectedColumns.toList();
                      final column = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, column);
                      _selected = reordered.toSet();
                    }),
                itemBuilder: (context, index) {
                  final column = selectedColumns[index];
                  return LibrarySelectedFieldRow(
                      key: ValueKey('selected-column-$column'),
                      handleKey: ValueKey('selected-column-$column-handle'),
                      label: widget.columnLabel(column),
                      removeTooltip: 'Remove column',
                      onRemove: column == _effectivePrimaryColumn
                          ? null
                          : () => setState(() => _selected.remove(column)));
                }),
          )),
        ]));
  }

  void _applyPreset(LibraryTableColumnPreset preset) {
    setState(() {
      _selected = {
        ...preset.columns,
        if (_effectivePrimaryColumn != null) _effectivePrimaryColumn!,
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

  List<Widget> _availableColumnTiles(List<String> columns,
      {required Color accent}) {
    if (widget.columnGroup == null) {
      return [for (final column in columns) _columnCheckbox(column)];
    }
    final grouped = <LibraryTableColumnGroup, List<String>>{};
    for (final column in columns) {
      grouped.putIfAbsent(widget.columnGroup!(column), () => []).add(column);
    }
    for (final groupColumns in grouped.values) {
      groupColumns.sort((a, b) => widget
          .columnLabel(a)
          .toLowerCase()
          .compareTo(widget.columnLabel(b).toLowerCase()));
    }
    final groups = [
      LibraryTableColumnGroup.images,
      ...LibraryTableColumnGroup.values
          .where((group) => group != LibraryTableColumnGroup.images)
    ];
    return [
      for (final group in groups)
        if ((grouped[group] ?? const []).isNotEmpty)
          LibraryFieldSelectionCategory(
              key: ValueKey('column-group-${group.name}'),
              title: _groupLabel(group),
              selected: grouped[group]!.every(_selected.contains),
              expanded: _query.isNotEmpty ||
                  (_expandedGroups[group] ??
                      group == LibraryTableColumnGroup.main ||
                          group == LibraryTableColumnGroup.images),
              onToggle: () => setState(() => _expandedGroups[group] =
                  !(_expandedGroups[group] ??
                      group == LibraryTableColumnGroup.main ||
                          group == LibraryTableColumnGroup.images)),
              onToggleAll: () => _toggleGroupColumns(grouped[group]!),
              children: [
                for (final column in grouped[group]!) _columnCheckbox(column)
              ]),
    ];
  }

  Widget _columnCheckbox(String column) => LibraryFieldSelectionCheckbox(
      key: ValueKey('available-column-$column'),
      label: widget.columnLabel(column),
      selected: _selected.contains(column),
      onTap: column == _effectivePrimaryColumn
          ? null
          : () => setState(() {
                if (!_selected.remove(column)) _selected.add(column);
              }));

  void _toggleGroupColumns(List<String> columns) {
    final primary = _effectivePrimaryColumn;
    final allSelected = columns.every(
      (column) =>
          (primary != null && column == primary) || _selected.contains(column),
    );
    setState(() {
      for (final column in columns) {
        if (primary != null && column == primary) {
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
          LibraryTableColumnGroup.credits => 'Credits',
          LibraryTableColumnGroup.images => 'Images',
          LibraryTableColumnGroup.loan => 'Loan',
        };
  }

  bool _sameColumnOrder(
    Set<Object> first,
    Set<Object> second,
  ) {
    return first.length == second.length &&
        List.generate(
                first.length, (i) => first.elementAt(i) == second.elementAt(i))
            .every((same) => same);
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
  final String Function(String column) columnLabel;
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
                  width: MediaQuery.sizeOf(context).width < 520 ? 100 : 160,
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
              mouseCursor: WidgetStateMouseCursor.clickable,
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
                                  fontWeight: FontWeight.w700,
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
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
    this.expandChild = false,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Color accent;
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
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}
