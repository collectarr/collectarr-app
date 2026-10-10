import 'package:collectarr_app/features/library/edit/session/library_edit_navigation_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
