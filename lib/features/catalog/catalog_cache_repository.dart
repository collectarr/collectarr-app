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
              thumbnailImageUrl: Value(item.thumbnailImageUrl),
              editionTitle: Value(item.editionTitle),
              physicalFormat: Value(item.physicalFormat),
              physicalFormatLabel: Value(item.physicalFormatLabel),
              publisher: Value(item.publisher),
              releaseDate: Value(item.releaseDate),
              releaseYear: Value(item.releaseYear),
              barcode: Value(item.barcode),
              variant: Value(item.variant),
              seriesId: Value(item.seriesId),
              seriesTitle: Value(item.seriesTitle),
              volumeName: Value(item.volumeName),
              volumeNumber: Value(item.volumeNumber),
              volumeStartYear: Value(item.volumeStartYear),
              seasonNumber: Value(item.seasonNumber),
              episodeNumber: Value(item.episodeNumber),
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
          thumbnailImageUrl: row.thumbnailImageUrl,
          editionTitle: row.editionTitle,
          physicalFormat: row.physicalFormat,
          physicalFormatLabel: row.physicalFormatLabel,
          publisher: row.publisher,
          releaseDate: row.releaseDate,
          releaseYear: row.releaseYear,
          barcode: row.barcode,
          variant: row.variant,
          seriesId: row.seriesId,
          seriesTitle: row.seriesTitle,
          volumeName: row.volumeName,
          volumeNumber: row.volumeNumber,
          volumeStartYear: row.volumeStartYear,
          seasonNumber: row.seasonNumber,
          episodeNumber: row.episodeNumber,
        ),
    };
  }

  Future<CatalogItem?> findByBarcode(String barcode, {String? kind}) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final query = _db.select(_db.catalogCache);
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind != null && normalizedKind.isNotEmpty) {
      query.where((row) => row.kind.equals(normalizedKind));
    }
    final compact = _compactBarcode(normalized);
    final rows = await query.get();
    final row = rows.cast<CatalogCacheData?>().firstWhere(
          (row) =>
              row != null &&
              row.barcode != null &&
              _compactBarcode(row.barcode!) == compact,
          orElse: () => null,
        );
    return row == null ? null : _itemFromRow(row);
  }

  Future<CatalogItem?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final row = await (_db.select(_db.catalogCache)
          ..where((row) => row.id.equals(normalized))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _itemFromRow(row);
  }

  Future<CatalogItem?> findByTitleAndIssue({
    required String title,
    required String? itemNumber,
    String? kind,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return null;
    }
    final query = _db.select(_db.catalogCache)
      ..where((row) => row.title.equals(normalizedTitle));
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind != null && normalizedKind.isNotEmpty) {
      query.where((row) => row.kind.equals(normalizedKind));
    }
    final normalizedIssue = itemNumber?.trim();
    if (normalizedIssue != null && normalizedIssue.isNotEmpty) {
      query.where((row) => row.itemNumber.equals(normalizedIssue));
    }
    query.limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _itemFromRow(row);
  }

  CatalogItem _itemFromRow(CatalogCacheData row) {
    return CatalogItem(
      id: row.id,
      kind: row.kind,
      title: row.title,
      itemNumber: row.itemNumber,
      synopsis: row.synopsis,
      coverImageUrl: row.coverImageUrl,
      thumbnailImageUrl: row.thumbnailImageUrl,
      editionTitle: row.editionTitle,
      physicalFormat: row.physicalFormat,
      physicalFormatLabel: row.physicalFormatLabel,
      publisher: row.publisher,
      releaseDate: row.releaseDate,
      releaseYear: row.releaseYear,
      barcode: row.barcode,
      variant: row.variant,
      seriesId: row.seriesId,
      seriesTitle: row.seriesTitle,
      volumeName: row.volumeName,
      volumeNumber: row.volumeNumber,
      volumeStartYear: row.volumeStartYear,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
    );
  }

  String _compactBarcode(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
