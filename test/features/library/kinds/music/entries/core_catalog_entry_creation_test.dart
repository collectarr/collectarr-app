import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_library_entry_create_payload.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Core Music entry creation preserves kind-decoded metadata and personal data',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // Fictional canonical response produced by tool/local_core/seed.py.
    final payload = jsonDecode(
        await File('test/support/fixtures/music_core_ui_album.json')
            .readAsString()) as Map<String, dynamic>;
    final catalog = CatalogItemDto.fromJson(payload);
    await CatalogItemCacheRepository(db).upsertAll([catalog]);
    await musicEntryContributor.createLibraryEntry(
      database: db,
      payload: MusicLibraryEntryCreatePayload(
          details: MusicEntryDetailsDraft(),
          quantity: 2,
          personalNotes: 'Keep this local note'),
      resolvedCatalogRef: catalog.catalogItemRef,
      id: 'ui-core-entry',
      createdAt: DateTime.utc(2026, 10, 14),
      existingIsDigital: null,
      ownerUserId: null,
      ownerLabel: null,
    );
    final entry = await MusicEntryRepository(db)
        .findById(const LibraryEntryId('ui-core-entry'));
    expect(entry, isNotNull);
    expect(entry!.metadata.publisher, 'Demo Records');
    expect(entry.metadata.countryCode, 'United Kingdom');
    expect(entry.metadata.discs, hasLength(2));
    expect(entry.metadata.discs.last.isLive, isTrue);
    expect(entry.metadata.discs.last.recordingLocations, ['Demo Hall']);
    expect(entry.metadata.credits.single.role, 'Producer');
    expect(entry.sourceCatalogRef, catalog.catalogItemRef);
    expect(entry.personal.quantity, 2);
    expect(entry.personal.personalNotes, 'Keep this local note');
    expect(entry.toJson()['catalog_data'], contains('publisher'));
    expect(entry.toJson()['catalog_data'], isNot(contains('label')));
    expect(entry.personal.indexNumber, 1);

    // A second entry without an Index takes the next free one.
    await musicEntryContributor.createLibraryEntry(
      database: db,
      payload:
          MusicLibraryEntryCreatePayload(details: MusicEntryDetailsDraft()),
      resolvedCatalogRef: catalog.catalogItemRef,
      id: 'ui-core-entry-2',
      createdAt: DateTime.utc(2026, 10, 14),
      existingIsDigital: null,
      ownerUserId: null,
      ownerLabel: null,
    );
    final second = await MusicEntryRepository(db)
        .findById(const LibraryEntryId('ui-core-entry-2'));
    expect(second!.personal.indexNumber, 2);
  });
}
