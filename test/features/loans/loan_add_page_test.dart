import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/loans/loan_add_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
      'loan page defaults the due date two weeks out and needs a loaner',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () => showLoanAddPage(
              context,
              LoanAddRequest(
                db: db,
                kind: CatalogMediaKind.music,
                singularLabel: 'Album',
                entries: const [
                  LoanAddEntry(
                      ref: LibraryEntryRef(
                          kind: CatalogMediaKind.music,
                          id: LibraryEntryId('entry-1')),
                      title: 'Arrival',
                      subtitle: 'ABBA'),
                ],
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.loanAdd,
        builder: (context, state) =>
            LoanAddPage(request: state.extra! as LoanAddRequest),
      ),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    String iso(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}'
        '-${d.day.toString().padLeft(2, '0')}';
    final today = DateUtils.dateOnly(DateTime.now());
    // A page with the Loan Manager header, not a dialog.
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Loan Manager'), findsOneWidget);
    expect(find.text('Loan Album'), findsWidgets);
    expect(find.text('Arrival'), findsWidgets);
    expect(find.text(iso(today)), findsOneWidget);
    // Calendar days: a daylight-saving change must not move it a day early.
    expect(find.text(iso(DateTime(today.year, today.month, today.day + 14))),
        findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
