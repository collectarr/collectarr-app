import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Game-owned graph.
final class GameOwnedRepository
    implements ReadRepository<GameOwnedItemId, GameOwnedItem> {
  const GameOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<GameOwnedItem?> findById(GameOwnedItemId id) async {
    final row = await (_db.select(_db.gameOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : GameLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<GameOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.gameOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) GameLocalMapper.fromOwnedItemRow(row)];
  }

  Future<void> upsert(GameOwnedItem item) {
    return _db
        .into(_db.gameOwnedItemsRows)
        .insertOnConflictUpdate(GameLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<GameOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.gameOwnedItemsRows,
        values.map(GameLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(GameOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
