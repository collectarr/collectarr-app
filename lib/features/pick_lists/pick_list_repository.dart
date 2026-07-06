import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'models/pick_list_value.dart';

const _entityType = 'pick_list_value';

class PickListRepository {
  PickListRepository(this._db);

  final LocalDatabase _db;
  late final _syncQueue = SyncQueueRepository(_db);

  Future<List<PickListValue>> valuesForList({
    required String listName,
    String? mediaKind,
    bool includeGlobal = true,
  }) async {
    final rows = await _rowsForList(
      listName,
      mediaKind: mediaKind,
      includeGlobal: includeGlobal,
    );
    final merged = <String, PickListValue>{};
    for (final row in rows) {
      final normalized = normalizePickListValue(row.value);
      final existing = merged[normalized];
      if (existing == null) {
        merged[normalized] = _fromRow(row);
        continue;
      }
      if (existing.isGlobal && row.mediaKind != null) {
        merged[normalized] = _fromRow(row);
        continue;
      }
      if (existing.mediaKind == row.mediaKind && row.sortOrder < existing.sortOrder) {
        merged[normalized] = _fromRow(row);
      }
    }
    final values = merged.values.toList(growable: false)
      ..sort(
        (left, right) {
          final sortOrder = left.sortOrder.compareTo(right.sortOrder);
          if (sortOrder != 0) {
            return sortOrder;
          }
          return left.effectiveLabel.toLowerCase().compareTo(
                right.effectiveLabel.toLowerCase(),
              );
        },
      );
    return values;
  }

  Future<List<String>> getValues(String listName, {String? mediaKind}) async {
    final rows = await valuesForList(
      listName: listName,
      mediaKind: mediaKind,
    );
    return rows.map((row) => row.value).toList(growable: false);
  }

  Future<bool> addValue(
    String listName,
    String value, {
    String? mediaKind,
  }) async {
    final normalized = normalizePickListValue(value);
    if (normalized.isEmpty) {
      return false;
    }
    final duplicate = await _findByNormalized(
      listName,
      normalized,
      mediaKind: mediaKind,
      includeGlobal: false,
    );
    if (duplicate != null) {
      return false;
    }
    final maxSort = await _maxSortOrder(listName, mediaKind: mediaKind);
    await _insertValue(
      PickListValue(
        id: const Uuid().v4(),
        listName: listName,
        mediaKind: mediaKind,
        value: value.trim(),
        sortOrder: maxSort + 1,
      ),
    );
    return true;
  }

