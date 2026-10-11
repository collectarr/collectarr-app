import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_workspace_detail_navigation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/barcode/barcode_batch_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_repository.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _LoanFilter { all, active, overdue, returned }

class LoanManagerPage extends ConsumerStatefulWidget {
  const LoanManagerPage({super.key, this.kind});
  final CatalogMediaKind? kind;

  @override
  ConsumerState<LoanManagerPage> createState() => _LoanManagerPageState();
}

class _LoanManagerPageState extends ConsumerState<LoanManagerPage> {
  final _barcodeController = TextEditingController();
  final _queryController = TextEditingController();
  var _filter = _LoanFilter.active;
  var _loading = true;
  int _loadGeneration = 0;
  String? _borrower;
  List<Loan> _loans = const [];
  Map<LibraryEntryRef, LibraryEntrySummary> _entryByRef = const {};
  Map<LibraryEntryRef, LibraryWorkspaceKindData> _kindPresentationByEntryRef =
      const {};
  Map<CatalogItemRef, List<LibraryEntrySummary>> _entryByCatalogRef = const {};

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

  @override
  void didUpdateWidget(covariant LoanManagerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) {
      _borrower = null;
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    setState(() {
      _loading = true;
    });
    try {
      final db = ref.read(localDatabaseProvider);
      final loansRepo = LoanRepository(db);
      final entryRepo = LibraryEntriesRepository(db);
      final locationRepo = LocationRepository(db);

      final loans = (await loansRepo.getAllLoans())
          .where((loan) =>
              widget.kind == null || loan.libraryEntryRef.kind == widget.kind)
          .toList();
      final libraryEntries = (await entryRepo.listActiveSummaries())
          .where(
              (entry) => widget.kind == null || entry.ref.kind == widget.kind)
          .toList();
      final kindPresentationByEntryRef =
          await CatalogWorkspaceDataRepository(db)
              .findEntries(libraryEntries.map((item) => item.ref));
      final locations = await locationRepo.getAll();
      final locationLabelsById = {
        for (final location in locations)
          location.id: location.fullPath(locations),
      };
      final summaries = [
        for (final item in libraryEntries)
          item.copyWith(
            locationLabel: item.locationLabel == null
                ? null
                : locationLabelsById[item.locationLabel!],
          ),
      ];
      final entryByCatalogRef = <CatalogItemRef, List<LibraryEntrySummary>>{};
      for (final item in summaries) {
        final localItemRef = item.sourceCatalogRef;
        if (localItemRef == null) continue;
        entryByCatalogRef
            .putIfAbsent(localItemRef, () => <LibraryEntrySummary>[])
            .add(item);
      }
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      setState(() {
        _loans = loans;
        _entryByRef = {
          for (final item in summaries) item.ref: item,
        };
        _kindPresentationByEntryRef = kindPresentationByEntryRef;
        _entryByCatalogRef = entryByCatalogRef;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _loading = false);
      showAppToast(context, 'Could not load loans: $error',
          tone: AppToastTone.error);
    }
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
      if (_borrower != null && loan.borrowerName != _borrower) return false;
      if (!matchesFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final entry = _entryByRef[loan.libraryEntryRef];
      final title = entry == null ? '' : _catalogTitleFor(entry);
      return loan.borrowerName.toLowerCase().contains(query) ||
          (loan.notes ?? '').toLowerCase().contains(query) ||
          loan.libraryEntryRef.id.value.toLowerCase().contains(query) ||
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
      _barcodeController.text = barcodes.first.value;
    });
  }

  Future<LibraryEntrySummary?> _resolveLibraryEntryFromBarcode(
      String barcode) async {
    final workspace = await ref.read(shelfProvider.future);
    final matching = <LibraryEntrySummary>[];
    for (final source in workspace.entries) {
      if (!source.isEntry ||
          (widget.kind != null && source.mediaKind != widget.kind)) {
        continue;
      }
      final card = libraryPresentationForKind(source.mediaKind)
          .buildCardPresentation(
              LibraryProjectionItem.fromShelf(
                  source, libraryKindRegistrationForKind(source.mediaKind)),
              coverFocused: false);
      if (card.identifierCode == barcode) {
        matching.add(source.libraryEntrySummary!);
      }
    }
    if (matching.length == 1) return matching.single;
    if (matching.length > 1) return _pickLibraryEntry(matching, barcode);
    final catalog = await CatalogLookupRepository(
      ref.read(localDatabaseProvider),
    ).resolve(CatalogLookupQuery(value: barcode), kind: widget.kind);
    if (catalog == null) {
      return null;
    }
    final libraryEntries = _entryByCatalogRef[catalog.ref] ?? const [];
    if (libraryEntries.isEmpty) {
      return null;
    }
    if (libraryEntries.length == 1) {
      return libraryEntries.single;
    }
    return _pickLibraryEntry(libraryEntries, catalog.title);
  }

