import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'pick_list_references.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'pick_list_definition_contributor.dart';
import 'models/pick_list_value.dart';

const _entityType = 'pick_list_value';

class PickListRepository {
  PickListRepository(
    this._db, {
    Iterable<PickListDefinitionContributor> contributors = const [],
  }) : _contributors = contributors.toList(growable: false);

  final LocalDatabase _db;
  final List<PickListDefinitionContributor> _contributors;
  late final _syncQueue = SyncQueueRepository(_db);

  Future<List<PickListValue>> valuesForList({
    required String listName,
    String? mediaKind,
    bool includeGlobal = true,
    bool includeHidden = false,
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
    final values = merged.values
        .where((value) => includeHidden || !value.isHidden)
        .toList(growable: false)
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

  Future<List<String>> entryOptions(String listName,
      {String? mediaKind}) async {
    if (listName.startsWith('customField:')) {
      return (await _customFieldUsages(listName, mediaKind)).$2.values.toList();
    }
    if (PickListReferences(_db).handles(listName)) {
      return (await PickListReferences(_db).usages(listName, mediaKind))
          .keys
          .toList();
    }
    final kind = _requestedKind(listName: listName, mediaKind: mediaKind);
    return [
      for (final contributor in _contributors)
        if (kind == null || contributor.kind == kind)
          ...await contributor.entryOptions(_db, pickListSemanticName(listName))
    ];
  }

  Future<Set<String>> hiddenValues(String listName, {String? mediaKind}) async {
    final values = await valuesForList(
        listName: listName, mediaKind: mediaKind, includeHidden: true);
    return {
      for (final value in values)
        if (value.isHidden) value.effectiveNormalizedValue
    };
  }

  Future<void> hideValue(PickListValue value) => upsertValue(PickListValue(
        id: value.id,
        listName: value.listName,
        mediaKind: value.mediaKind,
        value: value.value,
        sortName: value.sortName,
        sortOrder: value.sortOrder,
        isHidden: true,
      ));

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
      if (!duplicate.isHidden) return false;
      await upsertValue(PickListValue(
          id: duplicate.id,
          listName: listName,
          mediaKind: mediaKind,
          value: value.trim(),
          sortName: duplicate.sortName,
          sortOrder: duplicate.sortOrder));
      return true;
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
    if (normalized.isEmpty) throw ArgumentError('Name cannot be empty.');
    if (existing != null && existing.id != value.id && !existing.isHidden) {
      throw StateError(
          'This name already exists. Use Merge Mode to combine values.');
    }
    if (existing != null && existing.id != value.id && existing.isHidden) {
      await deleteValue(existing.id);
    }
    if (value.listName == 'locations' && !value.isHidden) {
      final locations = LocationRepository(_db);
      if (!(await locations.getAll()).any((location) =>
          normalizePickListValue(location.name) ==
          value.effectiveNormalizedValue)) {
        await locations.create(name: value.value.trim());
      }
    }
    await _db.into(_db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: value.id,
            listName: value.listName,
            mediaKind: Value(value.mediaKind),
            value: value.value.trim(),
            sortOrder: Value(value.sortOrder),
            sortName: Value(value.sortName),
            isHidden: Value(value.isHidden),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _enqueueChange(value.id, 'upsert', {
      'list_name': value.listName,
      'media_kind': value.mediaKind,
      'value': value.value.trim(),
      'sort_order': value.sortOrder,
      'sort_name': value.sortName,
      'is_hidden': value.isHidden,
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
    final countsByValue = await usageCountsByValue(
      listName: listName,
      values: values.map((value) => value.value),
      mediaKind: mediaKind,
    );
    final counts = <String, int>{};
    for (final value in values) {
      counts[value.id] =
          countsByValue[normalizePickListValue(value.value)] ?? 0;
    }
    return counts;
  }

  /// Returns usage counts keyed by normalized option value. This also supports
  /// built-in options that are not stored as pick-list rows.
  Future<Map<String, int>> usageCountsByValue({
    required String listName,
    required Iterable<String> values,
    String? mediaKind,
  }) async {
    final normalizedValues = <String>{};
    for (final value in values) {
      final normalized = normalizePickListValue(value);
      if (normalized.isNotEmpty) normalizedValues.add(normalized);
    }

    final counts = {for (final value in normalizedValues) value: 0};
    if (counts.isEmpty) return counts;

    if (PickListReferences(_db).handles(listName)) {
      final refsByValue = <String, Set<LibraryEntryRef>>{};
      for (final entry
          in (await PickListReferences(_db).usages(listName, mediaKind))
              .entries) {
        refsByValue
            .putIfAbsent(
                normalizePickListValue(entry.key), () => <LibraryEntryRef>{})
            .addAll(entry.value);
      }
      return {
        for (final value in normalizedValues)
          value: refsByValue[value]?.length ?? 0
      };
    }
    if (listName.startsWith('customField:')) {
      final usages = (await _customFieldUsages(listName, mediaKind)).$1;
      return {for (final value in normalizedValues) value: usages[value] ?? 0};
    }
    final semanticName = pickListSemanticName(listName);
    final requestedKind =
        _requestedKind(listName: listName, mediaKind: mediaKind);
    for (final contributor in _contributors) {
      if (requestedKind != null && contributor.kind != requestedKind) continue;
      final usages = await contributor.entryUsageCounts(_db, semanticName);
      for (final normalized in normalizedValues) {
        counts[normalized] = counts[normalized]! + (usages[normalized] ?? 0);
      }
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
      includeHidden: true,
    );
    final existing = {
      for (final row in existingValues) row.effectiveNormalizedValue
    };
    var nextSortOrder = existingValues.fold<int>(
      0,
      (maxSortOrder, row) =>
          row.sortOrder >= maxSortOrder ? row.sortOrder + 1 : maxSortOrder,
    );
    for (final value in normalizedValues) {
      final normalized = normalizePickListValue(value);
      if (existing.contains(normalized)) {
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
      existing.add(normalized);
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
            sortName: Value(value.sortName),
            isHidden: Value(value.isHidden),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _enqueueChange(value.id, 'upsert', {
      'list_name': value.listName,
      'media_kind': value.mediaKind,
      'value': value.value.trim(),
      'sort_order': value.sortOrder,
      'sort_name': value.sortName,
      'is_hidden': value.isHidden,
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
      sortName: row.sortName,
      isHidden: row.isHidden,
    );
  }

  CatalogMediaKind? _requestedKind({
    required String listName,
    required String? mediaKind,
  }) {
    final fromListName = catalogMediaKindFromApiValue(
      listName.split('.').first,
    );
    if (!fromListName.isUnknown) return fromListName;
    final fromMediaKind = catalogMediaKindFromApiValue(mediaKind);
    return fromMediaKind.isUnknown ? null : fromMediaKind;
  }

  Future<(Map<String, int>, Map<String, String>)> _customFieldUsages(
      String listName, String? mediaKind) async {
    const customFieldPrefix = 'customField:';
    if (!listName.startsWith(customFieldPrefix)) {
      return (<String, int>{}, <String, String>{});
    }
    final fieldId = listName.substring(customFieldPrefix.length);
    final definition = await (_db.select(_db.customFieldDefinitionsCache)
          ..where((row) => row.id.equals(fieldId))
          ..limit(1))
        .getSingleOrNull();
    if (definition == null ||
        (mediaKind != null &&
            definition.mediaKind != null &&
            definition.mediaKind != mediaKind)) {
      return (<String, int>{}, <String, String>{});
    }
    final rows = await (_db.select(_db.customFieldValuesCache)
          ..where((row) => row.fieldDefinitionId.equals(fieldId)))
        .get();
    final isMultiValue =
        CustomFieldValueType.fromApiValue(definition.fieldType).isMultiValue;
    final active = {
      for (final entry in await LibraryEntryStore(_db).list())
        if (mediaKind == null || entry.kind.apiValue == mediaKind)
          LibraryEntryRef(kind: entry.kind, id: LibraryEntryId(entry.id)).key
    };
    final used = <String, Set<String>>{};
    final labels = <String, String>{};
    for (final row in rows) {
      final rawValue = row.value;
      if (rawValue == null ||
          row.targetScope != CustomFieldTargetScope.libraryEntry.apiValue ||
          !active.contains(row.targetId)) {
        continue;
      }
      final values =
          isMultiValue ? parseCustomFieldMultiValues(rawValue) : [rawValue];
      for (final value in values) {
        final normalized = normalizePickListValue(value);
        if (normalized.isNotEmpty) {
          labels.putIfAbsent(normalized, () => value.trim());
          used.putIfAbsent(normalized, () => <String>{}).add(row.targetId);
        }
      }
    }
    return (
      {for (final entry in used.entries) entry.key: entry.value.length},
      labels
    );
  }

  Future<void> _enqueueChange(
    String entityId,
    String action,
    Map<String, dynamic> data,
  ) async {
    await _syncQueue.enqueue(
      SyncChange(
        id: const Uuid().v4(),
        entityType: _entityType,
        entityId: entityId,
        action: action,
        payload: data,
        clientChangedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
