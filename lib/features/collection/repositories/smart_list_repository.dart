import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class SmartListRepository {
  SmartListRepository(this._db);

  final LocalDatabase _db;

  Future<List<SmartList>> getAll({String? mediaKind}) async {
    final query = _db.select(_db.smartListsCache);
    if (mediaKind != null) {
      query.where(
          (t) => t.mediaKind.equals(mediaKind) | t.mediaKind.isNull());
    }
    query.orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await query.get();
    return rows
        .map((r) => SmartList.fromRow(r.id, r.name, r.criteriaJson))
        .toList();
  }

  Future<SmartList> create(SmartList smartList) async {
    final id = const Uuid().v4();
    final criteriaJson = jsonEncode(smartList.toJson());
    await _db.into(_db.smartListsCache).insert(
          SmartListsCacheCompanion.insert(
            id: id,
            name: smartList.name,
            mediaKind: Value(smartList.mediaKind),
            criteriaJson: criteriaJson,
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return SmartList.fromRow(id, smartList.name, criteriaJson);
  }

  Future<void> update(SmartList smartList) async {
    final criteriaJson = jsonEncode(smartList.toJson());
    await (_db.update(_db.smartListsCache)
          ..where((t) => t.id.equals(smartList.id)))
        .write(SmartListsCacheCompanion(
      name: Value(smartList.name),
      mediaKind: Value(smartList.mediaKind),
      criteriaJson: Value(criteriaJson),
    ));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.smartListsCache)..where((t) => t.id.equals(id)))
        .go();
  }
}
