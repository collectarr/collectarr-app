import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Ownership filter options used in the generic filter dialog.
enum LibraryOwnershipFilter {
  all,
  owned,
  wishlist,
  missingGrade,
  forSale,
  onOrder
}

String libraryOwnershipFilterLabel(
  LibraryOwnershipFilter filter, {
  LibraryTypeConfig? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(type: type, mediaType: mediaType);
  return switch (filter) {
    LibraryOwnershipFilter.all => labels.ownershipAll,
    LibraryOwnershipFilter.owned => labels.ownershipOwned,
    LibraryOwnershipFilter.wishlist => labels.ownershipWishlist,
    LibraryOwnershipFilter.missingGrade => labels.ownershipMissingGrade,
    LibraryOwnershipFilter.forSale => labels.ownershipForSale,
    LibraryOwnershipFilter.onOrder => labels.ownershipOnOrder,
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

String libraryTrackingStatusFilterLabel(
  LibraryTrackingStatusFilter filter, {
  LibraryTypeConfig? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(type: type, mediaType: mediaType);
  return switch (filter) {
    LibraryTrackingStatusFilter.all => labels.trackingAny,
    LibraryTrackingStatusFilter.notTracked => labels.trackingNotTracked,
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
    LibraryTrackingStatusFilter.paused => status == MediaTrackingStatus.paused,
    LibraryTrackingStatusFilter.dropped =>
      status == MediaTrackingStatus.dropped,
    LibraryTrackingStatusFilter.repeating =>
      status == MediaTrackingStatus.repeating,
  };
}

enum LibraryLoanStatusFilter { all, onLoan, available }

String libraryLoanStatusFilterLabel(
  LibraryLoanStatusFilter filter, {
  LibraryTypeConfig? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(type: type, mediaType: mediaType);
  return switch (filter) {
    LibraryLoanStatusFilter.all => labels.loanAny,
    LibraryLoanStatusFilter.onLoan => labels.loanOnLoan,
    LibraryLoanStatusFilter.available => labels.loanAvailable,
  };
}

enum LibraryDateRangeField { updated, purchased, started, finished }

String libraryDateRangeFieldLabel(
  LibraryDateRangeField field, {
  LibraryTypeConfig? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(type: type, mediaType: mediaType);
  return switch (field) {
    LibraryDateRangeField.updated => labels.dateUpdated,
    LibraryDateRangeField.purchased => labels.datePurchased,
    LibraryDateRangeField.started => labels.dateStarted,
    LibraryDateRangeField.finished => labels.dateFinished,
  };
}

LibraryFilterOptionLabels _libraryFilterOptionLabels({
  LibraryTypeConfig? type,
  Object? mediaType,
}) {
  return type?.presentation.filterOptionLabels ??
      collectarrLibraryTypes
          .byKind(mediaType)
          ?.presentation
          .filterOptionLabels ??
      const LibraryFilterOptionLabels();
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
    this.tag,
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
  final String? tag;
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
        tag != null ||
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
    if (tag != null) count++;
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
            other.tag == tag &&
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
        tag,
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

LibraryFilterSelection sanitizeLibraryFilterSelectionForType(
  LibraryFilterSelection selection,
  LibraryTypeConfig type,
) {
  final supportedFields = {
    for (final definition in type.presentation.filterFieldDefinitions)
      definition.field,
  };
  final hasGrades = type.grades.isNotEmpty &&
      supportedFields.contains(LibraryFilterField.grade);
  final hasConditions = type.conditions.isNotEmpty &&
      supportedFields.contains(LibraryFilterField.condition);

  return LibraryFilterSelection(
    ownershipFilter:
        selection.ownershipFilter == LibraryOwnershipFilter.missingGrade &&
                !hasGrades
            ? LibraryOwnershipFilter.all
            : selection.ownershipFilter,
    trackingStatusFilter: selection.trackingStatusFilter,
    loanStatusFilter: selection.loanStatusFilter,
    dateRangeField: selection.dateRangeField,
    dateFrom: selection.dateFrom,
    dateTo: selection.dateTo,
    customFieldDefinitionId: selection.customFieldDefinitionId,
    customFieldValue: selection.customFieldValue,
    series: supportedFields.contains(LibraryFilterField.series)
        ? selection.series
        : null,
    location: supportedFields.contains(LibraryFilterField.location)
        ? selection.location
        : null,
    tag:
        supportedFields.contains(LibraryFilterField.tag) ? selection.tag : null,
    grade: hasGrades ? selection.grade : null,
    condition: hasConditions ? selection.condition : null,
    publisher: supportedFields.contains(LibraryFilterField.publisher)
        ? selection.publisher
        : null,
    releaseYear: supportedFields.contains(LibraryFilterField.year)
        ? selection.releaseYear
        : null,
    country: supportedFields.contains(LibraryFilterField.country)
        ? selection.country
        : null,
    language: supportedFields.contains(LibraryFilterField.language)
        ? selection.language
        : null,
    missingCover: selection.missingCover,
    missingMetadata: selection.missingMetadata,
  );
}

/// Available filter values extracted from a set of library items.
class LibraryFilterOptions {
  const LibraryFilterOptions({
    this.series = const [],
    this.locations = const [],
    this.tags = const [],
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
  final List<String> tags;
  final List<String> grades;
  final List<String> conditions;
  final List<String> publishers;
  final List<String> releaseYears;
  final List<String> countries;
  final List<String> languages;
  final List<LibraryCustomFieldFilterOption> customFields;

  factory LibraryFilterOptions.fromEntries(
    List<LibraryWorkspaceEntry> entries, {
    required LibraryMediaAdapter adapter,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
  }) {
    final series = <String>{};
    final locations = <String>{};
    final tags = <String>[];
    final normalizedTags = <String>{};
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
      final filterValues = adapter.filterValuesForEntry(entry);
      final seriesTitle = filterValues.series;
      if (seriesTitle != null && seriesTitle.isNotEmpty) {
        series.add(seriesTitle);
      }
      if (entry.locationPath?.trim().isNotEmpty == true) {
        locations.add(entry.locationPath!.trim());
      }
      for (final tag in splitPickListValues(entry.tags)) {
        final normalized = tag.trim().toLowerCase();
        if (normalized.isEmpty || !normalizedTags.add(normalized)) {
          continue;
        }
        tags.add(tag);
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
      if (filterValues.country?.isNotEmpty == true) {
        countries.add(filterValues.country!);
      }
      if (filterValues.language?.isNotEmpty == true) {
        languages.add(filterValues.language!);
      }
      final ownedItemId = entry.ownedItemId;
      if (ownedItemId != null) {
        final values = customFieldValuesByDefinitionByItem[ownedItemId];
        if (values != null) {
          for (final fieldEntry in values.entries) {
            final normalizedValues = parseCustomFieldMultiValues(
              fieldEntry.value,
            );
            if (normalizedValues.isEmpty) {
              final normalized = fieldEntry.value.trim();
              if (normalized.isNotEmpty) {
                customFieldValues
                    .putIfAbsent(fieldEntry.key, () => <String>{})
                    .add(normalized);
              }
              continue;
            }
            for (final normalized in normalizedValues) {
              customFieldValues
                  .putIfAbsent(fieldEntry.key, () => <String>{})
                  .add(normalized);
            }
          }
        }
      }
    }

    return LibraryFilterOptions(
      series: series.toList()..sort(),
      locations: locations.toList()..sort(),
      tags: tags..sort(),
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
  if (!definition.valueType.supportsOptions ||
      definition.options == null ||
      definition.options!.isEmpty) {
    return const <String>{};
  }
  return definition.optionValues.toSet();
}

/// Returns true if the entry matches the active filter selection.
bool libraryFilterMatches(
  LibraryWorkspaceEntry entry,
  LibraryFilterSelection filters,
  LibraryMediaAdapter adapter,
) {
  final filterValues = adapter.filterValuesForEntry(entry);
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
  if (filters.ownershipFilter == LibraryOwnershipFilter.forSale &&
      !(entry.isOwned && entry.collectionStatus == 'for_sale')) {
    return false;
  }
  if (filters.ownershipFilter == LibraryOwnershipFilter.onOrder &&
      !(entry.isOwned && entry.collectionStatus == 'on_order')) {
    return false;
  }
  if (filters.series != null && filterValues.series != filters.series) {
    return false;
  }
  if (filters.location != null &&
      entry.locationPath?.trim() != filters.location) {
    return false;
  }
  if (filters.tag != null && !_entryHasTag(entry.tags, filters.tag!)) {
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
  if (filters.country != null && filterValues.country != filters.country) {
    return false;
  }
  if (filters.language != null && filterValues.language != filters.language) {
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
  String? _tag;
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
    _tag = i.tag;
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
    final palette = appPalette(context);
    final accent = widget.type.workspace.accent;
    final hasGrades = widget.type.grades.isNotEmpty;
    final hasConditions = widget.type.conditions.isNotEmpty;
    final labels = libraryMediaFilterLabels(widget.type);
    final selectedCustomField = _selectedCustomFieldOption();
    final viewport = MediaQuery.sizeOf(context);
    final ownershipValues = [
      LibraryOwnershipFilter.all,
      LibraryOwnershipFilter.owned,
      LibraryOwnershipFilter.wishlist,
      if (hasGrades) LibraryOwnershipFilter.missingGrade,
    ];

    final generalFilters = <Widget>[
      DropdownButtonFormField<LibraryOwnershipFilter>(
        initialValue: _ownership,
        dropdownColor: palette.panelRaised,
        borderRadius: kAppMenuBorderRadius,
        decoration: _filterFieldDecoration(context, label: 'Shelf'),
        items: [
          for (final f in ownershipValues)
            DropdownMenuItem(
              value: f,
              child: Text(libraryOwnershipFilterLabel(f, type: widget.type)),
            ),
        ],
        onChanged: (v) {
          if (v != null) setState(() => _ownership = v);
        },
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<LibraryTrackingStatusFilter>(
        initialValue: _trackingStatus,
        dropdownColor: palette.panelRaised,
        borderRadius: kAppMenuBorderRadius,
        decoration: _filterFieldDecoration(context, label: 'Tracking status'),
        items: [
          for (final filter in LibraryTrackingStatusFilter.values)
            DropdownMenuItem(
              value: filter,
              child: Text(
                libraryTrackingStatusFilterLabel(filter, type: widget.type),
              ),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _trackingStatus = value);
          }
        },
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<LibraryLoanStatusFilter>(
        initialValue: _loanStatus,
        dropdownColor: palette.panelRaised,
        borderRadius: kAppMenuBorderRadius,
        decoration: _filterFieldDecoration(context, label: 'Loan status'),
        items: [
          for (final filter in LibraryLoanStatusFilter.values)
            DropdownMenuItem(
              value: filter,
              child:
                  Text(libraryLoanStatusFilterLabel(filter, type: widget.type)),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _loanStatus = value);
          }
        },
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<LibraryDateRangeField>(
        initialValue: _dateRangeField,
        dropdownColor: palette.panelRaised,
        borderRadius: kAppMenuBorderRadius,
        decoration: _filterFieldDecoration(context, label: 'Date field'),
        items: [
          for (final field in LibraryDateRangeField.values)
            DropdownMenuItem(
              value: field,
              child: Text(libraryDateRangeFieldLabel(field, type: widget.type)),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _dateRangeField = value);
          }
        },
      ),
      const SizedBox(height: 10),
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
          const SizedBox(width: 10),
          Expanded(
            child: _DateFilterButton(
              label: 'To',
              value: _dateTo,
              onPick: () => _pickDate(isStart: false),
              onClear:
                  _dateTo == null ? null : () => setState(() => _dateTo = null),
            ),
          ),
        ],
      ),
    ];

    final detailFilters = _buildDetailFilters(
      context: context,
      labels: labels,
      palette: palette,
      hasGrades: hasGrades,
      hasConditions: hasConditions,
      selectedCustomField: selectedCustomField,
    );
    if (detailFilters.isNotEmpty) {
      detailFilters.add(const SizedBox(height: 10));
    }
    detailFilters.addAll([
      _FilterCheckboxTile(
        title: 'Missing covers',
        value: _missingCover,
        onChanged: (value) => setState(() => _missingCover = value),
      ),
      const SizedBox(height: 8),
      _FilterCheckboxTile(
        title: 'Missing metadata',
        value: _missingMetadata,
        onChanged: (value) => setState(() => _missingMetadata = value),
      ),
    ]);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: viewport.height - 36,
        ),
        child: SizedBox(
          width: viewport.width - 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.panelRaised,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: palette.divider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccentDialogHeader(
                  title: 'Select Filters',
                  accent: accent,
                  icon: Icons.filter_alt_outlined,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _FilterDialogPane(
                            title: 'General Filters',
                            accent: accent,
                            child: Column(children: generalFilters),
                          ),
                          const SizedBox(height: 12),
                          _FilterDialogPane(
                            title: 'Field Filters',
                            accent: accent,
                            child: Column(children: detailFilters),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: palette.divider)),
                  ),
                  child: Row(
                    children: [
                      LibraryDenseButton(
                        label: 'Clear',
                        onPressed: () => Navigator.of(context).pop(
                          LibraryFilterSelection.none,
                        ),
                        tone: LibraryDenseButtonTone.subtle,
                      ),
                      const Spacer(),
                      LibraryDenseButton(
                        label: 'Apply',
                        onPressed: () =>
                            Navigator.of(context).pop(_buildSelection()),
                        tone: LibraryDenseButtonTone.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetailFilters({
    required BuildContext context,
    required LibraryMediaFilterLabels labels,
    required AppThemePalette palette,
    required bool hasGrades,
    required bool hasConditions,
    required LibraryCustomFieldFilterOption? selectedCustomField,
  }) {
    final detailFilters = <Widget>[];
    if (widget.options.customFields.isNotEmpty) {
      _appendFilterField(
        detailFilters,
        DropdownButtonFormField<String>(
          initialValue: widget.options.customFields.any(
            (field) => field.definitionId == _customFieldDefinitionId,
          )
              ? _customFieldDefinitionId
              : null,
          isExpanded: true,
          dropdownColor: palette.panelRaised,
          borderRadius: kAppMenuBorderRadius,
          decoration: _filterFieldDecoration(context, label: 'Custom field'),
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
      );
    }
    if (selectedCustomField != null && selectedCustomField.values.isNotEmpty) {
      _appendFilterField(
        detailFilters,
        _FilterDropdown(
          label: '${selectedCustomField.label} value',
          empty: 'Any value',
          value: _customFieldValue,
          options: _customFieldValueOptions(selectedCustomField),
          onChanged: (value) => setState(() => _customFieldValue = value),
        ),
      );
    }

    final fieldSpecs = [
      for (final definition in widget.type.presentation.filterFieldDefinitions)
        _buildDetailFilterFieldSpec(
          definition: definition,
          labels: labels,
          hasGrades: hasGrades,
          hasConditions: hasConditions,
        ),
    ];

    for (final spec in fieldSpecs) {
      if (!spec.isVisible) {
        continue;
      }
      _appendFilterField(detailFilters, spec.builder());
    }

    return detailFilters;
  }

  _DetailFilterFieldSpec _buildDetailFilterFieldSpec({
    required LibraryFilterFieldDefinition definition,
    required LibraryMediaFilterLabels labels,
    required bool hasGrades,
    required bool hasConditions,
  }) {
    return switch (definition.field) {
      LibraryFilterField.series => _DetailFilterFieldSpec(
          isVisible: widget.options.series.isNotEmpty,
          builder: () => _FilterDropdown(
            label: labels.series,
            empty: labels.anySeries,
            value: _series,
            options: widget.options.series,
            onChanged: (value) => setState(() => _series = value),
          ),
        ),
      LibraryFilterField.location => _DetailFilterFieldSpec(
          isVisible: widget.options.locations.isNotEmpty,
          builder: () => _FilterDropdown(
            label: 'Location',
            empty: 'Any location',
            value: _location,
            options: widget.options.locations,
            onChanged: (value) => setState(() => _location = value),
          ),
        ),
      LibraryFilterField.tag => _DetailFilterFieldSpec(
          isVisible: widget.options.tags.isNotEmpty,
          builder: () => _AutocompleteFilterField(
            label: 'Tag',
            hint: 'Any tag',
            value: _tag,
            options: widget.options.tags,
            onChanged: (value) => setState(() => _tag = value),
          ),
        ),
      LibraryFilterField.publisher => _DetailFilterFieldSpec(
          isVisible: widget.options.publishers.isNotEmpty,
          builder: () => _FilterDropdown(
            label: labels.publisher,
            empty: labels.anyPublisher,
            value: _publisher,
            options: widget.options.publishers,
            onChanged: (value) => setState(() => _publisher = value),
          ),
        ),
      LibraryFilterField.year => _DetailFilterFieldSpec(
          isVisible: widget.options.releaseYears.isNotEmpty,
          builder: () => _FilterDropdown(
            label: labels.year,
            empty: labels.anyYear,
            value: _releaseYear,
            options: widget.options.releaseYears,
            onChanged: (value) => setState(() => _releaseYear = value),
          ),
        ),
      LibraryFilterField.grade => _DetailFilterFieldSpec(
          isVisible: hasGrades && widget.options.grades.isNotEmpty,
          builder: () => _FilterDropdown(
            label: 'Grade',
            empty: 'Any grade',
            value: _grade,
            options: widget.options.grades,
            onChanged: (value) => setState(() => _grade = value),
          ),
        ),
      LibraryFilterField.condition => _DetailFilterFieldSpec(
          isVisible: hasConditions && widget.options.conditions.isNotEmpty,
          builder: () => _FilterDropdown(
            label: 'Condition',
            empty: 'Any condition',
            value: _condition,
            options: widget.options.conditions,
            onChanged: (value) => setState(() => _condition = value),
          ),
        ),
      LibraryFilterField.country => _DetailFilterFieldSpec(
          isVisible: widget.options.countries.isNotEmpty,
          builder: () => _FilterDropdown(
            label: 'Country',
            empty: 'Any country',
            value: _country,
            options: widget.options.countries,
            onChanged: (value) => setState(() => _country = value),
          ),
        ),
      LibraryFilterField.language => _DetailFilterFieldSpec(
          isVisible: widget.options.languages.isNotEmpty,
          builder: () => _FilterDropdown(
            label: 'Language',
            empty: 'Any language',
            value: _language,
            options: widget.options.languages,
            onChanged: (value) => setState(() => _language = value),
          ),
        ),
    };
  }

  LibraryFilterSelection _buildSelection() {
    return LibraryFilterSelection(
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
      tag: _tag,
      grade: _grade,
      condition: _condition,
      publisher: _publisher,
      releaseYear: _releaseYear,
      country: _country,
      language: _language,
      missingCover: _missingCover,
      missingMetadata: _missingMetadata,
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

bool _entryHasTag(String? rawTags, String filterTag) {
  final normalizedFilter = filterTag.trim().toLowerCase();
  if (normalizedFilter.isEmpty) {
    return true;
  }
  for (final tag in splitPickListValues(rawTags)) {
    if (tag.trim().toLowerCase() == normalizedFilter) {
      return true;
    }
  }
  return false;
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
    final palette = appPalette(context);
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      dropdownColor: palette.panelRaised,
      borderRadius: kAppMenuBorderRadius,
      decoration: _filterFieldDecoration(context, label: label),
      items: [
        DropdownMenuItem(value: '', child: Text(empty)),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (v) => onChanged(v == null || v.isEmpty ? null : v),
    );
  }
}

class _AutocompleteFilterField extends StatelessWidget {
  const _AutocompleteFilterField({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ''),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return options;
        }
        return options.where(
          (option) => option.toLowerCase().contains(query),
        );
      },
      onSelected: (selection) => onChanged(selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: _filterFieldDecoration(
            context,
            label: label,
            hintText: hint,
            suffixIcon: controller.text.trim().isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged(null);
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear $label filter',
                  ),
          ),
          onChanged: (text) {
            final normalized = text.trim();
            onChanged(normalized.isEmpty ? null : normalized);
          },
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, displayedOptions) {
        final palette = appPalette(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: palette.panelRaised,
            elevation: 4,
            borderRadius: kAppMenuBorderRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 420),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final option in displayedOptions)
                    ListTile(
                      dense: true,
                      title: Text(option),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
    final palette = appPalette(context);
    final formatted = value == null
        ? label
        : MaterialLocalizations.of(context).formatMediumDate(value!);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        backgroundColor: palette.surfaceSubtle,
        side: BorderSide(color: palette.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
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
              tooltip: 'Clear',
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

void _appendFilterField(List<Widget> fields, Widget field) {
  if (fields.isNotEmpty) {
    fields.add(const SizedBox(height: 10));
  }
  fields.add(field);
}

class _DetailFilterFieldSpec {
  const _DetailFilterFieldSpec({
    required this.isVisible,
    required this.builder,
  });

  final bool isVisible;
  final Widget Function() builder;
}

class _FilterDialogPane extends StatelessWidget {
  const _FilterDialogPane({
    required this.title,
    required this.child,
    required this.accent,
  });

  final String title;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: accent,
              ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _FilterCheckboxTile extends StatelessWidget {
  const _FilterCheckboxTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: palette.surfaceSubtle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: palette.divider),
      ),
      child: CheckboxListTile(
        value: value,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        title: Text(title),
        controlAffinity: ListTileControlAffinity.leading,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        onChanged: (next) => onChanged(next ?? false),
      ),
    );
  }
}

InputDecoration _filterFieldDecoration(
  BuildContext context, {
  required String label,
  String? hintText,
  Widget? suffixIcon,
}) {
  final palette = appPalette(context);
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    suffixIcon: suffixIcon,
    isDense: true,
    filled: true,
    fillColor: palette.surfaceSubtle,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: palette.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: palette.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: palette.accent, width: 1.2),
    ),
  );
}
