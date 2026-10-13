import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('partial date separators share the field center and fixed geometry', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLibraryTheme(),
      home: Scaffold(body: Center(child: SizedBox(width: 300,
        child: LibraryPartialDateInput(onChanged: (_) {}),
      ))),
    ));
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(3));
    final center = tester.getRect(fields.first).center.dy;
    for (var i = 1; i < 3; i++) {
      final separator = find.byKey(ValueKey('partial-date-separator-$i'));
      expect(separator, findsOneWidget);
      final rect = tester.getRect(separator);
      expect(rect.width, 8);
      expect(rect.height, 1);
      expect(rect.center.dy, closeTo(center, 1.5));
    }
  });
}
