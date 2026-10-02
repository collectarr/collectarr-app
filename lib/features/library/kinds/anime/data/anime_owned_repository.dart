import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Anime-owned graph.
final class AnimeOwnedRepository
    implements ReadRepository<CollectionItemId, AnimeCollectionItem> {
  const AnimeOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<AnimeCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.animeCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : AnimeLocalMapper.fromCollectionItemRow(row);
  }

  Future<List<AnimeCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.animeCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) AnimeLocalMapper.fromCollectionItemRow(row),
    ];
  }

  Future<void> upsert(AnimeCollectionItem item) {
    return _db
        .into(_db.animeCollectionItemsRows)
        .insertOnConflictUpdate(AnimeLocalMapper.toCollectionItemRow(item));
  }

  Future<void> upsertAll(Iterable<AnimeCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.animeCollectionItemsRows,
        values.map(AnimeLocalMapper.toCollectionItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(AnimeCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
