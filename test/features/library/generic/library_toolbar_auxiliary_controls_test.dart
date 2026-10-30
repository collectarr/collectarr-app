import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_alphabet_options.dart';
import 'package:collectarr_app/features/library/config/presentation/library_alphabet_field.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('status menu stays below its trigger for a late selected status',
      (tester) async {
    var selected = LibraryCollectionStatusScope.sold;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: LibraryCollectionStatusScopeDropdown(
          collectionStatusScope: selected,
          onCollectionStatusScopeChanged: (value) => selected = value,
        ),
      )),
    ));
    final trigger = find.byKey(const Key('collection-status-scope-dropdown'));
    final triggerBottom = tester.getRect(trigger).bottom;
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('All')).top,
        greaterThanOrEqualTo(triggerBottom));
    await tester.tapAt(const Offset(700, 550));
    await tester.pumpAndSettle();
    expect(find.text('All'), findsNothing);
    expect(selected, LibraryCollectionStatusScope.sold);
    expect(tester.takeException(), isNull);
  });
  testWidgets('narrow alphabet keeps All on one line and scrolls to Z',
      (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 240,
                child: LibraryAlphaJumpBar(
                    availableLetters: const {'Z'},
                    selectedLetter: null,
                    accent: Colors.orange,
                    onLetterSelected: (value) => selected = value)))));
    final all = tester.widget<Text>(find.text('All'));
    expect(all.maxLines, 1);
    expect(all.softWrap, isFalse);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z'));
    expect(selected, 'Z');
    expect(tester.takeException(), isNull);
  });
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

  testWidgets('alphabet options show only with more than one field',
      (tester) async {
    Widget subject(List<LibraryAlphabetField> fields) => MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 1000,
                child: LibraryToolbarAlphabetRow(
                    letters: const {'A'},
                    selectedLetter: null,
                    alphabetOptions: LibraryAlphabetOptions(
                        fields: fields,
                        selected: fields.first,
                        onChanged: (_) {}),
                    accent: Colors.orange,
                    onLetterSelected: (_) {}))));
    const other =
        LibraryAlphabetField(id: 'series', label: 'Series', values: _noValues);
    await tester.pumpWidget(subject(const [LibraryAlphabetField.title]));
    expect(find.byTooltip('Alphabet Options'), findsNothing);
    await tester.pumpWidget(subject(const [LibraryAlphabetField.title, other]));
    expect(find.byTooltip('Alphabet Options'), findsOneWidget);
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

    Color? triggerColor() => (tester
            .widget<DecoratedBox>(find
                .descendant(
                    of: find
                        .byKey(const Key('collection-status-scope-dropdown')),
                    matching: find.byType(DecoratedBox))
                .first)
            .decoration as BoxDecoration)
        .color;
    expect(triggerColor(), Colors.transparent);

    await tester.tap(find.byKey(const Key('collection-status-scope-dropdown')));
    await tester.pumpAndSettle();

    expect(find.text('On Wish List'), findsOneWidget);
    // The trigger stays lit while its menu is open, as in the reference.
    expect(triggerColor(), isNot(Colors.transparent));

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

Iterable<String> _noValues(LibraryProjectionView item) => const [];
