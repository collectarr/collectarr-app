import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('table cell text shows fallback for empty values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LibraryTableCellText(null)),
    );

    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('table cell text renders provided value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LibraryTableCellText('Marvel Comics')),
    );

    expect(find.text('Marvel Comics'), findsOneWidget);
  });

  testWidgets('wrapped table cells span several lines instead of ellipsizing',
      (tester) async {
    const title = 'Live From The Sabaton Cruise 2014 (CD2)';
    Future<double> heightWhen({required bool wrap}) async {
      await tester.pumpWidget(MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 120,
            child: LibraryTableCellDisplayScope(
              wrap: wrap,
              child: const LibraryTableCellText(title),
            ),
          ),
        ),
      ));
      return tester.getSize(find.text(title)).height;
    }

    final singleLine = await heightWhen(wrap: false);
    final wrapped = await heightWhen(wrap: true);

    expect(wrapped, greaterThan(singleLine * 1.5));
  });
}
