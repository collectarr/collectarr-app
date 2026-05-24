import 'dart:convert';

import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Ownership filter options used in the generic filter dialog.
enum LibraryOwnershipFilter { all, owned, wishlist, missingGrade }

String libraryOwnershipFilterLabel(LibraryOwnershipFilter filter) {
  return switch (filter) {
    LibraryOwnershipFilter.all => 'All items',
    LibraryOwnershipFilter.owned => 'Owned only',
    LibraryOwnershipFilter.wishlist => 'Wishlist only',
    LibraryOwnershipFilter.missingGrade => 'Missing grade',
  };
}

enum LibraryTrackingStatusFilter {
  all,
  notTracked,
  planned,
  inProgress,
  completed,
  paused,
  dropped,
  repeating,
}

String libraryTrackingStatusFilterLabel(LibraryTrackingStatusFilter filter) {
  return switch (filter) {
    LibraryTrackingStatusFilter.all => 'Any tracking status',
    LibraryTrackingStatusFilter.notTracked => 'Not tracked',
    LibraryTrackingStatusFilter.planned => MediaTrackingStatus.planned.label,
    LibraryTrackingStatusFilter.inProgress =>
      MediaTrackingStatus.inProgress.label,
    LibraryTrackingStatusFilter.completed =>
      MediaTrackingStatus.completed.label,
    LibraryTrackingStatusFilter.paused => MediaTrackingStatus.paused.label,
    LibraryTrackingStatusFilter.dropped => MediaTrackingStatus.dropped.label,
    LibraryTrackingStatusFilter.repeating =>
      MediaTrackingStatus.repeating.label,
  };
}

bool libraryTrackingStatusMatchesFilter(
  MediaTrackingStatus status,
  LibraryTrackingStatusFilter filter,
) {
  return switch (filter) {
    LibraryTrackingStatusFilter.all => true,
    LibraryTrackingStatusFilter.notTracked =>
      status == MediaTrackingStatus.none,
    LibraryTrackingStatusFilter.planned =>
      status == MediaTrackingStatus.planned,
    LibraryTrackingStatusFilter.inProgress =>
      status == MediaTrackingStatus.inProgress,
    LibraryTrackingStatusFilter.completed =>
      status == MediaTrackingStatus.completed,
    LibraryTrackingStatusFilter.paused =>
      status == MediaTrackingStatus.paused,
    LibraryTrackingStatusFilter.dropped =>
      status == MediaTrackingStatus.dropped,
    LibraryTrackingStatusFilter.repeating =>
      status == MediaTrackingStatus.repeating,
  };
}

enum LibraryLoanStatusFilter { all, onLoan, available }

String libraryLoanStatusFilterLabel(LibraryLoanStatusFilter filter) {
  return switch (filter) {
    LibraryLoanStatusFilter.all => 'Any loan status',
    LibraryLoanStatusFilter.onLoan => 'Currently on loan',
    LibraryLoanStatusFilter.available => 'Available locally',
  };
}

enum LibraryDateRangeField { updated, purchased, started, finished }

String libraryDateRangeFieldLabel(LibraryDateRangeField field) {
  return switch (field) {
    LibraryDateRangeField.updated => 'Updated',
    LibraryDateRangeField.purchased => 'Purchased',
    LibraryDateRangeField.started => 'Started',
    LibraryDateRangeField.finished => 'Finished',
  };
}

class LibraryCustomFieldFilterOption {
  const LibraryCustomFieldFilterOption({
    required this.definitionId,
    required this.label,
    required this.fieldType,
    this.values = const [],
  });

  final String definitionId;
  final String label;
  final String fieldType;
  final List<String> values;
}

/// A media-agnostic filter selection that can represent any set of active
/// filters regardless of item kind.
class LibraryFilterSelection {
  const LibraryFilterSelection({
    this.ownershipFilter = LibraryOwnershipFilter.all,
    this.trackingStatusFilter = LibraryTrackingStatusFilter.all,
    this.loanStatusFilter = LibraryLoanStatusFilter.all,
    this.dateRangeField = LibraryDateRangeField.updated,
    this.dateFrom,
    this.dateTo,
    this.customFieldDefinitionId,
    this.customFieldValue,
    this.series,
    this.location,
    this.grade,
    this.condition,
    this.publisher,
    this.releaseYear,
    this.country,
    this.language,
    this.missingCover = false,
    this.missingMetadata = false,
  });

  static const none = LibraryFilterSelection();

