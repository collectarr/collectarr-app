import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
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
    CatalogEntityRef releaseRef, {
    bool includeDeleted = false,
  }) async {
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
                table.targetRefJson.like('%${releaseRef.id}%') &
                (includeDeleted
                    ? const Constant(true)
                    : table.deletedAt.isNull()),
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
    for (final item in values) {
      item.validateReleaseOwnership();
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.musicOwnedItemsRows,
        values.map(MusicLocalMapper.toOwnedItemRow).toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Remaps per-copy disc details after a release's discs are reordered or
  /// removed. Unknown indexes are retained, while details for removed discs
  /// are discarded explicitly.
  Future<void> remapMediumDetails({
    required CatalogEntityRef releaseRef,
    required Map<int, int> oldToNewIndex,
    required Set<int> removedIndexes,
  }) async {
    await _db.transaction(() async {
      final copies = await listByReleaseRef(
        releaseRef,
        includeDeleted: true,
      );
      if (copies.isEmpty) return;
      final now = DateTime.now().toUtc();
      final updated = <MusicOwnedItem>[];
      for (final copy in copies) {
        final media = <MusicOwnedMediumDetails>[];
        final occupiedIndexes = <int>{};
        var changed = false;
        for (final details in copy.details.media) {
          final nextIndex = oldToNewIndex[details.mediumIndex];
          if (nextIndex == null &&
              removedIndexes.contains(details.mediumIndex)) {
            changed = true;
            continue;
          }
          final resolvedIndex = nextIndex ?? details.mediumIndex;
          if (!occupiedIndexes.add(resolvedIndex)) {
            throw StateError(
              'Music copy ${copy.id.value} has colliding disc details at '
              'index $resolvedIndex; refusing to overwrite them.',
            );
          }
          changed = changed || resolvedIndex != details.mediumIndex;
          media.add(
            MusicOwnedMediumDetails(
              mediumIndex: resolvedIndex,
              storageDevice: details.storageDevice,
              storageSlot: details.storageSlot,
              matrixRunouts: details.matrixRunouts,
            ),
          );
        }
        if (changed) {
          updated.add(
            copy.copyWith(
              details: copy.details.copyWith(media: media),
              updatedAt: now,
            ),
          );
        }
      }
      await upsertAll(updated);
    });
  }

  Future<void> markDeleted(MusicOwnedItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
