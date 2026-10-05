import 'dart:convert';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
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
          ..orderBy([
            (row) => OrderingTerm.asc(row.clientChangedAt),
            // SQLite timestamps can have coarser precision than DateTime.
            // Create owners before their activity when timestamps tie.
            (_) => OrderingTerm.asc(const CustomExpression<int>(
                "CASE WHEN entity_type = 'library_entry' AND action = 'upsert' THEN 0 ELSE 1 END")),
          ]))
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
    final eligible = <SyncChange>[];
    for (final change in changes) {
      final payload = _catalogItemPayload(
        change.entityType,
        change.action,
        change.payload,
      );
      if (await _isPrivateLocalCatalogReference(payload['catalog_ref'])) {
        continue;
      }
      eligible.add(
        SyncChange(
          id: change.id,
          entityType: change.entityType,
          entityId: change.entityId,
          action: change.action,
          payload: payload,
          clientChangedAt: change.clientChangedAt,
        ),
      );
    }
    if (eligible.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.syncQueue,
        eligible.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<bool> _isPrivateLocalCatalogReference(Object? rawReference) async {
    if (rawReference is! Map) return false;
    final kind = rawReference['kind'];
    final id = rawReference['id'];
    if (kind is! String || id is! String) return false;
    final row = await (_db.select(_db.catalogItemsCache)
          ..where(
              (item) => item.catalogKind.equals(kind) & item.itemId.equals(id)))
        .getSingleOrNull();
    return row?.origin == 'privateLocal';
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
    _validateCatalogItemReference(
      row.entityType,
      row.action,
      payload,
    );
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
    final payload = _catalogItemPayload(
      change.entityType,
      change.action,
      change.payload,
    );
    return SyncQueueCompanion.insert(
      id: change.id,
      entityType: change.entityType,
      entityId: change.entityId,
      action: change.action,
      payloadJson: jsonEncode(payload),
      clientChangedAt: change.clientChangedAt,
    );
  }

  Map<String, dynamic> _catalogItemPayload(
    String entityType,
    String action,
    Map<String, dynamic> source,
  ) {
    final payload = Map<String, dynamic>.from(source);
    final rawReference = payload['catalog_ref'];
    if (rawReference is Map) {
      final catalogItemRef =
          CatalogItemRef.fromJson(Map<String, Object?>.from(rawReference));
      payload['catalog_ref'] = catalogItemRef.toJson();
    } else if (rawReference != null) {
      throw const FormatException(
        'Sync Catalog Item reference must be a JSON object.',
      );
    }
    if (payload.containsKey('target_ref')) {
      throw FormatException(
        'Sync $entityType payload cannot contain target_ref.',
      );
    }
    _validateCatalogItemReference(entityType, action, payload);
    return payload;
  }

  void _validateCatalogItemReference(
    String entityType,
    String action,
    Map<String, dynamic> payload,
  ) {
    if (payload.containsKey('target_ref')) {
      throw FormatException(
        'Sync $entityType payload cannot contain target_ref.',
      );
    }
    if (entityType == 'library_entry') {
      LibraryEntryRecord.fromJson(payload);
      return;
    }
    if (action == 'delete' && entityType != 'music_listen_event') return;
    if (entityType == 'music_listen_event') {
      final rawEntryRef = payload['library_entry_ref'];
      if (rawEntryRef is! Map) {
        throw const FormatException(
          'Music listen event requires its local library_entry_ref.',
        );
      }
      final libraryEntryRef = LibraryEntryRef.fromJson(
        Map<String, Object?>.from(rawEntryRef),
      );
      if (libraryEntryRef.kind != CatalogMediaKind.music) {
        throw const FormatException(
          'Music listen event library_entry_ref must be Music.',
        );
      }
      if (payload.containsKey('catalog_ref')) {
        throw const FormatException(
          'Music listen event cannot duplicate its local identity as catalog_ref.',
        );
      }
      return;
    }
    if (entityType == 'tracking_entry' ||
        entityType == 'tracking_unit' ||
        entityType == 'watch_session' ||
        entityType == 'metadata_override' ||
        entityType == 'custom_episode') {
      final rawEntryRef = payload['library_entry_ref'];
      if (rawEntryRef is! Map) {
        throw FormatException(
          'Sync $entityType requires its local library_entry_ref.',
        );
      }
      LibraryEntryRef.fromJson(Map<String, Object?>.from(rawEntryRef));
      if (payload.containsKey('catalog_ref')) {
        throw FormatException(
          'Sync $entityType cannot duplicate its local identity as catalog_ref.',
        );
      }
      return;
    }
    final required = switch (entityType) {
      'library_entry' ||
      'wishlist_item' ||
      'tracking_entry' ||
      'tracking_unit' ||
      'watch_session' ||
      'music_listen_event' ||
      'custom_episode' =>
        true,
      _ => false,
    };
    final rawReference = payload['catalog_ref'];
    if (!required && rawReference == null) return;
    if (rawReference is! Map) {
      throw FormatException(
        'Sync $entityType payload is missing its Catalog Item reference.',
      );
    }
    CatalogItemRef.fromJson(Map<String, Object?>.from(rawReference));
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
