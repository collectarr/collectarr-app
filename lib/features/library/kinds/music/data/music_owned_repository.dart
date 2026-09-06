import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Music-owned graph.
final class MusicOwnedRepository
    implements ReadRepository<MusicOwnedItemId, MusicOwnedItem> {
  const MusicOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MusicOwnedItem?> findById(MusicOwnedItemId id) async {
    final row = await (_db.select(_db.musicOwnedItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : MusicLocalMapper.fromOwnedItemRow(row);
  }

  Future<List<MusicOwnedItem>> listActive() async {
    final rows = await (_db.select(_db.musicOwnedItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [for (final row in rows) MusicLocalMapper.fromOwnedItemRow(row)];
  }

  Future<void> upsert(MusicOwnedItem item) {
    return _db
        .into(_db.musicOwnedItemsRows)
        .insertOnConflictUpdate(MusicLocalMapper.toOwnedItemRow(item));
  }

  Future<void> upsertAll(Iterable<MusicOwnedItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.musicOwnedItemsRows,
        values.map(MusicLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(MusicOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
