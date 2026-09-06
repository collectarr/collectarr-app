import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Book-owned graph.
final class BookOwnedRepository
    implements ReadRepository<BookOwnedItemId, BookOwnedItem> {
  const BookOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<BookOwnedItem?> findById(BookOwnedItemId id) async {
    final row = await (_db.select(_db.bookOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : BookLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<BookOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.bookOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) BookLocalMapper.fromOwnedItemRow(row)];
  }

  Future<void> upsert(BookOwnedItem item) {
    return _db
        .into(_db.bookOwnedItemsRows)
        .insertOnConflictUpdate(BookLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<BookOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.bookOwnedItemsRows,
        values.map(BookLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(BookOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
