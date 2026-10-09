import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'alphabet exposes Z inline and switches to a complete compact menu',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selected;
    Widget subject(double width) => MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: width,
                child: LibraryToolbarAlphabetRow(
                    letters: const {'A', 'Z'},
                    selectedLetter: selected,
                    accent: Colors.orange,
                    onLetterSelected: (value) => selected = value))));
    await tester.pumpWidget(subject(900));
    expect(find.text('Z'), findsOneWidget);
    expect(tester.getRect(find.text('Z')).right, lessThanOrEqualTo(900));
    await tester.pumpWidget(subject(350));
    expect(find.byTooltip('Filter A–Z'), findsOneWidget);
    await tester.tap(find.byTooltip('Filter A–Z'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Z'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Z'));
    await tester.pumpAndSettle();
    expect(selected, 'Z');
    expect(tester.takeException(), isNull);
  });

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

    expect(find.text('On Wish List'), findsOneWidget);

    await tester.tap(find.text('On Wish List').last);
    await tester.pumpAndSettle();

    expect(selected, LibraryCollectionStatusScope.wishList);
  });

  testWidgets('collection status scope trigger width tracks the current label',
      (
    tester,
  ) async {
    var selected = LibraryCollectionStatusScope.all;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: LibraryCollectionStatusScopeDropdown(
                collectionStatusScope: selected,
                onCollectionStatusScopeChanged: (value) {
                  setState(() => selected = value);
                },
              ),
            );
          },
        ),
      ),
    );

    final allWidth = tester
        .getSize(
          find.byKey(const Key('collection-status-scope-dropdown')),
        )
        .width;

    await tester.tap(find.byKey(const Key('collection-status-scope-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not in Collection').last);
    await tester.pumpAndSettle();

    final inCollectionWidth = tester
        .getSize(
          find.byKey(const Key('collection-status-scope-dropdown')),
        )
        .width;

    expect(inCollectionWidth, greaterThan(allWidth));
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
