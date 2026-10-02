import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_collection_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_collection_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Game-owned graph.
final class GameOwnedRepository
    implements ReadRepository<CollectionItemId, GameCollectionItem> {
  const GameOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<GameCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.gameCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : GameCollectionItemLocalMapper.fromRow(row);
  }

  Future<List<GameCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.gameCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) GameCollectionItemLocalMapper.fromRow(row)];
  }

  Future<void> upsert(GameCollectionItem item) {
    return _db
        .into(_db.gameCollectionItemsRows)
        .insertOnConflictUpdate(GameCollectionItemLocalMapper.toRow(item));
  }

  Future<void> upsertAll(Iterable<GameCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.gameCollectionItemsRows,
        values.map(GameCollectionItemLocalMapper.toRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(GameCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
