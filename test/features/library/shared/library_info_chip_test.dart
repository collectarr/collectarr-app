import 'package:collectarr_app/features/library/shared/library_info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LibraryInfoChip uses square chrome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: LibraryInfoChip(
            label: 'Owned',
            icon: Icons.check_circle_outline,
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.zero);
    expect(find.text('Owned'), findsOneWidget);
  });
}
