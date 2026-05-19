import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:flutter/material.dart';

class LibraryBulkEditSelection {
  const LibraryBulkEditSelection({
    this.condition,
    this.grade,
    this.storageBox,
    this.tags,
    this.readStatus,
    this.rating,
  });

  final String? condition;
  final String? grade;
  final String? storageBox;
  final String? tags;
  final String? readStatus;
  final int? rating;
}

class LibraryBulkEditDialog extends StatefulWidget {
  const LibraryBulkEditDialog({
    super.key,
    required this.type,
    required this.selectedCount,
  });

  final LibraryTypeConfig type;
  final int selectedCount;

  @override
  State<LibraryBulkEditDialog> createState() => _LibraryBulkEditDialogState();
}

class _LibraryBulkEditDialogState extends State<LibraryBulkEditDialog> {
  String? _condition;
  String? _grade;
  String? _readStatus;
  int? _rating;
  final _storageBoxController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _storageBoxController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingOptions = widget.type.trackingProfile.options;
    final conditions = widget.type.conditions;
    final grades = widget.type.grades;
    return AlertDialog(
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
            TextField(
              controller: _storageBoxController,
              decoration: const InputDecoration(
                labelText: 'Storage box',
                hintText: 'Leave blank to keep current',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Leave blank to keep current',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _readStatus,
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
              storageBox: _emptyToNull(_storageBoxController.text),
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
}
