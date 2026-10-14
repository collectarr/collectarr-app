import 'package:collectarr_app/ui/theme/app_typography.dart';
import 'package:collectarr_app/ui/theme/library_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calendar actions retain the active family and control text size',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLibraryTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showDatePicker(
              context: context,
              initialDate: DateTime(2026, 2, 18),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            ),
            child: const Text('Open calendar'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open calendar'));
    await tester.pumpAndSettle();
    for (final label in ['Cancel', 'OK']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.descendant(
          of: find.text(label), matching: find.byType(RichText)));
      final style = paragraph.text.style!;
      expect(style.fontFamily, appFontFamily);
      expect(style.fontSize, 14);
      expect(style.fontWeight, kAppNormalFontWeight);
    }
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Open calendar'), findsOneWidget);
  });
}
