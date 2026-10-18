import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_value_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Future<PickListValue?>> _open(WidgetTester tester,
    {PickListValue? existing}) async {
  late Future<PickListValue?> result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => result = showPickListValueEditorDialog(
          context: context,
          listName: 'music.record_label',
          label: 'Label',
          mediaKind: 'music',
          existing: existing,
        ),
        child: const Text('open'),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

Finder get _name => find.byType(TextField).at(0);
Finder get _sortName => find.byType(TextField).at(1);

String _text(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;

void main() {
  testWidgets('the Sort Name follows the Name as it is typed', (tester) async {
    final result = await _open(tester);

    await tester.enterText(_name, 'The End Records');
    expect(_text(tester, _sortName), 'End Records, The');

    await tester.enterText(_name, 'Napalm Records');
    expect(_text(tester, _sortName), 'Napalm Records');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    // A Sort Name equal to the Name is not stored.
    expect((await result)!.sortName, isNull);
  });

  testWidgets('a typed Sort Name stays when the Name changes', (tester) async {
    final result = await _open(tester);

    await tester.enterText(_name, 'The End Records');
    await tester.enterText(_sortName, 'End');
    await tester.enterText(_name, 'The End Records Ltd');
    expect(_text(tester, _sortName), 'End');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect((await result)!.sortName, 'End');
  });

  testWidgets('an existing value keeps an empty Sort Name until renamed',
      (tester) async {
    await _open(tester,
        existing: const PickListValue(
            id: 'label',
            listName: 'music.record_label',
            value: 'The End Records'));

    expect(_text(tester, _sortName), isEmpty);
    await tester.enterText(_name, 'The End Recordings');
    expect(_text(tester, _sortName), 'End Recordings, The');
  });
}
