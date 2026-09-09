import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:drift/drift.dart';

/// Persistence mechanics for opaque, kind-owned metadata corrections.
class UserMetadataOverridesCacheRepository {
  UserMetadataOverridesCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<UserMetadataOverride>> listActiveByTarget(
    CatalogEntityRef target,
  ) async {
    final overrides = await listActive();
    return overrides
        .where((override) => _sameTarget(override.targetRef, target))
        .toList(growable: false);
  }

  Future<List<UserMetadataOverride>> listActiveByTargets(
    Iterable<CatalogEntityRef> targets,
  ) async {
    final targetSet = targets.toSet();
    if (targetSet.isEmpty) return const <UserMetadataOverride>[];
    final overrides = await listActive();
    return overrides
        .where((override) => targetSet.contains(override.targetRef))
        .toList(growable: false);
  }

  Future<List<UserMetadataOverride>> listActive() async {
    final rows = await (_db.select(_db.userMetadataOverridesCache)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.targetRefJson),
            (tbl) => OrderingTerm.asc(tbl.fieldKey),
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

  Future<UserMetadataOverride?> findByField(
    CatalogEntityRef target,
    MetadataFieldId fieldId,
  ) async {
    final overrides = await listActiveByTarget(target);
    for (final override in overrides) {
      if (override.fieldId == fieldId) return override;
    }
    return null;
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

  UserMetadataOverridesCacheCompanion _toCompanion(
    UserMetadataOverride override,
  ) {
    return UserMetadataOverridesCacheCompanion(
      id: Value(override.id),
      targetRefJson: Value(jsonEncode(override.targetRef.toJson())),
      fieldKey: Value(override.fieldId.serializedValue),
      originalValue: Value(override.originalValue),
      overrideValue: Value(override.overrideValue),
      updatedAt: Value(override.updatedAt),
      deletedAt: Value(override.deletedAt),
    );
  }

  UserMetadataOverride _toModel(UserMetadataOverridesCacheData row) {
    final rawTarget = jsonDecode(row.targetRefJson);
    if (rawTarget is! Map) {
      throw const FormatException('Metadata override target_ref is invalid');
    }
    final targetRef = CatalogEntityRef.fromJson(
      Map<String, Object?>.from(rawTarget),
    );
    return UserMetadataOverride(
      id: row.id,
      targetRef: targetRef,
      fieldId: MetadataFieldId(
        kind: targetRef.mediaKind,
        value: row.fieldKey,
      ),
      originalValue: row.originalValue,
      overrideValue: row.overrideValue,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  bool _sameTarget(CatalogEntityRef left, CatalogEntityRef right) =>
      left == right;
}
