import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_copy_ref.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Persists App-owned copies independently of the Core catalog.
final class OwnedCopyV1Repository {
  const OwnedCopyV1Repository(this._database);

  final LocalDatabase _database;

  Future<OwnedCopyV1?> get(
    OwnedCopyRef ref, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.ownedCopiesV1Cache)
      ..where((row) =>
          row.kind.equals(ref.kind.apiValue) &
          row.catalogItemId.equals(ref.itemId) &
          row.id.equals(ref.copyId));
    if (!includeDeleted) {
      query.where((row) => row.deletedAt.isNull());
    }
    final row = await query.getSingleOrNull();
    return row == null ? null : _decodeRow(row);
  }

  Future<List<OwnedCopyV1>> listForCatalogItem(
    CatalogItemRef item, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.ownedCopiesV1Cache)
      ..where((row) =>
          row.kind.equals(item.kind.apiValue) &
          row.catalogItemId.equals(item.id));
    if (!includeDeleted) {
      query.where((row) => row.deletedAt.isNull());
    }
    query.orderBy([(row) => OrderingTerm.asc(row.id)]);
    final rows = await query.get();
    return [for (final row in rows) _decodeRow(row)];
  }

  Future<List<OwnedCopyV1>> listForKind(
    CatalogMediaKind kind, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.ownedCopiesV1Cache)
      ..where((row) => row.kind.equals(kind.apiValue));
    if (!includeDeleted) {
      query.where((row) => row.deletedAt.isNull());
    }
    query.orderBy([
      (row) => OrderingTerm.asc(row.catalogItemId),
      (row) => OrderingTerm.asc(row.id),
    ]);
    final rows = await query.get();
    return [for (final row in rows) _decodeRow(row)];
  }

  Stream<List<OwnedCopyV1>> watchForKind(
    CatalogMediaKind kind, {
    bool includeDeleted = false,
  }) {
    final query = _database.select(_database.ownedCopiesV1Cache)
      ..where((row) => row.kind.equals(kind.apiValue));
    if (!includeDeleted) {
      query.where((row) => row.deletedAt.isNull());
    }
    query.orderBy([
      (row) => OrderingTerm.asc(row.catalogItemId),
      (row) => OrderingTerm.asc(row.id),
    ]);
    return query.watch().map(
          (rows) => [for (final row in rows) _decodeRow(row)],
        );
  }

  Future<void> upsert(OwnedCopyV1 copy) async {
    await _database.into(_database.ownedCopiesV1Cache).insertOnConflictUpdate(
          _companion(copy, deletedAt: null),
        );
    await _enqueue(copy, action: 'upsert', changedAt: copy.updatedAt);
  }

  Future<void> upsertAll(Iterable<OwnedCopyV1> copies) async {
    final values = copies.toList(growable: false);
    if (values.isEmpty) return;
    await _database.transaction(() async {
      for (final copy in values) {
        await _database
            .into(_database.ownedCopiesV1Cache)
            .insertOnConflictUpdate(
              _companion(copy, deletedAt: null),
            );
      }
      await _enqueueAll(
        values.map(
          (copy) => SyncChange(
            id: const Uuid().v4(),
            entityType: _syncEntityType,
            entityId: copy.ref.copyId,
            action: 'upsert',
            payload: Map<String, dynamic>.from(copy.toJson()),
            clientChangedAt: copy.updatedAt,
          ),
        ),
      );
    });
  }

  Future<void> markDeleted(OwnedCopyRef ref, DateTime deletedAt) async {
    final copy = await get(ref, includeDeleted: true);
    if (copy == null) {
      throw StateError('Owned Copy $ref does not exist.');
    }
    final changed = await (_database.update(_database.ownedCopiesV1Cache)
          ..where((row) => _matchesRef(row, ref)))
        .write(
      OwnedCopiesV1CacheCompanion(
        deletedAt: Value(deletedAt.toUtc()),
      ),
    );
    if (changed == 0) {
      throw StateError('Owned Copy $ref does not exist.');
    }
    await _enqueue(copy, action: 'delete', changedAt: deletedAt);
  }

  /// Applies a server change without putting it back into the outgoing queue.
  Future<void> applySyncedChange({
    required OwnedCopyV1 copy,
    required String action,
    required DateTime changedAt,
  }) async {
    if (action != 'upsert' && action != 'delete') {
      throw FormatException('Unsupported Owned Copy sync action: $action');
    }
    await _database.transaction(() async {
      await _database.into(_database.ownedCopiesV1Cache).insertOnConflictUpdate(
            _companion(
              copy,
              deletedAt: action == 'delete' ? changedAt.toUtc() : null,
            ),
          );
    });
  }

  Future<void> restore(OwnedCopyRef ref) async {
    final copy = await get(ref, includeDeleted: true);
    if (copy == null) {
      throw StateError('Owned Copy $ref does not exist.');
    }
    final changed = await (_database.update(_database.ownedCopiesV1Cache)
          ..where((row) => _matchesRef(row, ref)))
        .write(
      const OwnedCopiesV1CacheCompanion(deletedAt: Value(null)),
    );
    if (changed == 0) {
      throw StateError('Owned Copy $ref does not exist.');
    }
    await _enqueue(copy, action: 'upsert', changedAt: DateTime.now().toUtc());
  }

  OwnedCopyV1 _decodeRow(OwnedCopiesV1CacheData row) {
    final decoded = jsonDecode(row.payloadJson);
    if (decoded is! Map) {
      throw const FormatException('Owned Copy payload must be a JSON object.');
    }
    final copy = OwnedCopyV1.fromJson(Map<String, Object?>.from(decoded));
    if (row.kind != copy.catalogItem.kind.apiValue ||
        row.catalogItemId != copy.catalogItem.id ||
        row.id != copy.ref.copyId) {
      throw FormatException(
        'Owned Copy cache key does not match payload identity '
        '(${row.kind}/${row.catalogItemId}/${row.id}).',
      );
    }
    return copy;
  }

  OwnedCopiesV1CacheCompanion _companion(
    OwnedCopyV1 copy, {
    required DateTime? deletedAt,
  }) =>
      OwnedCopiesV1CacheCompanion.insert(
        kind: copy.catalogItem.kind.apiValue,
        catalogItemId: copy.catalogItem.id,
        id: copy.ref.copyId,
        payloadJson: jsonEncode(copy.toJson()),
        deletedAt: Value(deletedAt),
      );

  static const _syncEntityType = 'owned_copy_v1';
  static const _uuid = Uuid();

  Future<void> _enqueue(
    OwnedCopyV1 copy, {
    required String action,
    required DateTime changedAt,
  }) async {
    await _enqueueAll([
      SyncChange(
        id: _uuid.v4(),
        entityType: _syncEntityType,
        entityId: copy.ref.copyId,
        action: action,
        payload: Map<String, dynamic>.from(copy.toJson()),
        clientChangedAt: changedAt.toUtc(),
      ),
    ]);
  }

  Future<void> _enqueueAll(Iterable<SyncChange> changes) async {
    final values = changes.toList(growable: false);
    if (values.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAll(
        _database.syncQueue,
        values.map(
          (change) => SyncQueueCompanion.insert(
            id: change.id,
            entityType: change.entityType,
            entityId: change.entityId,
            action: change.action,
            payloadJson: change.payloadJson,
            clientChangedAt: change.clientChangedAt,
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Expression<bool> _matchesRef(
    $OwnedCopiesV1CacheTable row,
    OwnedCopyRef ref,
  ) =>
      row.kind.equals(ref.kind.apiValue) &
      row.catalogItemId.equals(ref.itemId) &
      row.id.equals(ref.copyId);
}
