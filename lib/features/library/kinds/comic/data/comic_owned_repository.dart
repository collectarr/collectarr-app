import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:drift/drift.dart';

/// Persistence for the complete Comic-owned graph.
final class ComicOwnedRepository
    implements ReadRepository<CollectionItemId, ComicCollectionItem> {
  const ComicOwnedRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<ComicCollectionItem?> findById(CollectionItemId id) async {
    final row = await (_db.select(_db.comicCollectionItemsRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row == null) return null;
    final readingRow = await (_db.select(_db.comicReadingRows)
          ..where((table) => table.collectionItemRefKey.equals(CollectionItemRef(
                kind: CatalogMediaKind.comic,
                id: CollectionItemId(id.value),
              ).key)))
        .getSingleOrNull();
    return ComicLocalMapper.fromCollectionItemRow(
      row,
      reading: readingRow == null
          ? const ComicReadingState()
          : ComicLocalMapper.fromReadingRow(readingRow),
    );
  }

  Future<List<ComicCollectionItem>> listActive() async {
    final rows = await (_db.select(_db.comicCollectionItemsRows)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
    final result = <ComicCollectionItem>[];
    for (final row in rows) {
      final item = await findById(CollectionItemId(row.id));
      if (item != null) result.add(item);
    }
    return result;
  }

  Future<void> upsert(ComicCollectionItem item) async {
    await _db.transaction(() async {
      await _db
          .into(_db.comicCollectionItemsRows)
          .insertOnConflictUpdate(ComicLocalMapper.toCollectionItemRow(item));
      await _db
          .into(_db.comicReadingRows)
          .insertOnConflictUpdate(ComicLocalMapper.toReadingRow(item));
    });
  }

  Future<void> upsertAll(Iterable<ComicCollectionItem> items) async {
    final values = items.toList(growable: false);
    if (values.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(
          _db.comicCollectionItemsRows,
          values.map(ComicLocalMapper.toCollectionItemRow).toList(growable: false),
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          _db.comicReadingRows,
          values.map(ComicLocalMapper.toReadingRow).toList(growable: false),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> markDeleted(ComicCollectionItem item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }
}
