import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';

Future<String?> showLocationPickerDialog({
  required BuildContext context,
  required LocalDatabase db,
  String? currentLocationId,
}) {
  return showDialog<String?>(
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
  List<StorageLocation> _locations = const [];
  String? _selectedId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentLocationId;
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locations = await LocationRepository(widget.db).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _locations = locations;
      _loading = false;
    });
  }

  Future<void> _addLocation() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kClzPanel,
        title: const Text('New Location'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Living Room Shelf',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) {
      return;
    }
    final created = await LocationRepository(widget.db).create(name: result);
    await _loadLocations();
    if (!mounted) {
      return;
    }
    setState(() => _selectedId = created.id);
  }

  @override
  Widget build(BuildContext context) {
    final roots = _locations.where((location) => location.parentId == null).toList();
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _locations.isEmpty
                ? Center(
                    child: Text(
                      'No locations yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kClzTextMuted),
                    ),
                  )
                : RadioGroup<String?>(
                    groupValue: _selectedId,
                    onChanged: (value) => setState(() => _selectedId = value),
                    child: ListView(
                      children: [
                        const RadioListTile<String?>(
                          title: Text('None'),
                          value: null,
                          dense: true,
                        ),
                        ...roots.map(
                          (location) => _buildLocationTile(location, depth: 0),
                        ),
                      ],
                    ),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedId ?? ''),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildLocationTile(StorageLocation location, {required int depth}) {
    final children = _locations.where((entry) => entry.parentId == location.id).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: RadioListTile<String?>(
            title: Text(location.name),
            subtitle:
                location.description != null ? Text(location.description!) : null,
            value: location.id,
            dense: true,
          ),
        ),
        ...children.map(
          (child) => _buildLocationTile(child, depth: depth + 1),
        ),
      ],
    );
  }
}