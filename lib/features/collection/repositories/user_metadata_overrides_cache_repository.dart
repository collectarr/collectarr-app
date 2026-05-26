import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:drift/drift.dart';

class UserMetadataOverridesCacheRepository {
  UserMetadataOverridesCacheRepository(this._db);

  final LocalDatabase _db;

  /// All active (non-deleted) overrides for a single item, ordered by field.
  Future<List<UserMetadataOverride>> listActiveByItemId(String itemId) async {
    final rows = await (_db.select(_db.userMetadataOverridesCache)
          ..where(
            (tbl) => tbl.deletedAt.isNull() & tbl.itemId.equals(itemId),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fieldPath)]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  /// Active overrides for multiple items (batch).
  Future<List<UserMetadataOverride>> listActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids =
        itemIds.where((v) => v.isNotEmpty).toSet().toList(growable: false);
    if (ids.isEmpty) return const <UserMetadataOverride>[];
    final rows = await (_db.select(_db.userMetadataOverridesCache)
          ..where((tbl) => tbl.deletedAt.isNull() & tbl.itemId.isIn(ids))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fieldPath)]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  /// All active overrides across the entire library.
  Future<List<UserMetadataOverride>> listActive() async {
    final rows = await (_db.select(_db.userMetadataOverridesCache)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.itemId),
            (tbl) => OrderingTerm.asc(tbl.fieldPath),
          ]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<UserMetadataOverride?> findById(String id) async {
    final row = await (_db.select(_db.userMetadataOverridesCache)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Find the active override for a specific (item, field, edition?, variant?)
  /// combination.
  Future<UserMetadataOverride?> findByField(
    String itemId,
    String fieldPath, {
    String? editionId,
    String? variantId,
  }) async {
    final query = _db.select(_db.userMetadataOverridesCache)
      ..where(
        (tbl) =>
            tbl.deletedAt.isNull() &
            tbl.itemId.equals(itemId) &
            tbl.fieldPath.equals(fieldPath),
      );
    if (editionId != null) {
      query.where((tbl) => tbl.editionId.equals(editionId));
    } else {
      query.where((tbl) => tbl.editionId.isNull());
    }
    if (variantId != null) {
      query.where((tbl) => tbl.variantId.equals(variantId));
    } else {
      query.where((tbl) => tbl.variantId.isNull());
    }
    final row = await query.getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<void> upsert(UserMetadataOverride override) async {
    await _db
        .into(_db.userMetadataOverridesCache)
        .insertOnConflictUpdate(_toCompanion(override));
  }

  Future<void> upsertAll(List<UserMetadataOverride> overrides) async {
    if (overrides.isEmpty) return;
    final companions = overrides.map(_toCompanion).toList(growable: false);
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.userMetadataOverridesCache,
        companions,
      );
    });
  }

  Future<void> markDeleted(
    UserMetadataOverride override,
    DateTime deletedAt,
  ) async {
    await (_db.update(_db.userMetadataOverridesCache)
          ..where((tbl) => tbl.id.equals(override.id)))
        .write(
      UserMetadataOverridesCacheCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  // ── Mapping ──────────────────────────────────────────────────────────

  UserMetadataOverridesCacheCompanion _toCompanion(
    UserMetadataOverride o,
  ) {
    return UserMetadataOverridesCacheCompanion(
      id: Value(o.id),
      itemId: Value(o.itemId),
      editionId: Value(o.editionId),
      variantId: Value(o.variantId),
      fieldPath: Value(o.fieldPath),
      originalValue: Value(o.originalValue),
      overrideValue: Value(o.overrideValue),
      updatedAt: Value(o.updatedAt),
      deletedAt: Value(o.deletedAt),
    );
  }

  UserMetadataOverride _toModel(UserMetadataOverridesCacheData row) {
    return UserMetadataOverride(
      id: row.id,
      itemId: row.itemId,
      editionId: row.editionId,
      variantId: row.variantId,
      fieldPath: row.fieldPath,
      originalValue: row.originalValue,
      overrideValue: row.overrideValue,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
