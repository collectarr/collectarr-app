import 'dart:io';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_export_xml_flow.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

Future<void> advanceUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 30 && !done(); i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(done(), isTrue);
}

void main() {
  const selector = MethodChannel('plugins.flutter.io/file_selector');
  for (final kind in [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy
  ]) {
    testWidgets(
        '$kind exports local metadata through confirmation and Download',
        (tester) async {
      final db = LocalDatabase(NativeDatabase.memory());
      final scratch = Directory.systemTemp.createTempSync('collectarr-xml-');
      final destination = File('${scratch.path}/export.xml');
      addTearDown(() async {
        await db.close();
        scratch.deleteSync(recursive: true);
        tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(selector, null);
      });
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(selector,
          (call) async {
        expect(call.method, 'getSavePath');
        expect((call.arguments as Map)['suggestedName'],
            'collectarr-${kind.apiValue}.xml');
        return destination.path;
      });
      await tester.runAsync(() => LibraryEntryStore(db).put(LibraryEntryRecord(
            id: 'local-copy',
            kind: kind,
            catalogData: {'title': 'Local & complete', 'barcode': '123'},
            personalData: {'notes': 'Keep my notes'},
            updatedAt: DateTime.utc(2026),
          )));
      var finished = false;
      await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: Builder(builder: (context) {
        return TextButton(
            onPressed: () async {
              await exportLibraryEntriesXml(
                  context: context,
                  type: libraryKindRegistration(kind),
                  database: db,
                  entries: [
                    LibraryEntryRef(
                        kind: kind, id: const LibraryEntryId('local-copy'))
                  ]);
              finished = true;
            },
            child: const Text('Start'));
      }))));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export'));
      await tester.pump();
      await advanceUntil(
          tester, () => find.text('Download').evaluate().isNotEmpty);
      expect(destination.existsSync(), isFalse);
      await tester.tap(find.text('Download'));
      await advanceUntil(tester, () => finished);
      final xml = XmlDocument.parse(destination.readAsStringSync());
      expect(xml.findAllElements('item'), hasLength(1));
      expect(xml.findAllElements('field').map((field) => field.innerText),
          containsAll(['Local & complete', 'Keep my notes', '123']));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('an empty library explains why XML cannot be exported',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return TextButton(
          onPressed: () => exportLibraryEntriesXml(
              context: context,
              type: libraryKindRegistration(CatalogMediaKind.game),
              database: db,
              entries: const []),
          child: const Text('Start'));
    })));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('There are no games to export.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('There are no games to export.'), findsNothing);
  });
}
