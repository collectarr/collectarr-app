import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

class BatchLoanDraft {
  const BatchLoanDraft({
    required this.borrowerName,
    required this.lentDate,
    this.dueDate,
    this.notes,
  });

  final String borrowerName;
  final DateTime lentDate;
  final DateTime? dueDate;
  final String? notes;
}

class BatchLoanDialog extends StatefulWidget {
  const BatchLoanDialog({
    super.key,
    required this.accent,
    required this.itemCount,
  });

  final Color accent;
  final int itemCount;

  @override
  State<BatchLoanDialog> createState() => _BatchLoanDialogState();
}

class _BatchLoanDialogState extends State<BatchLoanDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _lentDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Loan ${widget.itemCount} items',
        style: TextStyle(color: widget.accent),
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Borrower name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BatchLoanDatePickerField(
                    label: 'Lent date',
                    value: _lentDate,
                    onChanged: (d) => setState(() => _lentDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BatchLoanDatePickerField(
                    label: 'Due date',
                    value: _dueDate,
                    onChanged: (d) => setState(() => _dueDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: widget.accent),
          child: const Text('Loan'),
        ),
      ],
    );
  }

  void _submit() {
    final borrowerName = _nameController.text.trim();
    if (borrowerName.isEmpty) return;
    Navigator.pop(
      context,
      BatchLoanDraft(
        borrowerName: borrowerName,
        lentDate: _lentDate,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }
}

class _BatchLoanDatePickerField extends StatelessWidget {
  const _BatchLoanDatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
        : 'Select';
    return OutlinedButton(
      onPressed: () async {
        final initialDate = value ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(height: 2),
          Text(display),
        ],
      ),
    );
  }
}
