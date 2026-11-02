import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/features/library/workspace/table/row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _active = Color(0xFF5EB1DE);
const _base = Color(0xFF2E3035);

Future<Color?> _rowFill(WidgetTester tester,
    {required bool selected, required bool checked}) async {
  await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: LibraryTableInkRow(
              selected: selected,
              checked: checked,
              odd: false,
              onTap: () {},
              selectedColor: _active,
              oddColor: _base,
              evenColor: _base,
              selectionRailColor: Colors.transparent,
              bottomBorderColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: const SizedBox(height: 20, width: 100)))));
  final box = tester.widget<DecoratedBox>(find
      .descendant(
          of: find.byType(LibraryTableInkRow),
          matching: find.byType(DecoratedBox))
      .first);
  return (box.decoration as BoxDecoration).color;
}

void main() {
  testWidgets('the active row is light blue and ticked rows dark blue',
      (tester) async {
    expect(await _rowFill(tester, selected: true, checked: false), _active);
    expect(await _rowFill(tester, selected: false, checked: true),
        kLibraryCheckedItemBackground);
    expect(await _rowFill(tester, selected: true, checked: true), _active);
    expect(await _rowFill(tester, selected: false, checked: false), _base);
  });
}
