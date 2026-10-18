import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_selection_dialog.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/ui/app_management_page_scaffold.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:go_router/go_router.dart';
import 'package:collectarr_app/ui/anchored_calendar.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// One library entry being lent.
class LoanAddEntry {
  const LoanAddEntry({
    required this.ref,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  final LibraryEntryRef ref;
  final String title;
  final String? subtitle;
  final String? imageUrl;
}

/// What the Loan Album page lends, passed as the route's extra.
class LoanAddRequest {
  const LoanAddRequest({
    required this.db,
    required this.kind,
    required this.singularLabel,
    required this.entries,
  });

  final LocalDatabase db;
  final CatalogMediaKind kind;
  final String singularLabel;
  final List<LoanAddEntry> entries;
}

/// Opens the reference "Loan Album" page: the items, Loaned To (picked from
/// the borrower list), Notes, Loan Date, Due Date two weeks later, and a blue
/// "Loan Album" button. Completes with true when loans were recorded.
Future<bool> showLoanAddPage(
        BuildContext context, LoanAddRequest request) async =>
    await context.push<bool>(
        AppRoutes.forKind(AppRoutes.loanAdd, request.kind.apiValue),
        extra: request) ??
    false;

/// Days between the loan and its default due date, as in the reference.
const kDefaultLoanDays = 14;

// Calendar days, not 24-hour periods, so a daylight-saving change in between
// does not move the due date a day early.
DateTime _dueAfter(DateTime lent) =>
    DateTime(lent.year, lent.month, lent.day + kDefaultLoanDays);

class LoanAddPage extends StatefulWidget {
  const LoanAddPage({super.key, required this.request});

  final LoanAddRequest request;

  @override
  State<LoanAddPage> createState() => _LoanAddPageState();
}

class _LoanAddPageState extends State<LoanAddPage> {
  LoanAddRequest get _request => widget.request;

  final _notes = TextEditingController();
  String? _borrower;
  late DateTime _lentDate = DateUtils.dateOnly(DateTime.now());
  late DateTime _dueDate = _dueAfter(_lentDate);
  var _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickBorrower() async {
    final options = await PickListRepository(_request.db).getValues('borrower');
    if (!mounted) return;
    final picked = await showAppDialog<Object?>(
      context: context,
      builder: (_) => PickListSelectionDialog(
        label: 'Loaner',
        pluralLabel: 'Loaners',
        options: options,
        selectedValues: [if (_borrower != null) _borrower!],
        multiple: false,
        listName: 'borrower',
        allowUserValues: true,
        db: _request.db,
      ),
    );
    if (picked is String && picked.trim().isNotEmpty && mounted) {
      setState(() => _borrower = picked.trim());
    }
  }

  Future<void> _pickDate(DateTime current, ValueChanged<DateTime> onPicked,
      BuildContext anchor) async {
    final picked = await showAppAnchoredCalendar(
        context: anchor,
        initialDate: current,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null && mounted) setState(() => onPicked(picked));
  }

  Future<void> _submit() async {
    final borrower = _borrower;
    if (borrower == null || _saving) return;
    setState(() => _saving = true);
    final notes = _notes.text.trim();
    for (final entry in _request.entries) {
      await LoanRepository(_request.db).create(Loan(
        id: const Uuid().v4(),
        libraryEntryRef: entry.ref,
        borrowerName: borrower,
        lentDate: _lentDate,
        dueDate: _dueDate,
        notes: notes.isEmpty ? null : notes,
      ));
      await enqueueLibraryEntrySnapshot(_request.db, entry.ref);
    }
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    const label = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    Widget dateField(String legend, IconData icon, DateTime value,
            ValueChanged<DateTime> onPicked) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(legend, style: label),
          const SizedBox(height: 8),
          Builder(
            builder: (anchor) => InkWell(
              onTap: () => _pickDate(value, onPicked, anchor),
              child: Container(
                width: 212,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  border: Border.all(color: const Color(0xFF666666)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(children: [
                  Container(
                    width: 42,
                    color: const Color(0xFF555555),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Text(
                      '${value.year}-${value.month.toString().padLeft(2, '0')}'
                      '-${value.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14)),
                ]),
              ),
            ),
          ),
        ]);
    final entries = _request.entries;
    final singular = _request.singularLabel;
    return AppManagementPageScaffold(
      icon: AppIcons.loans,
      title: 'Loan Manager',
      leading: const AppPageBackButton(),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
                entries.length > 1 ? 'Loan ${singular}s' : 'Loan $singular',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          ),
          // The items being lent.
          for (final entry in entries)
            Container(
              height: 78,
              margin: const EdgeInsets.only(bottom: 4),
              decoration:
                  BoxDecoration(border: Border.all(color: palette.divider)),
              child: Row(children: [
                SizedBox(
                    width: 76,
                    child: LibraryCoverImage(
                        title: entry.title,
                        imageUrl: entry.imageUrl,
                        fallbackAspectRatio: 1,
                        borderRadius: 0)),
                const SizedBox(width: 9),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      if (entry.subtitle?.isNotEmpty == true)
                        Text(entry.subtitle!,
                            style: const TextStyle(fontSize: 12)),
                    ])),
              ]),
            ),
          const SizedBox(height: 16),
          Container(
            color: palette.isDark
                ? const Color(0xFF383838)
                : palette.surfaceSubtle,
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      const Text('Loaned To', style: label),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickBorrower,
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.only(left: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF444444),
                            border: Border.all(color: const Color(0xFF666666)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(children: [
                            Expanded(
                                child: Text(_borrower ?? '',
                                    style: const TextStyle(fontSize: 14))),
                            IconButton(
                              style: IconButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: palette.textPrimary),
                              tooltip: 'Select loaner',
                              onPressed: _pickBorrower,
                              icon: const Icon(AppIcons.add, size: 16),
                            ),
                          ]),
                        ),
                      ),
                    ])),
                const SizedBox(width: 30),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      const Text('Notes', style: label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notes,
                        minLines: 3,
                        maxLines: 5,
                        decoration: settingsSelectDecoration(context),
                      ),
                    ])),
              ]),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                dateField('Loan Date', AppIcons.paperPlane, _lentDate, (date) {
                  _lentDate = date;
                  if (_dueDate.isBefore(date)) {
                    _dueDate = _dueAfter(date);
                  }
                }),
                const SizedBox(width: 30),
                dateField('Due Date', AppIcons.loans, _dueDate,
                    (date) => _dueDate = date),
                const Spacer(),
                SizedBox(
                  width: 212,
                  height: 32,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.utilityAction,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: _borrower == null || _saving ? null : _submit,
                    child: Row(children: [
                      const Spacer(),
                      Text(_request.entries.length > 1
                          ? 'Loan ${_request.singularLabel}s'
                          : 'Loan ${_request.singularLabel}'),
                      const Spacer(),
                      const Icon(AppIcons.caretRight, size: 12),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 15),
        ]),
      ),
    );
  }
}
