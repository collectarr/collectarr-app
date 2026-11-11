import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/tracking/registry.dart';
import 'package:collectarr_app/features/library/tracking/storage_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final kind in [
    CatalogMediaKind.book,
    CatalogMediaKind.comic,
    CatalogMediaKind.game,
  ]) {
    test('application registry persists ${kind.apiValue} reading/play state',
        () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository =
          TrackingStorageRepository(db, codecs: libraryTrackingStorageCodecs);
      final entry =
          LibraryEntryRef(kind: kind, id: const LibraryEntryId('reference'));
      final state = repository.create(
        id: 'tracking-reference',
        libraryEntryRef: entry,
        status: MediaTrackingStatus.completed,
        rating: 8,
        startedAt: DateTime.utc(2024, 10, 1),
        finishedAt: DateTime.utc(2024, 10, 9),
        updatedAt: DateTime.utc(2026),
      );
      await repository.upsertStorageRecord(state);
      final saved = (await repository.listActiveSummaries()).single;
      expect(saved.libraryEntryRef, entry);
      expect(saved.status, MediaTrackingStatus.completed);
      expect(saved.rating, 8);
      expect(saved.startedAt?.toUtc(), DateTime.utc(2024, 10, 1));
      expect(saved.completedAt?.toUtc(), DateTime.utc(2024, 10, 9));
    });
  }
}
