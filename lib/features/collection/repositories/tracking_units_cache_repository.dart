import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';

/// Orchestrates tracking-unit lifecycle across kind-owned persistence codecs.
///
/// There is deliberately no universal TrackingUnitsCache table. This class
/// owns only mixed-feature query/mutation mechanics; each registered kind owns
/// its table, row mapper, coordinates, and concrete unit reconstruction.
class TrackingUnitsCacheRepository {
  TrackingUnitsCacheRepository(
    this._db, {
    required Iterable<TrackingUnitCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingUnitCodec> _codecs;

  Future<List<TrackingUnit>> listActive() async {
    final units = <TrackingUnit>[];
    for (final codec in _codecs.values) {
      units.addAll(await codec.listFromStorage(_db));
    }
    units.sort(_compareForDisplay);
    return units;
  }

  Future<List<TrackingUnit>> findActiveByCatalogRefs(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final wanted = catalogRefs.toSet();
    if (wanted.isEmpty) return const <TrackingUnit>[];
    return (await listActive())
        .where((unit) => wanted.contains(unit.targetRef))
        .toList(growable: false);
  }

  Future<TrackingUnit?> findByRef(TrackingUnitRef ref) {
    return _codecForKind(ref.kind).findFromStorage(_db, ref);
  }

  Future<void> upsert(TrackingUnit unit) async {
    final codec = _codecForKind(unit.targetRef.mediaKind);
    await _db.transaction(() => codec.upsertToStorage(_db, unit));
  }

  Future<void> upsertAll(Iterable<TrackingUnit> units) async {
    final values = units.toList(growable: false);
    if (values.isEmpty) return;
    await _db.transaction(() async {
      for (final unit in values) {
        await _codecForKind(unit.targetRef.mediaKind)
            .upsertToStorage(_db, unit);
      }
    });
  }

  Future<void> markDeleted(TrackingUnit unit, DateTime deletedAt) {
    return _codecForKind(unit.targetRef.mediaKind)
        .markDeletedInStorage(_db, unit, deletedAt);
  }

  TrackingUnitCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
        'No tracking-unit codec is registered for kind "${kind.apiValue}".',
      );
    }
    return codec;
  }

  int _compareForDisplay(TrackingUnit a, TrackingUnit b) {
    final itemCompare = (a.targetRef.rootId ?? a.targetRef.id)
        .compareTo(b.targetRef.rootId ?? b.targetRef.id);
    if (itemCompare != 0) return itemCompare;
    final typeCompare = a.unitType.compareTo(b.unitType);
    if (typeCompare != 0) return typeCompare;
    final coordinatesCompare =
        _codecs[a.targetRef.mediaKind]?.compareCoordinates(a, b) ?? 0;
    if (coordinatesCompare != 0) return coordinatesCompare;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}