  Future<LibraryEntrySummary?> _pickLibraryEntry(
      List<LibraryEntrySummary> libraryEntries, String title) async {
    return showDialog<LibraryEntrySummary>(
      context: context,
      builder: (context) => _LibraryEntryPickerDialog(
        title: title,
        libraryEntries: libraryEntries,
      ),
    );
  }

  Future<void> _loanByBarcode() async {
    try {
      final barcode = _barcodeController.text.trim();
      if (barcode.isEmpty) {
        showAppToast(context, 'Enter or scan a barcode first.',
            tone: AppToastTone.info);
        return;
      }
      final libraryEntry = await _resolveLibraryEntryFromBarcode(barcode);
      if (!mounted) {
        return;
      }
      if (libraryEntry == null) {
        showAppToast(context, 'No collection item found for barcode $barcode.',
            tone: AppToastTone.error);
        return;
      }
      await _createLoan(libraryEntry);
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not lend this item: $error',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _returnByBarcode() async {
    try {
      final barcode = _barcodeController.text.trim();
      if (barcode.isEmpty) {
        showAppToast(context, 'Enter or scan a barcode first.',
            tone: AppToastTone.info);
        return;
      }
      final libraryEntry = await _resolveLibraryEntryFromBarcode(barcode);
      if (!mounted) {
        return;
      }
      if (libraryEntry == null) {
        showAppToast(context, 'No collection item found for barcode $barcode.',
            tone: AppToastTone.error);
        return;
      }
      final activeLoans = _loans
          .where((loan) =>
              loan.libraryEntryRef == libraryEntry.ref && loan.isActive)
          .toList();
      if (activeLoans.isEmpty) {
        showAppToast(context, 'No active loan found for that item.',
            tone: AppToastTone.info);
        return;
      }
      final loan = activeLoans.length == 1
          ? activeLoans.single
          : await _pickLoan(activeLoans, _catalogTitleFor(libraryEntry));
      if (loan == null || !mounted) {
        return;
      }
      await _returnLoan(loan);
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not return this item: $error',
            tone: AppToastTone.error);
      }
    }
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

