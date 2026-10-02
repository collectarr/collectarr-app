import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete BoardGame-owned graph.
final class BoardGameOwnedRepository
    implements ReadRepository<CollectionItemId, BoardGameCollectionItem> {
  const BoardGameOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<BoardGameCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.boardGameCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : BoardGameLocalMapper.fromCollectionItemRow(row);
  }

  Future<List<BoardGameCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.boardGameCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) BoardGameLocalMapper.fromCollectionItemRow(row),
    ];
  }

  Future<void> upsert(BoardGameCollectionItem item) {
    return _db
        .into(_db.boardGameCollectionItemsRows)
        .insertOnConflictUpdate(BoardGameLocalMapper.toCollectionItemRow(item));
  }

  Future<void> upsertAll(Iterable<BoardGameCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.boardGameCollectionItemsRows,
        values.map(BoardGameLocalMapper.toCollectionItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(BoardGameCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
