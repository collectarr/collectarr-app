import 'package:collectarr_app/features/library/workspace/library_workspace_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toolbar search exposes inline actions and filter chip', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Spider-Man');
    var lastSearch = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: LibraryToolbarSearch(
              controller: controller,
              hintText: 'Search comics...',
              onSearch: (value) => lastSearch = value,
              onScanBarcode: () {},
              onScanCover: () {},
              selectedFilterLabel: 'Owned',
              onClearFilter: () {},
              selectionColor: Colors.cyan,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    expect(find.byIcon(Icons.image_search), findsOneWidget);
    expect(find.text('Owned'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(lastSearch, 'Spider-Man');
    controller.dispose();
  });
}