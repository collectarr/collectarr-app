import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete TV-owned graph.
final class TvOwnedRepository
    implements ReadRepository<CollectionItemId, TvCollectionItem> {
  const TvOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<TvCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.tvCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : TvLocalMapper.fromCollectionItemRow(row);
  }

  Future<List<TvCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.tvCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) TvLocalMapper.fromCollectionItemRow(row)];
  }

  Future<void> upsert(TvCollectionItem item) {
    return _db
        .into(_db.tvCollectionItemsRows)
        .insertOnConflictUpdate(TvLocalMapper.toCollectionItemRow(item));
  }

  Future<void> upsertAll(Iterable<TvCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.tvCollectionItemsRows,
        values.map(TvLocalMapper.toCollectionItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(TvCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
