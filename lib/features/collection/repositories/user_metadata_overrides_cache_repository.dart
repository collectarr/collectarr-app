import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:drift/drift.dart';

/// Persistence mechanics for opaque, kind-entry metadata corrections.
class UserMetadataOverridesCacheRepository {
  UserMetadataOverridesCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<UserMetadataOverride>> listActiveByTarget(
    LibraryEntryRef libraryEntryRef,
  ) async {
    requireKnownLibraryEntryRef(libraryEntryRef, 'metadataOverride.libraryEntryRef');
    final overrides = await listActive();
    return overrides
        .where((override) => override.libraryEntryRef == libraryEntryRef)
        .toList(growable: false);
  }

  Future<List<UserMetadataOverride>> listActiveByTargets(
    Iterable<LibraryEntryRef> libraryEntryRefs,
  ) async {
    final entryRefSet = libraryEntryRefs.toSet();
    if (entryRefSet.isEmpty) return const <UserMetadataOverride>[];
    for (final entryRef in entryRefSet) {
      requireKnownLibraryEntryRef(entryRef, 'metadataOverride.libraryEntryRef');
    }
    final overrides = await listActive();
    return overrides
        .where((override) => entryRefSet.contains(override.libraryEntryRef))
        .toList(growable: false);
  }

  Future<List<UserMetadataOverride>> listActive() async {
    final rows = await (_db.select(_db.userMetadataOverridesCache)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.libraryEntryRefKey),
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
    LibraryEntryRef libraryEntryRef,
    MetadataFieldId fieldId,
  ) async {
    final overrides = await listActiveByTarget(libraryEntryRef);
    for (final override in overrides) {
      if (override.fieldId == fieldId) return override;
    }
    return null;
  }

  Future<void> upsert(UserMetadataOverride override) async {
    _validate(override);
    await _db
        .into(_db.userMetadataOverridesCache)
        .insertOnConflictUpdate(_toCompanion(override));
  }

  Future<void> upsertAll(List<UserMetadataOverride> overrides) async {
    if (overrides.isEmpty) return;
    for (final override in overrides) {
      _validate(override);
    }
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
      libraryEntryRefKey: Value(override.libraryEntryRef.key),
      fieldKey: Value(override.fieldId.serializedValue),
      originalValue: Value(override.originalValue),
      overrideValue: Value(override.overrideValue),
      updatedAt: Value(override.updatedAt),
      deletedAt: Value(override.deletedAt),
    );
  }

  UserMetadataOverride _toModel(UserMetadataOverridesCacheData row) {
    final libraryEntryRef = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
    requireKnownLibraryEntryRef(
      libraryEntryRef,
      'metadataOverride.libraryEntryRef',
    );
    final fieldId = MetadataFieldId(
      kind: libraryEntryRef.kind,
      value: row.fieldKey,
    );
    _validateField(libraryEntryRef.kind, fieldId);
    return UserMetadataOverride(
      id: row.id,
      libraryEntryRef: libraryEntryRef,
      fieldId: fieldId,
      originalValue: row.originalValue,
      overrideValue: row.overrideValue,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  void _validate(UserMetadataOverride override) {
    requireKnownLibraryEntryRef(
      override.libraryEntryRef,
      'metadataOverride.libraryEntryRef',
    );
    _validateField(override.libraryEntryRef.kind, override.fieldId);
    if (override.id.trim().isEmpty) {
      throw ArgumentError.value(
        override.id,
        'metadataOverride.id',
        'Metadata override id must not be empty.',
      );
    }
    if (override.overrideValue.trim().isEmpty) {
      throw ArgumentError.value(
        override.overrideValue,
        'metadataOverride.overrideValue',
        'Metadata override value must not be empty.',
      );
    }
  }

  void _validateField(CatalogMediaKind targetKind, MetadataFieldId fieldId) {
    if (fieldId.kind.isUnknown || fieldId.value.trim().isEmpty) {
      throw ArgumentError.value(
        fieldId,
        'metadataOverride.fieldId',
        'Metadata override field id must have a known kind and non-empty key.',
      );
    }
    if (!fieldId.appliesTo(targetKind)) {
      throw ArgumentError(
        'Metadata override field kind ${fieldId.kind.apiValue} does not '
        'match target kind ${targetKind.apiValue}.',
      );
    }
  }
}
