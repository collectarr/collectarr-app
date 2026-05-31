import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/inspector/inspector_loan_section.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('loan section keeps current loan records when dialog is cancelled', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await LoanRepository(db).create(
      Loan(
        id: 'loan-1',
        ownedItemId: 'owned-1',
        borrowerName: 'Alex',
        lentDate: DateTime.utc(2026, 5, 1),
        dueDate: DateTime.utc(2026, 5, 10),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorLoanSection(
            ownedItemId: 'owned-1',
            db: db,
            accent: Colors.orange,
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Alex'), findsOneWidget);

    await tester.tap(find.byTooltip('Lend this item'));
    await pumpUntilSettled(tester);

    expect(find.text('Lend Item'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await pumpUntilSettled(tester);

    final loans = await LoanRepository(db).getLoansForItem('owned-1');
    expect(loans, hasLength(1));
    expect(loans.single.borrowerName, 'Alex');
    expect(find.text('Alex'), findsOneWidget);
  });
}