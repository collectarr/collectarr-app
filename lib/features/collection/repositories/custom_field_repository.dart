import 'package:collectarr_app/core/db/local_database.dart';
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
        (row) => row.editScope.isNull() |
            row.editScope.equals(targetScope.apiValue),
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
            fieldType: def.fieldType,
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

  Future<List<CustomFieldValue>> listValuesForItem(String ownedItemId) async {
    return listValuesForTarget(ownedItemId);
  }

  Future<List<CustomFieldValue>> listValuesForTarget(String targetId) async {
    final rows = await (_db.select(_db.customFieldValuesCache)
          ..where((row) => row.ownedItemId.equals(targetId)))
        .get();
    return rows.map(_valueFromRow).toList(growable: false);
  }

  /// Returns all custom field values grouped by owned item id.
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
            ownedItemId: fieldValue.targetId,
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
            ownedItemId: v.targetId,
            fieldDefinitionId: v.fieldDefinitionId,
            value: Value(v.value),
            updatedAt: v.updatedAt,
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> deleteValuesForItem(String ownedItemId) {
    return deleteValuesForTarget(ownedItemId);
  }

  Future<void> deleteValuesForTarget(String targetId) {
    return (_db.delete(_db.customFieldValuesCache)
          ..where((row) => row.ownedItemId.equals(targetId)))
        .go();
  }

  CustomFieldDefinition _definitionFromRow(CustomFieldDefinitionsCacheData row) {
    return CustomFieldDefinition(
      id: row.id,
      name: row.name,
      fieldType: row.fieldType,
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
      ownedItemId: row.ownedItemId,
      fieldDefinitionId: row.fieldDefinitionId,
      value: row.value,
      updatedAt: row.updatedAt,
    );
  }
}
