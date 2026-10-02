import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists and restores the structural CollectionItemRef kind', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = LoanRepository(db);

    await repository.create(
      Loan(
        id: 'loan-book-1',
        collectionItemRef: const CollectionItemRef(
          kind: CatalogMediaKind.book,
          id: CollectionItemId('owned-book-1'),
        ),
        borrowerName: 'Alex',
        lentDate: DateTime.utc(2026, 5, 1),
      ),
    );

    final restored = (await repository.getAllLoans()).single;

    expect(restored.collectionItemRef.kind, CatalogMediaKind.book);
    expect(restored.collectionItemRef.id.value, 'owned-book-1');
  });
}
