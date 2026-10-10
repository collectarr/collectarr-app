import 'package:collectarr_app/features/library/edit/session/library_edit_navigation_guard.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
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
}
