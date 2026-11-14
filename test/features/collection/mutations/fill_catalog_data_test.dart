import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/library_entry_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/entries/repository.dart';
import 'package:collectarr_app/features/library/entries/store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a catalog pre-fill fills only the values an entry lacks', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = jsonDecode(
        File('tool/fixtures/music_inspector_reference.json')
            .readAsStringSync()) as Map<String, dynamic>;
    final entry = await seedMusicInspectorReference(db, fixture);
    final ref = LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id);
    final bus = CollectionEventBus();
    addTearDown(bus.dispose);
    final mutations = LibraryEntryMutations(
        libraryEntries: LibraryEntriesRepository(db),
        wishlist: WishlistItemsCacheRepository(db),
        catalogSummaries: CatalogDisplaySummaryRepository(db),
        syncQueue: SyncQueueRepository(db),
        mutationRunner: CollectionMutationRunner(database: db, events: bus));
    final before = (await LibraryEntryStore(db).find(ref.kind, ref.id.value))!;
    final title = before.catalogData['title'];
    expect(title, isNotNull);

    await mutations.fillCatalogData(ref, {
      'title': 'Pre-filled title',
      'prefill_series_probe': 'Pre-filled series',
    });

    final after = (await LibraryEntryStore(db).find(ref.kind, ref.id.value))!;
    expect(after.catalogData['title'], title);
    expect(after.catalogData['prefill_series_probe'], 'Pre-filled series');
  });
}
