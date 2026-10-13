import 'package:collectarr_app/features/library/inspector/inspector_custom_fields_section.dart';
import 'package:collectarr_app/features/settings/custom_field_editor_dialog.dart';
import 'package:collectarr_app/features/settings/custom_fields_tab_settings_dialog.dart';
import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/features/settings/custom_field_dialog.dart';
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
        svgAsset: AppIcons.customFieldsSvg,
        backgroundColor: appManagementCanvasColor(context),
        accent: accent ?? appPalette(context).accent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 18, 15, 24),
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
    if (mounted) {
      setState(() => _display = result);
      _invalidate();
    }
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
          padding: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: appPalette(context).divider))),
          child: Row(children: [
            Expanded(
                child: Text(_display.tabName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700))),
            IconButton(
                tooltip: 'Custom Fields help',
                onPressed: _showHelp,
                icon: const Icon(AppIcons.customFieldHelp, size: 16)),
            IconButton(
                tooltip: 'Custom Fields settings',
                onPressed: _configureTab,
                icon: const Icon(AppIcons.settings, size: 16)),
          ]),
        ),
        if (_definitions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 2),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('You do not have any Custom Fields yet.',
                  style: TextStyle(fontSize: 14)),
              InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: _showHelp,
                  child: Text('Read about Custom Fields before adding them.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary))),
            ]),
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
          style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 32),
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          onPressed: () => _showEditor(),
          icon: const Icon(AppIcons.add, size: 14),
          label: const Text('Add Custom Field'),
        ),
      ],
    );
  }

  void _showHelp() => showDialog<void>(
      context: context,
      builder: (_) => CustomFieldDialog(
          title: 'Custom Fields',
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ],
          child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                  'Custom Fields store your own information on collection items. Choose a field type, give it a name and try its preview.\n\n'
                  'Pick Lists let you manage values later. Fixed Button Bar and Fixed List values are locked after creation.\n\n'
                  'Use the drag handles to reorder fields. Tab settings control the name and visibility in the edit screen.\n\n'
                  'Deleting a field permanently removes its saved values.'))));

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
        headerIcon: AppIcons.delete,
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
    invalidateInspectorCustomFields(container);
  }
}

class _DefinitionTile extends StatefulWidget {
  const _DefinitionTile(
      {super.key,
      required this.definition,
      required this.index,
      required this.onEdit,
      required this.onDelete});
  final CustomFieldDefinition definition;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  State<_DefinitionTile> createState() => _DefinitionTileState();
}

class _DefinitionTileState extends State<_DefinitionTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleByDouble(_hovered ? 1.015 : 1, _hovered ? 1.015 : 1, 1, 1)
            ..rotateZ(_hovered ? .0087266 : 0),
          decoration: BoxDecoration(
              color: appManagementCanvasColor(context),
              boxShadow: [
                if (_hovered)
                  BoxShadow(color: palette.divider, offset: const Offset(2, 2))
              ]),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            ReorderableDragStartListener(
                index: widget.index,
                child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(AppIcons.customFieldDrag,
                        size: 16, color: palette.textMuted))),
            const SizedBox(width: 10),
            CustomFieldTypeIcon(type: widget.definition.valueType, size: 26),
            const SizedBox(width: 15),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.definition.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(widget.definition.valueTypeLabel,
                      style: TextStyle(fontSize: 13, color: palette.textMuted)),
                ])),
            IconButton(
                tooltip: 'Edit',
                onPressed: widget.onEdit,
                icon: const Icon(AppIcons.edit, size: 16)),
            IconButton(
                tooltip: 'Delete',
                onPressed: widget.onDelete,
                icon: const Icon(AppIcons.delete, size: 16)),
          ])),
    );
  }
}
