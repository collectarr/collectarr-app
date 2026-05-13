import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inspector section renders title and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryInspectorSection(
            title: 'Personal',
            children: [Text('Storage box')],
          ),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Storage box'), findsOneWidget);
  });

  testWidgets('inspector fact grid renders fact labels and values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData('Grade', '9.8'),
                LibraryInspectorFactData('Condition', 'Near Mint'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grade'), findsOneWidget);
    expect(find.text('9.8'), findsOneWidget);
    expect(find.text('Condition'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
  });
}
