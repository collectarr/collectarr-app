import 'package:collectarr_app/features/library/kinds/game_hardware/data/game_hardware_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_completeness.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/edit/value_tab.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/collections/repository.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
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
    final repository = GameHardwareEntryRepository(db);
    final entry = GameHardwareLibraryEntry(
        id: const LibraryEntryId('inventory-1'),
        metadata: GameHardwareCatalogMetadata(
            title: 'Test inventory',
            releaseDateParts: const PartialDate(year: 2020),
            platform: 'PC',
            hardwareType: 'Controller'),
        personal: GameHardwarePersonalData(
            ownerLabel: 'Local owner',
            tags: const ['Gift'],
            details: const GameHardwareEntryDetails(
                completeness: GameHardwareCompleteness.cib,
                serialNumber: 'LOCAL-1',
                hasManual: true,
                hasBox: true)),
        updatedAt: DateTime.utc(2026));
    await repository.upsert(entry);
    final read = await repository.findById(entry.id);
    expect(read!.toJson(), entry.toJson());
    expect(read.metadata.toJson(), isNot(contains('completed')));
    expect(read.metadata.toJson(), isNot(contains('serial_number')));
    final collections = LibraryCollectionRepository(db);
    final target = await collections.create('game', 'Games only');
    expect(
        () => collections.move([
              LibraryEntryRef(kind: CatalogMediaKind.gameHardware, id: entry.id)
            ], target.id),
        throwsArgumentError);
    expect((await collections.list('game')).single.kind, 'game');
  });
  test('revisions and copies of one product stay separate entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = GameHardwareEntryRepository(db);
    // As in CLZ, a revision is its own item titled by its variant and grouped
    // by Series; each owned copy is its own entry.
    GameHardwareLibraryEntry copy(String id, String revision, String serial) =>
        GameHardwareLibraryEntry(
            id: LibraryEntryId(id),
            metadata: GameHardwareCatalogMetadata(
                title: 'Test Deck [$revision]',
                seriesTitle: 'Test Deck',
                platform: 'PC',
                hardwareType: 'Console'),
            sourceCatalogRef: CatalogItemRef(
                kind: CatalogMediaKind.gameHardware, id: 'deck-$revision'),
            personal: GameHardwarePersonalData(
                details: GameHardwareEntryDetails(serialNumber: serial)),
            updatedAt: DateTime.utc(2026));
    final small = copy('deck-1', '256 GB', 'SN-1');
    final first = copy('deck-2', '512 GB', 'SN-2');
    final second = copy('deck-3', '512 GB', 'SN-3');
    await repository.upsertAll([small, first, second]);

    final active = await repository.listActive();
    expect(active.map((entry) => entry.metadata.seriesTitle).toSet(),
        {'Test Deck'});
    expect(active.map((entry) => entry.sourceCatalogRef?.id).toSet(),
        {'deck-256 GB', 'deck-512 GB'});
    expect(active.map((entry) => entry.personal.details.serialNumber).toSet(),
        {'SN-1', 'SN-2', 'SN-3'});

    await repository.markDeleted(first, DateTime.utc(2026, 2));
    final left = await repository.listActive();
    expect(left.map((entry) => entry.id.value).toSet(), {'deck-1', 'deck-3'});
    expect(
        (await repository.findById(second.id))!.personal.details.serialNumber,
        'SN-3');
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
        kind: CatalogMediaKind.gameHardware,
        catalogData: {'title': 'Test inventory'},
        personalData:
            const GameHardwareEntryDetails(priceChartingId: '123').toJson(),
        updatedAt: DateTime.utc(2026));
    final draft = LibraryEntryEditDraft(record);
    addTearDown(draft.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: ListenableBuilder(
                    listenable: draft,
                    builder: (context, _) =>
                        GameHardwareValueTab(draft: draft))))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CIB').first);
    await tester.pumpAndSettle();
    expect(draft.values['game_hardware_completeness'], 'cib');
    expect(draft.values['game_hardware_has_box'], isTrue);
    expect(draft.values['game_hardware_has_manual'], isTrue);
    final idField = find.widgetWithText(TextFormField, '123');
    await tester.enterText(idField, '');
    await tester.pumpAndSettle();
    expect(draft.values['game_hardware_price_charting_id'], isNull);
    expect(find.text('Storage Device'), findsNothing);
    expect(find.text('Completed'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
