import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccentDialogHeader', () {
    testWidgets(
        'renders white title, flat accent chrome, and white close button',
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

      // Verify flat accent chrome decoration is present
      final decoratedBoxes =
          tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final hasGradient = decoratedBoxes.any(
        (box) =>
            box.decoration is BoxDecoration &&
            (box.decoration as BoxDecoration).gradient != null,
      );
      expect(hasGradient, isFalse);
      expect(
          decoratedBoxes.any((box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).color == Colors.deepPurple),
          isTrue);
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
                      child: AccentDialogHeader(title: 'Dialog Title'),
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
    testWidgets('renders white title and flat header in AlertDialog',
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
