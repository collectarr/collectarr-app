import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('sort field search can be cleared and used again',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                    body: TextButton(
                  onPressed: () => showLibrarySortDialog(
                      context: context,
                      type: const MusicRegistration(),
                      currentRules: const [
                        LibrarySortRule(column: 'music.title', ascending: true)
                      ]),
                  child: const Text('Sort'),
                )))));
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<AccentDialogHeader>(find.byType(AccentDialogHeader))
            .accent,
        const MusicRegistration().identity.accent);
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.hintText == 'Search fields');
    await tester.enterText(search, 'Barcode');
    await tester.pumpAndSettle();
    expect(find.text('Barcode'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    await tester.enterText(search, 'Release Date');
    await tester.pumpAndSettle();
    expect(find.text('Barcode'), findsNothing);
    expect(find.byKey(const ValueKey('available-sort-music.release_date')),
        findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(700, 650));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Sorting favorites'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Sorting favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Latest release'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('selected-sort-music.release_date')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Select Sort Fields'), findsNothing);
  });
}