  final LibraryOwnershipFilter ownershipFilter;
  final LibraryTrackingStatusFilter trackingStatusFilter;
  final LibraryLoanStatusFilter loanStatusFilter;
  final LibraryDateRangeField dateRangeField;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? customFieldDefinitionId;
  final String? customFieldValue;
  final String? series;
  final String? location;
  final String? grade;
  final String? condition;
  final String? publisher;
  final String? releaseYear;
  final String? country;
  final String? language;
  final bool missingCover;
  final bool missingMetadata;

  bool get hasActiveDateRange => dateFrom != null || dateTo != null;

  bool get hasActiveFilters {
    return ownershipFilter != LibraryOwnershipFilter.all ||
        trackingStatusFilter != LibraryTrackingStatusFilter.all ||
        loanStatusFilter != LibraryLoanStatusFilter.all ||
        hasActiveDateRange ||
      customFieldDefinitionId != null ||
      customFieldValue != null ||
        series != null ||
        location != null ||
        grade != null ||
        condition != null ||
        publisher != null ||
        releaseYear != null ||
        country != null ||
        language != null ||
        missingCover ||
        missingMetadata;
  }

  int get activeFilterCount {
    var count = 0;
    if (ownershipFilter != LibraryOwnershipFilter.all) count++;
    if (trackingStatusFilter != LibraryTrackingStatusFilter.all) count++;
    if (loanStatusFilter != LibraryLoanStatusFilter.all) count++;
    if (hasActiveDateRange) count++;
    if (customFieldDefinitionId != null || customFieldValue != null) count++;
    if (series != null) count++;
    if (location != null) count++;
    if (grade != null) count++;
    if (condition != null) count++;
    if (publisher != null) count++;
    if (releaseYear != null) count++;
    if (country != null) count++;
    if (language != null) count++;
    if (missingCover) count++;
    if (missingMetadata) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryFilterSelection &&
            other.ownershipFilter == ownershipFilter &&
            other.trackingStatusFilter == trackingStatusFilter &&
            other.loanStatusFilter == loanStatusFilter &&
            other.dateRangeField == dateRangeField &&
            other.dateFrom == dateFrom &&
            other.dateTo == dateTo &&
            other.customFieldDefinitionId == customFieldDefinitionId &&
            other.customFieldValue == customFieldValue &&
            other.series == series &&
            other.location == location &&
            other.grade == grade &&
            other.condition == condition &&
            other.publisher == publisher &&
            other.releaseYear == releaseYear &&
            other.country == country &&
            other.language == language &&
            other.missingCover == missingCover &&
            other.missingMetadata == missingMetadata;
  }

  @override
  int get hashCode => Object.hash(
        ownershipFilter,
      trackingStatusFilter,
      loanStatusFilter,
      dateRangeField,
      dateFrom,
      dateTo,
      customFieldDefinitionId,
      customFieldValue,
        series,
        location,
        grade,
        condition,
        publisher,
        releaseYear,
        country,
        language,
        missingCover,
        missingMetadata,
      );
}

/// Available filter values extracted from a set of library items.
class LibraryFilterOptions {
  const LibraryFilterOptions({
    this.series = const [],
    this.locations = const [],
    this.grades = const [],
    this.conditions = const [],
    this.publishers = const [],
    this.releaseYears = const [],
    this.countries = const [],
    this.languages = const [],
    this.customFields = const [],
  });

  final List<String> series;
  final List<String> locations;
  final List<String> grades;
  final List<String> conditions;
  final List<String> publishers;
  final List<String> releaseYears;
  final List<String> countries;
  final List<String> languages;
  final List<LibraryCustomFieldFilterOption> customFields;

