import 'package:flutter/material.dart';

enum ComicsOwnershipFilter { all, owned, wishlist, missingGrade }

enum ComicsShelfQuickView {
  all,
  owned,
  wishlist,
  missingGrade,
  missingCovers,
  missingMetadata,
}

extension ComicsShelfQuickViewLabels on ComicsShelfQuickView {
  String get label {
    return switch (this) {
      ComicsShelfQuickView.all => 'All comics',
      ComicsShelfQuickView.owned => 'Owned',
      ComicsShelfQuickView.wishlist => 'Wishlist',
      ComicsShelfQuickView.missingGrade => 'Missing grade',
      ComicsShelfQuickView.missingCovers => 'Missing covers',
      ComicsShelfQuickView.missingMetadata => 'Missing metadata',
    };
  }

  IconData get icon {
    return switch (this) {
      ComicsShelfQuickView.all => Icons.library_books_outlined,
      ComicsShelfQuickView.owned => Icons.inventory_2_outlined,
      ComicsShelfQuickView.wishlist => Icons.star_border,
      ComicsShelfQuickView.missingGrade => Icons.workspace_premium_outlined,
      ComicsShelfQuickView.missingCovers => Icons.image_not_supported_outlined,
      ComicsShelfQuickView.missingMetadata => Icons.fact_check_outlined,
    };
  }

  ComicsFilterSelection get filters {
    return switch (this) {
      ComicsShelfQuickView.all => ComicsFilterSelection.none,
      ComicsShelfQuickView.owned => const ComicsFilterSelection(
          ownershipFilter: ComicsOwnershipFilter.owned,
        ),
      ComicsShelfQuickView.wishlist => const ComicsFilterSelection(
          ownershipFilter: ComicsOwnershipFilter.wishlist,
        ),
      ComicsShelfQuickView.missingGrade => const ComicsFilterSelection(
          ownershipFilter: ComicsOwnershipFilter.missingGrade,
        ),
      ComicsShelfQuickView.missingCovers => const ComicsFilterSelection(
          ownershipFilter: ComicsOwnershipFilter.all,
          missingCover: true,
        ),
      ComicsShelfQuickView.missingMetadata => const ComicsFilterSelection(
          ownershipFilter: ComicsOwnershipFilter.all,
          missingMetadata: true,
        ),
    };
  }
}

class ComicsFilterSelection {
  const ComicsFilterSelection({
    required this.ownershipFilter,
    this.series,
    this.grade,
    this.condition,
    this.publisher,
    this.releaseYear,
    this.missingCover = false,
    this.missingMetadata = false,
  });

  static const none = ComicsFilterSelection(
    ownershipFilter: ComicsOwnershipFilter.all,
  );

  final ComicsOwnershipFilter ownershipFilter;
  final String? series;
  final String? grade;
  final String? condition;
  final String? publisher;
  final String? releaseYear;
  final bool missingCover;
  final bool missingMetadata;

  bool get hasActiveFilters {
    return ownershipFilter != ComicsOwnershipFilter.all ||
        series != null ||
        grade != null ||
        condition != null ||
        publisher != null ||
        releaseYear != null ||
        missingCover ||
        missingMetadata;
  }

  int get activeFilterCount {
    var count = 0;
    if (ownershipFilter != ComicsOwnershipFilter.all) {
      count++;
    }
    if (series != null) {
      count++;
    }
    if (grade != null) {
      count++;
    }
    if (condition != null) {
      count++;
    }
    if (publisher != null) {
      count++;
    }
    if (releaseYear != null) {
      count++;
    }
    if (missingCover) {
      count++;
    }
    if (missingMetadata) {
      count++;
    }
    return count;
  }

