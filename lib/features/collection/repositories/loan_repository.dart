import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:drift/drift.dart';

class LoanRepository {
  const LoanRepository(this._db);
  final LocalDatabase _db;

  Future<List<Loan>> getLoansForItem(String ownedItemId) async {
    final rows = await (_db.select(_db.loansCache)
          ..where((t) => t.ownedItemId.equals(ownedItemId))
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
    await _db.into(_db.loansCache).insert(
          LoansCacheCompanion.insert(
            id: loan.id,
            ownedItemId: loan.ownedItemId,
            borrowerName: loan.borrowerName,
            lentDate: loan.lentDate,
            dueDate: Value(loan.dueDate),
            returnedDate: Value(loan.returnedDate),
            notes: Value(loan.notes),
          ),
        );
  }

  Future<void> markReturned(String loanId) async {
    await (_db.update(_db.loansCache)
          ..where((t) => t.id.equals(loanId)))
        .write(LoansCacheCompanion(returnedDate: Value(DateTime.now())));
  }

  Future<void> delete(String loanId) async {
    await (_db.delete(_db.loansCache)
          ..where((t) => t.id.equals(loanId)))
        .go();
  }

  Loan _fromRow(LoansCacheData row) {
    return Loan(
      id: row.id,
      ownedItemId: row.ownedItemId,
      borrowerName: row.borrowerName,
      lentDate: row.lentDate,
      dueDate: row.dueDate,
      returnedDate: row.returnedDate,
      notes: row.notes,
    );
  }
}
