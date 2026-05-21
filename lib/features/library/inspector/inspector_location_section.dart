import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';

class InspectorLocationSection extends StatefulWidget {
  const InspectorLocationSection({
    super.key,
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  @override
  State<InspectorLocationSection> createState() =>
      _InspectorLocationSectionState();
}

class _InspectorLocationSectionState extends State<InspectorLocationSection> {
  List<StorageLocation> _allLocations = [];
  String? _currentLocationId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = LocationRepository(widget.db);
    final all = await repo.getAll();
    final currentId = await repo.getItemLocationId(widget.ownedItemId);
    if (mounted) {
      setState(() {
        _allLocations = all;
        _currentLocationId = currentId;
        _loading = false;
      });
    }
  }

  Future<void> _pickLocation() async {
    final repo = LocationRepository(widget.db);
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => _LocationPickerDialog(
        allLocations: _allLocations,
        currentLocationId: _currentLocationId,
        db: widget.db,
      ),
    );
    if (result != null || result != _currentLocationId) {
      // result may be empty string to clear
      final newId = (result != null && result.isEmpty) ? null : result;
      await repo.assignItemToLocation(widget.ownedItemId, newId);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    final current = _currentLocationId != null
        ? _allLocations
            .cast<StorageLocation?>()
            .firstWhere((l) => l!.id == _currentLocationId, orElse: () => null)
        : null;

    return LibraryInspectorSection(
      title: 'Location',
      accentColor: widget.accent,
      children: [
        InkWell(
          onTap: _pickLocation,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              children: [
                Icon(
                  Icons.place,
                  size: 16,
                  color: current != null ? widget.accent : kClzTextMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    current != null
                        ? current.fullPath(_allLocations)
                        : 'No location assigned',
                    style: TextStyle(
                      color: current != null ? Colors.white : kClzTextMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit,
                  size: 14,
                  color: kClzTextMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPickerDialog extends StatefulWidget {
  const _LocationPickerDialog({
    required this.allLocations,
    required this.currentLocationId,
    required this.db,
  });

  final List<StorageLocation> allLocations;
  final String? currentLocationId;
  final LocalDatabase db;

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late List<StorageLocation> _locations;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _locations = List.of(widget.allLocations);
    _selectedId = widget.currentLocationId;
  }

  Future<void> _addLocation() async {
    final nameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kClzPanel,
        title: const Text('New Location'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Living Room Shelf',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final repo = LocationRepository(widget.db);
      final loc = await repo.create(name: result);
      setState(() {
        _locations.add(loc);
        _selectedId = loc.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build tree structure: roots then children
    final roots =
        _locations.where((l) => l.parentId == null).toList();

    return AlertDialog(
      backgroundColor: kClzPanel,
      title: Row(
        children: [
          const Expanded(child: Text('Assign Location')),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'New location',
            onPressed: _addLocation,
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        height: 300,
        child: _locations.isEmpty
            ? Center(
                child: Text(
                  'No locations yet.\nTap + to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kClzTextMuted),
                ),
              )
            : ListView(
                children: [
                  // "None" option to clear
                  RadioListTile<String?>(
                    title: const Text('None'),
                    value: null,
                    groupValue: _selectedId,
                    onChanged: (v) => setState(() => _selectedId = v),
                    dense: true,
                  ),
                  ...roots.map((loc) => _buildLocationTile(loc, 0)),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, _selectedId ?? ''),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildLocationTile(StorageLocation loc, int depth) {
    final children =
        _locations.where((l) => l.parentId == loc.id).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: RadioListTile<String?>(
            title: Text(loc.name),
            subtitle:
                loc.description != null ? Text(loc.description!) : null,
            value: loc.id,
            groupValue: _selectedId,
            onChanged: (v) => setState(() => _selectedId = v),
            dense: true,
          ),
        ),
        ...children.map((c) => _buildLocationTile(c, depth + 1)),
      ],
    );
  }
}
