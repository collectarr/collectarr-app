import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_entry_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';
import 'package:drift/drift.dart';

class TrackingEntriesCacheRepository {
  TrackingEntriesCacheRepository(
    this._db, {
    Iterable<TrackingEntryCodec> codecs = const [],
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingEntryCodec> _codecs;

  /// Creates the concrete tracking aggregate owned by [catalogRef]'s kind.
  ///
  /// The mixed Collection feature may orchestrate lifecycle mutations, but it
  /// must not instantiate the common tracking compatibility model.
  TrackingEntry create({
    required String id,
    required CatalogEntityRef catalogRef,
    OwnedItemRef? ownedRef,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    return _codecForKind(catalogRef.mediaKind).create(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedRef,
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: notes,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  /// Reads only the structural lifecycle projection required by mixed/global
  /// screens. It deliberately does not load kind-owned coordinate tables or
  /// reconstruct a [TrackingEntry] aggregate.
  Future<List<TrackingSummary>> listActiveSummaries() async {
    final rows = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return [
      for (final row in rows)
        TrackingSummary(
          id: row.id,
          catalogRef: _catalogRefForRow(row),
          ownedRef: ownedItemRefFromSerialized(row.ownedItemId),
          sourceType: trackingSourceTypeFromValue(row.sourceType),
          status: mediaTrackingStatusFromValue(row.status) ??
              MediaTrackingStatus.none,
          rating: row.rating,
          startedAt: row.startedAt,
          completedAt: row.finishedAt,
          notes: row.notes,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
    ];
  }

  Future<List<TrackingEntry>> listActive() async {
    final rows = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    if (rows.isEmpty) return const [];
    final coordinates = await _loadCoordinates(rows.map((row) => row.id));
    return rows
        .map((r) => _fromCache(r, coordinates[r.id]))
        .toList(growable: false);
  }

  Future<TrackingEntry?> findByRef(TrackingEntryRef ref) async {
    final row = await (_db.select(_db.trackingEntriesCache)
          ..where(
            (row) => row.id.equals(ref.id) & row.kind.equals(ref.kind.apiValue),
          )
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    final coordinates = await _loadCoordinates([row.id]);
    return _fromCache(row, coordinates[row.id]);
  }

  Future<List<TrackingEntry>> findActiveByCatalogRefs(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = catalogRefs.toSet();
    if (wanted.isEmpty) return const [];
    return (await listActive())
        .where((entry) => wanted.contains(entry.catalogRef))
        .toList(growable: false);
  }

  Future<List<TrackingEntry>> findActiveByCatalogRoots(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = {
      for (final ref in catalogRefs) _rootCatalogRef(ref),
    };
    if (wanted.isEmpty) return const [];
    return (await listActive())
        .where((entry) => wanted.contains(_rootCatalogRef(entry.catalogRef)))
        .toList(growable: false);
  }

  Future<void> upsert(TrackingEntry item) async {
    await _db.transaction(() async {
      await _db.into(_db.trackingEntriesCache).insert(
            _toCompanion(item),
            mode: InsertMode.insertOrReplace,
          );
      await _replaceCoordinates(item);
    });
  }

  Future<void> upsertAll(List<TrackingEntry> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(
          _db.trackingEntriesCache,
          items.map(_toCompanion),
          mode: InsertMode.insertOrReplace,
        );
      });
      for (final item in items) {
        await _replaceCoordinates(item);
      }
    });
  }

  Future<void> markDeleted(TrackingEntry item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }

  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
    final codec = _codecForKind(entry.catalogRef.mediaKind);
    return codec.toSyncPayload(entry);
  }

  TrackingEntry _fromCache(
    TrackingEntriesCacheData row,
    Object? coordinates,
  ) {
    final storageRow = TrackingEntryStorageRow(
      id: row.id,
      catalogRef: _catalogRefForRow(row),
      ownedRef: ownedItemRefFromSerialized(row.ownedItemId),
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
    return _codecForKind(catalogMediaKindFromApiValue(row.kind))
        .fromStorageRow(storageRow, coordinates);
  }

  TrackingEntriesCacheCompanion _toCompanion(TrackingEntry item) {
    return TrackingEntriesCacheCompanion.insert(
      id: item.id,
      kind: item.catalogRef.kind.apiValue,
      catalogRefJson: jsonEncode(item.catalogRef.toJson()),
      ownedItemId: Value(item.ownedRef?.key),
      sourceType: Value(item.sourceTypeApiValue),
      status: Value(item.statusStorageValue),
      rating: Value(item.rating),
      startedAt: Value(item.startedAt),
      finishedAt: Value(item.finishedAt),
      progressCurrent: Value(item.progressCurrent),
      progressTotal: Value(item.progressTotal),
      timesCompleted: Value(item.timesCompleted),
      notes: Value(item.notes),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }

  Future<void> _replaceCoordinates(TrackingEntry item) async {
    for (final codec in _codecs.values) {
      await codec.clearCoordinates(_db, item.id);
    }
    await _codecForKind(item.catalogRef.mediaKind).writeCoordinates(_db, item);
  }

  Future<Map<String, Object?>> _loadCoordinates([
    Iterable<String>? ids,
  ]) async {
    final coordinates = <String, Object?>{};
    for (final codec in _codecs.values) {
      coordinates.addAll(await codec.loadCoordinates(_db, ids));
    }
    return coordinates;
  }

  CatalogEntityRef _rootCatalogRef(CatalogEntityRef ref) {
    final rootId = ref.rootId;
    if (rootId != null && rootId.isNotEmpty) {
      return ref.copyWith(
        id: rootId,
        entityType: const CatalogEntityTypeId('work'),
        rootId: null,
        parentId: null,
      );
    }
    if (ref.entityType != const CatalogEntityTypeId('work')) {
      return ref.copyWith(
        entityType: const CatalogEntityTypeId('work'),
        parentId: null,
      );
    }
    return ref;
  }

  CatalogEntityRef _catalogRefForRow(TrackingEntriesCacheData row) {
    final raw = row.catalogRefJson.trim();
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw FormatException('Tracking entry catalog_ref is invalid: $raw');
    }
    return CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded));
  }

  TrackingEntryCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
          'No tracking-entry codec is registered for kind "${kind.apiValue}".');
    }
    return codec;
  }
}
