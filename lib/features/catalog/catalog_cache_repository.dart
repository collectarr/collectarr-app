import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_derived_data_service.dart';
import 'package:collectarr_app/features/library/api/library_metadata_transport_codec.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:drift/drift.dart';

/// Persists catalog envelopes locally without interpreting kind-owned data.
final class CatalogCacheRepository {
  const CatalogCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<void> upsertMetadataItems(List<LibraryMetadataItem> items) {
    return upsertAll(items);
  }

  Future<void> upsertAll(Iterable<dynamic> items) async {
    final catalogItems = [
      for (final item in items) _asCatalogItem(item),
    ];
    if (catalogItems.isEmpty) {
      return;
    }
    final cachedAt = DateTime.now().toUtc();
    await _db.batch((batch) {
      batch.insertAll(
        _db.catalogCache,
        [
          for (final item in catalogItems)
            CatalogCacheCompanion.insert(
              id: item.id,
              kind: item.kind,
              payloadJson: jsonEncode({
                'id': item.id,
                ...item.toSyncPayload(),
              }),
              cachedAt: cachedAt,
            ),
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
    await CatalogCacheDerivedDataService(_db).capture(catalogItems);
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
        await (_db.select(_db.catalogCache)
              ..where((row) => row.id.isIn(batch)))
            .get(),
      );
    }

    return {
      for (final row in rows) row.id: _itemFromRow(row),
    };
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

  Future<CatalogItem?> findByBarcode(String barcode, {String? kind}) async {
    final compact = _compactBarcode(barcode);
    if (compact.isEmpty) {
      return null;
    }
    final query = _db.select(_db.catalogCache);
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind != null && normalizedKind.isNotEmpty) {
      query.where((row) => row.kind.equals(normalizedKind));
    }
    final rows = await query.get();
    for (final row in rows) {
      final item = _itemFromRow(row);
      if (_compactBarcode(item.barcode ?? '') == compact) {
        return item;
      }
    }
    return null;
  }

  Future<CatalogItem?> findByTitleAndIssue({
    required String title,
    required String? itemNumber,
    String? kind,
  }) async {
    final normalizedTitle = title.trim().toLowerCase();
    if (normalizedTitle.isEmpty) {
      return null;
    }
    final normalizedKind = kind?.trim().toLowerCase();
    final normalizedItemNumber = itemNumber?.trim();
    final query = _db.select(_db.catalogCache);
    if (normalizedKind != null && normalizedKind.isNotEmpty) {
      query.where((row) => row.kind.equals(normalizedKind));
    }
    final rows = await query.get();
    for (final row in rows) {
      final item = _itemFromRow(row);
      if (item.title.trim().toLowerCase() != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          item.itemNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return item;
    }
    return null;
  }

  static CatalogItem _asCatalogItem(dynamic item) {
    if (item is CatalogItem) {
      return item;
    }
    if (item is LibraryMetadataItem) {
      return LibraryMetadataTransportCodec.toCatalogItem(item);
    }
    throw ArgumentError.value(
      item,
      'item',
      'Expected a catalog item or library metadata item.',
    );
  }

  static CatalogItem _itemFromRow(CatalogCacheData row) {
    final decoded = jsonDecode(row.payloadJson);
    if (decoded is! Map) {
      throw StateError('Invalid catalog cache payload for ${row.id}.');
    }
    final payload = Map<String, dynamic>.from(decoded);
    payload['id'] ??= row.id;
    payload['kind'] ??= row.kind;
    return CatalogItem.fromJson(payload);
  }

  static String _compactBarcode(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
