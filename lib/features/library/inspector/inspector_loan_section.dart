import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:uuid/uuid.dart';

class InspectorLoanSection extends StatefulWidget {
  const InspectorLoanSection({
    super.key,
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  @override
  State<InspectorLoanSection> createState() => _InspectorLoanSectionState();
}

class _InspectorLoanSectionState extends State<InspectorLoanSection> {
  List<Loan> _loans = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(InspectorLoanSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownedItemId != widget.ownedItemId) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = LoanRepository(widget.db);
    final loans = await repo.getLoansForItem(widget.ownedItemId);
    if (mounted) {
      setState(() {
        _loans = loans;
        _loading = false;
      });
    }
  }

  Future<void> _addLoan() async {
    final result = await showDialog<Loan>(
      context: context,
      builder: (context) => _LoanCreateDialog(
        ownedItemId: widget.ownedItemId,
        accent: widget.accent,
      ),
    );
    if (result != null) {
      await LoanRepository(widget.db).create(result);
      await _load();
    }
  }

  Future<void> _returnLoan(Loan loan) async {
    await LoanRepository(widget.db).markReturned(loan.id);
    await _load();
  }

  Future<void> _deleteLoan(Loan loan) async {
    await LoanRepository(widget.db).delete(loan.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    final activeLoans = _loans.where((l) => l.isActive).toList();
    final pastLoans = _loans.where((l) => !l.isActive).toList();

    return LibraryDetailSection(
      title: 'Loans',
      accentColor: widget.accent,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: 'Lend this item',
            onPressed: _addLoan,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              foregroundColor: widget.accent,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_loans.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surfaceSubtle.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.divider.withValues(alpha: 0.8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: palette.textMuted.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 16,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Not currently lent out.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: palette.textMuted,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Use the add action to record a new loan for this item.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          for (final loan in activeLoans)
            _LoanTile(
              loan: loan,
              accent: widget.accent,
              onReturn: () => _returnLoan(loan),
              onDelete: () => _deleteLoan(loan),
            ),
          if (pastLoans.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'History',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: widget.accent.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 6),
            for (final loan in pastLoans.take(5))
              _LoanTile(
                loan: loan,
                accent: widget.accent,
                onReturn: null,
                onDelete: () => _deleteLoan(loan),
              ),
          ],
        ],
      ],
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({
    required this.loan,
    required this.accent,
    required this.onReturn,
    required this.onDelete,
  });

  final Loan loan;
  final Color accent;
  final VoidCallback? onReturn;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isOverdue = loan.isOverdueAt(DateTime.now());
    final indicatorColor = isOverdue
        ? Colors.orange
        : loan.isActive
            ? accent
            : palette.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surfaceSubtle.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.divider.withValues(alpha: 0.8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: indicatorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  loan.isActive
                      ? (isOverdue ? Icons.warning_amber : Icons.person_outline)
                      : Icons.check_circle_outline,
                  size: 16,
                  color: indicatorColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.borrowerName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isOverdue ? Colors.orange : null,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (onReturn != null)
                IconButton(
                  icon: const Icon(Icons.assignment_return, size: 16),
                  tooltip: 'Mark returned',
                  onPressed: onReturn,
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: accent,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                tooltip: 'Delete loan record',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  foregroundColor: palette.textMuted,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    final lent = formatDate(loan.lentDate);
    if (loan.returnedDate != null) {
      return 'Lent $lent · returned ${formatDate(loan.returnedDate!)}';
    }
    if (loan.dueDate != null) {
      return 'Lent $lent · due ${formatDate(loan.dueDate!)}';
    }
    return 'Lent $lent';
  }
}

class _LoanCreateDialog extends StatefulWidget {
  const _LoanCreateDialog({
    required this.ownedItemId,
    required this.accent,
  });

  final String ownedItemId;
  final Color accent;

  @override
  State<_LoanCreateDialog> createState() => _LoanCreateDialogState();
}

class _LoanCreateDialogState extends State<_LoanCreateDialog> {
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
      title: Text('Lend Item', style: TextStyle(color: widget.accent)),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Borrower / contact',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Lent date',
                    value: _lentDate,
                    onChanged: (d) => setState(() => _lentDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'Due date (optional)',
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
          child: const Text('Lend'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final loan = Loan(
      id: const Uuid().v4(),
      ownedItemId: widget.ownedItemId,
      borrowerName: name,
      lentDate: _lentDate,
      dueDate: _dueDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.pop(context, loan);
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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
        : '—';
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(display),
      ),
    );
  }
}
