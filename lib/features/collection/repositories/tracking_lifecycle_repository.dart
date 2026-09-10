import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';

/// Orchestrates tracking-entry lifecycle across kind-owned persistence codecs.
///
/// The old universal tracking table is intentionally absent. Mixed Collection
/// code receives concrete entries only at the codec boundary and receives
/// structural summaries for global read projections.
class TrackingLifecycleRepository {
  TrackingLifecycleRepository(
    this._db, {
    Iterable<TrackingLifecycleCodec> codecs = const [],
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingLifecycleCodec> _codecs;

  TrackingLifecycle create({
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
      for (final entry in entries) TrackingSummary.fromLifecycle(entry),
    ];
  }

  Future<List<TrackingLifecycle>> listActive() async {
    return _list(activeOnly: true);
  }

  Future<List<TrackingLifecycle>> listAll() async {
    return _list(activeOnly: false);
  }

  Future<List<TrackingLifecycle>> _list({required bool activeOnly}) async {
    final entries = <TrackingLifecycle>[];
    for (final codec in _codecs.values) {
      entries.addAll(
        await codec.listFromStorage(_db, activeOnly: activeOnly),
      );
    }
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  Future<TrackingLifecycle?> findByRef(TrackingLifecycleRef ref) {
    return _codecForKind(ref.kind).findFromStorage(_db, ref);
  }

  Future<List<TrackingLifecycle>> findActiveByCatalogRefs(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = catalogRefs.toSet();
    if (wanted.isEmpty) return const [];
    return (await listActive())
        .where((entry) => wanted.contains(entry.catalogRef))
        .toList(growable: false);
  }

  Future<List<TrackingLifecycle>> findActiveByCatalogRoots(
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

  Future<void> upsert(TrackingLifecycle entry) async {
    final codec = _codecForKind(entry.catalogRef.mediaKind);
    await _db.transaction(() => codec.upsertToStorage(_db, entry));
  }

  Future<void> upsertAll(List<TrackingLifecycle> entries) async {
    if (entries.isEmpty) return;
    await _db.transaction(() async {
      for (final entry in entries) {
        await _codecForKind(entry.catalogRef.mediaKind)
            .upsertToStorage(_db, entry);
      }
    });
  }

  Future<void> markDeleted(TrackingLifecycle entry, DateTime deletedAt) {
    return _codecForKind(entry.catalogRef.mediaKind)
        .markDeletedInStorage(_db, entry, deletedAt);
  }

  Map<String, dynamic> toSyncPayload(TrackingLifecycle entry) {
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

  TrackingLifecycleCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
        'No tracking-entry codec is registered for kind "${kind.apiValue}".',
      );
    }
    return codec;
  }
}
