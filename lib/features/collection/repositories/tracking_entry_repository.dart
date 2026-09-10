import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_entry_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';

/// Orchestrates tracking-entry lifecycle across kind-owned persistence codecs.
///
/// The old universal tracking table is intentionally absent. Mixed Collection
/// code receives concrete entries only at the codec boundary and receives
/// structural summaries for global read projections.
class TrackingEntryRepository {
  TrackingEntryRepository(
    this._db, {
    Iterable<TrackingEntryCodec> codecs = const [],
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingEntryCodec> _codecs;

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

  Future<List<TrackingSummary>> listActiveSummaries() async {
    final entries = await listActive();
    return [
      for (final entry in entries) TrackingSummary.fromEntry(entry),
    ];
  }

  Future<List<TrackingEntry>> listActive() async {
    return _list(activeOnly: true);
  }

  Future<List<TrackingEntry>> listAll() async {
    return _list(activeOnly: false);
  }

  Future<List<TrackingEntry>> _list({required bool activeOnly}) async {
    final entries = <TrackingEntry>[];
    for (final codec in _codecs.values) {
      entries.addAll(
        await codec.listFromStorage(_db, activeOnly: activeOnly),
      );
    }
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  Future<TrackingEntry?> findByRef(TrackingEntryRef ref) {
    return _codecForKind(ref.kind).findFromStorage(_db, ref);
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

  Future<void> upsert(TrackingEntry entry) async {
    final codec = _codecForKind(entry.catalogRef.mediaKind);
    await _db.transaction(() => codec.upsertToStorage(_db, entry));
  }

  Future<void> upsertAll(List<TrackingEntry> entries) async {
    if (entries.isEmpty) return;
    await _db.transaction(() async {
      for (final entry in entries) {
        await _codecForKind(entry.catalogRef.mediaKind)
            .upsertToStorage(_db, entry);
      }
    });
  }

  Future<void> markDeleted(TrackingEntry entry, DateTime deletedAt) {
    return _codecForKind(entry.catalogRef.mediaKind)
        .markDeletedInStorage(_db, entry, deletedAt);
  }

  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
    return _codecForKind(entry.catalogRef.mediaKind).toSyncPayload(entry);
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

  TrackingEntryCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
        'No tracking-entry codec is registered for kind "${kind.apiValue}".',
      );
    }
    return codec;
  }
}
