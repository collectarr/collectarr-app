import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/barcode/barcode_batch_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _LoanFilter { all, active, overdue, returned }

class LoanManagerPage extends ConsumerStatefulWidget {
  const LoanManagerPage({super.key});

  @override
  ConsumerState<LoanManagerPage> createState() => _LoanManagerPageState();
}

class _LoanManagerPageState extends ConsumerState<LoanManagerPage> {
  final _barcodeController = TextEditingController();
  final _queryController = TextEditingController();
  var _filter = _LoanFilter.active;
  var _loading = true;
  List<Loan> _loans = const [];
  Map<String, OwnedItem> _ownedById = const {};
  Map<String, List<OwnedItem>> _ownedByCatalogId = const {};
  Map<String, CatalogItem> _catalogById = const {};
  Map<String, String> _locationLabelsById = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final db = ref.read(localDatabaseProvider);
    final loansRepo = LoanRepository(db);
    final ownedRepo = OwnedItemsCacheRepository(db);
    final catalogRepo = CatalogCacheRepository(db);
    final locationRepo = LocationRepository(db);

    final loans = await loansRepo.getAllLoans();
    final ownedItems = await ownedRepo.listActive();
    final catalogIds = ownedItems.map((item) => item.catalogRef.id);
    final catalogById = await catalogRepo.findByIds(catalogIds);
    final locations = await locationRepo.getAll();
    final locationLabelsById = {
      for (final location in locations)
        location.id: location.fullPath(locations),
    };
    final ownedById = {
      for (final item in ownedItems) item.id: item,
    };
    final ownedByCatalogId = <String, List<OwnedItem>>{};
    for (final item in ownedItems) {
      ownedByCatalogId.putIfAbsent(item.itemId, () => <OwnedItem>[]).add(item);
    }
    for (final copies in ownedByCatalogId.values) {
      copies.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _loans = loans;
      _ownedById = ownedById;
      _ownedByCatalogId = ownedByCatalogId;
      _catalogById = catalogById;
      _locationLabelsById = locationLabelsById;
      _loading = false;
    });
  }

  List<Loan> _filteredLoans() {
    final query = _queryController.text.trim().toLowerCase();
    final now = DateTime.now();
    final filtered = _loans.where((loan) {
      final active = loan.isActive;
      final overdue = loan.isOverdueAt(now);
      final matchesFilter = switch (_filter) {
        _LoanFilter.all => true,
        _LoanFilter.active => active,
        _LoanFilter.overdue => overdue,
        _LoanFilter.returned => !active,
      };
      if (!matchesFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final owned = _ownedById[loan.ownedItemId];
      final title =
          owned == null ? '' : _catalogById[owned.itemId]?.title ?? '';
      return loan.borrowerName.toLowerCase().contains(query) ||
          (loan.notes ?? '').toLowerCase().contains(query) ||
          loan.ownedItemId.toLowerCase().contains(query) ||
          title.toLowerCase().contains(query);
    }).toList(growable: false);
    filtered.sort((a, b) {
      final aOverdue = a.isOverdueAt(now);
      final bOverdue = b.isOverdueAt(now);
      if (aOverdue != bOverdue) {
        return aOverdue ? -1 : 1;
      }
      if (a.isActive != b.isActive) {
        return a.isActive ? -1 : 1;
      }
      final dueCompare =
          (a.dueDate ?? DateTime(9999)).compareTo(b.dueDate ?? DateTime(9999));
      if (dueCompare != 0) {
        return dueCompare;
      }
      return b.lentDate.compareTo(a.lentDate);
    });
    return filtered;
  }

  Future<void> _scanBarcode() async {
    final barcodes = await showBarcodeBatchScanSheet(context);
    if (barcodes == null || barcodes.isEmpty || !mounted) {
      return;
    }
    setState(() {
      _barcodeController.text = barcodes.first;
    });
  }

  Future<OwnedItem?> _resolveOwnedItemFromBarcode(String barcode) async {
    final catalog =
        await CatalogCacheRepository(ref.read(localDatabaseProvider))
            .findByBarcode(barcode);
    if (catalog == null) {
      return null;
    }
    final ownedItems = _ownedByCatalogId[catalog.id] ??
        await OwnedItemsCacheRepository(ref.read(localDatabaseProvider))
            .findActiveByItemIds([catalog.id]);
    if (ownedItems.isEmpty) {
      return null;
    }
    if (ownedItems.length == 1) {
      return ownedItems.single;
    }
    return _pickOwnedItem(ownedItems, catalog.title);
  }

  Future<OwnedItem?> _pickOwnedItem(
      List<OwnedItem> ownedItems, String title) async {
    return showDialog<OwnedItem>(
      context: context,
      builder: (context) => _OwnedItemPickerDialog(
        title: title,
        ownedItems: ownedItems,
        locationLabelsById: _locationLabelsById,
      ),
    );
  }

  Future<void> _loanByBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      showAppToast(context, 'Enter or scan a barcode first.',
          tone: AppToastTone.info);
      return;
    }
    final ownedItem = await _resolveOwnedItemFromBarcode(barcode);
    if (!mounted) {
      return;
    }
    if (ownedItem == null) {
      showAppToast(context, 'No owned item found for barcode $barcode.',
          tone: AppToastTone.error);
      return;
    }
    await _createLoan(ownedItem);
  }

  Future<void> _returnByBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      showAppToast(context, 'Enter or scan a barcode first.',
          tone: AppToastTone.info);
      return;
    }
    final ownedItem = await _resolveOwnedItemFromBarcode(barcode);
    if (!mounted) {
      return;
    }
    if (ownedItem == null) {
      showAppToast(context, 'No owned item found for barcode $barcode.',
          tone: AppToastTone.error);
      return;
    }
    final activeLoans = _loans
        .where((loan) => loan.ownedItemId == ownedItem.id && loan.isActive)
        .toList();
    if (activeLoans.isEmpty) {
      showAppToast(context, 'No active loan found for that item.',
          tone: AppToastTone.info);
      return;
    }
    final loan = activeLoans.length == 1
        ? activeLoans.single
        : await _pickLoan(activeLoans,
            _catalogById[ownedItem.itemId]?.title ?? ownedItem.itemId);
    if (loan == null || !mounted) {
      return;
    }
    await LoanRepository(ref.read(localDatabaseProvider)).markReturned(loan.id);
    await _load();
  }

  Future<Loan?> _pickLoan(List<Loan> loans, String title) async {
    return showDialog<Loan>(
      context: context,
      builder: (context) => _ActiveLoanPickerDialog(
        title: title,
        loans: loans,
      ),
    );
  }

  Future<void> _createLoan(OwnedItem ownedItem) async {
    final catalogTitle =
        _catalogById[ownedItem.itemId]?.title ?? ownedItem.itemId;
    final draft = await showDialog<_LoanDraft>(
      context: context,
      builder: (context) => _LoanCreateDialog(
        title: catalogTitle,
        accent: LibraryAccentScope.accentOf(context),
      ),
    );
    if (draft == null || !mounted) {
      return;
    }
    final repo = LoanRepository(ref.read(localDatabaseProvider));
    await repo.create(
      Loan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        ownedItemId: ownedItem.id,
        catalogRef: ownedItem.catalogRef,
        borrowerName: draft.borrowerName,
        lentDate: draft.lentDate,
        dueDate: draft.dueDate,
        notes: draft.notes,
      ),
    );
    await _load();
  }

  Future<void> _returnLoan(Loan loan) async {
    await LoanRepository(ref.read(localDatabaseProvider)).markReturned(loan.id);
    await _load();
  }

  Future<void> _deleteLoan(Loan loan) async {
    await LoanRepository(ref.read(localDatabaseProvider)).delete(loan.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final animationDuration = LibraryAccentScope.animationDurationOf(context);
    final filteredLoans = _filteredLoans();
    final now = DateTime.now();
    final activeCount = _loans.where((loan) => loan.isActive).length;
    final overdueCount = _loans.where((loan) => loan.isOverdueAt(now)).length;
    final returnedCount = _loans.where((loan) => !loan.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: animationDuration,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh loans',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _LoanSummaryRow(
                    total: _loans.length,
                    active: activeCount,
                    overdue: overdueCount,
                    returned: returnedCount,
                    accent: accent,
                  ),
                  const SizedBox(height: 12),
                  _LoanActionStrip(
                    barcodeController: _barcodeController,
                    queryController: _queryController,
                    filter: _filter,
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onScanBarcode: _scanBarcode,
                    onLoanByBarcode: _loanByBarcode,
                    onReturnByBarcode: _returnByBarcode,
                    onSearchChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  if (filteredLoans.isEmpty)
                    const _EmptyLoansState()
                  else
                    for (final loan in filteredLoans)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LoanRow(
                          loan: loan,
                          title: _loanTitle(loan),
                          barcode: _loanBarcode(loan),
                          accent: accent,
                          isOverdue: loan.isOverdueAt(now),
                          onReturn:
                              loan.isActive ? () => _returnLoan(loan) : null,
                          onDelete: () => _deleteLoan(loan),
                        ),
                      ),
                ],
              ),
            ),
    );
  }

  String _loanTitle(Loan loan) {
    final owned = _ownedById[loan.ownedItemId];
    return owned == null
        ? 'Unknown item'
        : _catalogById[owned.itemId]?.title ?? owned.itemId;
  }

  String? _loanBarcode(Loan loan) {
    final owned = _ownedById[loan.ownedItemId];
    if (owned == null) {
      return null;
    }
    return _catalogById[owned.itemId]?.barcode;
  }
}

