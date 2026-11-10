import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/read_history.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reading dates notify changes and completed status hides action',
      (tester) async {
    final draft = BookReadingDraft(null)..status = 'completed';
    addTearDown(draft.dispose);
    var changes = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body:
                BookReadHistoryTab(draft: draft, onChanged: () => changes++))));
    expect(find.text('Mark as read'), findsNothing);
    final date = tester.widget<LibraryPartialDateField>(find.byWidgetPredicate(
        (widget) =>
            widget is LibraryPartialDateField &&
            widget.label == 'Finished Date'));
    date.onChanged(const PartialDate(year: 2024, month: 5, day: 2));
    await tester.pump();
    expect(draft.finishedAt, DateTime(2024, 5, 2));
    expect(changes, 1);
    expect(draft.hasChanges, isTrue);
  });
}
