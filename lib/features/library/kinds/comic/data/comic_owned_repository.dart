import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Comic-owned graph.
final class ComicOwnedRepository
    implements ReadRepository<ComicOwnedItemId, ComicOwnedItem> {
  const ComicOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<ComicOwnedItem?> findById(ComicOwnedItemId id) async {
    final row = await (_db.select(_db.comicOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row == null) return null;
    final readingRow = await (_db.select(_db.comicReadingRows)
          ..where((table) => table.ownedItemId.equals(id.value)))
        .getSingleOrNull();
    return ComicLocalMapper.fromOwnedItemRow(
      row,
      reading: readingRow == null
          ? const ComicReadingState()
          : ComicLocalMapper.fromReadingRow(readingRow),
    );
  }

  Future<List<ComicOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.comicOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    final result = <ComicOwnedItem>[];
    for (final row in rows) {
      final item = await findById(ComicOwnedItemId(row.id));
      if (item != null) result.add(item);
    }
    return result;
  }

  Future<void> upsert(ComicOwnedItem item) async {
    await _db.transaction(() async {
      await _db
          .into(_db.comicOwnedItemsRows)
          .insertOnConflictUpdate(ComicLocalMapper.toOwnedItemRow(item));
      await _db
          .into(_db.comicReadingRows)
          .insertOnConflictUpdate(ComicLocalMapper.toReadingRow(item));
    });
  }

  Future<void> upsertAll(Iterable<ComicOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(
          _db.comicOwnedItemsRows,
          values.map(ComicLocalMapper.toOwnedItemRow).toList(growable: false),
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          _db.comicReadingRows,
          values.map(ComicLocalMapper.toReadingRow).toList(growable: false),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> markDeleted(ComicOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