  factory LibraryFilterOptions.fromEntries(
    List<LibraryWorkspaceEntry> entries,
    {
      List<CustomFieldDefinition> customFieldDefinitions = const [],
      Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
          const {},
    }
  ) {
    final series = <String>{};
    final locations = <String>{};
    final grades = <String>{};
    final conditions = <String>{};
    final publishers = <String>{};
    final years = <String>{};
    final countries = <String>{};
    final languages = <String>{};
    final customFieldValues = <String, Set<String>>{
      for (final definition in customFieldDefinitions)
        definition.id: {..._customFieldPresetOptions(definition)},
    };

    for (final entry in entries) {
      final seriesTitle = entry.series?.seriesTitle?.trim();
      if (seriesTitle != null && seriesTitle.isNotEmpty) {
        series.add(seriesTitle);
      }
      if (entry.storageBox?.trim().isNotEmpty == true) {
        locations.add(entry.storageBox!.trim());
      }
      if (entry.grade?.trim().isNotEmpty == true) {
        grades.add(entry.grade!.trim());
      }
      if (entry.condition?.trim().isNotEmpty == true) {
        conditions.add(entry.condition!.trim());
      }
      if (entry.publisher?.trim().isNotEmpty == true) {
        publishers.add(entry.publisher!.trim());
      }
      final year =
          entry.releaseYear?.toString() ?? entry.releaseDate?.year.toString();
      if (year != null) years.add(year);
      if (entry.country?.trim().isNotEmpty == true) {
        countries.add(entry.country!.trim());
      }
      if (entry.language?.trim().isNotEmpty == true) {
        languages.add(entry.language!.trim());
      }
      final ownedItemId = entry.ownedItemId;
      if (ownedItemId != null) {
        final values = customFieldValuesByDefinitionByItem[ownedItemId];
        if (values != null) {
          for (final fieldEntry in values.entries) {
            final normalized = fieldEntry.value.trim();
            if (normalized.isEmpty) {
              continue;
            }
            customFieldValues
                .putIfAbsent(fieldEntry.key, () => <String>{})
                .add(normalized);
          }
        }
      }
    }

    return LibraryFilterOptions(
      series: series.toList()..sort(),
      locations: locations.toList()..sort(),
      grades: grades.toList()..sort(),
      conditions: conditions.toList()..sort(),
      publishers: publishers.toList()..sort(),
      releaseYears: years.toList()..sort(),
      countries: countries.toList()..sort(),
      languages: languages.toList()..sort(),
      customFields: [
        for (final definition in customFieldDefinitions)
          LibraryCustomFieldFilterOption(
            definitionId: definition.id,
            label: definition.name,
            fieldType: definition.fieldType,
            values: (customFieldValues[definition.id] ?? <String>{}).toList()
              ..sort(),
          ),
      ],
    );
  }
}

Set<String> _customFieldPresetOptions(CustomFieldDefinition definition) {
  if (definition.fieldType != 'select' ||
      definition.options == null ||
      definition.options!.isEmpty) {
    return const <String>{};
  }
  try {
    return (jsonDecode(definition.options!) as List)
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  } catch (_) {
    return const <String>{};
  }
}

/// Returns true if the entry matches the active filter selection.
bool libraryFilterMatches(
  LibraryWorkspaceEntry entry,
  LibraryFilterSelection filters,
) {
  if (filters.ownershipFilter == LibraryOwnershipFilter.owned &&
      !entry.isOwned) {
    return false;
  }
  if (filters.ownershipFilter == LibraryOwnershipFilter.wishlist &&
      !entry.isWishlisted) {
    return false;
  }
  if (filters.ownershipFilter == LibraryOwnershipFilter.missingGrade &&
      !(entry.isOwned &&
          (entry.grade == null || entry.grade!.trim().isEmpty))) {
    return false;
  }
  if (filters.series != null &&
      entry.series?.seriesTitle?.trim() != filters.series) {
    return false;
  }
  if (filters.location != null && entry.storageBox?.trim() != filters.location) {
    return false;
  }
  if (filters.grade != null && entry.grade?.trim() != filters.grade) {
    return false;
  }
  if (filters.condition != null &&
      entry.condition?.trim() != filters.condition) {
    return false;
  }
  if (filters.publisher != null &&
      entry.publisher?.trim() != filters.publisher) {
    return false;
  }
  if (filters.releaseYear != null) {
    final year =
        entry.releaseYear?.toString() ?? entry.releaseDate?.year.toString();
    if (year != filters.releaseYear) return false;
  }
  if (filters.country != null && entry.country?.trim() != filters.country) {
    return false;
  }
  if (filters.language != null &&
      entry.language?.trim() != filters.language) {
    return false;
  }
  if (filters.missingCover && !entry.hasMissingCover) return false;
  if (filters.missingMetadata && !entry.hasMissingMetadata) return false;
  return true;
}

/// Shows a generic filter dialog and returns the selected filters, or null
/// if the user cancels.
Future<LibraryFilterSelection?> showLibraryFilterDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryFilterSelection current,
  required LibraryFilterOptions options,
}) {
  return showDialog<LibraryFilterSelection>(
    context: context,
    builder: (_) => _LibraryFilterDialog(
      type: type,
      initial: current,
      options: options,
    ),
  );
}

class _LibraryFilterDialog extends StatefulWidget {
  const _LibraryFilterDialog({
    required this.type,
    required this.initial,
    required this.options,
  });

  final LibraryTypeConfig type;
  final LibraryFilterSelection initial;
  final LibraryFilterOptions options;

  @override
  State<_LibraryFilterDialog> createState() => _LibraryFilterDialogState();
}

