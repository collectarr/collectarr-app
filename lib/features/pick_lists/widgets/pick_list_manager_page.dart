import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_scope.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_value_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_values_table.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showPickListManagerDialog({
  required BuildContext context,
  required LocalDatabase db,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AccentAlertDialog(
      backgroundColor: appPalette(context).panel,
      title: const Text('Manage pick lists'),
      content: SizedBox(
        width: 1240,
        height: 760,
        child: PickListManagerPage(db: db),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class PickListManagerPage extends StatefulWidget {
  const PickListManagerPage({super.key, required this.db});

  final LocalDatabase db;

  @override
  State<PickListManagerPage> createState() => _PickListManagerPageState();
}

class _PickListManagerPageState extends State<PickListManagerPage> {
  final _searchController = TextEditingController();
  final _registry = PickListRegistry();
  late final PickListRepository _repo = PickListRepository(widget.db);
  late final CustomFieldRepository _customFieldRepo = CustomFieldRepository(widget.db);

  String? _selectedKind = 'all';
  String? _selectedListName;
  bool _includeGlobalValues = true;
  bool _loading = true;
  List<PickListDefinition> _definitions = const [];
  List<PickListValue> _values = const [];
  Map<String, int> _usageCounts = const {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_reload);
    _load();
  }

  @override
  void dispose() {
    _searchController.removeListener(_reload);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final kind = _selectedKind == 'all' ? null : _selectedKind;
    final defs = _registry.definitionsForKind(kind);
    final customFields = await _customFieldRepo.listDefinitions(
      mediaKind: kind,
    );
    final customDefinitions = [
      for (final field in customFields)
        if (field.supportsOptions)
          PickListDefinition(
            id: 'customField:${field.id}',
            listName: 'customField:${field.id}',
            label: field.name,
            mediaKind: field.mediaKind,
            scope: PickListScope.customField,
            valueMode: field.valueType.isMultiValue
                ? PickListValueMode.multi
                : PickListValueMode.single,
            controlType: PickListControlType.dropdown,
            allowMerge: true,
          ),
    ];
    final filtered = [...defs, ...customDefinitions];
    final query = _searchController.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? filtered
        : filtered.where((definition) {
            return definition.label.toLowerCase().contains(query) ||
                definition.listName.toLowerCase().contains(query);
          }).toList(growable: false);
    final selected = _selectedListName;
    PickListDefinition? selectedDefinition;
    if (visible.isNotEmpty) {
      selectedDefinition = selected == null
          ? visible.first
          : visible.firstWhere(
              (definition) => definition.listName == selected,
              orElse: () => visible.first,
            );
    }
    final values = selectedDefinition == null
        ? const <PickListValue>[]
        : await _repo.valuesForList(
            listName: selectedDefinition.listName,
            mediaKind: selectedDefinition.mediaKind,
            includeGlobal: _includeGlobalValues,
          );
    final usageCounts = selectedDefinition == null
        ? const <String, int>{}
        : await _repo.usageCounts(
            listName: selectedDefinition.listName,
            mediaKind: selectedDefinition.mediaKind,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _definitions = visible;
      _values = values;
      _usageCounts = usageCounts;
      _selectedListName = selectedDefinition?.listName;
      _loading = false;
    });
  }

  void _reload() {
    unawaited(_load());
  }

  Future<void> _addValue() async {
    final definition = _selectedDefinition;
    if (definition == null) {
      return;
    }
    final result = await showPickListValueEditorDialog(
      context: context,
      listName: definition.listName,
      label: definition.label,
      mediaKind: definition.mediaKind,
    );
    if (result == null) {
      return;
    }
    await _repo.upsertValue(result);
    await _load();
  }

  Future<void> _editValue(PickListValue value) async {
    final definition = _selectedDefinition;
    if (definition == null) {
      return;
    }
    final result = await showPickListValueEditorDialog(
      context: context,
      listName: definition.listName,
      label: definition.label,
      mediaKind: definition.mediaKind,
      existing: value,
    );
    if (result == null) {
      return;
    }
    await _repo.upsertValue(result);
    await _load();
  }

  Future<void> _deleteValue(PickListValue value) async {
    await _repo.deleteValue(value.id);
    await _load();
  }

  Future<void> _reorder(List<String> orderedIds) async {
    final definition = _selectedDefinition;
    if (definition == null) {
      return;
    }
    await _repo.reorderValues(
      listName: definition.listName,
      mediaKind: definition.mediaKind,
      orderedIds: orderedIds,
    );
    await _load();
  }

  PickListDefinition? get _selectedDefinition {
    final selected = _selectedListName;
    if (selected == null) {
      return null;
    }
    for (final definition in _definitions) {
      if (definition.listName == selected) {
        return definition;
      }
    }
    return _definitions.isEmpty ? null : _definitions.first;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final definition = _selectedDefinition;
    final palette = appPalette(context);
    return Material(
      color: palette.panel,
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: Material(
              color: palette.panelRaised,
              child: Container(
                decoration: BoxDecoration(
                border: Border(right: BorderSide(color: palette.divider)),
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search lists',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedKind,
                      decoration: const InputDecoration(labelText: 'Kind'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All kinds')),
                        DropdownMenuItem(value: 'comic', child: Text('Comics')),
                        DropdownMenuItem(value: 'manga', child: Text('Manga')),
                        DropdownMenuItem(value: 'anime', child: Text('Anime')),
                        DropdownMenuItem(value: 'book', child: Text('Books')),
                        DropdownMenuItem(value: 'game', child: Text('Games')),
                        DropdownMenuItem(value: 'boardgame', child: Text('Board games')),
                        DropdownMenuItem(value: 'movie', child: Text('Movies')),
                        DropdownMenuItem(value: 'tv', child: Text('TV')),
                        DropdownMenuItem(value: 'music', child: Text('Music')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedKind = value ?? 'all';
                          _selectedListName = null;
                        });
                        unawaited(_load());
                      },
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    value: _includeGlobalValues,
                    onChanged: (value) {
                      setState(() => _includeGlobalValues = value);
                      unawaited(_load());
                    },
                    title: const Text('Include global values'),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _definitions.length,
                      itemBuilder: (context, index) {
                        final item = _definitions[index];
                        final selected = item.listName == definition?.listName;
                        return Material(
                          color:
                              selected ? palette.surface : Colors.transparent,
                          child: ListTile(
                            dense: true,
                            selected: selected,
                            title: Text(item.label),
                            subtitle: Text(item.listName),
                            onTap: () {
                              setState(() => _selectedListName = item.listName);
                              unawaited(_load());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: definition == null
                  ? const Center(child: Text('No pick list selected'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                definition.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _addValue,
                              icon: const Icon(Icons.add),
                              label: const Text('Add value'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PickListMetaChip(label: definition.scope.name),
                            _PickListMetaChip(
                              label: definition.mediaKind == null
                                  ? 'Global'
                                  : definition.mediaKind!,
                            ),
                            _PickListMetaChip(
                              label: definition.valueMode.name,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: PickListValuesTable(
                            values: _values,
                            usageCounts: _usageCounts,
                            onReorder: _reorder,
                            onEdit: _editValue,
                            onDelete: _deleteValue,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickListMetaChip extends StatelessWidget {
  const _PickListMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).panelRaised,
        border: Border.all(color: appPalette(context).divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label),
      ),
    );
  }
}
