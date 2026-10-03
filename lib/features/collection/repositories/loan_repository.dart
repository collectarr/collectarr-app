import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class LoanRepository {
  const LoanRepository(this._db);
  final LocalDatabase _db;

  Future<List<Loan>> getLoansForItem(LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    final rows = await (_db.select(_db.loansCache)
          ..where((t) => t.libraryEntryRefKey.equals(libraryEntryRef.key))
          ..orderBy([(t) => OrderingTerm.desc(t.lentDate)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<List<Loan>> getActiveLoans() async {
    final rows = await (_db.select(_db.loansCache)
          ..where((t) => t.returnedDate.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lentDate)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<List<Loan>> getAllLoans() async {
    final rows = await (_db.select(_db.loansCache)
          ..orderBy([(t) => OrderingTerm.desc(t.lentDate)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<void> create(Loan loan) async {
    requireKnownLibraryEntryRef(loan.libraryEntryRef);
    await _db.into(_db.loansCache).insert(
          LoansCacheCompanion.insert(
            id: loan.id,
            libraryEntryRefKey: loan.libraryEntryRef.key,
            borrowerName: loan.borrowerName,
            lentDate: loan.lentDate,
            dueDate: Value(loan.dueDate),
            returnedDate: Value(loan.returnedDate),
            notes: Value(loan.notes),
          ),
        );
  }

  Future<void> markReturned(String loanId) async {
    await (_db.update(_db.loansCache)..where((t) => t.id.equals(loanId))).write(
        LoansCacheCompanion(returnedDate: Value(DateTime.now().toUtc())));
  }

  Future<void> delete(String loanId) async {
    await (_db.delete(_db.loansCache)..where((t) => t.id.equals(loanId))).go();
  }

  Future<void> replaceForLibraryEntry(
    LibraryEntryRef ref,
    List<Loan> loans,
  ) async {
    requireKnownLibraryEntryRef(ref);
    for (final loan in loans) {
      if (loan.libraryEntryRef != ref) {
        throw ArgumentError.value(
          loan.libraryEntryRef,
          'loan.libraryEntryRef',
          'A loan snapshot must belong to its enclosing library entry.',
        );
      }
    }
    await (_db.delete(_db.loansCache)
          ..where((t) => t.libraryEntryRefKey.equals(ref.key)))
        .go();
    if (loans.isEmpty) return;
    await _db.batch((batch) {
      for (final loan in loans) {
        batch.insert(
          _db.loansCache,
          LoansCacheCompanion.insert(
            id: loan.id,
            libraryEntryRefKey: ref.key,
            borrowerName: loan.borrowerName,
            lentDate: loan.lentDate,
            dueDate: Value(loan.dueDate),
            returnedDate: Value(loan.returnedDate),
            notes: Value(loan.notes),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Loan _fromRow(LoansCacheData row) {
    return Loan(
      id: row.id,
      libraryEntryRef: LibraryEntryRef.fromKey(row.libraryEntryRefKey),
      borrowerName: row.borrowerName,
      lentDate: row.lentDate,
      dueDate: row.dueDate,
      returnedDate: row.returnedDate,
      notes: row.notes,
    );
  }
}
