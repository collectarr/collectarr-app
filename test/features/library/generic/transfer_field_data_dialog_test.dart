import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/library_entry_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/generic/transfer_field_data_dialog.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures/test_constants.dart';

void main() {
  testWidgets(
      'custom field move previews selected scope and clears source atomically',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = jsonDecode(
        File('tool/fixtures/music_inspector_reference.json')
            .readAsStringSync()) as Map<String, dynamic>;
    (fixture['personal'] as Map)['personal_notes'] = '';
    final entry = await seedMusicInspectorReference(db, fixture);
    final ref = LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id);
    final item = TransferableLibraryEntry(ref: ref, value: entry);
    final definition = CustomFieldDefinition(
        id: 'source-field',
        name: 'Reference source',
        fieldType: 'text',
        mediaKind: 'music',
        createdAt: DateTime.utc(2026));
    final custom = CustomFieldRepository(db);
    await custom.upsertDefinition(definition);
    await custom.upsertValue(CustomFieldValue(
        id: 'source-value',
        targetId: ref.key,
        targetScope: CustomFieldTargetScope.libraryEntry,
        fieldDefinitionId: definition.id,
        value: 'Moved from custom field',
        updatedAt: DateTime.utc(2026)));
    final bus = CollectionEventBus();
    addTearDown(bus.dispose);
    final mutations = LibraryEntryMutations(
        libraryEntries: LibraryEntriesRepository(db),
        wishlist: WishlistItemsCacheRepository(db),
        catalogSummaries: CatalogDisplaySummaryRepository(db),
        syncQueue: SyncQueueRepository(db),
        mutationRunner: CollectionMutationRunner(database: db, events: bus));
    TransferFieldResult? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      result = await showTransferFieldDataDialog(
                          context: context,
                          db: db,
                          type: const MusicRegistration(),
                          allItems: [item],
                          currentItems: [],
                          selectedItems: [item],
                          initialScope: TransferItemScope.currentList,
                          mutations: mutations,
                          customFieldDefinitions: [definition]);
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);
    expect(find.text('Current List (0)'), findsOneWidget);
    await tester.tap(find.text('Checkboxed (1)'));
    await tester.pumpAndSettle();
    final selects =
        find.byType(CompactSearchDropdownFormField<TransferableField>);
    await tester.tap(selects.first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Reference source');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reference source').last);
    await tester.pumpAndSettle();
    expect(find.text('1 item has data in this field'), findsOneWidget);
    await tester.tap(selects.last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Personal notes');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal notes').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Move (1)'));
    await tester.tap(find.text('Move (1)'));
    await pumpUntilSettled(tester);
    expect(result?.transferred, 1);
    expect(result?.total, 1);
    expect(
        (await MusicEntryRepository(db).findById(entry.id))!
            .personal
            .personalNotes,
        'Moved from custom field');
    expect((await custom.listAllValues())[ref.key]!.single.value, isNull);
    final queued = (await SyncQueueRepository(db).readPending()).changes;
    expect(queued, hasLength(1));
    final personal = queued.single.payload['personal_data'] as Map;
    final attachments = personal[libraryEntrySyncCustomFieldsKey] as List;
    expect((attachments.single as Map)['value'], isNull);
    expect(personal['personal_notes'], 'Moved from custom field');
    expect(tester.takeException(), isNull);
  });
}
