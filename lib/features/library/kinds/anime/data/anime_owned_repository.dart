import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Anime-owned graph.
final class AnimeOwnedRepository
    implements ReadRepository<AnimeOwnedItemId, AnimeOwnedItem> {
  const AnimeOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<AnimeOwnedItem?> findById(AnimeOwnedItemId id) async {
    final row = await (_db.select(_db.animeOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : AnimeLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<AnimeOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.animeOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) AnimeLocalMapper.fromOwnedItemRow(row),
    ];
  }

  Future<void> upsert(AnimeOwnedItem item) {
    return _db
        .into(_db.animeOwnedItemsRows)
        .insertOnConflictUpdate(AnimeLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<AnimeOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.animeOwnedItemsRows,
        values.map(AnimeLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(AnimeOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
