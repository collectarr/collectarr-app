import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists and restores the structural LibraryEntryRef kind', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = LoanRepository(db);

    await repository.create(
      Loan(
        id: 'loan-book-1',
        libraryEntryRef: const LibraryEntryRef(
          kind: CatalogMediaKind.book,
          id: LibraryEntryId('entry-book-1'),
        ),
        borrowerName: 'Alex',
        lentDate: DateTime.utc(2026, 5, 1),
      ),
    );

    final restored = (await repository.getAllLoans()).single;

    expect(restored.libraryEntryRef.kind, CatalogMediaKind.book);
    expect(restored.libraryEntryRef.id.value, 'entry-book-1');
  });
}