class _LoanSummaryRow extends StatelessWidget {
  const _LoanSummaryRow({
    required this.total,
    required this.active,
    required this.overdue,
    required this.returned,
    required this.accent,
  });

  final int total;
  final int active;
  final int overdue;
  final int returned;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SummaryChip(
            label: '$total total',
            icon: Icons.inventory_2_outlined,
            accent: accent),
        _SummaryChip(
            label: '$active active', icon: Icons.book_outlined, accent: accent),
        _SummaryChip(
            label: '$overdue overdue',
            icon: Icons.warning_amber_outlined,
            accent: Colors.orange),
        _SummaryChip(
            label: '$returned returned',
            icon: Icons.assignment_return_outlined,
            accent: Colors.green),
      ],
    );
  }
}

class _LoanActionStrip extends StatelessWidget {
  const _LoanActionStrip({
    required this.barcodeController,
    required this.queryController,
    required this.filter,
    required this.onFilterChanged,
    required this.onScanBarcode,
    required this.onLoanByBarcode,
    required this.onReturnByBarcode,
    required this.onSearchChanged,
  });

  final TextEditingController barcodeController;
  final TextEditingController queryController;
  final _LoanFilter filter;
  final ValueChanged<_LoanFilter> onFilterChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onLoanByBarcode;
  final VoidCallback onReturnByBarcode;
  final VoidCallback onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode / UPC / ISBN',
                  prefixIcon: const Icon(Icons.qr_code_scanner),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'Scan barcode',
                    onPressed: onScanBarcode,
                    icon: const Icon(Icons.document_scanner_outlined),
                  ),
                ),
                onSubmitted: (_) => onLoanByBarcode(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onLoanByBarcode,
              icon: const Icon(Icons.book_outlined),
              label: const Text('Loan out'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onReturnByBarcode,
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('Return'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: queryController,
          decoration: const InputDecoration(
            labelText: 'Search loans',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => onSearchChanged(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in const [
              (_LoanFilter.all, 'All'),
              (_LoanFilter.active, 'Active'),
              (_LoanFilter.overdue, 'Overdue'),
              (_LoanFilter.returned, 'Returned'),
            ])
              FilterChip(
                selected: filter == entry.$1,
                label: Text(entry.$2),
                onSelected: (_) => onFilterChanged(entry.$1),
              ),
          ],
        ),
      ],
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({
    required this.loan,
    required this.title,
    required this.barcode,
    required this.accent,
    required this.isOverdue,
    required this.onReturn,
    required this.onDelete,
  });

  final Loan loan;
  final String title;
  final String? barcode;
  final Color accent;
  final bool isOverdue;
  final VoidCallback? onReturn;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              loan.isActive
                  ? (isOverdue
                      ? Icons.warning_amber_outlined
                      : Icons.book_outlined)
                  : Icons.assignment_return_outlined,
              color: isOverdue
                  ? Colors.orange
                  : loan.isActive
                      ? accent
                      : colorScheme.onSurfaceVariant,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _MiniChip(label: loan.borrowerName),
            _MiniChip(label: loan.isActive ? 'loaned' : 'returned'),
            if (loan.dueDate != null)
              _MiniChip(label: 'due ${_fmt(loan.dueDate!)}'),
            if (loan.returnedDate != null)
              _MiniChip(label: 'returned ${_fmt(loan.returnedDate!)}'),
            _MiniChip(label: 'lent ${_fmt(loan.lentDate)}'),
            if (barcode != null) _MiniChip(label: barcode!),
            if (loan.notes != null && loan.notes!.trim().isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  loan.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (onReturn != null)
              FilledButton.tonalIcon(
                onPressed: onReturn,
                icon: const Icon(Icons.assignment_return_outlined),
                label: const Text('Return'),
              ),
            OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnedItemPickerDialog extends StatelessWidget {
  const _OwnedItemPickerDialog({
    required this.title,
    required this.ownedItems,
    required this.locationLabelsById,
  });

  final String title;
  final List<OwnedItem> ownedItems;
  final Map<String, String> locationLabelsById;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose copy for $title'),
      content: SizedBox(
        width: 520,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: ownedItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = ownedItems[index];
            final location = locationLabelsById[item.locationId];
            return ListTile(
              title: Text(item.condition ?? item.id),
              subtitle: Text([
                if (item.grade != null) item.grade!,
                if (location != null) location,
                if (item.purchaseDate != null) _fmt(item.purchaseDate!),
              ].where((value) => value.isNotEmpty).join(' · ')),
              onTap: () => Navigator.of(context).pop(item),
            );
          },
        ),
      ),
    );
  }
}

