import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_actions.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary actions render add button only', (
    tester,
  ) async {
    var addPressed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbarPrimaryActions(
              addLabel: 'Add Comics',
              onAdd: () => addPressed = true,
              onScanBarcode: () {},
              onRefreshMetadata: () {},
              addBackgroundColor: Colors.cyan,
              addForegroundColor: Colors.black,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Add Comics'), findsOneWidget);
    expect(find.byIcon(Icons.casino_outlined), findsNothing);

    await tester.tap(find.text('Add Comics'));
    await tester.pump();

    expect(addPressed, isTrue);
  });

  testWidgets('hovering Add darkens it like the editor Save button', (
    tester,
  ) async {
    const blue = Color(0xFF5EB1DE);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbarPrimaryActions(
              addLabel: 'Add Games',
              onAdd: () {},
              onScanBarcode: () {},
              onRefreshMetadata: () {},
              addBackgroundColor: blue,
              addForegroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
    Color? fill() => tester
        .widget<Material>(find.descendant(
            of: find.byType(FilledButton), matching: find.byType(Material)))
        .color;
    expect(fill(), blue);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Add Games')));
    await tester.pumpAndSettle();

    expect(fill(), filledButtonHoverColor(blue));
    expect(fill(), isNot(blue));
  });
}
