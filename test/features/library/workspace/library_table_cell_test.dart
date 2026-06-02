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
}
