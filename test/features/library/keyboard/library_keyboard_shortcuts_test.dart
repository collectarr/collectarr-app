import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
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
}