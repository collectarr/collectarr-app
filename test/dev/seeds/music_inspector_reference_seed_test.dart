import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'comparison seed persists canonical metadata and all personal scopes idempotently',
      () async {
    final database = LocalDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = jsonDecode(
        await File('tool/fixtures/music_inspector_reference.json')
            .readAsString()) as Map<String, dynamic>;
    final images = {
      'front_cover':
          await File('tool/fixtures/music-inspector-front.png').readAsBytes(),
      'back_cover':
          await File('tool/fixtures/music-inspector-back.png').readAsBytes(),
    };
    final entry =
        await seedMusicInspectorReference(database, fixture, images: images);
    await seedMusicInspectorReference(database, fixture, images: images);
    final ref = LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id);
    final records =
        await LibraryEntryStore(database).list(kind: CatalogMediaKind.music);
    expect(records, hasLength(1));
    expect(
        records.single.catalogData['title'], 'Collectarr Inspector Reference');
    expect(records.single.personalData['quantity'], 2);
    expect(records.single.personalData['location_id'],
        'collectarr-inspector-reference-location');
    expect(records.single.personalData['media'], hasLength(1));
    expect(await ItemImageRepository(database).listForLibraryEntryRef(ref),
        hasLength(2));
    final loans = await LoanRepository(database).getLoansForItem(ref);
    expect(loans.where((loan) => loan.isActive), hasLength(1));
    expect(loans.where((loan) => !loan.isActive), hasLength(1));
    final collision = Map<String, dynamic>.from(fixture);
    collision['catalog'] = {
      ...fixture['catalog'] as Map,
      'title': 'Unrelated entry'
    };
    await expectLater(
        seedMusicInspectorReference(database, collision), throwsStateError);
    expect(
        (await LibraryEntryStore(database)
                .find(CatalogMediaKind.music, entry.id.value))!
            .catalogData['title'],
        entry.metadata.title);
  });
}
