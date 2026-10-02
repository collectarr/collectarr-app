import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_collection_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Book-owned graph.
final class BookOwnedRepository
    implements ReadRepository<CollectionItemId, BookCollectionItem> {
  const BookOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<BookCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.bookCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : BookCollectionItemLocalMapper.fromRow(row);
  }

  Future<List<BookCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.bookCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) BookCollectionItemLocalMapper.fromRow(row)];
  }

  Future<void> upsert(BookCollectionItem item) {
    return _db
        .into(_db.bookCollectionItemsRows)
        .insertOnConflictUpdate(BookCollectionItemLocalMapper.toRow(item));
  }

  Future<void> upsertAll(Iterable<BookCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.bookCollectionItemsRows,
        values.map(BookCollectionItemLocalMapper.toRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(BookCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
