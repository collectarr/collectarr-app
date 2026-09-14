import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete TV-owned graph.
final class TvOwnedRepository
    implements ReadRepository<TvOwnedItemId, TvOwnedItem> {
  const TvOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<TvOwnedItem?> findById(TvOwnedItemId id) async {
    final row = await (_db.select(_db.tvOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : TvLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<TvOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.tvOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) TvLocalMapper.fromOwnedItemRow(row)];
  }

  Future<void> upsert(TvOwnedItem item) {
    return _db
        .into(_db.tvOwnedItemsRows)
        .insertOnConflictUpdate(TvLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<TvOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.tvOwnedItemsRows,
        values.map(TvLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(TvOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
