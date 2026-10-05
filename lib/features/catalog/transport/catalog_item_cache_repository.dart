import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:drift/drift.dart';

/// Stores Core snapshots and short-lived private Add candidates.
///
/// Complete local Library Entries live in LibraryEntryStore and are never
/// read through a Core Catalog Item reference. Private candidates are removed
/// from this cache after Add persists the independent local entry.
final class CatalogItemCacheRepository {
  static const _maxIdsPerQuery = 400;
  static const _maxCachedCoreItems = 5000;

  CatalogItemCacheRepository(this._db);

  final LocalDatabase _db;

  Future<void> upsert(CatalogItemDto item, {bool force = false}) async {
    final existing = await find(item.catalogItemRef);
    if (!_acceptIncoming(item, existing, force: force)) return;
    final envelope = item.toEnvelope();
    await _db.into(_db.catalogItemsCache).insertOnConflictUpdate(
          CatalogItemsCacheCompanion.insert(
            catalogKind: item.mediaKind.apiValue,
            itemId: item.id,
            origin: Value(item.origin.name),
            payloadJson: jsonEncode(envelope.toJson()),
            fetchedAt: DateTime.now().toUtc(),
          ),
        );
    await _trimCoreCache();
  }

  /// Removes a transient private candidate after Add has copied its catalog
  /// fields into the complete local Library Entry record.
  ///
  /// Core-owned rows are never removed by this operation.
  Future<void> removePrivateCandidate(CatalogItemRef ref) async {
    await (_db.delete(_db.catalogItemsCache)
          ..where((row) =>
              row.catalogKind.equals(ref.kind.apiValue) &
              row.itemId.equals(ref.id) &
              row.origin.equals(CatalogItemOrigin.privateLocal.name)))
        .go();
  }

  Future<void> upsertAll(
    Iterable<CatalogItemDto> items, {
    bool force = false,
  }) async {
    final snapshot = <CatalogItemDto>[];
    snapshot.addAll(items);
    if (snapshot.isEmpty) return;
    final cachedItems = await findByRefs(
      snapshot.map((item) => item.catalogItemRef),
    );
    final cachedByRef = {
      for (final item in cachedItems) item.catalogItemRef: item
    };
    final accepted = [
      for (final item in snapshot)
        if (_acceptIncoming(
          item,
          cachedByRef[item.catalogItemRef],
          force: force,
        ))
          item,
    ];
    if (accepted.isEmpty) return;
    await _db.batch((batch) {
      for (final item in accepted) {
        final envelope = item.toEnvelope();
        batch.insert(
          _db.catalogItemsCache,
          CatalogItemsCacheCompanion.insert(
            catalogKind: item.mediaKind.apiValue,
            itemId: item.id,
            origin: Value(item.origin.name),
            payloadJson: jsonEncode(envelope.toJson()),
            fetchedAt: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    await _trimCoreCache();
  }

  Future<CatalogItemDto?> find(CatalogItemRef ref) async {
    final row = await (_db.select(_db.catalogItemsCache)
          ..where((table) =>
              table.catalogKind.equals(ref.kind.apiValue) &
              table.itemId.equals(ref.id)))
        .getSingleOrNull();
    return row == null ? null : _decode(row.payloadJson, row.origin);
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
        result.addAll(rows.map((row) => _decode(row.payloadJson, row.origin)));
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
    final cached = rows
        .map((row) => _decode(row.payloadJson, row.origin))
        .toList(growable: false);
    return cached;
  }

  CatalogItemDto _decode(String payloadJson, String origin) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map) {
      throw const FormatException(
          'Cached Catalog Item payload must be an object');
    }
    final item = CatalogItemDto.fromJson(Map<String, dynamic>.from(decoded));
    final parsedOrigin = CatalogItemOrigin.values.where(
      (value) => value.name == origin,
    );
    if (parsedOrigin.isEmpty) {
      throw FormatException('Unknown cached Catalog Item origin "$origin".');
    }
    return item.withOrigin(parsedOrigin.first);
  }

  bool _acceptIncoming(
    CatalogItemDto incoming,
    CatalogItemDto? existing, {
    required bool force,
  }) {
    if (force) return true;
    if (existing == null) return true;
    if (incoming.origin != existing.origin) {
      return incoming.origin == CatalogItemOrigin.core;
    }
    final incomingRevision = _revision(incoming);
    final existingRevision = _revision(existing);
    if (incomingRevision != null &&
        existingRevision != null &&
        incomingRevision != existingRevision) {
      return incomingRevision > existingRevision;
    }
    // Search responses may be summaries. With no revision to order them,
    // accept only a payload that adds information; never replace an equally
    // complete item whose request completed later.
    return _completeness(incoming.kindData) > _completeness(existing.kindData);
  }

  int? _revision(CatalogItemDto item) => item.kindData['revision'] is int
      ? item.kindData['revision'] as int
      : null;

  int _completeness(Object? value) {
    if (value == null) return 0;
    if (value is String) return value.trim().isEmpty ? 0 : 1;
    if (value is num || value is bool) return 1;
    if (value is Iterable) {
      return value.fold<int>(
          0, (score, entry) => score + 1 + _completeness(entry));
    }
    if (value is Map) {
      var score = 0;
      for (final entry in value.entries) {
        if (const {'id', 'kind', 'revision', 'snapshot_version'}
            .contains(entry.key)) {
          continue;
        }
        final childScore = _completeness(entry.value);
        if (childScore > 0) score += 1 + childScore;
      }
      return score;
    }
    return 0;
  }

  /// Bounds the remote catalog cache without evicting locally owned entries.
  /// Owned entries are stored independently in [LibraryEntryStore] and remain
  /// visible offline when their corresponding Core snapshot is evicted.
  Future<void> _trimCoreCache() async {
    final table = _db.catalogItemsCache;
    final countExpression = table.catalogKind.count();
    final count = await (_db.selectOnly(table)
          ..addColumns([countExpression])
          ..where(table.origin.equals(CatalogItemOrigin.core.name)))
        .map((row) => row.read(countExpression) ?? 0)
        .getSingle();
    final excess = count - _maxCachedCoreItems;
    if (excess <= 0) return;

    final oldest = await (_db.select(table)
          ..where((row) => row.origin.equals(CatalogItemOrigin.core.name))
          ..orderBy([
            (row) => OrderingTerm.asc(row.fetchedAt),
            (row) => OrderingTerm.asc(row.catalogKind),
            (row) => OrderingTerm.asc(row.itemId),
          ])
          ..limit(excess))
        .get();
    await _db.transaction(() async {
      for (final row in oldest) {
        await (_db.delete(table)
              ..where((candidate) =>
                  candidate.catalogKind.equals(row.catalogKind) &
                  candidate.itemId.equals(row.itemId)))
            .go();
      }
    });
  }
}
