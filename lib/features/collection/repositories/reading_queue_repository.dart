import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/drift.dart';

class ReadingQueueRepository {
  ReadingQueueRepository(this._db);

  final LocalDatabase _db;

  /// Get all queued item IDs in order.
  Future<List<String>> getQueue() async {
    final rows = await (_db.select(_db.readingQueueCache)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => r.ownedItemId).toList();
  }

  /// Check if an item is in the queue.
  Future<bool> isInQueue(String ownedItemId) async {
    final row = await (_db.select(_db.readingQueueCache)
          ..where((t) => t.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row != null;
  }

  /// Add item to end of queue.
  Future<void> addToQueue(String ownedItemId) async {
    final maxPos = await _db.customSelect(
      'SELECT COALESCE(MAX(position), 0) AS m FROM reading_queue_cache',
    ).getSingle();
    final pos = (maxPos.data['m'] as int) + 1;
    await _db.into(_db.readingQueueCache).insertOnConflictUpdate(
          ReadingQueueCacheCompanion.insert(
            ownedItemId: ownedItemId,
            position: pos,
            addedAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Remove item from queue.
  Future<void> removeFromQueue(String ownedItemId) async {
    await (_db.delete(_db.readingQueueCache)
          ..where((t) => t.ownedItemId.equals(ownedItemId)))
        .go();
  }

  /// Move item to a new position (reorder).
  Future<void> moveToPosition(String ownedItemId, int newPosition) async {
    final queue = await getQueue();
    queue.remove(ownedItemId);
    final insertIdx = newPosition.clamp(0, queue.length);
    queue.insert(insertIdx, ownedItemId);
    // Rewrite all positions
    await _db.batch((batch) {
      for (var i = 0; i < queue.length; i++) {
        batch.update(
          _db.readingQueueCache,
          ReadingQueueCacheCompanion(position: Value(i)),
          where: (t) => t.ownedItemId.equals(queue[i]),
        );
      }
    });
  }

  /// Move item to top (next to read).
  Future<void> moveToTop(String ownedItemId) async {
    await moveToPosition(ownedItemId, 0);
  }
}
