import 'dart:async';
import 'dart:convert';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:uuid/uuid.dart';

Future<void> showCustomFieldsManagementDialog({
  required BuildContext context,
  required LocalDatabase db,
  bool startCreating = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AccentAlertDialog(
      backgroundColor: appPalette(context).panel,
      title: const Text('Manage custom fields'),
      content: SizedBox(
        width: 920,
        height: 560,
        child: SingleChildScrollView(
          child: CustomFieldsSettings(
            db: db,
            startCreating: startCreating,
          ),
        ),
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

/// Settings panel for managing custom field definitions.
class CustomFieldsSettings extends StatefulWidget {
  const CustomFieldsSettings({
    super.key,
    required this.db,
    this.startCreating = false,
  });

  final LocalDatabase db;
  final bool startCreating;

  @override
  State<CustomFieldsSettings> createState() => _CustomFieldsSettingsState();
}

class _CustomFieldsSettingsState extends State<CustomFieldsSettings> {
  late final CustomFieldRepository _repo;
  List<CustomFieldDefinition> _definitions = const [];
  bool _loading = true;
  bool _openedInitialEditor = false;

  @override
  void initState() {
    super.initState();
    _repo = CustomFieldRepository(widget.db);
    _reload();
    if (widget.startCreating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _openedInitialEditor) {
          return;
        }
        _openedInitialEditor = true;
        unawaited(_showEditor());
      });
    }
  }

  Future<void> _reload() async {
    final defs = await _repo.listDefinitions();
    if (mounted) {
      setState(() {
        _definitions = defs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_definitions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'No custom fields defined yet. Add one to track extra data on your items.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _definitions.length,
          onReorderItem: _onReorder,
          itemBuilder: (context, index) {
            final def = _definitions[index];
            return _DefinitionTile(
              key: ValueKey(def.id),
              definition: def,
              index: index,
              onEdit: () => _showEditor(existing: def),
              onDelete: () => _confirmDelete(def),
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Add custom field'),
        ),
      ],
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final reordered = List.of(_definitions);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    setState(() => _definitions = reordered);
    for (var i = 0; i < reordered.length; i++) {
      await _repo.upsertDefinition(reordered[i].copyWith(sortOrder: i));
    }
  }

  Future<void> _showEditor({CustomFieldDefinition? existing}) async {
    final result = await showDialog<CustomFieldDefinition>(
      context: context,
      builder: (context) => _CustomFieldEditor(existing: existing),
    );
    if (result != null) {
      await _repo.upsertDefinition(result);
      await _reload();
    }
  }

  Future<void> _confirmDelete(CustomFieldDefinition def) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: const Text('Delete custom field?'),
        content: Text(
          'This will permanently remove "${def.name}" and all its values from every item.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.deleteDefinition(def.id);
      await _reload();
    }
  }
}

class _DefinitionTile extends StatelessWidget {
  const _DefinitionTile({
    super.key,
    required this.definition,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomFieldDefinition definition;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: palette.panelRaised,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 640;
              final kindLabel = _mediaKindLabel(definition.mediaKind);
              final scopeLabel = _editScopeLabel(definition.editScope);
              final typeLabel = definition.valueTypeLabel;
              final rowChildren = <Widget>[
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kindLabel,
                        style: TextStyle(color: palette.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DefinitionPill(label: scopeLabel),
                const SizedBox(width: 8),
                _DefinitionPill(label: typeLabel),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ];
              if (!stacked) {
                return Row(children: rowChildren);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: palette.textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              definition.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              kindLabel,
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _DefinitionPill(label: scopeLabel),
                      _DefinitionPill(label: typeLabel),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CustomFieldEditor extends StatefulWidget {
  const _CustomFieldEditor({this.existing});

  final CustomFieldDefinition? existing;

  @override
  State<_CustomFieldEditor> createState() => _CustomFieldEditorState();
}

class _CustomFieldEditorState extends State<_CustomFieldEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _optionsController;
  late CustomFieldValueType _fieldType;
  String? _mediaKind;
  String? _editScope;

  static final List<CustomFieldValueType> _fieldTypes =
      CustomFieldValueType.values;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _fieldType = existing?.valueType ?? CustomFieldValueType.text;
    _mediaKind = existing?.mediaKind;
    _editScope = existing?.editScope;
    _optionsController = TextEditingController(
      text: _decodeOptions(existing?.options),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  String _decodeOptions(String? json) {
    if (json == null || json.isEmpty) return '';
    try {
      final list = jsonDecode(json) as List;
      return list.join(', ');
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'custom_fields',
        message: 'Failed to decode custom field options JSON.',
        error: error,
        stackTrace: stackTrace,
      );
      return '';
    }
  }

  String? _encodeOptions() {
    if (!_fieldType.supportsOptions) return null;
    final items = _optionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return items.isEmpty ? null : encodeCustomFieldOptions(items);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return AccentAlertDialog(
      title: Text(isNew ? 'New custom field' : 'Edit custom field'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Field name'),
                autofocus: true,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CustomFieldValueType>(
                initialValue: _fieldType,
                dropdownColor: appPalette(context).panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(labelText: 'Field type'),
                items: [
                  for (final type in _fieldTypes)
                    DropdownMenuItem<CustomFieldValueType>(
                      value: type,
                      child: Text(type.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _fieldType = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _mediaKind,
                dropdownColor: appPalette(context).panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Applies to',
                  hintText: 'All libraries',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All libraries'),
                  ),
                  for (final type in collectarrLibraryTypes.types)
                    DropdownMenuItem<String>(
                      value: type.workspace.kind.apiValue,
                      child: Text(type.singularLabel),
                    ),
                ],
                onChanged: (value) => setState(() => _mediaKind = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _editScope,
                dropdownColor: appPalette(context).panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Applies in',
                  hintText: 'All scopes',
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All scopes'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'media',
                    child: Text('Media'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'release',
                    child: Text('Release'),
                  ),
                ],
                onChanged: (value) => setState(() => _editScope = value),
              ),
              if (_fieldType.supportsOptions) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Options (comma-separated)',
                    hintText: 'Option A, Option B, Option C',
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isNew ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final def = CustomFieldDefinition(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      fieldType: _fieldType.apiValue,
      mediaKind: _mediaKind,
      editScope: _editScope,
      sortOrder: widget.existing?.sortOrder ?? 0,
      options: _encodeOptions(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    Navigator.of(context).pop(def);
  }
}

class _DefinitionPill extends StatelessWidget {
  const _DefinitionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String _mediaKindLabel(String? kind) {
  if (kind == null || kind.trim().isEmpty) {
    return 'All libraries';
  }
  final normalized = kind.trim().toLowerCase();
  for (final type in collectarrLibraryTypes.types) {
    if (type.workspace.kind.apiValue == normalized) {
      return type.singularLabel;
    }
  }
  return kind.trim();
}

String _editScopeLabel(String? scope) {
  return switch (scope) {
    null => 'All scopes',
    'media' => 'Media',
    'release' => 'Release',
    _ => scope,
  };
}
