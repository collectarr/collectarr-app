import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete BoardGame-owned graph.
final class BoardGameOwnedRepository
    implements ReadRepository<BoardGameOwnedItemId, BoardGameOwnedItem> {
  const BoardGameOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<BoardGameOwnedItem?> findById(BoardGameOwnedItemId id) async {
    final row = await (_db.select(_db.boardGameOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : BoardGameLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<BoardGameOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.boardGameOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) BoardGameLocalMapper.fromOwnedItemRow(row),
    ];
  }

  Future<void> upsert(BoardGameOwnedItem item) {
    return _db
        .into(_db.boardGameOwnedItemsRows)
        .insertOnConflictUpdate(BoardGameLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<BoardGameOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.boardGameOwnedItemsRows,
        values.map(BoardGameLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(BoardGameOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
