import 'dart:io';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/loans/loan_manager_page.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factories.dart';

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

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'comic-1', kind: 'music', title: 'Action Comics #1'),
    ]);
    await MusicEntryRepository(db).upsert(
      testMusicLibraryEntryFrom(testLibraryEntry(
        id: 'entry-1',
        itemId: 'comic-1',
        kind: 'music',
        catalogTitle: 'Action Comics #1',
        condition: 'Near Mint',
        updatedAt: DateTime.utc(2026, 5, 1),
      )),
    );

    final loanRepo = LoanRepository(db);
    await loanRepo.create(
      Loan(
        id: 'loan-1',
        libraryEntryRef: const LibraryEntryRef(
          kind: CatalogMediaKind.music,
          id: LibraryEntryId('entry-1'),
        ),
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

    expect(find.text('Loan Manager'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Action Comics #1'), findsWidgets);
    expect(find.text('1 items'), findsOneWidget);
    expect(find.text('Current Loans'), findsOneWidget);
    expect(find.text('Loan History'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    Uint8List? exported;
    const printingChannel = MethodChannel('net.nfet.printing');
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, (call) async {
      if (call.method == 'sharePdf') {
        final arguments = call.arguments as Map;
        expect(arguments['name'], 'collectarr-loans.pdf');
        exported = arguments['doc'] as Uint8List;
        return 1;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, null));
    await tester.tap(find.text('print to pdf'));
    await pumpUntilSettled(tester);
    expect(exported, isNotNull);
    expect(ascii.decode(exported!.take(4).toList()), '%PDF');
    expect(exported!.length, greaterThan(1000));
    await tester.tap(find.text('Loan History'));
    await pumpUntilSettled(tester);
    expect(find.text('Alice'), findsNothing);
    expect(find.text('0 items'), findsOneWidget);
    await tester.tap(find.text('Current Loans'));
    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Return'));
    await pumpUntilSettled(tester);
    expect((await loanRepo.getAllLoans()).single.isActive, false);
    final changes = (await SyncQueueRepository(db).readPending()).changes;
    expect(changes, hasLength(1));
    final loanSnapshot = (changes.single.payload['personal_data']
        as Map)[libraryEntrySyncLoansKey] as List;
    expect((loanSnapshot.single as Map)['returned_date'], isNotNull);
    await tester.tap(find.text('Loan History'));
    await pumpUntilSettled(tester);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Action Comics #1'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
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

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
          id: 'comic-2', kind: 'music', title: 'Detective Comics #27'),
    ]);
    await MusicEntryRepository(db).upsert(
      testMusicLibraryEntryFrom(testLibraryEntry(
        id: 'entry-2',
        itemId: 'comic-2',
        kind: 'music',
        catalogTitle: 'Detective Comics #27',
        condition: 'Near Mint',
        updatedAt: DateTime.utc(2026, 5, 1),
      )),
    );

    final loanRepo = LoanRepository(db);
    await loanRepo.create(
      Loan(
        id: 'loan-2',
        libraryEntryRef: const LibraryEntryRef(
          kind: CatalogMediaKind.music,
          id: LibraryEntryId('entry-2'),
        ),
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

    expect(find.text('Loan Manager'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Detective Comics #27'), findsOneWidget);
    expect(find.textContaining('OVERDUE: 2020-01-15'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Return'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets(
      'barcode return resolves a local Music copy without a Core snapshot',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final database = LocalDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = jsonDecode(
        File('tool/fixtures/music_inspector_reference.json')
            .readAsStringSync()) as Map<String, dynamic>;
    final catalog = fixture['catalog'] as Map;
    for (final field in [
      'cover_image_url',
      'thumbnail_image_url',
      'back_cover_image_url'
    ]) {
      catalog.remove(field);
    }
    await seedMusicInspectorReference(database, fixture);
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
            home: LoanManagerPage(kind: CatalogMediaKind.music))));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Lend / return by barcode'));
    await pumpUntilSettled(tester);
    final input = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.labelText == 'Barcode / UPC / ISBN');
    await tester.enterText(input, '039842503912');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Return'));
    await pumpUntilSettled(tester);
    final loans = await LoanRepository(database).getAllLoans();
    expect(
        loans
            .firstWhere((loan) => loan.borrowerName == 'Alex Reference')
            .isActive,
        false);
    final changes = (await SyncQueueRepository(database).readPending()).changes;
    expect(changes, hasLength(1));
    final snapshot = (changes.single.payload['personal_data']
        as Map)[libraryEntrySyncLoansKey] as List;
    expect(snapshot.where((loan) => (loan as Map)['returned_date'] != null),
        hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
