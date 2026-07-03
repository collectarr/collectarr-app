import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:drift/drift.dart';

class TrackingEntriesCacheRepository {
  const TrackingEntriesCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<List<TrackingEntry>> listActive() async {
    final rows = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(_fromCache).toList(growable: false);
  }

  Future<TrackingEntry?> findById(String id) async {
    final row = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromCache(row);
  }

  Future<List<TrackingEntry>> findActiveByItemIds(Iterable<String> itemIds) async {
    final values = itemIds.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const [];
    }
    final items = <TrackingEntry>[];
    for (var index = 0; index < values.length; index += _lookupBatchSize) {
      final end = (index + _lookupBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      final rows = await (_db.select(_db.trackingEntriesCache)
            ..where(
              (row) => row.itemId.isIn(batch) & row.deletedAt.isNull(),
            ))
          .get();
      items.addAll(rows.map(_fromCache));
    }
    return items;
  }

  Future<void> upsert(TrackingEntry item) {
    return _db.into(_db.trackingEntriesCache).insert(
          _toCompanion(item),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> upsertAll(List<TrackingEntry> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.trackingEntriesCache,
        items.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(TrackingEntry item, DateTime deletedAt) {
    return _db.into(_db.trackingEntriesCache).insert(
          _toCompanion(
            item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  TrackingEntry _fromCache(TrackingEntriesCacheData row) {
    return TrackingEntry(
      id: row.id,
      catalogRef: _catalogRefForRow(row),
      itemId: row.itemId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      episodeRatings: _decodeEpisodeRatings(row.episodeRatings),
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  TrackingEntriesCacheCompanion _toCompanion(TrackingEntry item) {
    return TrackingEntriesCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      ownedItemId: Value(item.ownedItemId),
      editionId: Value(item.editionId),
      variantId: Value(item.variantId),
      bundleReleaseId: Value(item.bundleReleaseId),
      sourceType: Value(item.sourceTypeApiValue),
      status: Value(item.statusStorageValue),
      rating: Value(item.rating),
      startedAt: Value(item.startedAt),
      finishedAt: Value(item.finishedAt),
      progressCurrent: Value(item.progressCurrent),
      progressTotal: Value(item.progressTotal),
      timesCompleted: Value(item.timesCompleted),
      notes: Value(item.notes),
      seasonNumber: Value(item.seasonNumber),
      episodeNumber: Value(item.episodeNumber),
      episodeRatings: Value(_encodeEpisodeRatings(item.episodeRatings)),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }

  CatalogEntityRef _catalogRefForRow(TrackingEntriesCacheData row) {
    final anchor = PersonalItemAnchor.fromRaw(
      anchorType: row.sourceType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
    );
    final entityType = row.seasonNumber != null || row.episodeNumber != null
        ? CatalogEntityType.episode
        : switch (anchor?.type) {
            PersonalItemAnchorType.bundleRelease => CatalogEntityType.release,
            PersonalItemAnchorType.variant => CatalogEntityType.release,
            PersonalItemAnchorType.edition => CatalogEntityType.edition,
            _ => CatalogEntityType.work,
          };
    return CatalogEntityRef(
      kind: 'unknown',
      entityType: entityType,
      id: row.itemId,
    );
  }

  static Map<String, int>? _decodeEpisodeRatings(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k as String, (v as num).toInt()));
      }
    } catch (_) {
      // Malformed JSON in episode ratings is non-critical; fall through to null.
    }
    return null;
  }

  static String? _encodeEpisodeRatings(Map<String, int> ratings) {
    if (ratings.isEmpty) return null;
    return jsonEncode(ratings);
  }
}