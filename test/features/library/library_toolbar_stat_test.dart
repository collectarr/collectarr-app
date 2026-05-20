import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders toolbar stat label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryToolbarStat(label: 'Shown', value: 42),
        ),
      ),
    );

    expect(find.text('Shown'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });
}
