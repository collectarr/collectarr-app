import 'package:collectarr_app/features/library/edit/fields/dialog_widgets.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/features/library/ui/primitives/multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/value_chip.dart';
import 'package:collectarr_app/ui/pick_list_field_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpGenres(WidgetTester tester, Set<String> values) =>
    tester.pumpWidget(MaterialApp(
        theme: editDialogTheme(),
        home: Scaffold(
            body: Center(
                child: SizedBox(
                    width: 360,
                    child: LibraryMultiValuePickField<String>(
                        label: 'Genre',
                        value: values,
                        options: const <LibraryFieldOption<String>>[],
                        onChanged: (_) {},
                        onOpenPicker: (
                                {required label,
                                required selectedValues,
                                required options,
                                searchHint,
                                customValueHint}) async =>
                            null))))));

Rect _fieldRect(WidgetTester tester) =>
    tester.getRect(find.byType(InputDecorator).first);

void main() {
  testWidgets('the editor is as tall as a chip and centred in its row',
      (tester) async {
    await _pumpGenres(tester, {'Science Fiction'});
    final chip = tester.getRect(find.byType(LibraryValueChip));
    final editor = tester.getRect(find.byType(TextField));
    expect(_fieldRect(tester).height, LibraryMetrics.defaultFieldHeight);
    expect(editor.center.dy, closeTo(chip.center.dy, .5));
  });

  testWidgets('wrapped values keep the list button on the first row',
      (tester) async {
    await _pumpGenres(tester, {
      'Science Fiction',
      'Action Adventure',
      'Horror Thriller',
      'Comedy Drama',
    });
    await tester.pump();
    final field = _fieldRect(tester);
    final button = tester.getRect(find.byType(PickListFieldButton));
    final chips = tester
        .widgetList<LibraryValueChip>(find.byType(LibraryValueChip))
        .map((chip) => tester.getRect(find.byWidget(chip)).top)
        .toSet();
    expect(chips.length, greaterThan(1));
    // As in the reference: 4 px to the first chip row, 3 px between rows and
    // after the last one, inside a 1 px border.
    expect(chips.reduce((a, b) => a < b ? a : b) - field.top, 4);
    expect(field.height, 4 + chips.length * 29 - 3 + 4);
    expect(button.top, field.top + 1);
    expect(button.height, LibraryMetrics.defaultFieldHeight - 1);
    expect(
        tester
            .widget<PickListFieldButton>(find.byType(PickListFieldButton))
            .bottomBorder,
        isTrue);
  });

  testWidgets('Enter adds the typed value and keeps typing in the field',
      (tester) async {
    await _pumpGenres(tester, {});
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Mystery');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Mystery'), findsOneWidget);
    final editable = tester.state<EditableTextState>(find.byType(EditableText));
    expect(editable.widget.focusNode.hasFocus, isTrue);
  });
}
