import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<List<LibrarySortRule>?> showLibrarySortDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required List<LibrarySortRule> currentRules,
  bool Function(LibrarySortColumn column)? defaultAscendingForColumn,
}) {
  return showDialog<List<LibrarySortRule>>(
    context: context,
    builder: (context) => _LibrarySortDialog(
      type: type,
      currentRules: currentRules,
      defaultAscendingForColumn: defaultAscendingForColumn,
    ),
  );
}

class _LibrarySortDialog extends StatefulWidget {
  const _LibrarySortDialog({
    required this.type,
    required this.currentRules,
    this.defaultAscendingForColumn,
  });

  final LibraryTypeConfig type;
  final List<LibrarySortRule> currentRules;
  final bool Function(LibrarySortColumn column)? defaultAscendingForColumn;

  @override
  State<_LibrarySortDialog> createState() => _LibrarySortDialogState();
}

class _LibrarySortDialogState extends State<_LibrarySortDialog> {
  late List<LibrarySortRule> _rules;
  late final TextEditingController _presetNameController;
  late final LibrarySortPresetStore _presetStore;
  List<LibrarySortPreset> _savedPresets = const [];
  bool _loadingPresets = true;
  String? _editingPresetId;
  String _query = '';
  final Map<LibrarySortFieldGroup, bool> _expandedGroups = {
    LibrarySortFieldGroup.main: true,
    LibrarySortFieldGroup.value: false,
    LibrarySortFieldGroup.edition: false,
    LibrarySortFieldGroup.personal: true,
  };

