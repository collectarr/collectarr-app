import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class ReadingQueueRepository {
  ReadingQueueRepository(this._db);

  final LocalDatabase _db;

  /// Get all queued owned-item references in order.
  Future<List<OwnedItemRef>> getQueue() async {
    final rows = await (_db.select(_db.readingQueueCache)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => OwnedItemRef.fromKey(r.ownedRefKey)).toList();
  }

  /// Check if an item is in the queue.
  Future<bool> isInQueue(OwnedItemRef ref) async {
    requireKnownOwnedRef(ref);
    final row = await (_db.select(_db.readingQueueCache)
          ..where((t) => t.ownedRefKey.equals(ref.key)))
        .getSingleOrNull();
    return row != null;
  }

  /// Add item to end of queue.
  Future<void> addToQueue(OwnedItemRef ref) async {
    requireKnownOwnedRef(ref);
    final maxPos = await _db
        .customSelect(
          'SELECT COALESCE(MAX(position), 0) AS m FROM reading_queue_cache',
        )
        .getSingle();
    final pos = (maxPos.data['m'] as int) + 1;
    await _db.into(_db.readingQueueCache).insertOnConflictUpdate(
          ReadingQueueCacheCompanion.insert(
            ownedRefKey: ref.key,
            position: pos,
            addedAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Remove item from queue.
  Future<void> removeFromQueue(OwnedItemRef ref) async {
    requireKnownOwnedRef(ref);
    await (_db.delete(_db.readingQueueCache)
          ..where((t) => t.ownedRefKey.equals(ref.key)))
        .go();
  }

  /// Move item to a new position (reorder).
  Future<void> moveToPosition(OwnedItemRef ref, int newPosition) async {
    requireKnownOwnedRef(ref);
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
          where: (t) => t.ownedRefKey.equals(queue[i].key),
        );
      }
    });
  }

  /// Move item to top (next to read).
  Future<void> moveToTop(OwnedItemRef ref) async {
    await moveToPosition(ref, 0);
  }
}
