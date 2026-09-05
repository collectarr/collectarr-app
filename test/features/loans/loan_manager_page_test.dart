import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/loans/loan_manager_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';

void main() {
  testWidgets('loan manager renders on desktop and filters loans',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await LibraryCatalogRepository(db).upsertAll([
      typedCatalogItemFromMap({
        'id': 'comic-1',
        'kind': 'comic',
        'title': 'Action Comics #1',
      }),
    ]);
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'comic-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 1),
          ),
        );

    final loanRepo = LoanRepository(db);
    await loanRepo.create(
      Loan(
        id: 'loan-1',
        ownedItemId: 'owned-1',
        catalogRef: const CatalogEntityRef(
            entityType: CatalogEntityType.work, kind: 'comic', id: 'comic-1'),
        borrowerName: 'Alice',
        lentDate: DateTime.utc(2026, 5, 1),
        dueDate: DateTime.utc(2026, 5, 15),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: LoanManagerPage()),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Loans'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Action Comics #1'), findsOneWidget);
    expect(find.text('1 total'), findsOneWidget);
    expect(find.text('1 active'), findsOneWidget);
  });

  testWidgets('loan manager renders due-date-first card on compact screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await LibraryCatalogRepository(db).upsertAll([
      typedCatalogItemFromMap({
        'id': 'comic-2',
        'kind': 'comic',
        'title': 'Detective Comics #27',
      }),
    ]);
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-2',
            itemId: 'comic-2',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 1),
          ),
        );

    final loanRepo = LoanRepository(db);
    await loanRepo.create(
      Loan(
        id: 'loan-2',
        ownedItemId: 'owned-2',
        catalogRef: const CatalogEntityRef(
            entityType: CatalogEntityType.work, kind: 'comic', id: 'comic-2'),
        borrowerName: 'Bob',
        lentDate: DateTime.utc(2020, 1, 1),
        dueDate: DateTime.utc(2020, 1, 15),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: LoanManagerPage()),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Loans'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Detective Comics #27'), findsOneWidget);
    expect(find.textContaining('OVERDUE: 2020-01-15'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Return'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
  });
}
