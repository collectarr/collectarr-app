import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'sort drag down saves normalized order and Cancel discards direction changes',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var rules = const [
      LibrarySortRule(column: 'music.title', ascending: true),
      LibrarySortRule(column: 'music.release_date', ascending: false)
    ];
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    child: const Text('Open'),
                    onPressed: () async {
                      final result = await showLibrarySortDialog(
                          context: context,
                          type: const MusicRegistration(),
                          currentRules: rules);
                      if (result != null) rules = result;
                    })))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final selectedContext =
        tester.element(find.byKey(const ValueKey('selected-sort-music.title')));
    final palette = appPalette(selectedContext);
    expect(palette.accent, const MusicRegistration().identity.accent);
    expect(
        palette.selection,
        Color.alphaBlend(
            palette.accent.withValues(alpha: 0.22), palette.panel));
    await dragDown(tester,
        find.byKey(const ValueKey('selected-sort-music.title-handle')), 76);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(rules.map((r) => r.column), ['music.release_date', 'music.title']);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
        tester
            .getTopLeft(
                find.byKey(const ValueKey('selected-sort-music.release_date')))
            .dy,
        lessThan(tester
            .getTopLeft(find.byKey(const ValueKey('selected-sort-music.title')))
            .dy));
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey('selected-sort-music.title')),
        matching: find.text('ASC')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(rules.last.ascending, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('column drag down saves exact order and Cancel discards removal',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var columns = {'title', 'publisher', 'barcode'};
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    child: const Text('Open'),
                    onPressed: () async {
                      final result = await showDialog<Set<String>>(
                          context: context,
                          builder: (_) => LibraryColumnChooserDialog(
                              accent: Colors.orange,
                              availableColumns: const [
                                'title',
                                'publisher',
                                'barcode'
                              ],
                              selectedColumns: columns,
                              defaultColumns: const {'title'},
                              primaryColumn: 'title',
                              columnLabel: (c) => c));
                      if (result != null) columns = result;
                    })))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await dragDown(
        tester, find.byKey(const ValueKey('selected-column-title-handle')), 76);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(columns.toList(), ['publisher', 'barcode', 'title']);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('available-column-barcode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(columns.toList(), ['publisher', 'barcode', 'title']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('field dialogs fit a narrow viewport with saved favorites',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(420, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LibraryColumnChooserDialog(
                accent: Colors.orange,
                availableColumns: const ['title', 'publisher', 'barcode'],
                selectedColumns: const {'title', 'publisher'},
                defaultColumns: const {'title'},
                columnLabel: (c) => c,
                presets: const [
                  LibraryTableColumnPreset(
                      label: 'Reference', columns: {'title', 'barcode'})
                ],
                onSavePreset: (name, columns) async => []))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showLibrarySortDialog(
                            context: context,
                            type: const MusicRegistration(),
                            currentRules: const [
                              LibrarySortRule(
                                  column: 'music.title', ascending: true)
                            ]),
                    child: const Text('Sort'))))));
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> dragDown(
    WidgetTester tester, Finder handle, double distance) async {
  final start = tester.getCenter(handle);
  final gesture = await tester.startGesture(start);
  await tester.pump();
  await gesture.moveTo(start + const Offset(0, 24));
  await tester.pump(const Duration(milliseconds: 300));
  await gesture.moveTo(start + Offset(0, distance));
  await tester.pump(const Duration(milliseconds: 300));
  await gesture.up();
  await tester.pumpAndSettle();
}
