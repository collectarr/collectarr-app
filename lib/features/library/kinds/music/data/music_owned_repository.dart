import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
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

  /// Loads active copies for one concrete release without scanning every
  /// Music copy into the UI layer.
  Future<List<MusicOwnedItem>> listByReleaseRef(
    CatalogEntityRef releaseRef,
  ) async {
    if (releaseRef.mediaKind != CatalogMediaKind.music ||
        releaseRef.entityType.apiValue != 'release') {
      throw ArgumentError.value(
        releaseRef,
        'releaseRef',
        'Music owned copies require a concrete release reference',
      );
    }
    final rows = await (_db.select(_db.musicOwnedItemsRows)
          ..where(
            (table) =>
                table.deletedAt.isNull() &
                table.targetRefJson.like('%${releaseRef.id}%'),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    final items = [
      for (final row in rows) MusicLocalMapper.fromOwnedItemRow(row)
    ];
    return [
      for (final item in items)
        if (item.releaseRef == releaseRef) item
    ];
  }

  Future<void> upsert(MusicOwnedItem item) {
    item.validateReleaseOwnership();
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
