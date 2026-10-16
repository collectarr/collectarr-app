import 'dart:convert';
import 'dart:io';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_import_sources.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest =
      jsonDecode(File('test/fixtures/imports/manifest.json').readAsStringSync())
          as Map<String, dynamic>;
  for (final source in musicImportSources.where((s) => s.importer != null)) {
    test(
        '${source.id} fixture imports complete albums and sync data into isolated storage',
        () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final events = CollectionEventBus();
      addTearDown(events.dispose);
      final container = ProviderContainer(overrides: [
        localDatabaseProvider.overrideWithValue(db),
        collectionMutationRunnerProvider.overrideWithValue(
            CollectionMutationRunner(database: db, events: events)),
      ]);
      addTearDown(container.dispose);
      final rows = source.importer!.parse(File(
              'test/fixtures/imports/${(manifest['music.${source.id}'] as Map<String, dynamic>)['minimal']}')
          .readAsStringSync());
      final importer = container.read(collectionImportOrchestratorProvider);
      expect(await importer.importRows(rows), 2);
      final saved = await MusicEntryRepository(db)
          .findById(LibraryEntryId(rows.first.itemId));
      expect(saved!.metadata.title, 'After & Before');
      expect(saved.metadata.artist, 'Mira "Echo" Ionescu');
      expect(saved.metadata.discs, hasLength(2));
      expect(saved.sourceCatalogRef, isNull);
      final pending = (await SyncQueueRepository(db).readPending()).changes;
      expect(
          pending.where((c) => c.entityType == 'library_entry'), hasLength(2));
      // A repeated import updates the same local identities instead of creating copies.
      expect(await importer.importRows(rows), 2);
      expect(await MusicEntryRepository(db).listActive(), hasLength(2));
    });
  }
}
