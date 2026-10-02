import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_owned_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Movie-owned graph.
final class MovieOwnedRepository
    implements ReadRepository<CollectionItemId, MovieCollectionItem> {
  const MovieOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MovieCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.movieCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : MovieOwnedLocalMapper.fromRow(row);
  }

  Future<List<MovieCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.movieCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) MovieOwnedLocalMapper.fromRow(row),
    ];
  }

  Future<void> upsert(MovieCollectionItem item) {
    return _db
        .into(_db.movieCollectionItemsRows)
        .insertOnConflictUpdate(MovieOwnedLocalMapper.toRow(item));
  }

  Future<void> upsertAll(Iterable<MovieCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.movieCollectionItemsRows,
        values.map(MovieOwnedLocalMapper.toRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(MovieCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
