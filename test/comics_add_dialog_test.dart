import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('add comic dialog renders search and target controls',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => const ShelfState(
              entries: [],
              ownedCount: 0,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 0,
              totalPaidCents: null,
              primaryCurrency: null,
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: Scaffold(body: AddComicDialog())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Comics from Collectarr Core'), findsOneWidget);
    expect(find.text('Search Series'), findsOneWidget);
    expect(find.text('Add as owned'), findsOneWidget);
    expect(find.text('Add 1 Comic to Collection'), findsOneWidget);

    final yearField = find.widgetWithText(TextField, 'Year');
    expect(tester.widget<TextField>(yearField).textAlign, TextAlign.center);
    await tester.enterText(yearField, '20ab24');
    expect(tester.widget<TextField>(yearField).controller?.text, '2024');
  });

  testWidgets('add issue requires an issue number', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => const ShelfState(
              entries: [],
              ownedCount: 0,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 0,
              totalPaidCents: null,
              primaryCurrency: null,
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: Scaffold(body: AddComicDialog())),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Issue'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter series title...'),
      'Over the Garden Wall',
    );
    await tester.tap(find.text('Search Issue'));
    await tester.pumpAndSettle();

    expect(
        find.text('Issue number is required for Add Issue.'), findsOneWidget);
  });

  testWidgets('search input accepts space while dialog shortcuts are active',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => const ShelfState(
              entries: [],
              ownedCount: 0,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 0,
              totalPaidCents: null,
              primaryCurrency: null,
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: Scaffold(body: AddComicDialog())),
      ),
    );

    await tester.pumpAndSettle();
    final searchField = find.widgetWithText(TextField, 'Enter series title...');
    await tester.tap(searchField);
    await tester.enterText(searchField, 'absolute');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.enterText(searchField, 'absolute batman');
    expect(
      tester.widget<TextField>(searchField).controller?.text,
      'absolute batman',
    );
  });

  testWidgets('enter searches from the add issue search field', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shelfProvider.overrideWith(
            (ref) async => const ShelfState(
              entries: [],
              ownedCount: 0,
              wishlistCount: 0,
              missingGradeCount: 0,
              pricedCount: 0,
              totalPaidCents: null,
              primaryCurrency: null,
              hasMixedCurrencies: false,
            ),
          ),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: Scaffold(body: AddComicDialog())),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Issue'));
    await tester.pumpAndSettle();

    final searchField = find.widgetWithText(TextField, 'Enter series title...');
    await tester.tap(searchField);
    await tester.enterText(searchField, 'Over the Garden Wall');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      find.text('Issue number is required for Add Issue.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(searchField).controller?.text,
      'Over the Garden Wall',
    );

    final issueField = find.widgetWithText(TextField, 'Issue');
    expect(tester.widget<TextField>(issueField).textAlign, TextAlign.center);
  });
}
