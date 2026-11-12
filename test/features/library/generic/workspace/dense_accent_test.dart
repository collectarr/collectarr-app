import 'package:collectarr_app/features/library/workspace/chrome/dense_controls.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'popup selected marker stays white outside the launcher accent scope',
      (tester) async {
    const accent = Color(0xffed8b23);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.cyan, brightness: Brightness.dark)),
        home: Scaffold(
            body: LibraryAccentScope(
                kind: 'music',
                accent: accent,
                animationsEnabled: false,
                child: LibraryDenseMenuButton<String>(
                    label: 'Favorites',
                    icon: Icons.star_outline,
                    entries: [
                      LibraryDenseMenuEntry(
                          value: 'chosen',
                          label: 'Chosen columns',
                          icon: Icons.view_column_outlined,
                          active: true)
                    ],
                    onSelected: (_) {})))));
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Chosen columns'), findsOneWidget);
    final marker = tester.widget<Icon>(find.byIcon(AppIcons.check));
    expect(marker.color, Colors.white);
  });
}
