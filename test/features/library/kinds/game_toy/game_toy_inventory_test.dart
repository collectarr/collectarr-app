import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('separate typed entry persists personal fields and partial dates',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = GameToyEntryRepository(db);
    final entry = GameToyLibraryEntry(
        id: const LibraryEntryId('inventory-1'),
        metadata: GameToyCatalogMetadata(
            title: 'Test inventory',
            releaseDateParts: const PartialDate(year: 2020),
            toyType: 'Figure',
            toySubtype: 'Amiibo'),
        personal: GameToyPersonalData(
            ownerLabel: 'Local owner',
            tags: const ['Gift'],
            details: const GameToyEntryDetails(
                completeness: GameToyCompleteness.newSealed, hasBox: true)),
        updatedAt: DateTime.utc(2026));
    await repository.upsert(entry);
    final read = await repository.findById(entry.id);
    expect(read!.toJson(), entry.toJson());
    expect(read.metadata.toJson(), isNot(contains('completed')));
    expect(read.metadata.toJson(), isNot(contains('serial_number')));
    final collections = LibraryCollectionRepository(db);
    final target = await collections.create('game', 'Games only');
    expect(
        () => collections.move(
            [LibraryEntryRef(kind: CatalogMediaKind.gameToy, id: entry.id)],
            target.id),
        throwsArgumentError);
    expect((await collections.list('game')).single.kind, 'game');
  });
  testWidgets(
      'Value selection updates packaging and supports clearing stored ID',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final record = LibraryEntryRecord(
        id: 'inventory-1',
        kind: CatalogMediaKind.gameToy,
        catalogData: {'title': 'Test inventory'},
        personalData:
            const GameToyEntryDetails(priceChartingId: '123').toJson(),
        updatedAt: DateTime.utc(2026));
    final draft = LibraryEntryEditDraft(record);
    addTearDown(draft.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: ListenableBuilder(
                    listenable: draft,
                    builder: (context, _) => GameToyValueTab(draft: draft))))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New').first);
    await tester.pumpAndSettle();
    expect(draft.values['game_toy_completeness'], 'new');
    expect(draft.values['game_toy_has_box'], isTrue);
    expect(find.text('Manual'), findsNothing);
    expect(find.text('CIB'), findsNothing);
    expect(() => GameToyCompleteness.parse('graded'), throwsFormatException);
    final idField = find.widgetWithText(TextFormField, '123');
    await tester.enterText(idField, '');
    await tester.pumpAndSettle();
    expect(draft.values['game_toy_price_charting_id'], isNull);
    expect(find.text('Storage Device'), findsNothing);
    expect(find.text('Completed'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
