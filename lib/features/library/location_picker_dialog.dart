import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/entries/repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_values_table.dart';
import 'package:collectarr_app/features/settings/location_management_dialog.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Returns the chosen location's id, an empty string for no location, or null
/// when closed without choosing.
Future<String?> showLocationPickerDialog({
  required BuildContext context,
  required LocalDatabase db,
  String? currentLocationId,
}) {
  return showAppDialog<String?>(
    context: context,
    builder: (context) => LocationPickerDialog(
      db: db,
      currentLocationId: currentLocationId,
    ),
  );
}

String? locationPathForId(
  List<StorageLocation> allLocations,
  String? locationId,
) {
  if (locationId == null) {
    return null;
  }
  final location = allLocations
      .cast<StorageLocation?>()
      .firstWhere((entry) => entry?.id == locationId, orElse: () => null);
  return location?.fullPath(allLocations);
}

/// The pick list panel for the shared Location tree: each row names its full
/// path, so nested locations stay apart and sort under their parents.
class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({
    super.key,
    required this.db,
    this.currentLocationId,
  });

  final LocalDatabase db;
  final String? currentLocationId;

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final _search = TextEditingController();
  List<StorageLocation> _locations = const [];
  Map<String, int> _counts = const {};
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final locations = await LocationRepository(widget.db).getAll();
    final counts = <String, int>{};
    for (final entry
        in await LibraryEntriesRepository(widget.db).listActiveSummaries()) {
      final id = entry.locationId;
      if (id != null) counts.update(id, (n) => n + 1, ifAbsent: () => 1);
    }
    if (!mounted) return;
    setState(() {
      _locations = locations;
      _counts = counts;
      _busy = false;
    });
  }

  Future<void> _create() async {
    final created = await showAppDialog<({String name, String? parentId})>(
      context: context,
      builder: (_) => _NewLocationDialog(locations: _locations),
    );
    if (created == null) return;
    await LocationRepository(widget.db)
        .create(name: created.name, parentId: created.parentId);
    await _load();
  }

  Future<void> _manage() async {
    await showLocationManagementDialog(context: context, db: widget.db);
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
                          title: 'Select Location',
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
                          trailing: Wrap(spacing: 5, runSpacing: 6, children: [
                            FilledButton(
                                onPressed: _busy ? null : _create,
                                style: pickListButtonStyle(context),
                                child: const Text('New Location')),
                            FilledButton(
                                onPressed: _busy ? null : _manage,
                                style: pickListButtonStyle(context,
                                    primary: false),
                                child: const Text('Manage Locations')),
                          ])),
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
                                      selectedIds: {
                                        if (widget.currentLocationId
                                            case final id?)
                                          id
                                      },
                                      mode: PickListTableMode.singleSelect,
                                      onSelect: (value) =>
                                          Navigator.pop(context, value.id)))),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FilledButton(
                                    style: pickListButtonStyle(context,
                                        primary: false, footer: true),
                                    onPressed: () => Navigator.pop(context, ''),
                                    child: const Text('No Location')),
                              ])),
                    ]))));
  }
}

/// A new location's name and where it sits in the tree.
class _NewLocationDialog extends StatefulWidget {
  const _NewLocationDialog({required this.locations});

  final List<StorageLocation> locations;

  @override
  State<_NewLocationDialog> createState() => _NewLocationDialogState();
}

class _NewLocationDialogState extends State<_NewLocationDialog> {
  static const _topLevel = '';
  final _name = TextEditingController();
  String _parentId = _topLevel;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a name.');
      return;
    }
    Navigator.pop(context, (
      name: name,
      parentId: _parentId == _topLevel ? null : _parentId,
    ));
  }

  String _parentLabel(String id) {
    if (id == _topLevel) return 'Top level';
    return locationPathForId(widget.locations, id) ?? id;
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
                    title: 'New Location',
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
                                  values: [
                                    _topLevel,
                                    for (final location in widget.locations)
                                      location.id
                                  ],
                                  labelOf: _parentLabel,
                                  onChanged: (id) =>
                                      setState(() => _parentId = id))),
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
