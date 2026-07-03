import 'package:collectarr_app/features/library/workspace/table/library_table_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('table ink row reserves selection rail and handles taps',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryTableInkRow(
            selected: true,
            odd: false,
            onTap: () => tapped = true,
            selectedColor: Colors.blue,
            oddColor: Colors.green,
            evenColor: Colors.black,
            selectionRailColor: Colors.yellow,
            bottomBorderColor: Colors.grey,
            hoverColor: Colors.cyan,
            selectionRailWidth: 3,
            horizontalMargin: 8,
            child: const Text('Row'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Row'));
    await tester.pump();
    final paddingFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Padding &&
          widget.padding == const EdgeInsets.fromLTRB(8, 1, 5, 1),
    );
    final decoration = tester
        .widget<DecoratedBox>(find.byType(DecoratedBox))
        .decoration as BoxDecoration;
    final border = decoration.border! as Border;

    expect(tapped, isTrue);
    expect(paddingFinder, findsOneWidget);
    expect(border.left.width, 3);
    expect(border.left.color, Colors.yellow);
  });
}
