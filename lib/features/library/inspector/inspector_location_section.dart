import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    if (result == null) {
      return;
    }
    // result may be empty string to clear
    final newId = result.isEmpty ? null : result;
    if (newId == _currentLocationId) {
      return;
    }
    await repo.assignItemToLocation(widget.ownedItemId, newId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;

    final current = _currentLocationId != null
        ? _allLocations
            .cast<StorageLocation?>()
            .firstWhere((l) => l!.id == _currentLocationId, orElse: () => null)
        : null;

    return LibraryInspectorSection(
      title: 'Location',
      accentColor: widget.accent,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickLocation,
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surfaceSubtle.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: palette.divider.withValues(alpha: 0.8)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (current != null ? widget.accent : palette.textMuted)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        Icons.place,
                        size: 16,
                        color: current != null ? widget.accent : palette.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current != null
                                ? current.fullPath(_allLocations)
                                : 'No location assigned',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: current != null ? null : palette.textMuted,
                                  fontWeight: current != null ? FontWeight.w600 : null,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            current != null
                                ? 'Tap to change or clear this assignment'
                                : 'Tap to assign a storage location',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: palette.textMuted,
                    ),
                  ],
                ),
              ),
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
        backgroundColor: appPalette(ctx).panel,
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
    final palette = appPalette(context);
    // Build tree structure: roots then children
    final roots =
        _locations.where((l) => l.parentId == null).toList();

    return AlertDialog(
      backgroundColor: palette.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        height: _locations.isEmpty ? null : 300,
        child: _locations.isEmpty
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withValues(alpha: 0.82),
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kAppAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(Icons.place_outlined, color: kAppAccent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No locations yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create a location first so this item can be assigned without leaving the dialog.',
                        style: TextStyle(color: palette.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: _addLocation,
                          icon: const Icon(Icons.add),
                          label: const Text('Create first location'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Material(
                color: palette.surfaceSubtle.withValues(alpha: 0.64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: palette.divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: RadioGroup<String?>(
                  groupValue: _selectedId,
                  onChanged: (value) => setState(() => _selectedId = value),
                  child: ListView(
                    children: [
                      RadioListTile<String?>(
                        title: const Text('None'),
                        subtitle: const Text('Clear the current location'),
                        value: null,
                        dense: true,
                      ),
                      ...roots.map((loc) => _buildLocationTile(loc, 0)),
                    ],
                  ),
                ),
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
            dense: true,
            secondary: depth == 0
                ? const Icon(Icons.folder_open_outlined, size: 18)
                : const Icon(Icons.subdirectory_arrow_right, size: 16),
          ),
        ),
        ...children.map((c) => _buildLocationTile(c, depth + 1)),
      ],
    );
  }
}
