import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/library_sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/features/library/generic/library_folder_reorder_list.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';

Future<List<LibrarySortRule>?> showLibrarySortDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
  required List<LibrarySortRule> currentRules,
  bool Function(String column)? defaultAscendingForColumn,
  List<String>? availableColumns,
  String title = 'Select Sort Fields',
  String confirmLabel = 'Save',
  String? description,
}) {
  return showAppDialog<List<LibrarySortRule>>(
    context: context,
    builder: (context) => _LibrarySortDialog(
      type: type,
      currentRules: currentRules,
      defaultAscendingForColumn: defaultAscendingForColumn,
      availableColumns: availableColumns,
      title: title,
      confirmLabel: confirmLabel,
      description: description,
    ),
  );
}

class _LibrarySortDialog extends StatefulWidget {
  const _LibrarySortDialog({
    required this.type,
    required this.currentRules,
    this.defaultAscendingForColumn,
    this.availableColumns,
    required this.title,
    required this.confirmLabel,
    this.description,
  });

  final LibraryKindRegistration type;
  final List<LibrarySortRule> currentRules;
  final bool Function(String column)? defaultAscendingForColumn;
  final List<String>? availableColumns;
  final String title;
  final String confirmLabel;
  final String? description;

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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Map<LibraryTableColumnGroup, bool> _expandedGroups = {
    LibraryTableColumnGroup.main: true,
    LibraryTableColumnGroup.value: false,
    LibraryTableColumnGroup.edition: false,
    LibraryTableColumnGroup.personal: false,
  };

