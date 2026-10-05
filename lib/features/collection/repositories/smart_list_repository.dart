import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/generic/smart_list.dart';
import 'package:collectarr_app/features/library/generic/smart_list_resolver.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class SmartListRepository {
  SmartListRepository(this._db);

  final LocalDatabase _db;

  Future<List<SmartList>> getAll({
    required String mediaKind,
    required SmartListCriteriaTarget target,
  }) async {
    final query = _db.select(_db.smartListsCache);
    query.orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await query.get();
    final lists = <SmartList>[];
    for (final row in rows) {
      try {
        final criteria = SmartListCriteriaCodec.decode(row.criteriaJson);
        _validateKnownKinds(criteria.kinds);
        if (!criteria.kinds.contains(mediaKind) || criteria.target != target) {
          continue;
        }
        final kind = catalogMediaKindFromApiValue(mediaKind);
        if (kind.isUnknown) {
          throw FormatException('Unsupported Smart List kind: $mediaKind.');
        }
        lists.add(SmartListResolver.resolve(
          id: row.id,
          name: row.name,
          criteria: criteria,
          kind: kind,
        ));
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'smart_lists',
          message:
              'Skipping invalid SmartList row id="${row.id}", name="${row.name}"; the stored row was preserved.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return List.unmodifiable(lists);
  }

  Future<SmartList> create(SmartList smartList) async {
    _validateKnownKinds(smartList.kinds);
    final id = const Uuid().v4();
    final criteriaJson = SmartListCriteriaCodec.encode(smartList.toCriteria());
    await _db.into(_db.smartListsCache).insert(
          SmartListsCacheCompanion.insert(
            id: id,
            name: smartList.name,
            criteriaJson: criteriaJson,
            createdAt: DateTime.now().toUtc(),
        ),
      );
    return SmartList(
      id: id,
      name: smartList.name,
      target: smartList.target,
      kinds: smartList.kinds,
      filterSelection: smartList.filterSelection,
      quickView: smartList.quickView,
      sortRules: smartList.sortRules,
      searchQuery: smartList.searchQuery,
      degradedSortTokens: smartList.degradedSortTokens,
      degradedFieldTokens: smartList.degradedFieldTokens,
    );
  }

  Future<void> update(SmartList smartList) async {
    _validateKnownKinds(smartList.kinds);
    final criteriaJson = SmartListCriteriaCodec.encode(smartList.toCriteria());
    await (_db.update(_db.smartListsCache)
          ..where((t) => t.id.equals(smartList.id)))
        .write(SmartListsCacheCompanion(
      name: Value(smartList.name),
      criteriaJson: Value(criteriaJson),
    ));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.smartListsCache)..where((t) => t.id.equals(id))).go();
  }

  void _validateKnownKinds(Iterable<String> kinds) {
    for (final rawKind in kinds) {
      if (catalogMediaKindFromApiValue(rawKind).isUnknown) {
        throw FormatException('Unsupported Smart List kind: $rawKind.');
      }
    }
  }
}
