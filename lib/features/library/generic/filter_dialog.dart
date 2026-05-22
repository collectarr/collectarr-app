import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/clz_style.dart';
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

/// A media-agnostic filter selection that can represent any set of active
/// filters regardless of item kind.
class LibraryFilterSelection {
  const LibraryFilterSelection({
    this.ownershipFilter = LibraryOwnershipFilter.all,
    this.series,
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
  final String? series;
  final String? grade;
  final String? condition;
  final String? publisher;
  final String? releaseYear;
  final String? country;
  final String? language;
  final bool missingCover;
  final bool missingMetadata;

  bool get hasActiveFilters {
    return ownershipFilter != LibraryOwnershipFilter.all ||
        series != null ||
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
    if (series != null) count++;
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
            other.series == series &&
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
        series,
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
    this.grades = const [],
    this.conditions = const [],
    this.publishers = const [],
    this.releaseYears = const [],
    this.countries = const [],
    this.languages = const [],
  });

  final List<String> series;
  final List<String> grades;
  final List<String> conditions;
  final List<String> publishers;
  final List<String> releaseYears;
  final List<String> countries;
  final List<String> languages;

  factory LibraryFilterOptions.fromEntries(
    List<LibraryWorkspaceEntry> entries,
  ) {
    final series = <String>{};
    final grades = <String>{};
    final conditions = <String>{};
    final publishers = <String>{};
    final years = <String>{};
    final countries = <String>{};
    final languages = <String>{};

    for (final entry in entries) {
      final seriesTitle = entry.series?.seriesTitle?.trim();
      if (seriesTitle != null && seriesTitle.isNotEmpty) {
        series.add(seriesTitle);
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
    }

    return LibraryFilterOptions(
      series: series.toList()..sort(),
      grades: grades.toList()..sort(),
      conditions: conditions.toList()..sort(),
      publishers: publishers.toList()..sort(),
      releaseYears: years.toList()..sort(),
      countries: countries.toList()..sort(),
      languages: languages.toList()..sort(),
    );
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
  String? _series;
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
    _series = i.series;
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
                value: _ownership,
                dropdownColor: kClzPanelRaised,
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
              series: _series,
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
      value: options.contains(value) ? value : null,
      isExpanded: true,
      dropdownColor: kClzPanelRaised,
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
