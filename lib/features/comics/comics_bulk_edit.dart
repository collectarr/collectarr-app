import 'package:flutter/material.dart';

class ComicsBulkEditSelection {
  const ComicsBulkEditSelection({
    this.condition,
    this.grade,
    this.storageBox,
    this.tags,
    this.readStatus,
  });

  final String? condition;
  final String? grade;
  final String? storageBox;
  final String? tags;
  final String? readStatus;
}

class ComicsBulkEditDialog extends StatefulWidget {
  const ComicsBulkEditDialog({
    super.key,
    required this.conditions,
    required this.grades,
  });

  final List<String> conditions;
  final List<String> grades;

  @override
  State<ComicsBulkEditDialog> createState() => _ComicsBulkEditDialogState();
}

class _ComicsBulkEditDialogState extends State<ComicsBulkEditDialog> {
  String? _condition;
  String? _grade;
  String? _readStatus;
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
    return AlertDialog(
      title: const Text('Bulk edit'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Keep current')),
                for (final option in widget.conditions)
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
            DropdownButtonFormField<String>(
              initialValue: _grade,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Keep current')),
                for (final option in widget.grades)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (value) {
                setState(
                  () => _grade = value == null || value.isEmpty ? null : value,
                );
              },
            ),
            const SizedBox(height: 12),
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
                labelText: 'Read status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('Keep current')),
                DropdownMenuItem(value: 'Unread', child: Text('Unread')),
                DropdownMenuItem(value: 'Reading', child: Text('Reading')),
                DropdownMenuItem(value: 'Read', child: Text('Read')),
              ],
              onChanged: (value) {
                setState(() => _readStatus =
                    value == null || value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ComicsBulkEditSelection(
              condition: _condition,
              grade: _grade,
              storageBox: _emptyToNull(_storageBoxController.text),
              tags: _emptyToNull(_tagsController.text),
              readStatus: _readStatus,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
