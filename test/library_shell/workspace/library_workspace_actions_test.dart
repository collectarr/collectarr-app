import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary actions render add button and random pick action', (
    tester,
  ) async {
    var addPressed = false;
    var randomPressed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbarPrimaryActions(
              addLabel: 'Add Comics',
              onAdd: () => addPressed = true,
              onScanBarcode: () {},
              onRefreshMetadata: () {},
              onRandomPick: () => randomPressed = true,
              addBackgroundColor: Colors.cyan,
              addForegroundColor: Colors.black,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Add Comics'), findsOneWidget);
    expect(find.byIcon(Icons.casino_outlined), findsOneWidget);

    await tester.tap(find.text('Add Comics'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.casino_outlined));

    expect(addPressed, isTrue);
    expect(randomPressed, isTrue);
  });
}