  ComicsShelfQuickView? get quickView {
    for (final view in ComicsShelfQuickView.values) {
      if (this == view.filters) {
        return view;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ComicsFilterSelection &&
            other.ownershipFilter == ownershipFilter &&
            other.series == series &&
            other.grade == grade &&
            other.condition == condition &&
            other.publisher == publisher &&
            other.releaseYear == releaseYear &&
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
        missingCover,
        missingMetadata,
      );
}

class ComicsFilterDialog extends StatefulWidget {
  const ComicsFilterDialog({
    super.key,
    required this.initialSelection,
    required this.seriesOptions,
    required this.gradeOptions,
    required this.conditionOptions,
    required this.publisherOptions,
    required this.releaseYearOptions,
  });

  final ComicsFilterSelection initialSelection;
  final List<String> seriesOptions;
  final List<String> gradeOptions;
  final List<String> conditionOptions;
  final List<String> publisherOptions;
  final List<String> releaseYearOptions;

  @override
  State<ComicsFilterDialog> createState() => _ComicsFilterDialogState();
}

class _ComicsFilterDialogState extends State<ComicsFilterDialog> {
  late ComicsOwnershipFilter _ownershipFilter;
  String? _series;
  String? _grade;
  String? _condition;
  String? _publisher;
  String? _releaseYear;
  late bool _missingCover;
  late bool _missingMetadata;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelection;
    _ownershipFilter = initial.ownershipFilter;
    _series = initial.series;
    _grade = initial.grade;
    _condition = initial.condition;
    _publisher = initial.publisher;
    _releaseYear = initial.releaseYear;
    _missingCover = initial.missingCover;
    _missingMetadata = initial.missingMetadata;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter comics'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ComicsOwnershipFilter>(
                initialValue: _ownershipFilter,
                decoration: const InputDecoration(
                  labelText: 'Shelf',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final filter in ComicsOwnershipFilter.values)
                    DropdownMenuItem(
                      value: filter,
                      child: Text(comicsOwnershipFilterLabel(filter)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _ownershipFilter = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Series',
                emptyLabel: 'Any series',
                value: _series,
                options: widget.seriesOptions,
                onChanged: (value) => setState(() => _series = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Publisher',
                emptyLabel: 'Any publisher',
                value: _publisher,
                options: widget.publisherOptions,
                onChanged: (value) => setState(() => _publisher = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Year',
                emptyLabel: 'Any year',
                value: _releaseYear,
                options: widget.releaseYearOptions,
                onChanged: (value) => setState(() => _releaseYear = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Grade',
                emptyLabel: 'Any grade',
                value: _grade,
                options: widget.gradeOptions,
                onChanged: (value) => setState(() => _grade = value),
              ),
              const SizedBox(height: 12),
              _StringFilterDropdown(
                label: 'Condition',
                emptyLabel: 'Any condition',
                value: _condition,
                options: widget.conditionOptions,
                onChanged: (value) => setState(() => _condition = value),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _missingCover,
                contentPadding: EdgeInsets.zero,
                title: const Text('Missing covers'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() => _missingCover = value ?? false);
                },
              ),
              CheckboxListTile(
                value: _missingMetadata,
                contentPadding: EdgeInsets.zero,
                title: const Text('Missing metadata'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() => _missingMetadata = value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              const ComicsFilterSelection(
                ownershipFilter: ComicsOwnershipFilter.all,
              ),
            );
          },
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              ComicsFilterSelection(
                ownershipFilter: _ownershipFilter,
                series: _series,
                grade: _grade,
                condition: _condition,
                publisher: _publisher,
                releaseYear: _releaseYear,
                missingCover: _missingCover,
                missingMetadata: _missingMetadata,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _StringFilterDropdown extends StatelessWidget {
  const _StringFilterDropdown({
    required this.label,
    required this.emptyLabel,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String emptyLabel;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: '', child: Text(emptyLabel)),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) {
        onChanged(value == null || value.isEmpty ? null : value);
      },
    );
  }
}

String comicsOwnershipFilterLabel(ComicsOwnershipFilter filter) {
  return switch (filter) {
    ComicsOwnershipFilter.all => 'All comics',
    ComicsOwnershipFilter.owned => 'Owned',
    ComicsOwnershipFilter.wishlist => 'Wishlist',
    ComicsOwnershipFilter.missingGrade => 'Missing grade',
  };
}
