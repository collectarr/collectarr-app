import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:drift/drift.dart';

class CustomFieldRepository {
  const CustomFieldRepository(this._db);

  final LocalDatabase _db;

  // --- Definitions ---

  Future<List<CustomFieldDefinition>> listDefinitions({
    String? mediaKind,
    String? editScope,
    CustomFieldTargetScope? targetScope,
  }) async {
    final query = _db.select(_db.customFieldDefinitionsCache)
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    if (mediaKind != null) {
      query.where(
        (row) => row.mediaKind.isNull() | row.mediaKind.equals(mediaKind),
      );
    }
    if (editScope != null) {
      query.where(
        (row) => row.editScope.isNull() | row.editScope.equals(editScope),
      );
    }
    if (targetScope != null && targetScope != CustomFieldTargetScope.all) {
      query.where(
        (row) =>
            row.editScope.isNull() | row.editScope.equals(targetScope.apiValue),
      );
    }
    final rows = await query.get();
    return rows.map(_definitionFromRow).toList(growable: false);
  }

  Future<void> upsertDefinition(CustomFieldDefinition def) {
    return _db.into(_db.customFieldDefinitionsCache).insert(
          CustomFieldDefinitionsCacheCompanion.insert(
            id: def.id,
            name: def.name,
            fieldType: def.valueType.apiValue,
            mediaKind: Value(def.mediaKind),
            editScope: Value(def.editScope),
            sortOrder: Value(def.sortOrder),
            options: Value(def.options),
            createdAt: def.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> deleteDefinition(String id) async {
    await (_db.delete(_db.customFieldValuesCache)
          ..where((row) => row.fieldDefinitionId.equals(id)))
        .go();
    await (_db.delete(_db.customFieldDefinitionsCache)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  // --- Values ---

  Future<List<CustomFieldValue>> listValuesForTarget({
    CatalogEntityRef? catalogRef,
    String? targetId,
    CustomFieldTargetScope? targetScope,
  }) async {
    final resolvedTargetId = targetId ?? catalogRef?.id;
    final resolvedTargetScope =
        targetScope ?? _targetScopeForCatalogRef(catalogRef);
    if (resolvedTargetId == null || resolvedTargetScope == null) {
      throw ArgumentError(
        'listValuesForTarget requires either catalogRef or targetId + targetScope',
      );
    }
    final rows = await (_db.select(_db.customFieldValuesCache)
          ..where((row) =>
              row.targetId.equals(resolvedTargetId) &
              row.targetScope.equals(resolvedTargetScope.apiValue)))
        .get();
    return rows.map(_valueFromRow).toList(growable: false);
  }

  /// Returns all custom field values grouped by target id.
  Future<Map<String, List<CustomFieldValue>>> listAllValues() async {
    final rows = await _db.select(_db.customFieldValuesCache).get();
    final map = <String, List<CustomFieldValue>>{};
    for (final row in rows) {
      final value = _valueFromRow(row);
      (map[value.targetId] ??= []).add(value);
    }
    return map;
  }

  Future<void> upsertValue(CustomFieldValue fieldValue) {
    return upsertValueForTarget(fieldValue);
  }

  Future<void> upsertValueForTarget(CustomFieldValue fieldValue) {
    return _db.into(_db.customFieldValuesCache).insert(
          CustomFieldValuesCacheCompanion.insert(
            id: fieldValue.id,
            targetId: fieldValue.targetId,
            targetScope: fieldValue.targetScope.apiValue,
            catalogRefJson: Value(fieldValue.catalogRef == null
                ? null
                : jsonEncode(fieldValue.catalogRef!.toJson())),
            fieldDefinitionId: fieldValue.fieldDefinitionId,
            value: Value(fieldValue.value),
            updatedAt: fieldValue.updatedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> upsertValues(List<CustomFieldValue> values) async {
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.customFieldValuesCache,
        values.map(
          (v) => CustomFieldValuesCacheCompanion.insert(
            id: v.id,
            targetId: v.targetId,
            targetScope: v.targetScope.apiValue,
            catalogRefJson: Value(v.catalogRef == null
                ? null
                : jsonEncode(v.catalogRef!.toJson())),
            fieldDefinitionId: v.fieldDefinitionId,
            value: Value(v.value),
            updatedAt: v.updatedAt,
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> deleteValuesForTarget({
    CatalogEntityRef? catalogRef,
    String? targetId,
    CustomFieldTargetScope? targetScope,
  }) async {
    final resolvedTargetId = targetId ?? catalogRef?.id;
    final resolvedTargetScope =
        targetScope ?? _targetScopeForCatalogRef(catalogRef);
    if (resolvedTargetId == null || resolvedTargetScope == null) {
      throw ArgumentError(
        'deleteValuesForTarget requires either catalogRef or targetId + targetScope',
      );
    }
    await (_db.delete(_db.customFieldValuesCache)
          ..where((row) =>
              row.targetId.equals(resolvedTargetId) &
              row.targetScope.equals(resolvedTargetScope.apiValue)))
        .go();
  }

  CustomFieldDefinition _definitionFromRow(
      CustomFieldDefinitionsCacheData row) {
    return CustomFieldDefinition(
      id: row.id,
      name: row.name,
      fieldType: CustomFieldValueType.fromApiValue(row.fieldType).apiValue,
      mediaKind: row.mediaKind,
      editScope: row.editScope,
      sortOrder: row.sortOrder,
      options: row.options,
      createdAt: row.createdAt,
    );
  }

  CustomFieldValue _valueFromRow(CustomFieldValuesCacheData row) {
    return CustomFieldValue(
      id: row.id,
      targetId: row.targetId,
      targetScope: CustomFieldTargetScope.fromApiValue(row.targetScope),
      catalogRef: row.catalogRefJson == null
          ? null
          : CatalogEntityRef.fromJson(
              jsonDecode(row.catalogRefJson!) as Map<String, dynamic>,
            ),
      fieldDefinitionId: row.fieldDefinitionId,
      value: row.value,
      updatedAt: row.updatedAt,
    );
  }

  CustomFieldTargetScope? _targetScopeForCatalogRef(CatalogEntityRef? ref) {
    if (ref == null) {
      return null;
    }
    return switch (ref.entityType) {
      CatalogEntityType.work => CustomFieldTargetScope.work,
      CatalogEntityType.season => CustomFieldTargetScope.work,
      CatalogEntityType.edition => CustomFieldTargetScope.edition,
      CatalogEntityType.release => CustomFieldTargetScope.release,
      CatalogEntityType.issue => CustomFieldTargetScope.issue,
      CatalogEntityType.episode => CustomFieldTargetScope.episode,
      CatalogEntityType.track => CustomFieldTargetScope.track,
      CatalogEntityType.ownedCopy ||
      CatalogEntityType.copy =>
        CustomFieldTargetScope.ownedCopy,
      CatalogEntityType.trackingEntry => CustomFieldTargetScope.trackingEntry,
      CatalogEntityType.bundleRelease || CatalogEntityType.unknown => null,
    };
  }
}
