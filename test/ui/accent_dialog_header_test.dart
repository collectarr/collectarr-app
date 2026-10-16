import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccentDialogHeader', () {
    testWidgets('renders white title, flat accent chrome, and white close button',
        (tester) async {
      var closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LibraryAccentScope(
            kind: 'music',
            accent: Colors.deepPurple,
            animationsEnabled: false,
            child: Scaffold(
              body: AccentDialogHeader(
                title: 'Test Modal',
                icon: Icons.album,
                onClose: () => closed = true,
              ),
            ),
          ),
        ),
      );

      // Verify title is white
      final titleFinder = find.text('Test Modal');
      expect(titleFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontSize, 18);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
      expect(textWidget.style?.height, 1);

      // Verify icon is white
      final iconFinder = find.byIcon(Icons.album);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, Colors.white);

      // Verify close button is present and white
      final closeFinder = find.byIcon(AppIcons.close);
      expect(closeFinder, findsOneWidget);

      await tester.tap(closeFinder);
      expect(closed, isTrue);

      // Flat accent chrome without a border, as in the reference.
      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>();
      final chrome =
          decorations.where((d) => d.color == Colors.deepPurple).toList();
      expect(chrome, isNotEmpty);
      expect(chrome.every((d) => d.border == null), isTrue);
      expect(decorations.every((d) => d.gradient == null), isTrue);
    });

    testWidgets('pops dialog when onClose is omitted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const Dialog(
                      child: AccentDialogHeader(
                          icon: Icons.settings, title: 'Dialog Title'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.byIcon(AppIcons.close), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsNothing);
    });

    testWidgets('hides close button when showCloseButton is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccentDialogHeader(
              icon: Icons.settings,
              title: 'No Close',
              showCloseButton: false,
            ),
          ),
        ),
      );

      expect(find.text('No Close'), findsOneWidget);
      expect(find.byIcon(AppIcons.close), findsNothing);
    });
  });

  group('AccentAlertDialog', () {
    testWidgets('renders white title and gradient header in AlertDialog',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccentAlertDialog(
              title: Text('Alert Title'),
              content: Text('Alert content'),
            ),
          ),
        ),
      );

      final titleFinder = find.text('Alert Title');
      expect(titleFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, Colors.white);
      expect(find.byIcon(AppIcons.close), findsOneWidget);
    });
  });
}
