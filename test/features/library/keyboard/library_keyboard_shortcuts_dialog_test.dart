import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shortcuts dialog shows key caps and a shared Close button',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showKeyboardShortcutsDialog(context),
                    child: const Text('open'))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Ctrl'), findsNWidgets(6));
    expect(find.text('F5'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    final close = find.widgetWithText(FilledButton, 'Close');
    expect(close, findsOneWidget);
    expect(tester.getSize(close), const Size(100, 32));
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard Shortcuts'), findsNothing);
  });
}
