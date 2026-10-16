import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/loans/loan_item_dialog.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'loan form defaults the due date two weeks out and needs a loaner',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showLoanItemDialog(
            context: context,
            db: db,
            libraryEntryRef: const LibraryEntryRef(
                kind: CatalogMediaKind.music, id: LibraryEntryId('entry-1')),
            singularLabel: 'Album',
            title: 'Arrival',
            subtitle: 'ABBA',
          ),
          child: const Text('Open'),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    String iso(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}'
        '-${d.day.toString().padLeft(2, '0')}';
    final today = DateUtils.dateOnly(DateTime.now());
    expect(find.text('Loan Album'), findsWidgets);
    expect(find.text('Arrival'), findsWidgets);
    expect(find.text(iso(today)), findsOneWidget);
    // Calendar days: a daylight-saving change must not move it a day early.
    expect(find.text(iso(DateTime(today.year, today.month, today.day + 14))),
        findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