class _ActiveLoanPickerDialog extends StatelessWidget {
  const _ActiveLoanPickerDialog({
    required this.title,
    required this.loans,
  });

  final String title;
  final List<Loan> loans;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose active loan for $title'),
      content: SizedBox(
        width: 520,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: loans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final loan = loans[index];
            return ListTile(
              title: Text(loan.borrowerName),
              subtitle: Text([
                'lent ${_fmt(loan.lentDate)}',
                if (loan.dueDate != null) 'due ${_fmt(loan.dueDate!)}',
              ].join(' · ')),
              onTap: () => Navigator.of(context).pop(loan),
            );
          },
        ),
      ),
    );
  }
}

class _LoanDraft {
  const _LoanDraft({
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

class _LoanCreateDialog extends StatefulWidget {
  const _LoanCreateDialog({
    required this.title,
    required this.accent,
  });

  final String title;
  final Color accent;

  @override
  State<_LoanCreateDialog> createState() => _LoanCreateDialogState();
}

class _LoanCreateDialogState extends State<_LoanCreateDialog> {
  final _borrowerController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _lentDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void dispose() {
    _borrowerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Loan out ${widget.title}'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _borrowerController,
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
                    onChanged: (value) => setState(() => _lentDate = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'Due date',
                    value: _dueDate,
                    onChanged: (value) => setState(() => _dueDate = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
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
          onPressed: _borrowerController.text.trim().isEmpty
              ? null
              : () {
                  Navigator.of(context).pop(
                    _LoanDraft(
                      borrowerName: _borrowerController.text.trim(),
                      lentDate: _lentDate,
                      dueDate: _dueDate,
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    ),
                  );
                },
          style: FilledButton.styleFrom(backgroundColor: widget.accent),
          child: const Text('Lend'),
        ),
      ],
    );
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
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(value == null ? '—' : _fmt(value!)),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: accent),
      label: Text(label),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EmptyLoansState extends StatelessWidget {
  const _EmptyLoansState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text('No loans match the current filter.')),
    );
  }
}

String _fmt(DateTime dt) {
  final local = dt.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