class _LibraryFilterDialogState extends State<_LibraryFilterDialog> {
  late LibraryOwnershipFilter _ownership;
  late LibraryTrackingStatusFilter _trackingStatus;
  late LibraryLoanStatusFilter _loanStatus;
  late LibraryDateRangeField _dateRangeField;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _customFieldDefinitionId;
  String? _customFieldValue;
  String? _series;
  String? _location;
  String? _grade;
  String? _condition;
  String? _publisher;
  String? _releaseYear;
  String? _country;
  String? _language;
  late bool _missingCover;
  late bool _missingMetadata;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _ownership = i.ownershipFilter;
    _trackingStatus = i.trackingStatusFilter;
    _loanStatus = i.loanStatusFilter;
    _dateRangeField = i.dateRangeField;
    _dateFrom = i.dateFrom;
    _dateTo = i.dateTo;
    _customFieldDefinitionId = i.customFieldDefinitionId;
    _customFieldValue = i.customFieldValue;
    _series = i.series;
    _location = i.location;
    _grade = i.grade;
    _condition = i.condition;
    _publisher = i.publisher;
    _releaseYear = i.releaseYear;
    _country = i.country;
    _language = i.language;
    _missingCover = i.missingCover;
    _missingMetadata = i.missingMetadata;
  }

  @override
  Widget build(BuildContext context) {
    final hasGrades = widget.type.grades.isNotEmpty;
    final hasConditions = widget.type.conditions.isNotEmpty;
    final labels = libraryMediaFilterLabels(widget.type);
    final selectedCustomField = _selectedCustomFieldOption();
    final ownershipValues = [
      LibraryOwnershipFilter.all,
      LibraryOwnershipFilter.owned,
      LibraryOwnershipFilter.wishlist,
      if (hasGrades) LibraryOwnershipFilter.missingGrade,
    ];

    return AlertDialog(
      title: Text('Filter ${widget.type.pluralLabel.toLowerCase()}'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LibraryOwnershipFilter>(
                initialValue: _ownership,
                dropdownColor: kAppPanelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Shelf',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final f in ownershipValues)
                    DropdownMenuItem(
                      value: f,
                      child: Text(libraryOwnershipFilterLabel(f)),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _ownership = v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LibraryTrackingStatusFilter>(
                initialValue: _trackingStatus,
                dropdownColor: kAppPanelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Tracking status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final filter in LibraryTrackingStatusFilter.values)
                    DropdownMenuItem(
                      value: filter,
                      child: Text(libraryTrackingStatusFilterLabel(filter)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _trackingStatus = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LibraryLoanStatusFilter>(
                initialValue: _loanStatus,
                dropdownColor: kAppPanelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Loan status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final filter in LibraryLoanStatusFilter.values)
                    DropdownMenuItem(
                      value: filter,
                      child: Text(libraryLoanStatusFilterLabel(filter)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _loanStatus = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LibraryDateRangeField>(
                initialValue: _dateRangeField,
                dropdownColor: kAppPanelRaised,
                borderRadius: kAppMenuBorderRadius,
                decoration: const InputDecoration(
                  labelText: 'Date field',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final field in LibraryDateRangeField.values)
                    DropdownMenuItem(
                      value: field,
                      child: Text(libraryDateRangeFieldLabel(field)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateRangeField = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateFilterButton(
                      label: 'From',
                      value: _dateFrom,
                      onPick: () => _pickDate(isStart: true),
                      onClear: _dateFrom == null
                          ? null
                          : () => setState(() => _dateFrom = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateFilterButton(
                      label: 'To',
                      value: _dateTo,
                      onPick: () => _pickDate(isStart: false),
                      onClear: _dateTo == null
                          ? null
                          : () => setState(() => _dateTo = null),
                    ),
                  ),
                ],
              ),
              if (widget.options.customFields.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: widget.options.customFields.any(
                    (field) => field.definitionId == _customFieldDefinitionId,
                  )
                      ? _customFieldDefinitionId
                      : null,
                  isExpanded: true,
                  dropdownColor: kAppPanelRaised,
                  borderRadius: kAppMenuBorderRadius,
                  decoration: const InputDecoration(
                    labelText: 'Custom field',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Any custom field'),
                    ),
                    for (final field in widget.options.customFields)
                      DropdownMenuItem<String>(
                        value: field.definitionId,
                        child: Text(field.label),
                      ),
                  ],
                  onChanged: (value) {
                    final nextDefinitionId =
                        value == null || value.isEmpty ? null : value;
                    setState(() {
                      _customFieldDefinitionId = nextDefinitionId;
                      final nextField = _selectedCustomFieldOption();
                      if (_customFieldValue != null &&
                          (nextField == null ||
                              !nextField.values.contains(_customFieldValue))) {
                        _customFieldValue = null;
                      }
                    });
                  },
                ),
              ],
              if (selectedCustomField != null &&
                  selectedCustomField.values.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: '${selectedCustomField.label} value',
                  empty: 'Any value',
                  value: _customFieldValue,
                  options: _customFieldValueOptions(selectedCustomField),
                  onChanged: (value) => setState(() => _customFieldValue = value),
                ),
              ],
              if (widget.options.series.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: labels.series,
                  empty: labels.anySeries,
                  value: _series,
                  options: widget.options.series,
                  onChanged: (v) => setState(() => _series = v),
                ),
              ],
              if (widget.options.locations.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: 'Location',
                  empty: 'Any location',
                  value: _location,
                  options: widget.options.locations,
                  onChanged: (v) => setState(() => _location = v),
                ),
              ],
              if (widget.options.publishers.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: labels.publisher,
                  empty: labels.anyPublisher,
                  value: _publisher,
                  options: widget.options.publishers,
                  onChanged: (v) => setState(() => _publisher = v),
                ),
              ],
              if (widget.options.releaseYears.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: labels.year,
                  empty: labels.anyYear,
                  value: _releaseYear,
                  options: widget.options.releaseYears,
                  onChanged: (v) => setState(() => _releaseYear = v),
                ),
              ],
              if (hasGrades && widget.options.grades.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: 'Grade',
                  empty: 'Any grade',
                  value: _grade,
                  options: widget.options.grades,
                  onChanged: (v) => setState(() => _grade = v),
                ),
              ],
              if (hasConditions && widget.options.conditions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: 'Condition',
                  empty: 'Any condition',
                  value: _condition,
                  options: widget.options.conditions,
                  onChanged: (v) => setState(() => _condition = v),
                ),
              ],
              if (widget.options.countries.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: 'Country',
                  empty: 'Any country',
                  value: _country,
                  options: widget.options.countries,
                  onChanged: (v) => setState(() => _country = v),
                ),
              ],
              if (widget.options.languages.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterDropdown(
                  label: 'Language',
                  empty: 'Any language',
                  value: _language,
                  options: widget.options.languages,
                  onChanged: (v) => setState(() => _language = v),
                ),
              ],
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _missingCover,
                contentPadding: EdgeInsets.zero,
                title: const Text('Missing covers'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) =>
                    setState(() => _missingCover = v ?? false),
              ),
              CheckboxListTile(
                value: _missingMetadata,
                contentPadding: EdgeInsets.zero,
                title: const Text('Missing metadata'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) =>
                    setState(() => _missingMetadata = v ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(LibraryFilterSelection.none),
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            LibraryFilterSelection(
              ownershipFilter: _ownership,
              trackingStatusFilter: _trackingStatus,
              loanStatusFilter: _loanStatus,
              dateRangeField: _dateRangeField,
              dateFrom: _dateFrom,
              dateTo: _dateTo,
              customFieldDefinitionId: _customFieldDefinitionId,
              customFieldValue: _customFieldValue,
              series: _series,
              location: _location,
              grade: _grade,
              condition: _condition,
              publisher: _publisher,
              releaseYear: _releaseYear,
              country: _country,
              language: _language,
              missingCover: _missingCover,
              missingMetadata: _missingMetadata,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final currentValue = isStart ? _dateFrom : _dateTo;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  LibraryCustomFieldFilterOption? _selectedCustomFieldOption() {
    for (final field in widget.options.customFields) {
      if (field.definitionId == _customFieldDefinitionId) {
        return field;
      }
    }
    return null;
  }

  List<String> _customFieldValueOptions(
    LibraryCustomFieldFilterOption option,
  ) {
    final values = option.values.toList(growable: true);
    final currentValue = _customFieldValue;
    if (currentValue != null &&
        currentValue.isNotEmpty &&
        !values.contains(currentValue)) {
      values.add(currentValue);
      values.sort();
    }
    return values;
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.empty,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String empty;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      dropdownColor: kAppPanelRaised,
      borderRadius: kAppMenuBorderRadius,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: '', child: Text(empty)),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (v) => onChanged(v == null || v.isEmpty ? null : v),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final formatted = value == null
        ? label
        : MaterialLocalizations.of(context).formatMediumDate(value!);
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              formatted,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 16),
              splashRadius: 14,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 8),
            ),
        ],
      ),
    );
  }
}