  Future<void> upsertValue(PickListValue value) async {
    final normalized = normalizePickListValue(value.value);
    final existing = await _findByNormalized(
      value.listName,
      normalized,
      mediaKind: value.mediaKind,
      includeGlobal: false,
    );
    if (existing != null && existing.id != value.id) {
      await _db.into(_db.pickListValuesCache).insert(
            PickListValuesCacheCompanion.insert(
              id: existing.id,
              listName: value.listName,
              mediaKind: Value(value.mediaKind),
              value: value.value.trim(),
              sortOrder: Value(value.sortOrder),
            ),
            mode: InsertMode.insertOrReplace,
          );
      return;
    }
    await _db.into(_db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: value.id,
            listName: value.listName,
            mediaKind: Value(value.mediaKind),
            value: value.value.trim(),
            sortOrder: Value(value.sortOrder),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _enqueueChange(value.id, 'upsert', {
      'list_name': value.listName,
      'media_kind': value.mediaKind,
      'value': value.value.trim(),
      'sort_order': value.sortOrder,
    });
  }

  Future<void> deleteValue(String id) async {
    final row = await (_db.select(_db.pickListValuesCache)
          ..where((table) => table.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return;
    }
    await (_db.delete(_db.pickListValuesCache)
          ..where((table) => table.id.equals(id)))
        .go();
    await _enqueueChange(id, 'delete', {
      'list_name': row.listName,
      'media_kind': row.mediaKind,
      'value': row.value,
    });
  }

  Future<void> reorderValues({
    required String listName,
    required String? mediaKind,
    required List<String> orderedIds,
  }) async {
    final rows = await _rowsForList(
      listName,
      mediaKind: mediaKind,
      includeGlobal: false,
    );
    final byId = {for (final row in rows) row.id: row};
    final finalOrder = <String>[
      ...orderedIds.where(byId.containsKey),
      ...byId.keys.where((id) => !orderedIds.contains(id)),
    ];
    for (var index = 0; index < finalOrder.length; index++) {
      final id = finalOrder[index];
      await (_db.update(_db.pickListValuesCache)
            ..where((table) => table.id.equals(id)))
          .write(PickListValuesCacheCompanion(sortOrder: Value(index)));
    }
  }

  Future<List<String>> listNames() async {
    final result = await _db.customSelect(
      'SELECT DISTINCT list_name AS list_name FROM pick_list_values_cache ORDER BY list_name',
    ).get();
    return result.map((row) => row.read<String>('list_name')).toList(growable: false);
  }

  Future<Map<String, int>> usageCounts({
    required String listName,
    String? mediaKind,
  }) async {
    final values = await valuesForList(
      listName: listName,
      mediaKind: mediaKind,
    );
    final counts = <String, int>{};
    for (final value in values) {
      counts[value.id] = await _usageCountForValue(listName, value.value);
    }
    return counts;
  }

  Future<void> captureValues(
    String listName,
    Iterable<String?> values, {
    String? mediaKind,
  }) async {
    await _db.transaction(() async {
      await captureValuesWithoutTransaction(
        listName,
        values,
        mediaKind: mediaKind,
      );
    });
  }

  Future<void> captureValuesWithoutTransaction(
    String listName,
    Iterable<String?> values, {
    String? mediaKind,
  }) async {
    final normalizedValues = values
        .map((value) => value?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedValues.isEmpty) {
      return;
    }
    final existingValues = await valuesForList(
      listName: listName,
      mediaKind: mediaKind,
      includeGlobal: false,
    );
    final existing = {
      for (final row in existingValues) row.effectiveNormalizedValue: row,
    };
    var nextSortOrder = existingValues.fold<int>(
      0,
      (maxSortOrder, row) => row.sortOrder >= maxSortOrder
          ? row.sortOrder + 1
          : maxSortOrder,
    );
    for (final value in normalizedValues) {
      final normalized = normalizePickListValue(value);
      if (existing.containsKey(normalized)) {
        continue;
      }
      await _insertValue(
        PickListValue(
          id: const Uuid().v4(),
          listName: listName,
          mediaKind: mediaKind,
          value: value,
          sortOrder: nextSortOrder,
        ),
      );
      nextSortOrder += 1;
    }
  }

  Future<void> removeValue(String listName, String value) async {
    final normalized = normalizePickListValue(value);
    final rows = await _rowsForList(
      listName,
      mediaKind: null,
      includeGlobal: true,
    );
    final ids = rows
        .where((row) => normalizePickListValue(row.value) == normalized)
        .map((row) => row.id)
        .toList(growable: false);
    for (final id in ids) {
      await deleteValue(id);
    }
  }

  Future<void> setValues(
    String listName,
    List<String> values, {
    String? mediaKind,
  }) async {
    final rows = await _rowsForList(
      listName,
      mediaKind: mediaKind,
      includeGlobal: mediaKind != null,
    );
    for (final row in rows) {
      await deleteValue(row.id);
    }
    for (var i = 0; i < values.length; i++) {
      await _insertValue(
        PickListValue(
          id: const Uuid().v4(),
          listName: listName,
          mediaKind: mediaKind,
          value: values[i],
          sortOrder: i,
        ),
      );
    }
  }

  Future<PickListValue?> _findByNormalized(
    String listName,
    String normalized, {
    String? mediaKind,
    required bool includeGlobal,
  }) async {
    final rows = await _rowsForList(
      listName,
      mediaKind: mediaKind,
      includeGlobal: includeGlobal,
    );
    for (final row in rows) {
      if (normalizePickListValue(row.value) == normalized) {
        return _fromRow(row);
      }
    }
    return null;
  }

  Future<int> _maxSortOrder(String listName, {String? mediaKind}) async {
    final rows = await _rowsForList(
      listName,
      mediaKind: mediaKind,
      includeGlobal: false,
    );
    if (rows.isEmpty) {
      return -1;
    }
    return rows.map((row) => row.sortOrder).reduce((a, b) => a > b ? a : b);
  }

  Future<void> _insertValue(PickListValue value) async {
    await _db.into(_db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: value.id,
            listName: value.listName,
            mediaKind: Value(value.mediaKind),
            value: value.value.trim(),
            sortOrder: Value(value.sortOrder),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _enqueueChange(value.id, 'upsert', {
      'list_name': value.listName,
      'media_kind': value.mediaKind,
      'value': value.value.trim(),
      'sort_order': value.sortOrder,
    });
  }

  Future<List<PickListValuesCacheData>> _rowsForList(
    String listName, {
    required String? mediaKind,
    required bool includeGlobal,
  }) async {
    final query = _db.select(_db.pickListValuesCache)
      ..where((table) => table.listName.equals(listName));
    if (mediaKind == null) {
      query.where((table) => table.mediaKind.isNull());
    } else if (includeGlobal) {
      query.where(
        (table) => table.mediaKind.isNull() | table.mediaKind.equals(mediaKind),
      );
    } else {
      query.where((table) => table.mediaKind.equals(mediaKind));
    }
    query.orderBy([
      (table) => OrderingTerm.asc(table.sortOrder),
      (table) => OrderingTerm.asc(table.value),
    ]);
    return query.get();
  }

  PickListValue _fromRow(PickListValuesCacheData row) {
    return PickListValue(
      id: row.id,
      listName: row.listName,
      mediaKind: row.mediaKind,
      value: row.value,
      sortOrder: row.sortOrder,
    );
  }

  Future<int> _usageCountForValue(String listName, String value) async {
    final normalized = normalizePickListValue(value);
    if (normalized.isEmpty) {
      return 0;
    }
    final directColumns = <String, List<(String table, String column)>>{
      'condition': [('owned_items_cache', 'condition')],
      'grade': [('owned_items_cache', 'grade')],
      'raw_or_slabbed': [('owned_items_cache', 'rawOrSlabbed')],
      'grading_company': [('owned_items_cache', 'gradingCompany')],
      'label_type': [('owned_items_cache', 'labelType')],
      'page_quality': [('owned_items_cache', 'pageQuality')],
      'key_category': [('owned_items_cache', 'keyCategory')],
      'key_severity': [('owned_items_cache', 'keySeverity')],
      'purchase_store': [('owned_items_cache', 'purchaseStore')],
      'sold_to': [('owned_items_cache', 'soldTo')],
      'region': [('owned_items_cache', 'region')],
      'packaging': [('owned_items_cache', 'packaging')],
      'distributor': [('owned_items_cache', 'distributor')],
      'collection_status': [('owned_items_cache', 'collectionStatus')],
      'features': [('owned_items_cache', 'features')],
      'publisher': [('catalog_cache', 'publisher')],
      'imprint': [('catalog_cache', 'imprint')],
      'language': [('catalog_cache', 'language')],
      'country': [('catalog_cache', 'country')],
      'age_ratings': [('catalog_cache', 'ageRating')],
      'series_groups': [('catalog_cache', 'seriesGroup')],
      'physical_formats': [
        ('catalog_cache', 'physicalFormat'),
        ('catalog_cache', 'physicalFormatLabel'),
      ],
    };
    final ownedColumns = directColumns[listName] ?? const <(String table, String column)>[];
    var total = 0;
    for (final column in ownedColumns) {
      total += await _countTextColumn(column.$1, column.$2, normalized);
    }
    if (listName == 'tags') {
      total += await _countTagField(normalized);
    }
    total += await _countCustomFieldValues(normalized);
    return total;
  }

  Future<int> _countTextColumn(
    String tableName,
    String columnName,
    String normalized,
  ) async {
    final result = await _db.customSelect(
      'SELECT COUNT(*) AS count FROM $tableName WHERE lower(trim(coalesce($columnName, \'\'))) = ?',
      variables: [Variable.withString(normalized)],
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> _countTagField(String normalized) async {
    final result = await _db.customSelect(
      'SELECT COUNT(*) AS count FROM owned_items_cache WHERE lower(coalesce(tags, \'\')) LIKE ?',
      variables: [Variable.withString('%${normalized.replaceAll("'", "''")}%')],
    ).getSingle();
    return result.read<int>('count');
  }

  Future<int> _countCustomFieldValues(String normalized) async {
    final result = await _db.customSelect(
      'SELECT COUNT(*) AS count FROM custom_field_values_cache WHERE lower(trim(coalesce(value, \'\'))) = ?',
      variables: [Variable.withString(normalized)],
    ).getSingle();
    return result.read<int>('count');
  }

  Future<void> _enqueueChange(
    String entityId,
    String action,
    Map<String, dynamic> payload,
  ) async {
    await _syncQueue.enqueue(
      SyncChange(
        id: const Uuid().v4(),
        entityType: _entityType,
        entityId: entityId,
        action: action,
        payload: payload,
        clientChangedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
