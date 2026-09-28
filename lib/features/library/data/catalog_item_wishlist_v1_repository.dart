import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/library/domain/catalog_item_wishlist_v1.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Persists a wishlist independently from Owned Copies and Core catalog data.
final class CatalogItemWishlistV1Repository {
  const CatalogItemWishlistV1Repository(this._database);

  static const _entityType = 'catalog_item_wishlist_v1';
  static const _uuid = Uuid();

  final LocalDatabase _database;

  Future<List<CatalogItemWishlistV1>> listForKind(
    CatalogMediaKind kind, {
    bool includeDeleted = false,
  }) async {
    final rows = await (_database.select(_database.wishlistItemsCache)
          ..where((row) =>
              includeDeleted ? const Constant(true) : row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return _visibleRows(rows, kind, includeDeleted: includeDeleted);
  }

  Stream<List<CatalogItemWishlistV1>> watchForKind(CatalogMediaKind kind) =>
      _database
          .select(_database.wishlistItemsCache)
          .watch()
          .map((rows) => _visibleRows(rows, kind));

  Future<CatalogItemWishlistV1?> findByCatalogItem(
    CatalogItemRef reference, {
    bool includeDeleted = false,
  }) async {
    for (final entry in await listForKind(
      reference.kind,
      includeDeleted: includeDeleted,
    )) {
      if (entry.catalogItem == reference) return entry;
    }
    return null;
  }

  Future<SyncChange?> currentSyncChange(
    String id, {
    required String changeId,
    required DateTime changedAt,
  }) async {
    final row = await (_database.select(_database.wishlistItemsCache)
          ..where((entry) => entry.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final entry = _decode(row);
    return SyncChange(
      id: changeId,
      entityType: _entityType,
      entityId: entry.id,
      action: row.deletedAt == null ? 'upsert' : 'delete',
      payload: Map<String, dynamic>.from(entry.toJson()),
      clientChangedAt: changedAt.toUtc(),
    );
  }

  Future<CatalogItemWishlistV1> add(
    CatalogItemRef reference, {
    int? targetPriceCents,
    String? currency,
    String? notes,
  }) async {
    final existing = await findByCatalogItem(reference, includeDeleted: true);
    final now = DateTime.now().toUtc();
    final entry = CatalogItemWishlistV1(
      id: existing?.id ??
          _uuid.v5(
            Namespace.url.value,
            'collectarr:wishlist:${reference.kind.apiValue}:${reference.id}',
          ),
      catalogItem: reference,
      targetPriceCents: targetPriceCents ?? existing?.targetPriceCents,
      currency: currency ?? existing?.currency,
      notes: notes ?? existing?.notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _database.transaction(() async {
      await _write(entry, deletedAt: null);
      await _enqueue(entry, action: 'upsert', changedAt: now);
    });
    return entry;
  }

  Future<void> markDeleted(
    CatalogItemWishlistV1 entry,
    DateTime deletedAt,
  ) async {
    final changedAt = deletedAt.toUtc();
    await _database.transaction(() async {
      await _write(entry, deletedAt: changedAt, updatedAt: changedAt);
      await _enqueue(entry, action: 'delete', changedAt: changedAt);
    });
  }

  /// Applies a remote change without echoing it into the outgoing queue.
  Future<void> applySyncedChange({
    required CatalogItemWishlistV1 entry,
    required String action,
    required DateTime changedAt,
  }) async {
    if (action != 'upsert' && action != 'delete') {
      throw FormatException('Unsupported Wishlist v1 action: $action');
    }
    await _write(
      entry,
      deletedAt: action == 'delete' ? changedAt.toUtc() : null,
      updatedAt: changedAt.toUtc(),
    );
  }

  Future<void> _write(
    CatalogItemWishlistV1 entry, {
    required DateTime? deletedAt,
    DateTime? updatedAt,
  }) async {
    await _database.into(_database.wishlistItemsCache).insertOnConflictUpdate(
          WishlistItemsCacheCompanion.insert(
            id: entry.id,
            catalogRefJson: jsonEncode(entry.catalogItem.toJson()),
            targetPriceCents: Value(entry.targetPriceCents),
            currency: Value(entry.currency),
            notes: Value(entry.notes),
            createdAt: entry.createdAt,
            updatedAt: updatedAt ?? entry.updatedAt,
            deletedAt: Value(deletedAt),
          ),
        );
  }

  CatalogItemWishlistV1 _decode(WishlistItemsCacheData row) {
    final raw = jsonDecode(row.catalogRefJson);
    if (raw is! Map) {
      throw FormatException('Wishlist v1 row ${row.id} has an invalid ref.');
    }
    return CatalogItemWishlistV1(
      id: row.id,
      catalogItem: CatalogItemRef.fromJson(Map<String, Object?>.from(raw)),
      targetPriceCents: row.targetPriceCents,
      currency: row.currency,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CatalogItemWishlistV1? _tryDecode(WishlistItemsCacheData row) {
    final raw = jsonDecode(row.catalogRefJson);
    if (raw is! Map || raw.containsKey('entity_type')) return null;
    return _decode(row);
  }

  List<CatalogItemWishlistV1> _visibleRows(
    Iterable<WishlistItemsCacheData> rows,
    CatalogMediaKind kind, {
    bool includeDeleted = false,
  }) {
    final result = <CatalogItemWishlistV1>[];
    for (final row in rows) {
      if (!includeDeleted && row.deletedAt != null) continue;
      final entry = _tryDecode(row);
      if (entry != null && entry.catalogItem.kind == kind) result.add(entry);
    }
    return List.unmodifiable(result);
  }

  Future<void> _enqueue(
    CatalogItemWishlistV1 entry, {
    required String action,
    required DateTime changedAt,
  }) async {
    final change = SyncChange(
      id: _uuid.v4(),
      entityType: _entityType,
      entityId: entry.id,
      action: action,
      payload: Map<String, dynamic>.from(entry.toJson()),
      clientChangedAt: changedAt.toUtc(),
    );
    await _database.into(_database.syncQueue).insertOnConflictUpdate(
          SyncQueueCompanion.insert(
            id: change.id,
            entityType: change.entityType,
            entityId: change.entityId,
            action: change.action,
            payloadJson: change.payloadJson,
            clientChangedAt: change.clientChangedAt,
          ),
        );
  }
}
