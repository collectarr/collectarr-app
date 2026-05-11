import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class SyncQueueRepository {
  SyncQueueRepository(this._db);

  final LocalDatabase _db;
  final Uuid _uuid = const Uuid();

  Future<void> enqueue(SyncChange change) {
    return _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            entityType: change.entityType,
            entityId: Value(change.entityId),
            action: change.action,
            payloadJson: jsonEncode(change.payload),
            clientChangedAt: change.clientChangedAt ?? DateTime.now().toUtc(),
          ),
        );
  }

  Future<List<SyncChange>> pending() async {
    final rows = await _db.select(_db.syncQueue).get();
    return rows
        .map(
          (row) => SyncChange(
            entityType: row.entityType,
            entityId: row.entityId,
            action: row.action,
            payload: jsonDecode(row.payloadJson) as Map<String, dynamic>,
            clientChangedAt: row.clientChangedAt,
          ),
        )
        .toList();
  }

  Future<void> clear() {
    return _db.delete(_db.syncQueue).go();
  }
}

