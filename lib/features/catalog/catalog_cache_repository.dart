import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:drift/drift.dart';

class CatalogCacheRepository {
  const CatalogCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<void> upsertAll(List<CatalogItem> items) async {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    await _db.batch((batch) {
      batch.insertAll(
        _db.catalogCache,
        [
          for (final item in items)
            CatalogCacheCompanion.insert(
              id: item.id,
              kind: item.kind,
              title: item.title,
              itemNumber: Value(item.itemNumber),
              synopsis: Value(item.synopsis),
              coverImageUrl: Value(item.coverImageUrl),
              publisher: Value(item.publisher),
              releaseYear: Value(item.releaseYear),
              cachedAt: now,
            ),
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<Map<String, CatalogItem>> findByIds(Iterable<String> ids) async {
    final values = ids.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const {};
    }

    final rows = <CatalogCacheData>[];
    for (var index = 0; index < values.length; index += _lookupBatchSize) {
      final end = (index + _lookupBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      rows.addAll(
        await (_db.select(_db.catalogCache)..where((row) => row.id.isIn(batch)))
            .get(),
      );
    }

    return {
      for (final row in rows)
        row.id: CatalogItem(
          id: row.id,
          kind: row.kind,
          title: row.title,
          itemNumber: row.itemNumber,
          synopsis: row.synopsis,
          coverImageUrl: row.coverImageUrl,
          thumbnailImageUrl: null,
          publisher: row.publisher,
          releaseYear: row.releaseYear,
        ),
    };
  }
}
