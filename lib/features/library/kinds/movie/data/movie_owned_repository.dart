import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Movie-owned graph.
final class MovieOwnedRepository
    implements ReadRepository<MovieOwnedItemId, MovieOwnedItem> {
  const MovieOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MovieOwnedItem?> findById(MovieOwnedItemId id) async {
    final row = await (_db.select(_db.movieOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : MovieLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<MovieOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.movieOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) MovieLocalMapper.fromOwnedItemRow(row),
    ];
  }

  Future<void> upsert(MovieOwnedItem item) {
    return _db
        .into(_db.movieOwnedItemsRows)
        .insertOnConflictUpdate(MovieLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<MovieOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.movieOwnedItemsRows,
        values.map(MovieLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(MovieOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
