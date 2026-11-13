import 'dart:io';
import 'dart:async';
import 'package:collectarr_app/features/library/kinds/game/integrations/import/clz_game_web_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/config/import_sources.dart';
import 'package:collectarr_app/features/library/reports/import/guided_import_panel.dart';
import 'package:collectarr_app/features/library/reports/import/csv_import_panel.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guided parsing runs through the background parser', () async {
    for (final fixture in ['minimal', 'optional']) {
      final content = File('test/fixtures/imports/game/clz_web/$fixture.xml')
          .readAsStringSync();
      final rows = await parseGuidedImport(const ClzGameWebImporter(), content);
      expect(rows, hasLength(1), reason: fixture);
    }
    await expectLater(parseGuidedImport(const ClzGameWebImporter(), '<wrong/>'),
        throwsFormatException);
  });

  testWidgets('file reading shows progress and Reset clears the selection',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final reading = Completer<String>();
    await tester.pumpWidget(MaterialApp(
      theme: buildLibraryTheme(),
      home: Scaffold(
          body: GuidedImportPanel(
        pluralLabel: 'Albums',
        source:
            musicImportSources.singleWhere((source) => source.id == 'discogs'),
        filePicker: ({required label, required extensions}) async =>
            (name: 'collection.csv', readContent: () => reading.future),
        onImport: (rows, _) async => rows.length,
        onComplete: (_) {},
      )),
    ));
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Reading file'), findsOneWidget);
    reading.complete('Artist,Title,release_id\nMira,Example,123');
    await tester.pumpAndSettle();
    expect(find.text('Selected File: '), findsOneWidget);
    expect(find.text('collection.csv'), findsOneWidget);
    await tester.tap(find.byKey(const Key('import_file_reset')));
    await tester.pumpAndSettle();
    expect(find.text('No File Selected'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('import_guided.submit')))
            .onPressed,
        isNull);
  });

  testWidgets(
      'guided import parses the chosen file on Import and clears stale errors',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var content = '<wrong><title>Do not import</title></wrong>';
    var saved = 0;
    var completed = 0;
    await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
            body: SingleChildScrollView(
                child: GuidedImportPanel(
                    pluralLabel: 'Albums',
                    parse: (importer, content) async => importer.parse(content),
                    source: musicImportSources
                        .singleWhere((s) => s.id == 'discogs'),
                    filePicker: ({required label, required extensions}) async =>
                        (
                          name: 'collection.csv',
                          readContent: () async => content
                        ),
                    onImport: (rows, _) async {
                      saved += rows.length;
                      return rows.length;
                    },
                    onComplete: (count) => completed = count)))));
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Unsupported / invalid export'), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('import_guided.submit')));
    await tester.tap(find.byKey(const Key('import_guided.submit')));
    await tester.pumpAndSettle();
    expect(find.text('Unsupported / invalid export'), findsOneWidget);
    expect(find.text('0 records saved'), findsOneWidget);
    expect(saved, 0);
    await tester.tap(find.byKey(const Key('import_file_reset')));
    await tester.pumpAndSettle();
    content = File('test/fixtures/imports/music/discogs/quoted_multiline.csv')
        .readAsStringSync();
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Unsupported / invalid export'), findsNothing);
    expect(saved, 0);
    await tester.ensureVisible(find.byKey(const Key('import_guided.submit')));
    await tester.tap(find.byKey(const Key('import_guided.submit')));
    await tester.pumpAndSettle();
    expect(saved, 2);
    expect(completed, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'mapped CSV requires a Title mapping without first-column fallbacks',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var content = 'Artist,Label\nMira,Example';
    var saved = 0;
    await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
            body: SingleChildScrollView(
                child: CsvImportPanel(
                    capability: musicKindImport,
                    pluralLabel: 'Albums',
                    filePicker: ({required label, required extensions}) async =>
                        (
                          name: 'collection.csv',
                          readContent: () async => content
                        ),
                    onImport: (rows, _) async {
                      saved += rows.length;
                      return rows.length;
                    },
                    onComplete: (_) {})))));
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('import_csv.submit')));
    await tester.tap(find.byKey(const Key('import_csv.submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Map a column to Title'), findsOneWidget);
    expect(saved, 0);
    await tester.ensureVisible(find.byKey(const Key('import_file_reset')));
    await tester.tap(find.byKey(const Key('import_file_reset')));
    await tester.pumpAndSettle();
    content =
        'Title,Artist,Purchase Price,Notes\nAfter & Before,Mira,12.50,Example';
    await tester.ensureVisible(find.byKey(const Key('import_file_picker_btn')));
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('import_csv.submit')));
    await tester.tap(find.byKey(const Key('import_csv.submit')));
    await tester.pumpAndSettle();
    expect(saved, 1);
    expect(tester.takeException(), isNull);
  });
}
