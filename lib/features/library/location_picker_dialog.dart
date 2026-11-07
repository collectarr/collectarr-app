import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_values_table.dart';
import 'package:collectarr_app/features/settings/location_management_dialog.dart';
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
    final repository = LocationRepository(widget.db);
    final locations = await repository.getAll();
    final counts = await repository.itemCounts();
    if (!mounted) return;
    setState(() {
      _locations = locations;
      _counts = counts;
      _busy = false;
    });
  }

  Future<void> _create() async {
    final created =
        await showLocationEditorDialog(context: context, locations: _locations);
    if (created == null) return;
    await LocationRepository(widget.db).create(
        name: created.name,
        parentId: created.parentId,
        description: created.description);
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
