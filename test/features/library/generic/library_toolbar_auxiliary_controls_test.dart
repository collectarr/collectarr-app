import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('collection status scope dropdown opens and selects a scope', (
    tester,
  ) async {
    var selected = LibraryCollectionStatusScope.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryCollectionStatusScopeDropdown(
            collectionStatusScope: selected,
            onCollectionStatusScopeChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);

    await tester.tap(find.byKey(const Key('collection-status-scope-dropdown')));
    await tester.pumpAndSettle();

    expect(find.text('Wish List'), findsOneWidget);

    await tester.tap(find.text('Wish List').last);
    await tester.pumpAndSettle();

    expect(selected, LibraryCollectionStatusScope.wishList);
  });

  testWidgets('inline issue jump field submits trimmed values', (tester) async {
    var submitted = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryInlineIssueJumpField(
            onSubmitted: (value) => submitted = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), ' 42 ');
    await tester.tap(find.byTooltip('Jump to issue'));
    await tester.pump();

    expect(submitted, '42');
    expect(find.text('42'), findsNothing);
  });
}