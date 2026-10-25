import 'dart:io';
import 'package:collectarr_app/features/library/kinds/music/config/music_import_sources.dart';
import 'package:collectarr_app/features/library/reports/import/guided_import_panel.dart';
import 'package:collectarr_app/features/library/reports/import/csv_import_panel.dart';
import 'package:collectarr_app/features/library/reports/import/import_rows_review.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'guided file selection reviews records before explicit confirmation and clears stale errors',
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
                    source: musicImportSources
                        .singleWhere((s) => s.id == 'discogs'),
                    filePicker: ({required label, required extensions}) async =>
                        (name: 'collection.csv', content: content),
                    onImport: (rows, _) async {
                      saved += rows.length;
                      return rows.length;
                    },
                    onComplete: (count) => completed = count)))));
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Unsupported / invalid export'), findsOneWidget);
    expect(find.text('0 records saved'), findsOneWidget);
    expect(saved, 0);
    content = File('test/fixtures/imports/music/discogs/quoted_multiline.csv')
        .readAsStringSync();
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    expect(find.byType(ImportRowsReview), findsOneWidget);
    expect(find.text('After & Before'), findsOneWidget);
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
      'mapped CSV requires review and a Title mapping without first-column fallbacks',
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
                        (name: 'collection.csv', content: content),
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
    content =
        'Title,Artist,Purchase Price,Notes\nAfter & Before,Mira,12.50,Example';
    await tester.ensureVisible(find.byKey(const Key('import_file_picker_btn')));
    await tester.tap(find.byKey(const Key('import_file_picker_btn')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('import_csv.submit')));
    await tester.tap(find.byKey(const Key('import_csv.submit')));
    await tester.pumpAndSettle();
    expect(find.byType(ImportRowsReview), findsOneWidget);
    expect(saved, 0);
    await tester.ensureVisible(find.byKey(const Key('import_csv.submit')));
    await tester.tap(find.byKey(const Key('import_csv.submit')));
    await tester.pumpAndSettle();
    expect(saved, 1);
    expect(tester.takeException(), isNull);
  });
}
