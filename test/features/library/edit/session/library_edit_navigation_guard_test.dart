import 'package:collectarr_app/features/library/edit/session/commit_scope.dart';
import 'package:collectarr_app/features/library/edit/session/navigation_guard.dart';
import 'package:collectarr_app/features/library/edit/shell/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('route back uses the guard while Save can close the editor',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: Builder(
          builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('Open editor'),
                  onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      Future<void> cancel() async {
                        if (await confirmLeaveLibraryEdit(context,
                                hasUnsavedChanges: true) &&
                            context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }

                      return LibraryEditDialogScaffold(
                        formKey: GlobalKey<FormState>(),
                        accent: Colors.orange,
                        icon: Icons.edit,
                        title: 'Test editor',
                        badges: const [],
                        body: const Text('Edited content'),
                        onClose: cancel,
                        onCancel: cancel,
                        onSave: () => Navigator.of(context).pop(),
                      );
                    },
                  ),
                ),
              )),
    ));
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await navigator.currentState!.maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Unsaved changes'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Edited content'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Edited content'), findsNothing);
    expect(find.text('Unsaved changes'), findsNothing);
  });
  testWidgets(
      'dirty navigation requires an explicit discard and can be canceled',
      (tester) async {
    var navigations = 0;
    var dirty = true;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: FilledButton(
                    onPressed: () async {
                      if (await confirmLeaveLibraryEdit(context,
                          hasUnsavedChanges: dirty)) {
                        navigations++;
                      }
                    },
                    child: const Text('Next'))))));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(navigations, 0);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(navigations, 0);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(navigations, 1);
    dirty = false;
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(navigations, 2);
    expect(find.text('Unsaved changes'), findsNothing);
  });

  group('Next and Previous', () {
    Future<List<String>> run(
      WidgetTester tester, {
      required bool dirty,
      required bool valid,
    }) async {
      final events = <String>[];
      final commits =
          LibraryEditCommitHandle(itemLabel: 'comic', onKeptOpen: () {});
      await tester.pumpWidget(MaterialApp(
        home: LibraryEditCommitScope(
          handle: commits,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => saveAndShowLibraryEditNeighbour(
                  context,
                  hasUnsavedChanges: dirty,
                  save: () async {
                    events.add('save');
                    if (valid && commits.takeCommit()) events.add('kept');
                  },
                  show: () async {
                    events.add('show');
                    commits.pendingSwitch = Future<void>.delayed(
                        const Duration(milliseconds: 900),
                        () => events.add('shown'));
                  },
                ),
                child: const Text('Next'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump();
      // As in the reference, the window always says Saving and the item
      // is hidden behind it.
      const title = 'Saving comic';
      expect(find.text(title), findsOneWidget);
      expect(commits.hidden.value, isTrue);
      await tester.pump(const Duration(milliseconds: 800));
      if (valid) expect(find.text(title), findsOneWidget);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text(title), findsNothing);
      expect(commits.hidden.value, isFalse);
      return events;
    }

    testWidgets('save a changed item and stay up until the next one shows',
        (tester) async {
      expect(await run(tester, dirty: true, valid: true),
          ['save', 'kept', 'show', 'shown']);
    });

    testWidgets('only load an unchanged item', (tester) async {
      expect(await run(tester, dirty: false, valid: true), ['show', 'shown']);
    });

    testWidgets('keep an item that does not validate', (tester) async {
      expect(await run(tester, dirty: true, valid: false), ['save']);
    });
  });
}
