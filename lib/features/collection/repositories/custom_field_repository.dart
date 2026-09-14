import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
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
    _validateDefinition(def);
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
    required String targetId,
    required CustomFieldTargetScope targetScope,
  }) async {
    _requireTarget(targetId, targetScope);
    final rows = await (_db.select(_db.customFieldValuesCache)
          ..where((row) =>
              row.targetId.equals(targetId) &
              row.targetScope.equals(targetScope.apiValue)))
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
    _validateValue(fieldValue);
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
    for (final value in values) {
      _validateValue(value);
    }
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
    required String targetId,
    required CustomFieldTargetScope targetScope,
  }) async {
    _requireTarget(targetId, targetScope);
    await (_db.delete(_db.customFieldValuesCache)
          ..where((row) =>
              row.targetId.equals(targetId) &
              row.targetScope.equals(targetScope.apiValue)))
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
    final targetScope = CustomFieldTargetScope.fromApiValue(row.targetScope);
    _requireTarget(row.targetId, targetScope);
    final catalogRefJson = row.catalogRefJson;
    CatalogEntityRef? catalogRef;
    if (catalogRefJson != null) {
      final decoded = jsonDecode(catalogRefJson);
      if (decoded is! Map) {
        throw const FormatException(
            'catalogRefJson must contain a JSON object');
      }
      catalogRef = CatalogEntityRef.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      requireKnownCatalogRef(catalogRef, 'customField.catalogRef');
    }
    return CustomFieldValue(
      id: row.id,
      targetId: row.targetId,
      targetScope: targetScope,
      catalogRef: catalogRef,
      fieldDefinitionId: row.fieldDefinitionId,
      value: row.value,
      updatedAt: row.updatedAt,
    );
  }

  void _requireTarget(String targetId, CustomFieldTargetScope targetScope) {
    if (targetId.trim().isEmpty || targetScope == CustomFieldTargetScope.all) {
      throw ArgumentError(
        'Custom field target requires a non-empty id and an explicit scope.',
      );
    }
    if (targetScope == CustomFieldTargetScope.ownedCopy) {
      final ownedRef = OwnedItemRef.fromKey(targetId);
      requireKnownOwnedRef(ownedRef, 'customField.ownedRef');
    }
  }

  void _validateDefinition(CustomFieldDefinition definition) {
    if (definition.id.trim().isEmpty || definition.name.trim().isEmpty) {
      throw ArgumentError(
        'Custom field definitions require non-empty id and name.',
      );
    }
    final rawKind = definition.mediaKind?.trim();
    if (rawKind != null && rawKind.isNotEmpty) {
      if (catalogMediaKindFromApiValue(rawKind).isUnknown) {
        throw ArgumentError.value(
          rawKind,
          'definition.mediaKind',
          'Custom field definition has an unknown media kind.',
        );
      }
    }
  }

  void _validateValue(CustomFieldValue value) {
    _requireTarget(value.targetId, value.targetScope);
    if (value.id.trim().isEmpty) {
      throw ArgumentError.value(
        value.id,
        'fieldValue.id',
        'Custom field value id must not be empty.',
      );
    }
    if (value.fieldDefinitionId.trim().isEmpty) {
      throw ArgumentError.value(
        value.fieldDefinitionId,
        'fieldValue.fieldDefinitionId',
        'Custom field definition id must not be empty.',
      );
    }
    if (value.catalogRef != null) {
      requireKnownCatalogRef(value.catalogRef!, 'fieldValue.catalogRef');
    }
  }
}
