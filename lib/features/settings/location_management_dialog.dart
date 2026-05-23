import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showLocationManagementDialog({
  required BuildContext context,
  required LocalDatabase db,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => LocationManagementDialog(db: db),
  );
}

class LocationManagementDialog extends StatefulWidget {
  const LocationManagementDialog({
    super.key,
    required this.db,
  });

  final LocalDatabase db;

  @override
  State<LocationManagementDialog> createState() =>
      _LocationManagementDialogState();
}

class _LocationManagementDialogState extends State<LocationManagementDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<StorageLocation> _locations = const [];
  String? _selectedLocationId;
  String? _draftParentId;
  bool _creating = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleDraftChanged);
    _descriptionController.addListener(_handleDraftChanged);
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleDraftChanged);
    _descriptionController.removeListener(_handleDraftChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleDraftChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  StorageLocation? get _selectedLocation {
    final selectedId = _selectedLocationId;
    if (selectedId == null) {
      return null;
    }
    return _locations.cast<StorageLocation?>().firstWhere(
          (location) => location?.id == selectedId,
          orElse: () => null,
        );
  }

  Future<void> _loadLocations() async {
    final locations = await LocationRepository(widget.db).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _locations = locations;
      _loading = false;
      if (_selectedLocationId != null &&
          locations.every((location) => location.id != _selectedLocationId)) {
        _selectedLocationId = null;
      }
    });
  }

  void _selectLocation(StorageLocation location) {
    setState(() {
      _creating = false;
      _selectedLocationId = location.id;
      _draftParentId = location.parentId;
      _nameController.text = location.name;
      _descriptionController.text = location.description ?? '';
    });
  }

  void _beginCreate({String? parentId}) {
    setState(() {
      _creating = true;
      _selectedLocationId = null;
      _draftParentId = parentId;
      _nameController.clear();
      _descriptionController.clear();
    });
  }

  Set<String> _descendantIds(String id) {
    final descendants = <String>{};
    void collect(String currentId) {
      for (final child in _locations.where((location) => location.parentId == currentId)) {
        if (descendants.add(child.id)) {
          collect(child.id);
        }
      }
    }

    collect(id);
    return descendants;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) {
      return;
    }
    final repo = LocationRepository(widget.db);
    setState(() => _saving = true);
    try {
      if (_creating) {
        final created = await repo.create(
          name: name,
          parentId: _draftParentId,
          description: description.isEmpty ? null : description,
        );
        await _loadLocations();
        if (!mounted) {
          return;
        }
        _selectLocation(created);
      } else {
        final selected = _selectedLocation;
        if (selected == null) {
          return;
        }
        final updated = StorageLocation(
          id: selected.id,
          name: name,
          parentId: _draftParentId,
          description: description.isEmpty ? null : description,
          sortOrder: selected.sortOrder,
        );
        await repo.update(updated);
        await _loadLocations();
        if (!mounted) {
          return;
        }
        _selectLocation(updated);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deleteSelected() async {
    final selected = _selectedLocation;
    if (selected == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kAppPanel,
        title: const Text('Delete location'),
        content: Text(
          'Delete "${selected.fullPath(_locations)}"? Children will become top-level locations and items assigned directly to this location will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await LocationRepository(widget.db).delete(selected.id);
    await _loadLocations();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLocationId = null;
      _creating = false;
      _nameController.clear();
      _descriptionController.clear();
      _draftParentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedLocation;
    final roots = _locations.where((location) => location.parentId == null).toList();
    final blockedParentIds = selected == null ? const <String>{} : _descendantIds(selected.id);
    final parentChoices = [
      for (final location in _locations)
        if (selected == null || (location.id != selected.id && !blockedParentIds.contains(location.id)))
          location,
    ];

    return AlertDialog(
      backgroundColor: kAppPanel,
      title: const Text('Manage locations'),
      content: SizedBox(
        width: 920,
        height: 520,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _beginCreate(),
                              icon: const Icon(Icons.add_outlined),
                              label: const Text('New root'),
                            ),
                            OutlinedButton.icon(
                              onPressed: selected == null
                                  ? null
                                  : () => _beginCreate(parentId: selected.id),
                              icon: const Icon(Icons.subdirectory_arrow_right),
                              label: const Text('New child'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kAppDivider),
                            ),
                            child: _locations.isEmpty
                                ? Center(
                                    child: Text(
                                      'No locations yet. Create a root location to start the hierarchy.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: kAppTextMuted),
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.all(12),
                                    children: [
                                      for (final root in roots)
                                        _LocationListTile(
                                          location: root,
                                          allLocations: _locations,
                                          selectedId: _selectedLocationId,
                                          onSelected: _selectLocation,
                                          depth: 0,
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kAppDivider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _creating || selected != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    Expanded(
                                      child: ListView(
                                        children: [
                                          Text(
                                            _creating ? 'New location' : 'Edit location',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Location name',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          DropdownButtonFormField<String?>(
                                            key: ValueKey(
                                              'parent-${_selectedLocationId ?? 'new'}-${_draftParentId ?? 'root'}',
                                            ),
                                            initialValue: _draftParentId,
                                            dropdownColor: kAppPanelRaised,
                                            borderRadius: kAppMenuBorderRadius,
                                            decoration: const InputDecoration(
                                              labelText: 'Parent location',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: [
                                              const DropdownMenuItem<String?>(
                                                value: null,
                                                child: Text('Top level'),
                                              ),
                                              for (final location in parentChoices)
                                                DropdownMenuItem<String?>(
                                                  value: location.id,
                                                  child: Text(location.fullPath(_locations)),
                                                ),
                                            ],
                                            onChanged: (value) {
                                              setState(() => _draftParentId = value);
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _descriptionController,
                                            minLines: 3,
                                            maxLines: 4,
                                            decoration: const InputDecoration(
                                              labelText: 'Description',
                                              alignLabelWithHint: true,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _creating
                                                ? 'Create a reusable location that can be assigned across add, edit, and bulk flows.'
                                                : 'Renaming or reparenting updates the hierarchy label everywhere this location id is resolved.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: kAppTextMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      if (!_creating)
                                        OutlinedButton.icon(
                                          onPressed: _saving ? null : _deleteSelected,
                                          icon: const Icon(Icons.delete_outline),
                                          label: const Text('Delete location'),
                                        ),
                                      FilledButton.icon(
                                        onPressed: _saving ||
                                                _nameController.text.trim().isEmpty
                                            ? null
                                            : _save,
                                        icon: _saving
                                            ? const SizedBox.square(
                                                dimension: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Icon(_creating
                                                ? Icons.add_task_outlined
                                                : Icons.save_outlined),
                                        label: Text(
                                          _creating ? 'Create location' : 'Save changes',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  'Select a location to edit it, or create a new root or child location.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: kAppTextMuted),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _LocationListTile extends StatelessWidget {
  const _LocationListTile({
    required this.location,
    required this.allLocations,
    required this.selectedId,
    required this.onSelected,
    required this.depth,
  });

  final StorageLocation location;
  final List<StorageLocation> allLocations;
  final String? selectedId;
  final ValueChanged<StorageLocation> onSelected;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final children = allLocations.where((entry) => entry.parentId == location.id).toList();
    final selected = selectedId == location.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              selected: selected,
              selectedTileColor: Colors.white.withValues(alpha: 0.06),
              leading: Icon(
                depth == 0
                    ? Icons.folder_outlined
                    : Icons.subdirectory_arrow_right,
                size: 18,
              ),
              title: Text(location.name),
              subtitle: Text(location.fullPath(allLocations)),
              onTap: () => onSelected(location),
            ),
          ),
        ),
        for (final child in children)
          _LocationListTile(
            location: child,
            allLocations: allLocations,
            selectedId: selectedId,
            onSelected: onSelected,
            depth: depth + 1,
          ),
      ],
    );
  }
}