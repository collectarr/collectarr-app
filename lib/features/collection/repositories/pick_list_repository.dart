import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _entityType = 'pick_list_value';

/// Repository for managing custom pick list values (conditions, grades, tags, etc.)
class PickListRepository {
  PickListRepository(this._db);

  final LocalDatabase _db;
  late final _syncQueue = SyncQueueRepository(_db);

  /// Get all values for a named pick list, optionally filtered by media kind.
  Future<List<String>> getValues(String listName, {String? mediaKind}) async {
    final query = _db.select(_db.pickListValuesCache)
      ..where((t) => t.listName.equals(listName))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (mediaKind != null) {
      query.where(
          (t) => t.mediaKind.equals(mediaKind) | t.mediaKind.isNull());
    }
    final rows = await query.get();
    return rows.map((r) => r.value).toList();
  }

  /// Add a value to a pick list. Returns true if added, false if duplicate.
  Future<bool> addValue(String listName, String value,
      {String? mediaKind}) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.pickListValuesCache)
            ..where((t) =>
                t.listName.equals(listName) & t.value.equals(value)))
          .getSingleOrNull();
      if (existing != null) return false;

      final maxSort = await _db.customSelect(
        'SELECT COALESCE(MAX(sort_order), 0) AS m FROM pick_list_values_cache WHERE list_name = ?',
        variables: [Variable.withString(listName)],
      ).getSingle();
      final sortOrder = (maxSort.data['m'] as int) + 1;

      final id = const Uuid().v4();
      await _db.into(_db.pickListValuesCache).insert(
            PickListValuesCacheCompanion.insert(
              id: id,
              listName: listName,
              mediaKind: Value(mediaKind),
              value: value,
              sortOrder: Value(sortOrder),
            ),
          );
      await _enqueueChange(id, 'upsert', {
        'list_name': listName,
        'media_kind': mediaKind,
        'value': value,
        'sort_order': sortOrder,
      });
      return true;
    });
  }

  /// Remove a value from a pick list.
  Future<void> removeValue(String listName, String value) async {
    final existing = await (_db.select(_db.pickListValuesCache)
          ..where(
              (t) => t.listName.equals(listName) & t.value.equals(value))
          ..limit(1))
        .getSingleOrNull();
    await (_db.delete(_db.pickListValuesCache)
          ..where(
              (t) => t.listName.equals(listName) & t.value.equals(value)))
        .go();
    if (existing != null) {
      await _enqueueChange(existing.id, 'delete', {
        'list_name': listName,
        'value': value,
      });
    }
  }

  /// Replace all values in a pick list.
  Future<void> setValues(String listName, List<String> values,
      {String? mediaKind}) async {
    final existingRows = await (_db.select(_db.pickListValuesCache)
          ..where((t) {
            final expr = t.listName.equals(listName);
            return mediaKind != null
                ? expr & t.mediaKind.equals(mediaKind)
                : expr;
          }))
        .get();
    await (_db.delete(_db.pickListValuesCache)
          ..where((t) {
            final expr = t.listName.equals(listName);
            return mediaKind != null
                ? expr & t.mediaKind.equals(mediaKind)
                : expr;
          }))
        .go();
    final changes = <SyncChange>[];
    final now = DateTime.now().toUtc();
    for (final row in existingRows) {
      changes.add(SyncChange(
        id: const Uuid().v4(),
        entityType: _entityType,
        entityId: row.id,
        action: 'delete',
        payload: {
          'list_name': row.listName,
          'value': row.value,
        },
        clientChangedAt: now,
      ));
    }
    await _db.batch((batch) {
      for (var i = 0; i < values.length; i++) {
        final id = const Uuid().v4();
        batch.insert(
          _db.pickListValuesCache,
          PickListValuesCacheCompanion.insert(
            id: id,
            listName: listName,
            mediaKind: Value(mediaKind),
            value: values[i],
            sortOrder: Value(i),
          ),
        );
        changes.add(SyncChange(
          id: const Uuid().v4(),
          entityType: _entityType,
          entityId: id,
          action: 'upsert',
          payload: {
            'list_name': listName,
            'media_kind': mediaKind,
            'value': values[i],
            'sort_order': i,
          },
          clientChangedAt: now,
        ));
      }
    });
    if (changes.isNotEmpty) {
      await _syncQueue.enqueueAll(changes);
    }
  }

  Future<void> _enqueueChange(
      String entityId, String action, Map<String, dynamic> payload) async {
    await _syncQueue.enqueue(SyncChange(
      id: const Uuid().v4(),
      entityType: _entityType,
      entityId: entityId,
      action: action,
      payload: payload,
      clientChangedAt: DateTime.now().toUtc(),
    ));
  }
}