  @override
  void initState() {
    super.initState();
    _presetNameController = TextEditingController();
    _presetStore = LibrarySortPresetStore(widget.type);
    _rules = widget.currentRules.isEmpty
        ? [_defaultRule()]
        : List<LibrarySortRule>.from(widget.currentRules);
    _loadPresets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _presetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = _filteredColumns();
    return LibraryFieldSelectionDialog(
        title: widget.title,
        accent: widget.type.identity.accent,
        confirmLabel: widget.confirmLabel,
        onSave: _saveAndClose,
        headerAction: PopupMenuButton<LibrarySortPreset>(
            tooltip: 'Sorting favorites',
            icon: const Icon(AppIcons.settings, color: Colors.white, size: 16),
            enabled: !_loadingPresets,
            onSelected: _applyPreset,
            itemBuilder: (context) => [
                  PopupMenuItem(
                      enabled: false,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _nameFavorite();
                          },
                          child: const Text('Save favorite'))),
                  for (final preset in _combinedPresets)
                    PopupMenuItem(
                        value: preset,
                        child: Row(children: [
                          Expanded(
                              child: Tooltip(
                                  message: _sortRuleSummary(
                                      widget.type, preset.rules),
                                  child: Text(preset.label))),
                          if (preset.isSaved)
                            IconButton(
                                tooltip: 'Delete favorite',
                                icon:
                                    const Icon(Icons.delete_outline, size: 16),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deletePreset(preset.id!);
                                }),
                        ])),
                ]),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
              _rules
                  .map((rule) => _sortColumnLabel(widget.type, rule.column))
                  .join(' / '),
              style: librarySelectionFieldStyle.copyWith(
                  fontSize: 18, height: 1.25)),
          if (widget.description != null) ...[
            const SizedBox(height: 8),
            Text(widget.description!)
          ],
          const SizedBox(height: 15),
          Expanded(
              child: LibraryFieldSelectionPanes(
            available: Column(children: [
              LibraryFieldSelectionSearch(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value)),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView(children: [
                for (final group in [
                  LibraryTableColumnGroup.images,
                  ...LibraryTableColumnGroup.values
                      .where((group) => group != LibraryTableColumnGroup.images)
                ])
                  if (_groupColumns(group, columns).isNotEmpty)
                    LibraryFieldSelectionCategory(
                        title: _groupLabel(group),
                        expanded: _query.isNotEmpty ||
                            (_expandedGroups[group] ??
                                group == LibraryTableColumnGroup.main ||
                                    group == LibraryTableColumnGroup.images),
                        onToggle: () => setState(() => _expandedGroups[group] =
                            !(_expandedGroups[group] ??
                                group == LibraryTableColumnGroup.main ||
                                    group == LibraryTableColumnGroup.images)),
                        children: [
                          for (final column in _groupColumns(group, columns))
                            LibraryFieldSelectionCheckbox(
                                key: ValueKey('available-sort-$column'),
                                label: _sortColumnLabel(widget.type, column),
                                selected:
                                    _rules.any((rule) => rule.column == column),
                                onTap: () => _toggleColumn(column)),
                        ]),
              ])),
            ]),
            selected: LibraryFolderReorderList(
                padding: const EdgeInsets.all(10),
                rowSpacing: 3,
                placeholderColor: const Color(0xff808080),
                itemCount: _rules.length,
                onReorder: (oldIndex, newIndex) => setState(() {
                      final rule = _rules.removeAt(oldIndex);
                      _rules.insert(newIndex, rule);
                    }),
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  return LibrarySelectedFieldRow(
                      key: ValueKey('selected-sort-${rule.column}'),
                      handleKey:
                          ValueKey('selected-sort-${rule.column}-handle'),
                      label: _sortColumnLabel(widget.type, rule.column),
                      direction: rule.ascending ? 'ASC' : 'DESC',
                      onToggleDirection: () => setState(() => _rules[index] =
                          rule.copyWith(ascending: !rule.ascending)),
                      removeTooltip: _rules.length > 1
                          ? 'Remove sort field'
                          : 'At least one sort field is required',
                      onRemove: _rules.length > 1
                          ? () => setState(() => _rules.removeAt(index))
                          : null);
                }),
          )),
        ]));
  }

  Future<void> _nameFavorite() async {
    var label = _presetNameController.text;
    final name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Save Sorting Favorite'),
                content: TextFormField(
                    initialValue: label,
                    autofocus: true,
                    onChanged: (value) => label = value,
                    decoration:
                        const InputDecoration(labelText: 'Preset name')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.of(context).pop(label.trim()),
                      child: const Text('Save'))
                ]));
    if (name != null && name.isNotEmpty && mounted) {
      _presetNameController.text = name;
      await _savePresetOnly();
    }
  }

  LibrarySortRule _defaultRule() {
    final column = libraryKindWorkspaceForKind(widget.type.kind)
        .workspaceFields
        .defaultSort
        .value;
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
    final available = (widget.availableColumns ??
            [
              for (final definition
                  in libraryKindWorkspaceForKind(widget.type.kind)
                      .workspaceFields
                      .sorts)
                definition.id.value,
            ])
        .toSet();
    return [
      for (final favorite in librarySortFavoritesForType(widget.type))
        if (favorite.rules.every((rule) => available.contains(rule.column)))
          LibrarySortPreset(
            id: favorite.id,
            label: favorite.label,
            rules: favorite.rules,
            icon: favorite.icon,
            isBuiltIn: true,
          ),
      ..._savedPresets.where((preset) =>
          preset.rules.every((rule) => available.contains(rule.column))),
    ];
  }

  List<String> _filteredColumns() {
    final query = _query.trim().toLowerCase();
    final available = widget.availableColumns ??
        [
          for (final def in libraryKindWorkspaceForKind(widget.type.kind)
              .workspaceFields
              .sorts)
            def.id.value,
        ];
    final result = available.where((column) {
      if (query.isEmpty) {
        return true;
      }
      return _sortColumnLabel(widget.type, column)
          .toLowerCase()
          .contains(query);
    }).toList()
      ..sort((a, b) => _sortColumnLabel(widget.type, a)
          .toLowerCase()
          .compareTo(_sortColumnLabel(widget.type, b).toLowerCase()));
    return result;
  }

  List<String> _groupColumns(
    LibraryTableColumnGroup group,
    List<String> columns,
  ) {
    return [
      for (final column in columns)
        if (_sortFieldGroup(widget.type, column) == group) column,
    ];
  }

  bool _defaultAscending(String column) {
    return widget.defaultAscendingForColumn?.call(column) ??
        _defaultSortAscending(widget.type, column);
  }

  void _toggleColumn(String column) {
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

String _sortRuleSummary(
  LibraryKindRegistration type,
  List<LibrarySortRule> rules,
) {
  return rules
      .map(
        (rule) =>
            '${_sortColumnLabel(type, rule.column)} ${rule.ascending ? 'ASC' : 'DESC'}',
      )
      .join('  |  ');
}

LibraryTableColumnGroup _sortFieldGroup(
  LibraryKindRegistration type,
  String column,
) {
  final fields = libraryKindWorkspaceForKind(type.kind).workspaceFields;
  final sort = fields.sortDefinitionFor(fields.decodeSortId(column));
  final matchingColumns = fields.columns.where((definition) =>
      definition.id.value == column || definition.sortId?.value == column);
  final groupStr =
      (matchingColumns.isEmpty ? sort.group : matchingColumns.first.group)
          .toLowerCase();
  return LibraryTableColumnGroup.values.firstWhere(
    (g) => g.name.toLowerCase() == groupStr,
    orElse: () => LibraryTableColumnGroup.main,
  );
}

String _groupLabel(LibraryTableColumnGroup group) {
  return switch (group) {
    LibraryTableColumnGroup.main => 'Main',
    LibraryTableColumnGroup.value => 'Value',
    LibraryTableColumnGroup.edition => 'Edition',
    LibraryTableColumnGroup.personal => 'Personal',
    LibraryTableColumnGroup.credits => 'Credits',
    LibraryTableColumnGroup.images => 'Images',
    LibraryTableColumnGroup.loan => 'Loan',
  };
}

bool _defaultSortAscending(
  LibraryKindRegistration type,
  String column,
) {
  final fields = libraryKindWorkspaceForKind(type.kind).workspaceFields;
  return fields.sortDefinitionFor(fields.decodeSortId(column)).defaultAscending;
}

List<LibrarySortRule> _dedupeRules(List<LibrarySortRule> rules) {
  final seen = <String>{};
  final deduped = <LibrarySortRule>[];
  for (final rule in rules) {
    if (seen.add(rule.column)) {
      deduped.add(rule);
    }
  }
  return deduped;
}

String _sortColumnLabel(
  LibraryKindRegistration type,
  String column,
) {
  try {
    final fields = libraryKindWorkspaceForKind(type.kind).workspaceFields;
    return fields.sortDefinitionFor(fields.decodeSortId(column)).label;
  } on StateError {
    return librarySortColumnFallbackLabel(column);
  }
}
