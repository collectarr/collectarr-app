import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/entries/entry_import_transport.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active summary projection keeps only structural copy identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final entry = ComicLibraryEntry(
      id: const LibraryEntryId('entry-comic-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'entry-comic-1',
      ),
      condition: 'Near Mint',
      grade: '9.8',
      ownerLabel: 'Alex',
      locationId: 'shelf-a',
      catalogData: const {'title': 'Batman: Year One'},
      updatedAt: DateTime.utc(2026, 5, 1),
      details: const ComicEntryDetails(),
    );
    await LibraryEntriesRepository(db).replaceFromTransport(
      EntryImportTransport(
        ref: LibraryEntryRef(
          kind: CatalogMediaKind.comic,
          id: LibraryEntryId(entry.id.value),
        ),
        payload: LibraryEntryRecord(
          id: entry.id.value,
          kind: CatalogMediaKind.comic,
          catalogData: const {'title': 'Batman: Year One'},
          personalData: const {
            'condition': 'Near Mint',
            'grade': '9.8',
            'owner_label': 'Alex',
            'location_id': 'shelf-a',
          },
          updatedAt: DateTime.utc(2026, 5, 1),
        ).toJson(),
      ),
    );

    final summaries = await LibraryEntriesRepository(db).listActiveSummaries();

    expect(summaries, hasLength(1));
    final summary = summaries.single;
    expect(summary.ref.kind, CatalogMediaKind.comic);
    expect(summary.ref.id.value, 'entry-comic-1');
    expect(summary.catalogRef?.id, 'entry-comic-1');
    expect(summary.ownerLabel, 'Alex');
    expect(summary.locationLabel, 'shelf-a');
    final record = await LibraryEntriesRepository(db).payloadByRef(summary.ref);
    expect(record?['catalog_data'], {'title': 'Batman: Year One'});
  });

  test('invalid attachment import does not partially persist the entry',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ref = LibraryEntryRef(
      kind: CatalogMediaKind.comic,
      id: const LibraryEntryId('invalid-import'),
    );
    final payload = LibraryEntryRecord(
      id: ref.id.value,
      kind: ref.kind,
      catalogData: const {'title': 'Valid catalog data'},
      personalData: const {
        libraryEntrySyncImagesKey: [
          {'id': 'image-without-data'},
        ],
      },
      updatedAt: DateTime.utc(2026, 5, 1),
    ).toJson();

    await expectLater(
      LibraryEntriesRepository(db).replaceFromTransport(
        EntryImportTransport(ref: ref, payload: payload),
      ),
      throwsA(isA<TypeError>()),
    );

    expect(await LibraryEntriesRepository(db).payloadByRef(ref), isNull);
  });

  test('sync snapshot includes complete metadata and local attachments',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ref = LibraryEntryRef(
      kind: CatalogMediaKind.comic,
      id: const LibraryEntryId('sync-entry'),
    );
    final entries = LibraryEntriesRepository(db);
    await entries.replaceFromTransport(
      EntryImportTransport(
        ref: ref,
        payload: LibraryEntryRecord(
          id: ref.id.value,
          kind: ref.kind,
          catalogData: const {'title': 'Local catalog title', 'year': 2024},
          personalData: const {'condition': 'Near Mint', 'quantity': 2},
          sourceCatalogRef: const CatalogItemRef(
            kind: CatalogMediaKind.comic,
            id: 'core-comic-4',
          ),
          updatedAt: DateTime.utc(2026, 10, 2),
        ).toJson(),
      ),
    );
    await ItemImageRepository(db).add(
      ItemImage(
        id: 'image-1',
        libraryEntryRef: ref,
        imageData: Uint8List.fromList([1, 2, 3]),
        createdAt: DateTime.utc(2026, 10, 2),
      ),
    );
    await CustomFieldRepository(db).upsertValue(
      CustomFieldValue(
        id: 'field-value-1',
        targetId: ref.key,
        targetScope: CustomFieldTargetScope.libraryEntry,
        fieldDefinitionId: 'field-signed',
        value: 'Artist',
        updatedAt: DateTime.utc(2026, 10, 2),
      ),
    );

    final change = await entries.syncChangeForCurrentEntry(
      ref,
      action: 'upsert',
      changedAt: DateTime.utc(2026, 10, 2, 12),
    );
    final personal = change.payload['personal_data'] as Map<String, dynamic>;

    expect(change.entityType, 'library_entry');
    expect(change.entityId, 'sync-entry');
    expect(change.payload['catalog_data'], {
      'title': 'Local catalog title',
      'year': 2024,
    });
    expect(personal['quantity'], 2);
    expect(personal[libraryEntrySyncImagesKey], hasLength(1));
    expect(
      (personal[libraryEntrySyncImagesKey] as List).single['image_data'],
      'AQID',
    );
    expect(personal[libraryEntrySyncCustomFieldsKey], hasLength(1));
    expect(
      (personal[libraryEntrySyncCustomFieldsKey] as List)
          .single['field_definition_id'],
      'field-signed',
    );
  });
}