  Future<void> _createLoan(LibraryEntrySummary libraryEntry) async {
    try {
      final catalogTitle = _catalogTitleFor(libraryEntry);
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
      final loan = Loan(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          libraryEntryRef: libraryEntry.ref,
          borrowerName: draft.borrowerName,
          lentDate: draft.lentDate,
          dueDate: draft.dueDate,
          notes: draft.notes);
      await _writeLoan(loan, (repository) => repository.create(loan));
      await _load();
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not create loan: $error',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _writeLoan(Loan loan,
      Future<void> Function(LoanRepository repository) action) async {
    final database = ref.read(localDatabaseProvider);
    await database.transaction(() async {
      await action(LoanRepository(database));
      await enqueueLibraryEntrySnapshot(database, loan.libraryEntryRef);
    });
    ref.invalidate(shelfProvider);
  }

  Future<void> _returnLoan(Loan loan) async {
    try {
      await _writeLoan(loan, (repository) => repository.markReturned(loan.id));
      await _load();
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not update loan: $error',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _deleteLoan(Loan loan) async {
    try {
      await _writeLoan(loan, (repository) => repository.delete(loan.id));
      await _load();
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not update loan: $error',
            tone: AppToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final filteredLoans = _filteredLoans();
    final now = DateTime.now();
    final borrowers = _loans.map((loan) => loan.borrowerName).toSet().toList()
      ..sort();
    return Scaffold(
      backgroundColor: appManagementCanvasColor(context),
      appBar: AppPageHeader(
          icon: Icons.people_outline,
          title: const Text('Loan Manager'),
          actions: [
            IconButton(
              tooltip: 'Refresh loans',
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
          ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Wrap(
                              spacing: 16,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                for (final tab in [
                                  (
                                    label: 'Current Loans',
                                    filter: _LoanFilter.active
                                  ),
                                  (
                                    label: 'Loan History',
                                    filter: _LoanFilter.returned
                                  )
                                ])
                                  TextButton(
                                      onPressed: () =>
                                          setState(() => _filter = tab.filter),
                                      style: TextButton.styleFrom(
                                          foregroundColor: _filter == tab.filter
                                              ? accent
                                              : appPalette(context).textPrimary,
                                          shape: const RoundedRectangleBorder(),
                                          side: BorderSide(
                                              color: _filter == tab.filter
                                                  ? accent
                                                  : Colors.transparent)),
                                      child: Text(tab.label,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700))),
                                SizedBox(
                                    width: 210,
                                    child: DropdownButtonFormField<String>(
                                        key: ValueKey(_borrower),
                                        initialValue: _borrower ?? '',
                                        isExpanded: true,
                                        items: [
                                          const DropdownMenuItem(
                                              value: '',
                                              child: Text('all loaners')),
                                          for (final name in borrowers)
                                            DropdownMenuItem(
                                                value: name, child: Text(name))
                                        ],
                                        onChanged: (name) => setState(() =>
                                            _borrower =
                                                name == '' ? null : name))),
                                SizedBox(
                                    width: 210,
                                    child: TextField(
                                        controller: _queryController,
                                        onChanged: (_) => setState(() {}),
                                        decoration: const InputDecoration(
                                            hintText: 'Search loans',
                                            prefixIcon:
                                                Icon(Icons.search, size: 18),
                                            isDense: true))),
                                TextButton.icon(
                                    onPressed: filteredLoans.isEmpty
                                        ? null
                                        : () => _printLoans(filteredLoans),
                                    icon: const Icon(
                                        Icons.picture_as_pdf_outlined,
                                        size: 16),
                                    label: const Text('print to pdf')),
                              ]),
                          const Divider(height: 20),
                          Text('${filteredLoans.length} items'),
                          const SizedBox(height: 8),
                          if (MediaQuery.sizeOf(context).width >= 650 &&
                              filteredLoans.isNotEmpty)
                            _loanTable(filteredLoans, accent)
                          else if (filteredLoans.isEmpty)
                            const _EmptyLoansState()
                          else
                            for (final loan in filteredLoans)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _LoanRow(
                                  loan: loan,
                                  title: _loanTitle(loan),
                                  accent: accent,
                                  isOverdue: loan.isOverdueAt(now),
                                  onReturn: loan.isActive
                                      ? () => _returnLoan(loan)
                                      : null,
                                  onDelete: () => _deleteLoan(loan),
                                ),
                              ),
                          const SizedBox(height: 16),
                          ExpansionTile(
                              title: const Text('Lend / return by barcode'),
                              children: [
                                _LoanActionStrip(
                                  barcodeController: _barcodeController,
                                  filter: _filter,
                                  onFilterChanged: (value) =>
                                      setState(() => _filter = value),
                                  onScanBarcode: _scanBarcode,
                                  onLoanByBarcode: _loanByBarcode,
                                  onReturnByBarcode: _returnByBarcode,
                                ),
                              ]),
                        ],
                      ))),
            ),
    );
  }

  Widget _loanTable(List<Loan> loans, Color accent) => LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 32,
                headingRowColor: WidgetStatePropertyAll(
                    appPalette(context).isDark
                        ? const Color(0xFF44474F)
                        : appPalette(context).toolbar),
                dataRowColor: WidgetStatePropertyAll(appPalette(context).isDark
                    ? const Color(0xFF2B2B2B)
                    : appPalette(context).panel),
                dataRowMinHeight: 100,
                dataRowMaxHeight: 115,
                columnSpacing: 24,
                horizontalMargin: 8,
                columns: [
                  const DataColumn(label: Text('Album')),
                  const DataColumn(label: Text('Loaned To')),
                  DataColumn(
                      label: Text(_filter == _LoanFilter.returned
                          ? 'Returned Date'
                          : 'Due Date')),
                  const DataColumn(label: Text(''))
                ],
                rows: [
                  for (final loan in loans)
                    DataRow(cells: [
                      DataCell(InkWell(
                          onTap: () => _openLoanEntry(loan),
                          child: SizedBox(
                              width: 340,
                              child: Row(children: [
                                SizedBox(
                                    width: 60,
                                    height: 76,
                                    child: LibraryCoverImage(
                                        title: _loanTitle(loan),
                                        libraryEntryRef: loan.libraryEntryRef)),
                                const SizedBox(width: 10),
                                Expanded(child: _loanAlbumFacts(loan, accent)),
                              ])))),
                      DataCell(Text(loan.borrowerName)),
                      DataCell(Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _filter == _LoanFilter.returned
                                    ? (loan.returnedDate == null
                                        ? '-'
                                        : _fmt(loan.returnedDate!))
                                    : (loan.dueDate == null
                                        ? '-'
                                        : _fmt(loan.dueDate!)),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: loan.isOverdueAt(DateTime.now())
                                        ? Colors.orange
                                        : null)),
                            const SizedBox(height: 4),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.send_outlined, size: 14),
                              const SizedBox(width: 5),
                              Text(_fmt(loan.lentDate))
                            ]),
                            if (loan.notes?.isNotEmpty == true)
                              SizedBox(
                                  width: 180,
                                  child: Text(loan.notes!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                          ])),
                      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                        if (loan.isActive)
                          TextButton(
                              onPressed: () => _returnLoan(loan),
                              child: const Text('Return')),
                        IconButton(
                            tooltip: 'Delete loan record',
                            onPressed: () => _deleteLoan(loan),
                            icon: const Icon(Icons.delete_outline, size: 16))
                      ])),
                    ])
                ],
              ))));

  Widget _loanAlbumFacts(Loan loan, Color accent) {
    final source = ref
        .watch(shelfProvider)
        .asData
        ?.value
        .entries
        .where((entry) => entry.libraryEntryRef == loan.libraryEntryRef)
        .firstOrNull;
    final card = source == null
        ? null
        : libraryPresentationForKind(source.mediaKind).buildCardPresentation(
            LibraryProjectionItem.fromShelf(
                source, libraryKindRegistrationForKind(source.mediaKind)),
            coverFocused: false);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_loanTitle(loan),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
          if (card?.contextFacts.firstOrNull case final creator?)
            Text(creator, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (card?.identifierCode case final identifier?)
            Row(children: [
              const Icon(Icons.view_week_outlined, size: 16),
              const SizedBox(width: 4),
              Flexible(
                  child: Text(identifier,
                      style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
        ]);
  }

  Future<void> _openLoanEntry(Loan loan) async {
    try {
      final state = await ref.read(shelfProvider.future);
      final item = state.entries
          .where((entry) => entry.libraryEntryRef == loan.libraryEntryRef)
          .firstOrNull;
      if (!mounted) return;
      if (item == null) {
        showAppToast(context, 'This collection item is unavailable.',
            tone: AppToastTone.info);
        return;
      }
      await openWorkspaceEntryDetails(context, item);
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not open the album: $error',
            tone: AppToastTone.error);
      }
    }
  }

  Future<void> _printLoans(List<Loan> loans) async {
    try {
      final regular = pw.Font.ttf(
          await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'));
      final bold =
          pw.Font.ttf(await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'));
      final document =
          pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
      document.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (_) => [
                pw.Text(
                    _filter == _LoanFilter.returned
                        ? 'Loan History'
                        : 'Current Loans',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(headers: [
                  'Title',
                  'Loaner',
                  'Loan Date',
                  'Due Date',
                  'Returned Date',
                  'Notes'
                ], data: [
                  for (final loan in loans)
                    [
                      _loanTitle(loan),
                      loan.borrowerName,
                      _fmt(loan.lentDate),
                      loan.dueDate == null ? '' : _fmt(loan.dueDate!),
                      loan.returnedDate == null ? '' : _fmt(loan.returnedDate!),
                      loan.notes ?? ''
                    ]
                ]),
              ]));
      await Printing.sharePdf(
          bytes: await document.save(), filename: 'collectarr-loans.pdf');
    } catch (error) {
      if (mounted) {
        showAppToast(context, 'Could not export loans: $error',
            tone: AppToastTone.error);
      }
    }
  }

  String _loanTitle(Loan loan) {
    final entry = _entryByRef[loan.libraryEntryRef];
    return entry == null ? 'Unknown item' : _catalogTitleFor(entry);
  }

  String _catalogTitleFor(LibraryEntrySummary item) =>
      _kindPresentationByEntryRef[item.ref]?.displayLabel ?? 'Unknown title';
}

class _LoanActionStrip extends StatelessWidget {
  const _LoanActionStrip({
    required this.barcodeController,
    required this.filter,
    required this.onFilterChanged,
    required this.onScanBarcode,
    required this.onLoanByBarcode,
    required this.onReturnByBarcode,
  });

  final TextEditingController barcodeController;
  final _LoanFilter filter;
  final ValueChanged<_LoanFilter> onFilterChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onLoanByBarcode;
  final VoidCallback onReturnByBarcode;

  @override
  Widget build(BuildContext context) {
    final windowClass = AppWindowClass.of(context);
    final barcodeField = TextField(
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (windowClass.isCompact) ...[
          barcodeField,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onLoanByBarcode,
                  icon: const Icon(Icons.book_outlined),
                  label: const Text('Loan out'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReturnByBarcode,
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Return'),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(child: barcodeField),
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
        ],
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
    required this.accent,
    required this.isOverdue,
    required this.onReturn,
    required this.onDelete,
  });

  final Loan loan;
  final String title;
  final Color accent;
  final bool isOverdue;
  final VoidCallback? onReturn;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final windowClass = AppWindowClass.of(context);

    if (windowClass.isCompact) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isOverdue
                ? Colors.orange.withValues(alpha: 0.5)
                : colorScheme.outlineVariant,
          ),
        ),
        color: isOverdue
            ? Colors.orange.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
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
                    size: 18,
                  ),
                  if (loan.dueDate != null)
                    _MiniChip(
                      label: isOverdue
                          ? 'OVERDUE: ${_fmt(loan.dueDate!)}'
                          : 'due ${_fmt(loan.dueDate!)}',
                    ),
                  _MiniChip(label: loan.borrowerName),
                  _MiniChip(label: loan.isActive ? 'loaned' : 'returned'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _MiniChip(label: 'lent ${_fmt(loan.lentDate)}'),
                  if (loan.returnedDate != null)
                    _MiniChip(label: 'returned ${_fmt(loan.returnedDate!)}'),
                ],
              ),
              if (loan.notes != null && loan.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  loan.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReturn != null) ...[
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onReturn,
                      icon: const Icon(
                        Icons.assignment_return_outlined,
                        size: 16,
                      ),
                      label: const Text('Return'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

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

class _LibraryEntryPickerDialog extends StatelessWidget {
  const _LibraryEntryPickerDialog({
    required this.title,
    required this.libraryEntries,
  });

  final String title;
  final List<LibraryEntrySummary> libraryEntries;

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: Text('Choose copy for $title'),
      content: SizedBox(
        width: 520,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: libraryEntries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = libraryEntries[index];
            return ListTile(
              title: Text(item.ownerLabel ?? 'Copy ${item.ref.id.value}'),
              subtitle: Text([
                if (item.locationLabel != null) item.locationLabel!,
                item.ref.id.value,
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
    return AccentAlertDialog(
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
    return AccentAlertDialog(
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
            Column(
              children: [
                _DatePickerField(
                  label: 'Lent date',
                  value: _lentDate,
                  onChanged: (value) {
                    if (value != null) setState(() => _lentDate = value);
                  },
                ),
                const SizedBox(height: 12),
                _DatePickerField(
                  label: 'Due date',
                  value: _dueDate,
                  onChanged: (value) => setState(() => _dueDate = value),
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
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => LibraryDateFieldButton(
        label: label,
        value: value,
        onChanged: onChanged,
      );
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
      child: Center(child: Text('No loans found.')),
    );
  }
}

String _fmt(DateTime dt) {
  final local = dt.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
