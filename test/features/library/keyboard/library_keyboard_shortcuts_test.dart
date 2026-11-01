import 'package:collectarr_app/features/library/keyboard/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ctrl+a invokes select-all shortcut', (tester) async {
    var selectAllInvocations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryKeyboardShortcuts(
            onSelectAll: () => selectAllInvocations += 1,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    addTearDown(() => tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);

    expect(selectAllInvocations, 1);
  });

  testWidgets('delete invokes delete shortcut', (tester) async {
    var deleteInvocations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryKeyboardShortcuts(
            onDelete: () => deleteInvocations += 1,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.delete);

    expect(deleteInvocations, 1);
  });

  testWidgets('a focused text field keeps K, J and Delete', (tester) async {
    var moves = 0;
    var deletes = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryKeyboardShortcuts(
            onNextItem: () => moves += 1,
            onPreviousItem: () => moves += 1,
            onDelete: () => deletes += 1,
            child: const TextField(),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);

    expect(moves, 0);
    expect(deletes, 0);
  });

  testWidgets('K and J move between items outside text fields', (tester) async {
    var moves = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryKeyboardShortcuts(
            onNextItem: () => moves += 1,
            onPreviousItem: () => moves += 1,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);

    expect(moves, 2);
  });
}
