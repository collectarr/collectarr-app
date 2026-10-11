import 'package:collectarr_app/features/settings/custom_field_editor_dialog.dart';
import 'package:collectarr_app/features/settings/custom_fields_tab_settings_dialog.dart';
import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/features/library/ui/library_management_page.dart';
import 'package:collectarr_app/features/library/generic/library_custom_field_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/settings/custom_field_type_picker.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';

Future<void> showCustomFieldsManagementPage({
  required BuildContext context,
  required LocalDatabase db,
  bool startCreating = false,
  Color? accent,
  String? mediaKind,
}) =>
    Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (context) => LibraryManagementPage(
        title: 'Manage Custom Fields',
        icon: AppIcons.customFields,
        accent: accent ?? appPalette(context).accent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 930),
            child: CustomFieldsSettings(
                db: db, mediaKind: mediaKind, startCreating: startCreating),
          )),
        ),
      ),
    ));

/// Settings panel for managing custom field definitions.
class CustomFieldsSettings extends StatefulWidget {
  const CustomFieldsSettings({
    super.key,
    required this.db,
    this.startCreating = false,
    this.mediaKind,
  });

  final LocalDatabase db;
  final bool startCreating;
  final String? mediaKind;

  @override
  State<CustomFieldsSettings> createState() => _CustomFieldsSettingsState();
}

class _CustomFieldsSettingsState extends State<CustomFieldsSettings> {
  late final CustomFieldRepository _repo;
  List<CustomFieldDefinition> _definitions = const [];
  bool _loading = true;
  bool _openedInitialEditor = false;
  CustomFieldsDisplaySettings _display = const CustomFieldsDisplaySettings();

  @override
  void initState() {
    super.initState();
    _repo = CustomFieldRepository(widget.db);
    _reload();
    unawaited(_loadDisplay());
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

  Future<void> _loadDisplay() async {
    final display = await CustomFieldsDisplaySettings.read(widget.mediaKind);
    if (mounted) setState(() => _display = display);
  }

  Future<void> _configureTab() async {
    final result = await showDialog<CustomFieldsDisplaySettings>(
      context: context,
      builder: (context) => CustomFieldsTabSettingsDialog(settings: _display),
    );
    if (result == null) return;
    await result.save(widget.mediaKind);
    if (mounted) setState(() => _display = result);
  }

  Future<void> _reload() async {
    final defs = await _repo.listDefinitions(mediaKind: widget.mediaKind);
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: appPalette(context).divider))),
          child: Row(children: [
            Expanded(
                child: Text(_display.tabName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700))),
            IconButton(
                tooltip: 'Custom Fields settings',
                onPressed: _configureTab,
                icon: const Icon(Icons.settings_outlined, size: 18)),
          ]),
        ),
        if (_definitions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'You do not have any Custom Fields yet.',
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
        FilledButton.icon(
          onPressed: () => _showEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Add Custom Field'),
        ),
      ],
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final reordered = List.of(_definitions);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    setState(() => _definitions = reordered);
    await _repo.reorderDefinitions(reordered.map((def) => def.id).toList());
    _invalidate();
  }

  Future<void> _showEditor({CustomFieldDefinition? existing}) async {
    final type = existing?.valueType ??
        await showDialog<CustomFieldValueType>(
          context: context,
          builder: (context) => const CustomFieldTypePicker(),
        );
    if (type == null || !mounted) return;
    final display = existing == null
        ? const CustomFieldDisplaySettings()
        : await CustomFieldDisplaySettings.read(existing.id);
    if (!mounted) return;
    final all = await _repo.listDefinitions();
    if (!mounted) return;
    final nextOrder = all.fold<int>(
        0,
        (value, definition) =>
            definition.sortOrder >= value ? definition.sortOrder + 1 : value);
    final result = await showDialog<CustomFieldEditorResult>(
      context: context,
      builder: (context) => CustomFieldEditorDialog(
          existing: existing,
          initialType: type,
          initialMediaKind: widget.mediaKind,
          initialDisplay: display,
          sortOrder: nextOrder),
    );
    if (result != null) {
      await _repo.upsertDefinition(result.definition);
      await result.display.save(result.definition.id);
      _invalidate();
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
      await CustomFieldDisplaySettings.delete(def.id);
      _invalidate();
      await _reload();
    }
  }

  void _invalidate() {
    final container = ProviderScope.containerOf(context, listen: false);
    container.invalidate(libraryCustomFieldCacheProvider);
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
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 640;
              final kindLabel = _mediaKindLabel(definition.mediaKind);
              const scopeLabel = 'Library item';
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
                        style:
                            TextStyle(color: palette.textMuted, fontSize: 13),
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
                                fontSize: 13,
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
  for (final type in defaultLibraryKindRegistry.allKinds) {
    if (type.kind.apiValue == normalized) {
      return type.identity.singularLabel;
    }
  }
  return kind.trim();
}
