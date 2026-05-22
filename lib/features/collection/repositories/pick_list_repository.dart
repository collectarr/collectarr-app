import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing custom pick list values (conditions, grades, tags, etc.)
class PickListRepository {
  PickListRepository(this._db);

  final LocalDatabase _db;

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

      await _db.into(_db.pickListValuesCache).insert(
            PickListValuesCacheCompanion.insert(
              id: const Uuid().v4(),
              listName: listName,
              mediaKind: Value(mediaKind),
              value: value,
              sortOrder: Value(sortOrder),
            ),
          );
      return true;
    });
  }

  /// Remove a value from a pick list.
  Future<void> removeValue(String listName, String value) async {
    await (_db.delete(_db.pickListValuesCache)
          ..where(
              (t) => t.listName.equals(listName) & t.value.equals(value)))
        .go();
  }

  /// Replace all values in a pick list.
  Future<void> setValues(String listName, List<String> values,
      {String? mediaKind}) async {
    await (_db.delete(_db.pickListValuesCache)
          ..where((t) => t.listName.equals(listName)))
        .go();
    await _db.batch((batch) {
      for (var i = 0; i < values.length; i++) {
        batch.insert(
          _db.pickListValuesCache,
          PickListValuesCacheCompanion.insert(
            id: const Uuid().v4(),
            listName: listName,
            mediaKind: Value(mediaKind),
            value: values[i],
            sortOrder: Value(i),
          ),
        );
      }
    });
  }
}
