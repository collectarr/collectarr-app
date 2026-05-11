import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:drift/drift.dart';

class SyncQueueRepository {
  const SyncQueueRepository(this._db);

  final LocalDatabase _db;

  Future<int> pendingCount() async {
    final count = _db.syncQueue.id.count();
    final query = _db.selectOnly(_db.syncQueue)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<SyncChange>> listPending() async {
    final rows = await (_db.select(_db.syncQueue)
          ..orderBy([(row) => OrderingTerm.asc(row.clientChangedAt)]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> enqueue(SyncChange change) {
    return _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            id: change.id,
            entityType: change.entityType,
            entityId: change.entityId,
            action: change.action,
            payloadJson: change.payloadJson,
            clientChangedAt: change.clientChangedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final values = ids.toList(growable: false);
    if (values.isEmpty) {
      return;
    }
    await (_db.delete(_db.syncQueue)..where((row) => row.id.isIn(values))).go();
  }

  SyncChange _fromRow(SyncQueueData row) {
    return SyncChange(
      id: row.id,
      entityType: row.entityType,
      entityId: row.entityId,
      action: row.action,
      payload: (jsonDecode(row.payloadJson) as Map).cast<String, dynamic>(),
      clientChangedAt: row.clientChangedAt,
    );
  }
}
