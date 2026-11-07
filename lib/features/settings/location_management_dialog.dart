import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_values_table.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_message_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showLocationManagementDialog({
  required BuildContext context,
  required LocalDatabase db,
  bool startCreating = false,
}) {
  return showAppDialog<void>(
    context: context,
    builder: (context) => LocationManagementDialog(
      db: db,
      startCreating: startCreating,
    ),
  );
}

/// What the location editor returns.
typedef LocationDraft = ({String name, String? parentId, String? description});

/// Asks for a location's name, place in the tree and description.
Future<LocationDraft?> showLocationEditorDialog({
  required BuildContext context,
  required List<StorageLocation> locations,
  StorageLocation? existing,
}) =>
    showAppDialog<LocationDraft>(
      context: context,
      builder: (_) => _LocationEditorDialog(
        locations: locations,
        existing: existing,
      ),
    );

/// Every location in the shared tree, as a pick list table: each row names
/// its full path, with its item count, and edits or removes that location.
class LocationManagementDialog extends StatefulWidget {
  const LocationManagementDialog({
    super.key,
    required this.db,
    this.startCreating = false,
  });

  final LocalDatabase db;
  final bool startCreating;

  @override
  State<LocationManagementDialog> createState() =>
      _LocationManagementDialogState();
}

class _LocationManagementDialogState extends State<LocationManagementDialog> {
  final _search = TextEditingController();
  List<StorageLocation> _locations = const [];
  Map<String, int> _counts = const {};
  bool _busy = true;

  LocationRepository get _repository => LocationRepository(widget.db);

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    await _load();
    if (widget.startCreating && mounted) await _create();
  }

  Future<void> _load() async {
    final locations = await _repository.getAll();
    final counts = await _repository.itemCounts();
    if (!mounted) return;
    setState(() {
      _locations = locations;
      _counts = counts;
      _busy = false;
    });
  }

  Future<void> _create() async {
    final draft =
        await showLocationEditorDialog(context: context, locations: _locations);
    if (draft == null) return;
    await _repository.create(
        name: draft.name,
        parentId: draft.parentId,
        description: draft.description);
    await _load();
  }

  StorageLocation _locationOf(PickListValue value) =>
      _locations.firstWhere((location) => location.id == value.id);

  Future<void> _edit(PickListValue value) async {
    final location = _locationOf(value);
    final draft = await showLocationEditorDialog(
        context: context, locations: _locations, existing: location);
    if (draft == null) return;
    await _repository.update(StorageLocation(
      id: location.id,
      name: draft.name,
      parentId: draft.parentId,
      description: draft.description,
      sortOrder: location.sortOrder,
    ));
    await _load();
  }

  Future<void> _delete(PickListValue value) async {
    final confirmed = await showAppMessageDialog(
      context: context,
      title: 'Delete location',
      message: 'Delete "${value.effectiveLabel}"? Its children become '
          'top-level locations and items assigned directly to it are cleared.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;
    await _repository.delete(value.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizePickListValue(_search.text);
    final visible = [
      for (final location in _locations)
        PickListValue(
            id: location.id,
            listName: 'locations',
            value: location.name,
            displayLabel: location.fullPath(_locations))
    ]
        .where((value) =>
            normalizePickListValue(value.effectiveLabel).contains(query))
        .toList();
    return PickListDialog(
        child: Material(
            color: pickListSurface(context),
            child: DefaultTextStyle.merge(
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PickListHeader(
                          title: 'Manage Locations',
                          onClose: () => Navigator.pop(context)),
                      PickListToolbar(
                          search: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: pickListInputDecoration(context,
                                  hintText: 'Search...',
                                  suffixIcon: IconButton(
                                      style: IconButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          side: BorderSide.none),
                                      padding: EdgeInsets.zero,
                                      iconSize: 16,
                                      color: appPalette(context)
                                          .textMuted
                                          .withValues(alpha: .65),
                                      icon: Icon(query.isEmpty
                                          ? Icons.search
                                          : Icons.close),
                                      onPressed: () =>
                                          setState(() => _search.clear())))),
                          trailing: FilledButton(
                              onPressed: _busy ? null : _create,
                              style: pickListButtonStyle(context),
                              child: const Text('New Location'))),
                      Flexible(
                          fit: FlexFit.loose,
                          child: SizedBox(
                              height: math.max(visible.length, 1) * 48.0 + 48,
                              child: _busy
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : PickListValuesTable(
                                      values: visible,
                                      usageCounts: _counts,
                                      showSortName: false,
                                      onEdit: _edit,
                                      onDelete: _delete))),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton(
                                    style: pickListButtonStyle(context,
                                        primary: false, footer: true),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close')),
                              ])),
                    ]))));
  }
}

class _LocationEditorDialog extends StatefulWidget {
  const _LocationEditorDialog({required this.locations, this.existing});

  final List<StorageLocation> locations;
  final StorageLocation? existing;

  @override
  State<_LocationEditorDialog> createState() => _LocationEditorDialogState();
}

class _LocationEditorDialogState extends State<_LocationEditorDialog> {
  static const _topLevel = '';
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late String _parentId = widget.existing?.parentId ?? _topLevel;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  /// A location cannot move under itself or anything nested in it.
  List<String> get _parentChoices {
    final blocked = <String>{};
    void block(String id) {
      if (!blocked.add(id)) return;
      for (final child in widget.locations.where((l) => l.parentId == id)) {
        block(child.id);
      }
    }

    if (widget.existing case final existing?) block(existing.id);
    return [
      _topLevel,
      for (final location in widget.locations)
        if (!blocked.contains(location.id)) location.id
    ];
  }

  String _parentLabel(String id) {
    if (id == _topLevel) return 'Top level';
    return widget.locations
        .firstWhere((location) => location.id == id)
        .fullPath(widget.locations);
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a name.');
      return;
    }
    final description = _description.text.trim();
    Navigator.pop<LocationDraft>(context, (
      name: name,
      parentId: _parentId == _topLevel ? null : _parentId,
      description: description.isEmpty ? null : description,
    ));
  }

  Widget _labeled(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ]),
      );

  @override
  Widget build(BuildContext context) => PickListDialog(
      child: Material(
          color: pickListSurface(context),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PickListHeader(
                    title: widget.existing == null
                        ? 'New Location'
                        : 'Edit Location',
                    onClose: () => Navigator.pop(context)),
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _labeled(
                              'Name',
                              TextField(
                                  controller: _name,
                                  autofocus: true,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submit(),
                                  decoration: settingsSelectDecoration(context)
                                      .copyWith(errorText: _nameError))),
                          _labeled(
                              'Parent',
                              SettingsSelect<String>(
                                  value: _parentId,
                                  values: _parentChoices,
                                  labelOf: _parentLabel,
                                  onChanged: (id) =>
                                      setState(() => _parentId = id))),
                          _labeled(
                              'Description',
                              TextField(
                                  controller: _description,
                                  minLines: 3,
                                  maxLines: 4,
                                  decoration:
                                      settingsSelectDecoration(context))),
                        ])),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                              style: pickListButtonStyle(context,
                                  primary: false, footer: true),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          const SizedBox(width: 5),
                          FilledButton(
                              style: pickListButtonStyle(context, footer: true),
                              onPressed: _submit,
                              child: const Text('Save')),
                        ])),
              ])));
}