  @override
  void initState() {
    super.initState();
    _presetNameController = TextEditingController();
    _presetStore = LibrarySortPresetStore(widget.type.workspace);
    _rules = widget.currentRules.isEmpty
        ? [_defaultRule()]
        : List<LibrarySortRule>.from(widget.currentRules);
    _loadPresets();
  }

  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = widget.type.workspace.accent;
    final viewport = MediaQuery.sizeOf(context);
    final availableColumns = _filteredColumns();
    final matchingPreset = _matchingPreset;
    final favoriteCount = _combinedPresets.length + (matchingPreset == null ? 1 : 0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 860),
        child: SizedBox(
          width: viewport.width - 48,
          height: viewport.height - 36,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.panelRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.divider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                AccentDialogHeader(
                  title: 'Select Sort Fields',
                  accent: accent,
                  icon: Icons.sort,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 300,
                          child: _PaneFrame(
                            title: 'Sorting Favorites',
                            count: favoriteCount,
                            accent: accent,
                            expandChild: true,
                            trailing: LibraryDenseIconButton(
                              tooltip: 'New preset',
                              onPressed: _resetDraft,
                              icon: Icons.add,
                              tone: LibraryDenseButtonTone.subtle,
                            ),
                            child: _loadingPresets
                                ? const Center(child: CircularProgressIndicator())
                                : ListView(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                    children: [
                                      if (matchingPreset == null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: _SortPresetTile(
                                            key: const ValueKey('sort-preset-current-draft'),
                                            title: _presetNameController.text.trim().isEmpty
                                                ? 'Current draft'
                                                : _presetNameController.text.trim(),
                                            summary: _sortRuleSummary(widget.type, _rules),
                                            accent: accent,
                                            selected: true,
                                            onTap: () {},
                                          ),
                                        ),
                                      for (final preset in _combinedPresets)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: _SortPresetTile(
                                            key: ValueKey('sort-preset-${preset.id ?? preset.label}'),
                                            title: preset.label,
                                            summary: _sortRuleSummary(widget.type, preset.rules),
                                            accent: accent,
                                            icon: preset.icon,
                                            selected: matchingPreset != null &&
                                                (matchingPreset.id == preset.id &&
                                                    matchingPreset.label == preset.label),
                                            builtIn: preset.isBuiltIn,
                                            onTap: () => _applyPreset(preset),
                                            onDelete: preset.isSaved
                                                ? () => _deletePreset(preset.id!)
                                                : null,
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              _PaneFrame(
                                title: 'Preset',
                                accent: accent,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _presetNameController,
                                          decoration: InputDecoration(
                                            labelText: 'Preset name',
                                            filled: true,
                                            fillColor: palette.field,
                                            border: const OutlineInputBorder(),
                                            suffixIcon: _presetNameController.text.isEmpty
                                                ? null
                                                : IconButton(
                                                    tooltip: 'Clear preset name',
                                                    onPressed: () {
                                                      setState(() {
                                                        _editingPresetId = null;
                                                        _presetNameController.clear();
                                                      });
                                                    },
                                                    icon: const Icon(Icons.close),
                                                  ),
                                          ),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      LibraryDenseButton(
                                        label: 'Save favorite',
                                        icon: Icons.bookmark_add_outlined,
                                        onPressed: _presetNameController.text.trim().isEmpty
                                            ? null
                                            : _savePresetOnly,
                                        tone: LibraryDenseButtonTone.subtle,
                                      ),
                                    ],
                                  ),
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
                                        count: availableColumns.length,
                                        accent: accent,
                                        expandChild: true,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText: 'Search fields',
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: palette.field,
                                                  border: const OutlineInputBorder(),
                                                  prefixIcon: const Icon(Icons.search),
                                                  suffixIcon: _query.isEmpty
                                                      ? null
                                                      : IconButton(
                                                          tooltip: 'Clear search',
                                                          onPressed: () => setState(() => _query = ''),
                                                          icon: const Icon(Icons.close),
                                                        ),
                                                ),
                                                onChanged: (value) => setState(() => _query = value),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView(
                                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                children: [
                                                  for (final group in LibrarySortFieldGroup.values)
                                                    if (_groupColumns(group, availableColumns).isNotEmpty)
                                                      _SortFieldGroupPanel(
                                                        title: _groupLabel(group),
                                                        accent: accent,
                                                        expanded: _expandedGroups[group] ?? true,
                                                        onToggle: () => setState(
                                                          () => _expandedGroups[group] =
                                                              !(_expandedGroups[group] ?? true),
                                                        ),
                                                        children: [
                                                          for (final column in _groupColumns(group, availableColumns))
                                                            _AvailableSortFieldTile(
                                                              key: ValueKey('available-sort-${column.name}'),
                                                              label: _sortColumnLabel(widget.type, column),
                                                              directionLabel: _defaultAscending(column)
                                                                  ? 'ASC'
                                                                  : 'DESC',
                                                              selected: _rules.any(
                                                                (rule) => rule.column == column,
                                                              ),
                                                              onTap: () => _toggleColumn(column),
                                                            ),
                                                        ],
                                                      ),
                                                ],
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
                                        title: 'Selected fields',
                                        count: _rules.length,
                                        accent: accent,
                                        expandChild: true,
                                        child: ReorderableListView.builder(
                                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                          itemCount: _rules.length,
                                          buildDefaultDragHandles: false,
                                          proxyDecorator: (child, index, animation) {
                                            return Material(
                                              color: Color.alphaBlend(
                                                accent.withValues(alpha: 0.14),
                                                palette.panelRaised,
                                              ),
                                              elevation: 6,
                                              borderRadius: BorderRadius.circular(6),
                                              child: child,
                                            );
                                          },
                                          onReorderItem: (oldIndex, newIndex) {
                                            setState(() {
                                              final reordered = _rules.toList(growable: true);
                                              final rule = reordered.removeAt(oldIndex);
                                              if (oldIndex < newIndex) {
                                                newIndex -= 1;
                                              }
                                              reordered.insert(newIndex, rule);
                                              _rules = reordered;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            final rule = _rules[index];
                                            return _SelectedSortRuleTile(
                                              key: ValueKey('selected-sort-${rule.column.name}'),
                                              index: index,
                                              dragHandleKey: ValueKey(
                                                'selected-sort-${rule.column.name}-handle',
                                              ),
                                              title: _sortColumnLabel(widget.type, rule.column),
                                              ascending: rule.ascending,
                                              canMoveUp: index > 0,
                                              canMoveDown: index < _rules.length - 1,
                                              removable: _rules.length > 1,
                                              onMoveUp: () {
                                                if (index <= 0) {
                                                  return;
                                                }
                                                setState(() {
                                                  final reordered = _rules.toList(growable: true);
                                                  final current = reordered.removeAt(index);
                                                  reordered.insert(index - 1, current);
                                                  _rules = reordered;
                                                });
                                              },
                                              onMoveDown: () {
                                                if (index >= _rules.length - 1) {
                                                  return;
                                                }
                                                setState(() {
                                                  final reordered = _rules.toList(growable: true);
                                                  final current = reordered.removeAt(index);
                                                  reordered.insert(index + 1, current);
                                                  _rules = reordered;
                                                });
                                              },
                                              onToggleDirection: () {
                                                setState(() {
                                                  _rules[index] = _rules[index].copyWith(
                                                    ascending: !_rules[index].ascending,
                                                  );
                                                });
                                              },
                                              onRemove: () {
                                                if (_rules.length <= 1) {
                                                  return;
                                                }
                                                setState(() {
                                                  _rules.removeAt(index);
                                                });
                                              },
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
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'The first field is primary. Later fields break ties.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      LibraryDenseButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        tone: LibraryDenseButtonTone.subtle,
                      ),
                      const SizedBox(width: 8),
                      LibraryDenseButton(
                        label: 'Save',
                        icon: Icons.check,
                        onPressed: _saveAndClose,
                        tone: LibraryDenseButtonTone.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LibrarySortRule _defaultRule() {
    final column = widget.type.workspace.defaultSortColumn;
    return LibrarySortRule(
      column: column,
      ascending: _defaultAscending(column),
    );
  }

  Future<void> _loadPresets() async {
    final savedPresets = await _presetStore.read();
    if (!mounted) {
      return;
    }
    String? editingPresetId;
    String presetName = '';
    for (final preset in savedPresets) {
      if (_sameSortRules(preset.rules, _rules)) {
        editingPresetId = preset.id;
        presetName = preset.label;
        break;
      }
    }
    setState(() {
      _savedPresets = savedPresets;
      _loadingPresets = false;
      _editingPresetId = editingPresetId;
      _presetNameController.text = presetName;
    });
  }

  List<LibrarySortPreset> get _combinedPresets {
    return [
      for (final favorite in librarySortFavoritesForType(widget.type))
        LibrarySortPreset(
          id: favorite.id,
          label: favorite.label,
          rules: favorite.rules,
          icon: favorite.icon,
          isBuiltIn: true,
        ),
      ..._savedPresets,
    ];
  }

  LibrarySortPreset? get _matchingPreset {
    for (final preset in _combinedPresets) {
      if (_sameSortRules(preset.rules, _rules)) {
        return preset;
      }
    }
    return null;
  }

  List<LibrarySortColumn> _filteredColumns() {
    final query = _query.trim().toLowerCase();
    return widget.type.availableSortColumns.where((column) {
      if (query.isEmpty) {
        return true;
      }
        return _sortColumnLabel(widget.type, column)
          .toLowerCase()
          .contains(query);
    }).toList(growable: false);
  }

  List<LibrarySortColumn> _groupColumns(
    LibrarySortFieldGroup group,
    List<LibrarySortColumn> columns,
  ) {
    return [
      for (final column in columns)
        if (_sortFieldGroup(widget.type, column) == group) column,
    ];
  }

  bool _defaultAscending(LibrarySortColumn column) {
    return widget.defaultAscendingForColumn?.call(column) ??
      _defaultSortAscending(widget.type, column);
  }

  void _toggleColumn(LibrarySortColumn column) {
    final existingIndex = _rules.indexWhere((rule) => rule.column == column);
    setState(() {
      if (existingIndex >= 0) {
        if (_rules.length > 1) {
          _rules.removeAt(existingIndex);
        }
        return;
      }
      _rules = _dedupeRules([
        ..._rules,
        LibrarySortRule(
          column: column,
          ascending: _defaultAscending(column),
        ),
      ]);
    });
  }

  void _applyPreset(LibrarySortPreset preset) {
    setState(() {
      _rules = List<LibrarySortRule>.from(preset.rules);
      _editingPresetId = preset.isSaved ? preset.id : null;
      _presetNameController.text = preset.isSaved ? preset.label : '';
    });
  }

  void _resetDraft() {
    setState(() {
      _rules = [_defaultRule()];
      _editingPresetId = null;
      _presetNameController.clear();
      _query = '';
    });
  }

  Future<void> _savePresetOnly() async {
    final label = _presetNameController.text.trim();
    if (label.isEmpty) {
      return;
    }
    final nextPresets = await _presetStore.savePreset(
      id: _editingPresetId,
      label: label,
      rules: _rules,
    );
    if (!mounted) {
      return;
    }
    String? nextEditingId;
    for (final preset in nextPresets) {
      if (preset.label == label && _sameSortRules(preset.rules, _rules)) {
        nextEditingId = preset.id;
      }
    }
    setState(() {
      _savedPresets = nextPresets;
      _editingPresetId = nextEditingId;
    });
  }

  Future<void> _deletePreset(String id) async {
    final nextPresets = await _presetStore.deletePreset(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _savedPresets = nextPresets;
      if (_editingPresetId == id) {
        _editingPresetId = null;
        _presetNameController.clear();
      }
    });
  }

  Future<void> _saveAndClose() async {
    if (_presetNameController.text.trim().isNotEmpty) {
      await _savePresetOnly();
      if (!mounted) {
        return;
      }
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_dedupeRules(_rules));
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

class _SortPresetTile extends StatelessWidget {
  const _SortPresetTile({
    super.key,
    required this.title,
    required this.summary,
    required this.accent,
    required this.selected,
    required this.onTap,
    this.icon,
    this.builtIn = false,
    this.onDelete,
  });

  final String title;
  final String summary;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool builtIn;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(accent.withValues(alpha: 0.10), palette.surfaceSubtle)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon ?? (selected ? Icons.check : Icons.sort),
                size: 16,
                color: selected ? accent : palette.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (builtIn)
                          Text(
                            'Built-in',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: palette.textMuted,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 6),
                LibraryDenseIconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: Icons.delete_outline,
                  tone: LibraryDenseButtonTone.subtle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SortFieldGroupPanel extends StatelessWidget {
  const _SortFieldGroupPanel({
    required this.title,
    required this.accent,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final Color accent;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: palette.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}

class _AvailableSortFieldTile extends StatelessWidget {
  const _AvailableSortFieldTile({
    super.key,
    required this.label,
    required this.directionLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String directionLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? palette.selection : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 16,
                color: selected ? palette.accent : palette.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ),
              Text(
                directionLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedSortRuleTile extends StatelessWidget {
  const _SelectedSortRuleTile({
    super.key,
    required this.index,
    required this.dragHandleKey,
    required this.title,
    required this.ascending,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.removable,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onToggleDirection,
    required this.onRemove,
  });

  final int index;
  final Key dragHandleKey;
  final String title;
  final bool ascending;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool removable;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onToggleDirection;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return ReorderableDragStartListener(
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: palette.surfaceSubtle,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: palette.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_indicator,
                      key: dragHandleKey,
                      size: 16,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  LibraryDenseButton(
                    label: ascending ? 'ASC' : 'DESC',
                    onPressed: onToggleDirection,
                    tone: LibraryDenseButtonTone.subtle,
                  ),
                  LibraryDenseIconButton(
                    tooltip: 'Move up',
                    onPressed: canMoveUp ? onMoveUp : null,
                    icon: Icons.arrow_upward,
                    tone: LibraryDenseButtonTone.subtle,
                  ),
                  LibraryDenseIconButton(
                    tooltip: 'Move down',
                    onPressed: canMoveDown ? onMoveDown : null,
                    icon: Icons.arrow_downward,
                    tone: LibraryDenseButtonTone.subtle,
                  ),
                  removable
                      ? LibraryDenseIconButton(
                          tooltip: 'Remove sort field',
                          onPressed: onRemove,
                          icon: Icons.close,
                          tone: LibraryDenseButtonTone.subtle,
                        )
                      : Tooltip(
                          message: 'At least one sort field is required',
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: palette.textMuted,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _sameSortRules(List<LibrarySortRule> first, List<LibrarySortRule> second) {
  if (first.length != second.length) {
    return false;
  }
  for (var index = 0; index < first.length; index += 1) {
    if (first[index] != second[index]) {
      return false;
    }
  }
  return true;
}

String _sortRuleSummary(LibraryTypeConfig type, List<LibrarySortRule> rules) {
  return rules
      .map(
        (rule) =>
            '${_sortColumnLabel(type, rule.column)} ${rule.ascending ? 'ASC' : 'DESC'}',
      )
      .join('  |  ');
}

LibrarySortFieldGroup _sortFieldGroup(
  LibraryTypeConfig type,
  LibrarySortColumn column,
) {
  return type.presentation.sortColumnDefinitionFor(column).group;
}

String _groupLabel(LibrarySortFieldGroup group) {
  return switch (group) {
    LibrarySortFieldGroup.main => 'Main',
    LibrarySortFieldGroup.value => 'Value',
    LibrarySortFieldGroup.edition => 'Edition',
    LibrarySortFieldGroup.personal => 'Personal',
  };
}

bool _defaultSortAscending(LibraryTypeConfig type, LibrarySortColumn column) {
  return type.presentation.sortColumnDefinitionFor(column).defaultAscending;
}

List<LibrarySortRule> _dedupeRules(List<LibrarySortRule> rules) {
  final seen = <LibrarySortColumn>{};
  final deduped = <LibrarySortRule>[];
  for (final rule in rules) {
    if (seen.add(rule.column)) {
      deduped.add(rule);
    }
  }
  return deduped;
}

String _sortColumnLabel(LibraryTypeConfig type, LibrarySortColumn column) {
  return type.presentation.sortColumnDefinitionFor(column).label;
}