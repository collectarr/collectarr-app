import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:drift/drift.dart';

class SyncQueueRepository {
  const SyncQueueRepository(this._db);

  static const _deleteBatchSize = 500;

  final LocalDatabase _db;

  Future<int> pendingCount() async {
    final result = await readPending();
    return result.changes.length;
  }

  Future<List<SyncChange>> listPending() async {
    final result = await readPending();
    return result.changes;
  }

  /// Reads runnable changes and preserves identifying details for invalid rows.
  ///
  /// Invalid rows remain in Drift and can be inspected or repaired using their
  /// ID and original stored values.
  Future<SyncQueueReadResult> readPending() async {
    final rows = await (_db.select(_db.syncQueue)
          ..orderBy([(row) => OrderingTerm.asc(row.clientChangedAt)]))
        .get();
    final changes = <SyncChange>[];
    final invalidRows = <InvalidSyncQueueRow>[];
    for (final row in rows) {
      try {
        changes.add(_fromRow(row));
      } catch (error, stackTrace) {
        invalidRows.add(
          InvalidSyncQueueRow(
            id: row.id,
            entityType: row.entityType,
            entityId: row.entityId,
            action: row.action,
            payloadJson: row.payloadJson,
            clientChangedAt: row.clientChangedAt,
            error: error.toString(),
          ),
        );
        logRecoverableError(
          source: 'sync_queue',
          message:
              'Skipping invalid sync queue row id="${row.id}"; the stored row was preserved.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return SyncQueueReadResult(
      changes: changes,
      invalidRows: invalidRows,
    );
  }

  Future<void> enqueue(SyncChange change) {
    return enqueueAll([change]);
  }

  Future<void> enqueueAll(List<SyncChange> changes) async {
    if (changes.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.syncQueue,
        changes.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final values = ids.toList(growable: false);
    if (values.isEmpty) {
      return;
    }
    for (var index = 0; index < values.length; index += _deleteBatchSize) {
      final end = (index + _deleteBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      await (_db.delete(_db.syncQueue)..where((row) => row.id.isIn(batch)))
          .go();
    }
  }

  SyncChange _fromRow(SyncQueueData row) {
    final decodedPayload = jsonDecode(row.payloadJson);
    if (decodedPayload is! Map) {
      throw const FormatException('Sync queue payload must be a JSON object.');
    }
    final payload = <String, dynamic>{};
    for (final entry in decodedPayload.entries) {
      if (entry.key is! String) {
        throw const FormatException('Sync queue payload keys must be strings.');
      }
      payload[entry.key as String] = entry.value;
    }
    if (row.entityType.trim().isEmpty ||
        row.entityId.trim().isEmpty ||
        row.action.trim().isEmpty) {
      throw const FormatException(
        'Sync queue entity type, entity id and action must be non-empty.',
      );
    }
    return SyncChange(
      id: row.id,
      entityType: row.entityType,
      entityId: row.entityId,
      action: row.action,
      payload: Map.unmodifiable(payload),
      clientChangedAt: row.clientChangedAt,
    );
  }

  SyncQueueCompanion _toCompanion(SyncChange change) {
    return SyncQueueCompanion.insert(
      id: change.id,
      entityType: change.entityType,
      entityId: change.entityId,
      action: change.action,
      payloadJson: change.payloadJson,
      clientChangedAt: change.clientChangedAt,
    );
  }
}

final class SyncQueueReadResult {
  SyncQueueReadResult({
    required List<SyncChange> changes,
    required List<InvalidSyncQueueRow> invalidRows,
  })  : changes = List.unmodifiable(changes),
        invalidRows = List.unmodifiable(invalidRows);

  /// Operations that can be submitted to sync.
  final List<SyncChange> changes;

  /// Stored rows that could not be decoded. They remain untouched in Drift.
  final List<InvalidSyncQueueRow> invalidRows;
}

final class InvalidSyncQueueRow {
  const InvalidSyncQueueRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payloadJson,
    required this.clientChangedAt,
    required this.error,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String payloadJson;
  final DateTime clientChangedAt;
  final String error;
}
