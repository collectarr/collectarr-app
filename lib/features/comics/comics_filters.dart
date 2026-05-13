import 'package:flutter/material.dart';

enum ComicsOwnershipFilter { all, owned, wishlist, missingGrade }

class ComicsFilterSelection {
  const ComicsFilterSelection({
    required this.ownershipFilter,
    this.grade,
    this.condition,
    this.publisher,
    this.releaseYear,
  });

  final ComicsOwnershipFilter ownershipFilter;
  final String? grade;
  final String? condition;
  final String? publisher;
  final String? releaseYear;
}

class ComicsFilterDialog extends StatefulWidget {
  const ComicsFilterDialog({
    super.key,
    required this.initialSelection,
    required this.gradeOptions,
    required this.conditionOptions,
    required this.publisherOptions,
    required this.releaseYearOptions,
  });

  final ComicsFilterSelection initialSelection;
  final List<String> gradeOptions;
  final List<String> conditionOptions;
  final List<String> publisherOptions;
  final List<String> releaseYearOptions;

  @override
  State<ComicsFilterDialog> createState() => _ComicsFilterDialogState();
}

class _ComicsFilterDialogState extends State<ComicsFilterDialog> {
  late ComicsOwnershipFilter _ownershipFilter;
  String? _grade;
  String? _condition;
  String? _publisher;
  String? _releaseYear;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelection;
    _ownershipFilter = initial.ownershipFilter;
    _grade = initial.grade;
    _condition = initial.condition;
    _publisher = initial.publisher;
    _releaseYear = initial.releaseYear;
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
                grade: _grade,
                condition: _condition,
                publisher: _publisher,
                releaseYear: _releaseYear,
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
