import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_collection_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Manga-owned graph.
final class MangaOwnedRepository
    implements ReadRepository<CollectionItemId, MangaCollectionItem> {
  const MangaOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MangaCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.mangaCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : MangaCollectionItemLocalMapper.fromRow(row);
  }

  Future<List<MangaCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.mangaCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) MangaCollectionItemLocalMapper.fromRow(row)];
  }

  Future<void> upsert(MangaCollectionItem item) {
    return _db
        .into(_db.mangaCollectionItemsRows)
        .insertOnConflictUpdate(MangaCollectionItemLocalMapper.toRow(item));
  }

  Future<void> upsertAll(Iterable<MangaCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.mangaCollectionItemsRows,
        values.map(MangaCollectionItemLocalMapper.toRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(MangaCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
