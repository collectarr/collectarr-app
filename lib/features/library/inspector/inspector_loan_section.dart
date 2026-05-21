import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';
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
    final activeLoans = _loans.where((l) => l.isActive).toList();
    final pastLoans = _loans.where((l) => !l.isActive).toList();

    return LibraryInspectorSection(
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Not currently lent out.',
              style: TextStyle(color: kClzTextMuted, fontSize: 13),
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
              style: TextStyle(
                color: widget.accent.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
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
    final isOverdue = loan.isOverdue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            loan.isActive
                ? (isOverdue ? Icons.warning_amber : Icons.person_outline)
                : Icons.check_circle_outline,
            size: 16,
            color: isOverdue
                ? Colors.orange
                : loan.isActive
                    ? accent
                    : kClzTextMuted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.borrowerName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isOverdue ? Colors.orange : null,
                  ),
                ),
                Text(
                  _subtitle,
                  style: const TextStyle(
                    color: kClzTextMuted,
                    fontSize: 11,
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
              foregroundColor: kClzTextMuted,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final lent = _formatDate(loan.lentDate);
    if (loan.returnedDate != null) {
      return 'Lent $lent · returned ${_formatDate(loan.returnedDate!)}';
    }
    if (loan.dueDate != null) {
      return 'Lent $lent · due ${_formatDate(loan.dueDate!)}';
    }
    return 'Lent $lent';
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
    return AlertDialog(
      backgroundColor: kClzPanel,
      title: Text('Lend Item', style: TextStyle(color: widget.accent)),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Borrower name',
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
