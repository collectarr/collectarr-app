import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders add mode tab and handles taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAddModeTab(
            icon: Icons.qr_code_2,
            label: 'Barcode',
            selected: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Barcode'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2), findsOneWidget);

    await tester.tap(find.text('Barcode'));
    expect(tapped, isTrue);
  });
}
