import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class ReadingQueueRepository {
  ReadingQueueRepository(this._db);

  final LocalDatabase _db;

  /// Get all queued entry-item references in order.
  Future<List<LibraryEntryRef>> getQueue() async {
    final rows = await (_db.select(_db.readingQueueCache)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows
        .map((r) => LibraryEntryRef.fromKey(r.libraryEntryRefKey))
        .toList();
  }

  /// Check if an item is in the queue.
  Future<bool> isInQueue(LibraryEntryRef ref) async {
    requireKnownLibraryEntryRef(ref);
    final row = await (_db.select(_db.readingQueueCache)
          ..where((t) => t.libraryEntryRefKey.equals(ref.key)))
        .getSingleOrNull();
    return row != null;
  }

  Future<int?> positionFor(LibraryEntryRef ref) async {
    requireKnownLibraryEntryRef(ref);
    final row = await (_db.select(_db.readingQueueCache)
          ..where((t) => t.libraryEntryRefKey.equals(ref.key)))
        .getSingleOrNull();
    return row?.position;
  }

  Future<void> applySyncedPosition(
    LibraryEntryRef ref,
    int? position,
  ) async {
    requireKnownLibraryEntryRef(ref);
    if (position == null) {
      await removeFromQueue(ref);
      return;
    }
    await _db.into(_db.readingQueueCache).insertOnConflictUpdate(
          ReadingQueueCacheCompanion.insert(
            libraryEntryRefKey: ref.key,
            position: position,
            addedAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Add item to end of queue.
  Future<void> addToQueue(LibraryEntryRef ref) async {
    requireKnownLibraryEntryRef(ref);
    final maxPos = await _db
        .customSelect(
          'SELECT COALESCE(MAX(position), 0) AS m FROM reading_queue_cache',
        )
        .getSingle();
    final pos = (maxPos.data['m'] as int) + 1;
    await _db.into(_db.readingQueueCache).insertOnConflictUpdate(
          ReadingQueueCacheCompanion.insert(
            libraryEntryRefKey: ref.key,
            position: pos,
            addedAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Remove item from queue.
  Future<void> removeFromQueue(LibraryEntryRef ref) async {
    requireKnownLibraryEntryRef(ref);
    await (_db.delete(_db.readingQueueCache)
          ..where((t) => t.libraryEntryRefKey.equals(ref.key)))
        .go();
  }

  /// Move item to a new position (reorder).
  Future<void> moveToPosition(LibraryEntryRef ref, int newPosition) async {
    requireKnownLibraryEntryRef(ref);
    final queue = await getQueue();
    queue.remove(ref);
    final insertIdx = newPosition.clamp(0, queue.length);
    queue.insert(insertIdx, ref);
    // Rewrite all positions
    await _db.batch((batch) {
      for (var i = 0; i < queue.length; i++) {
        batch.update(
          _db.readingQueueCache,
          ReadingQueueCacheCompanion(position: Value(i)),
          where: (t) => t.libraryEntryRefKey.equals(queue[i].key),
        );
      }
    });
  }

  /// Move item to top (next to read).
  Future<void> moveToTop(LibraryEntryRef ref) async {
    await moveToPosition(ref, 0);
  }
}
