import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_owned_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Music-owned graph.
final class MusicOwnedRepository
    implements ReadRepository<CollectionItemId, MusicCollectionItem> {
  const MusicOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MusicCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.musicCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    return row == null ? null : MusicOwnedLocalMapper.fromCollectionItemRow(row);
  }

  Future<List<MusicCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.musicCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    return [
      for (final row in rows) MusicOwnedLocalMapper.fromCollectionItemRow(row),
    ];
  }

  /// Loads active copies for one concrete Catalog Item.
  Future<List<MusicCollectionItem>> listByCatalogRef(
    CatalogEntityRef catalogRef, {
    bool includeDeleted = false,
  }) async {
    if (catalogRef.mediaKind != CatalogMediaKind.music ||
        !catalogRef.isKnown ||
        catalogRef.entityType != CatalogEntityTypeId.catalogItem) {
      throw ArgumentError.value(
        catalogRef,
        'catalogRef',
        'Music collection items require a concrete Catalog Item reference',
      );
    }
    final rows = await (_db.select(_db.musicCollectionItemsRows)
          ..where(
            (table) =>
                table.itemId.equals(catalogRef.id) &
                (includeDeleted
                    ? const Constant(true)
                    : table.deletedAt.isNull()),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    final items = [
      for (final row in rows) MusicOwnedLocalMapper.fromCollectionItemRow(row)
    ];
    return [
      for (final item in items)
        if (item.catalogRef == catalogRef) item
    ];
  }

  Future<void> upsert(MusicCollectionItem item) {
    item.validateCatalogItemOwnership();
    return _db
        .into(_db.musicCollectionItemsRows)
        .insertOnConflictUpdate(MusicOwnedLocalMapper.toCollectionItemRow(item));
  }

  Future<void> upsertAll(Iterable<MusicCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    for (final item in values) {
      item.validateCatalogItemOwnership();
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.musicCollectionItemsRows,
        values
            .map(MusicOwnedLocalMapper.toCollectionItemRow)
            .toList(growable: false),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Remaps per-copy disc details after an item's discs are reordered or
  /// removed. Unknown indexes are retained, while details for removed discs
  /// are discarded explicitly.
  Future<void> remapMediumDetails({
    required CatalogEntityRef catalogRef,
    required Map<int, int> oldToNewIndex,
    required Set<int> removedIndexes,
  }) async {
    await _db.transaction(() async {
      final copies = await listByCatalogRef(
        catalogRef,
        includeDeleted: true,
      );
      if (copies.isEmpty) return;
      final now = DateTime.now().toUtc();
      final updated = <MusicCollectionItem>[];
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
              mediaCondition: details.mediaCondition,
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

  Future<void> markDeleted(MusicCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
