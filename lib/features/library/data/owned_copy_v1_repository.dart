import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_copy_ref.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:drift/drift.dart';

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
    final existing = await _storedRow(copy.ref);
    await _database.into(_database.ownedCopiesV1Cache).insertOnConflictUpdate(
          _companion(copy, deletedAt: existing?.deletedAt),
        );
  }

  Future<void> upsertAll(Iterable<OwnedCopyV1> copies) async {
    final values = copies.toList(growable: false);
    if (values.isEmpty) return;
    await _database.transaction(() async {
      for (final copy in values) {
        final existing = await _storedRow(copy.ref);
        await _database
            .into(_database.ownedCopiesV1Cache)
            .insertOnConflictUpdate(
              _companion(copy, deletedAt: existing?.deletedAt),
            );
      }
    });
  }

  Future<void> markDeleted(OwnedCopyRef ref, DateTime deletedAt) async {
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
  }

  Future<void> restore(OwnedCopyRef ref) async {
    final changed = await (_database.update(_database.ownedCopiesV1Cache)
          ..where((row) => _matchesRef(row, ref)))
        .write(
      const OwnedCopiesV1CacheCompanion(deletedAt: Value(null)),
    );
    if (changed == 0) {
      throw StateError('Owned Copy $ref does not exist.');
    }
  }

  Future<OwnedCopiesV1CacheData?> _storedRow(OwnedCopyRef ref) {
    final query = _database.select(_database.ownedCopiesV1Cache)
      ..where((row) => _matchesRef(row, ref));
    return query.getSingleOrNull();
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

  Expression<bool> _matchesRef(
    $OwnedCopiesV1CacheTable row,
    OwnedCopyRef ref,
  ) =>
      row.kind.equals(ref.kind.apiValue) &
      row.catalogItemId.equals(ref.itemId) &
      row.id.equals(ref.copyId);
}
