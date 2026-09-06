import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
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
      if (existing.mediaKind == row.mediaKind &&
          row.sortOrder < existing.sortOrder) {
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
    final result = await _db
        .customSelect(
          'SELECT DISTINCT list_name AS list_name FROM pick_list_values_cache ORDER BY list_name',
        )
        .get();
    return result
        .map((row) => row.read<String>('list_name'))
        .toList(growable: false);
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
      (maxSortOrder, row) =>
          row.sortOrder >= maxSortOrder ? row.sortOrder + 1 : maxSortOrder,
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
    final catalogPayloadFields = <String, List<String>>{
      'publisher': ['publisher'],
      'imprint': ['imprint'],
      'language': ['language'],
      'country': ['country'],
      'age_rating': ['age_rating'],
      'series_group': ['series_group'],
      'physical_format': ['physical_format', 'physical_format_label'],
      'format': ['physical_format', 'physical_format_label'],
    };
    final semanticName = pickListSemanticName(listName);
    var total = await _countOwnedStandardField(semanticName, normalized);
    total += await _countOwnedDetails(semanticName, normalized);
    for (final field
        in catalogPayloadFields[semanticName] ?? const <String>[]) {
      total += await _countCatalogPayloadField(field, normalized);
    }
    if (semanticName == 'tags') {
      total += await _countTagField(normalized);
    }
    total += await _countCustomFieldValues(normalized);
    return total;
  }

  Future<int> _countOwnedDetails(String semanticName, String normalized) async {
    final key = switch (semanticName) {
      'raw_or_slabbed' => 'raw_or_slabbed',
      'grading_company' => 'grading_company',
      'grader_notes' => 'grader_notes',
      'signed_by' => 'signed_by',
      'label_type' => 'label_type',
      'custom_label' => 'custom_label',
      'page_quality' => 'page_quality',
      'certification_number' => 'certification_number',
      'key_category' => 'key_category',
      'key_severity' => 'key_severity',
      'features' => 'features',
      'region' => 'region',
      'packaging' => 'packaging',
      'distributor' => 'distributor',
      'game_completeness' => 'game_completeness',
      _ => null,
    };
    if (key == null) {
      return 0;
    }
    final rows = await OwnedItemsRepository(_db).listActive();
    var count = 0;
    for (final row in rows) {
      final details = row.details.toJson();
      final value = details[key];
      if (value is String && normalizePickListValue(value) == normalized) {
        count += 1;
      }
    }
    return count;
  }

  Future<int> _countOwnedStandardField(
    String semanticName,
    String normalized,
  ) async {
    final rows = await OwnedItemsRepository(_db).listActive();
    var count = 0;
    for (final row in rows) {
      final value = switch (semanticName) {
        'condition' => row.condition,
        'grade' => row.grade,
        'purchase_store' => row.purchaseStore,
        'sold_to' => row.soldTo,
        'collection_status' => row.collectionStatus,
        _ => null,
      };
      if (value != null && normalizePickListValue(value) == normalized) {
        count++;
      }
    }
    return count;
  }

  Future<int> _countCatalogPayloadField(
    String fieldName,
    String normalized,
  ) async {
    final items = await LibraryCatalogRepository(_db).findAll();
    var count = 0;
    for (final item in items) {
      final payload = item.payload;
      if (payload[fieldName] is String) {
        if (normalizePickListValue(payload[fieldName] as String) ==
            normalized) {
          count++;
        }
      }
    }
    return count;
  }

  Future<int> _countTagField(String normalized) async {
    final rows = await OwnedItemsRepository(_db).listActive();
    return rows.where((row) {
      final values = (row.tags ?? '')
          .split(',')
          .map((value) => normalizePickListValue(value));
      return values.contains(normalized);
    }).length;
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
