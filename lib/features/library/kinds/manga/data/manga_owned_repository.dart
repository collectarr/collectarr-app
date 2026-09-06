import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Manga-owned graph.
final class MangaOwnedRepository
    implements ReadRepository<MangaOwnedItemId, MangaOwnedItem> {
  const MangaOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MangaOwnedItem?> findById(MangaOwnedItemId id) async {
    final row = await (_db.select(_db.mangaOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : MangaLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<MangaOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.mangaOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) MangaLocalMapper.fromOwnedItemRow(row)];
  }

  Future<void> upsert(MangaOwnedItem item) {
    return _db
        .into(_db.mangaOwnedItemsRows)
        .insertOnConflictUpdate(MangaLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<MangaOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.mangaOwnedItemsRows,
        values.map(MangaLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(MangaOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
