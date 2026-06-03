import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryBulkEditSelection {
  const LibraryBulkEditSelection({
    this.condition,
    this.grade,
    this.applyLocation = false,
    this.locationId,
    this.tags,
    this.readStatus,
    this.rating,
  });

  final String? condition;
  final String? grade;
  final bool applyLocation;
  final String? locationId;
  final String? tags;
  final String? readStatus;
  final int? rating;
}

class LibraryBulkEditDialog extends ConsumerStatefulWidget {
  const LibraryBulkEditDialog({
    super.key,
    required this.type,
    required this.selectedCount,
  });

  final LibraryTypeConfig type;
  final int selectedCount;

  @override
  ConsumerState<LibraryBulkEditDialog> createState() =>
      _LibraryBulkEditDialogState();
}

class _LibraryBulkEditDialogState extends ConsumerState<LibraryBulkEditDialog> {
  String? _condition;
  String? _grade;
  String? _readStatus;
  int? _rating;
  final _tagsController = TextEditingController();
  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _tagOptions = const [];
  bool _applyLocation = false;
  String? _locationId;

  @override
  void initState() {
    super.initState();
    _conditionOptions = widget.type.conditions;
    _gradeOptions = widget.type.grades;
    _loadAvailableLocations();
    _loadPickListOptions();
  }

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final trackingOptions = widget.type.trackingProfile.options;
    final conditions = _conditionOptions;
    final grades = _gradeOptions;
    return AccentAlertDialog(
      title: Text('Bulk edit (${widget.selectedCount} items)'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            if (conditions.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _condition,
                dropdownColor: palette.panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                      value: '', child: Text('Keep current')),
                  for (final option in conditions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  setState(
                    () => _condition =
                        value == null || value.isEmpty ? null : value,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            if (grades.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: _grade,
                dropdownColor: palette.panelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                      value: '', child: Text('Keep current')),
                  for (final option in grades)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  setState(
                    () =>
                        _grade = value == null || value.isEmpty ? null : value,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            _locationField(),
            const SizedBox(height: 12),
            TagPickListField(
              controller: _tagsController,
              options: _tagOptions,
              label: 'Tags',
              hint: 'Leave blank to keep current',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _readStatus,
              dropdownColor: palette.panelRaised,
              borderRadius: kAppMenuBorderRadius,
              decoration: const InputDecoration(
                labelText: 'Tracking status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Keep current')),
                for (final option in trackingOptions)
                  DropdownMenuItem(
                    value: option.storageValue,
                    child: Text(option.label),
                  ),
              ],
              onChanged: (value) {
                setState(() => _readStatus =
                    value == null || value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _rating,
              dropdownColor: palette.panelRaised,
              borderRadius: kAppMenuBorderRadius,
              decoration: const InputDecoration(
                labelText: 'Rating',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: -1, child: Text('Keep current')),
                const DropdownMenuItem(value: 0, child: Text('No rating')),
                for (var i = 1; i <= 5; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text('${'★' * i}${'☆' * (5 - i)}'),
                  ),
              ],
              onChanged: (value) {
                setState(
                    () => _rating = value == null || value == -1 ? null : value);
              },
            ),
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
          onPressed: () => Navigator.of(context).pop(
            LibraryBulkEditSelection(
              condition: _condition,
              grade: _grade,
              applyLocation: _applyLocation,
              locationId: _locationId,
              tags: _emptyToNull(_tagsController.text),
              readStatus: _readStatus,
              rating: _rating,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() => _availableLocations = locations);
  }

  Future<void> _loadPickListOptions() async {
    final options = await loadConditionGradePickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInConditions: widget.type.conditions,
      builtInGrades: widget.type.grades,
      selectedCondition: _condition,
      selectedGrade: _grade,
    );
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_tagsController.text),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _conditionOptions = options.conditions;
      _gradeOptions = options.grades;
      _tagOptions = tagOptions;
    });
  }

  Widget _locationField() {
    final summary = !_applyLocation
        ? 'Keep current location'
        : locationPathForId(_availableLocations, _locationId) ?? 'Clear location';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _pickLocation,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.place),
            ),
            child: Text(
              summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: !_applyLocation ? appPalette(context).textMuted : null,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _applyLocation = false;
                  _locationId = null;
                });
              },
              child: const Text('Keep current'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _applyLocation = true;
                  _locationId = null;
                });
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _locationId,
    );
    if (result == null) {
      return;
    }
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _applyLocation = true;
      _locationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }
}
