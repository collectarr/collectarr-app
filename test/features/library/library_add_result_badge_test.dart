import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders add result badge label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryAddResultBadge('ComicVine'),
        ),
      ),
    );

    expect(find.text('ComicVine'), findsOneWidget);
  });
}
