import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:drift/drift.dart';

/// Stores Core Catalog Items as complete, kind-owned flat payloads.
///
/// This cache is the local transport source for catalog reads. Personal
/// Collection Items and activity live in their separate App-owned tables.
final class CatalogItemCacheRepository {
  static const _maxIdsPerQuery = 400;

  CatalogItemCacheRepository(this._db);

  final LocalDatabase _db;

  Future<void> upsert(CatalogItemDto item) async {
    final envelope = item.toEnvelope();
    await _db.into(_db.catalogItemsCache).insertOnConflictUpdate(
          CatalogItemsCacheCompanion.insert(
            catalogKind: item.mediaKind.apiValue,
            itemId: item.id,
            payloadJson: jsonEncode(envelope.toJson()),
            fetchedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> upsertAll(Iterable<CatalogItemDto> items) async {
    final snapshot = items.toList(growable: false);
    if (snapshot.isEmpty) return;
    await _db.batch((batch) {
      for (final item in snapshot) {
        final envelope = item.toEnvelope();
        batch.insert(
          _db.catalogItemsCache,
          CatalogItemsCacheCompanion.insert(
            catalogKind: item.mediaKind.apiValue,
            itemId: item.id,
            payloadJson: jsonEncode(envelope.toJson()),
            fetchedAt: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<CatalogItemDto?> find(CatalogItemRef ref) async {
    final row = await (_db.select(_db.catalogItemsCache)
          ..where((table) =>
              table.catalogKind.equals(ref.kind.apiValue) &
              table.itemId.equals(ref.id)))
        .getSingleOrNull();
    return row == null ? null : _decode(row.payloadJson);
  }

  Future<List<CatalogItemDto>> findByRefs(Iterable<CatalogItemRef> refs) async {
    final wanted = refs.toSet();
    if (wanted.isEmpty) return const <CatalogItemDto>[];
    final byKind = <CatalogMediaKind, Set<String>>{};
    for (final ref in wanted) {
      byKind.putIfAbsent(ref.kind, () => <String>{}).add(ref.id);
    }
    final result = <CatalogItemDto>[];
    for (final entry in byKind.entries) {
      final ids = entry.value.toList(growable: false);
      for (var offset = 0; offset < ids.length; offset += _maxIdsPerQuery) {
        final end = (offset + _maxIdsPerQuery).clamp(0, ids.length);
        final chunk = ids.sublist(offset, end);
        final rows = await (_db.select(_db.catalogItemsCache)
              ..where((table) =>
                  table.catalogKind.equals(entry.key.apiValue) &
                  table.itemId.isIn(chunk)))
            .get();
        result.addAll(rows.map((row) => _decode(row.payloadJson)));
      }
    }
    return result;
  }

  Future<List<CatalogItemDto>> findAll({CatalogMediaKind? kind}) async {
    final query = _db.select(_db.catalogItemsCache);
    if (kind != null) {
      query.where((table) => table.catalogKind.equals(kind.apiValue));
    }
    final rows = await query.get();
    return rows.map((row) => _decode(row.payloadJson)).toList(growable: false);
  }

  CatalogItemDto _decode(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map) {
      throw const FormatException(
          'Cached Catalog Item payload must be an object');
    }
    return CatalogItemDto.fromJson(Map<String, dynamic>.from(decoded));
  }
}
