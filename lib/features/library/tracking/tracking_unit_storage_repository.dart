import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_codec.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';

/// Orchestrates tracking-unit lifecycle across kind-entry persistence codecs.
///
/// There is deliberately no universal tracking-unit table. This class
/// owns only mixed-feature query/mutation mechanics; each registered kind owns
/// its table, row mapper, coordinates, and concrete unit reconstruction.
class TrackingUnitStorageRepository {
  TrackingUnitStorageRepository(
    this._db, {
    required Iterable<TrackingUnitStorageCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, TrackingUnitStorageCodec> _codecs;

  Future<List<TrackingUnitSummary>> listActive() async {
    final units = <TrackingUnitSummary>[];
    for (final codec in _codecs.values) {
      units.addAll(await codec.listFromStorage(_db));
    }
    units.sort(_compareForDisplay);
    return units;
  }

  Future<List<TrackingUnitSummary>> findActiveByLibraryEntryRefs(
    Iterable<LibraryEntryRef> libraryEntryRefs,
  ) async {
    final wanted = libraryEntryRefs.toSet();
    if (wanted.isEmpty) return const <TrackingUnitSummary>[];
    return (await listActive())
        .where((unit) => wanted.contains(unit.libraryEntryRef))
        .toList(growable: false);
  }

  Future<TrackingUnitSummary?> findByRef(TrackingUnitRef ref) {
    return _codecForKind(ref.kind).findFromStorage(_db, ref);
  }

  Future<void> upsert(TrackingUnitSummary unit) async {
    _validateUnitTarget(unit);
    final codec = _codecForKind(unit.libraryEntryRef.kind);
    await _db.transaction(() => codec.upsertToStorage(_db, unit));
  }

  Future<void> upsertAll(Iterable<TrackingUnitSummary> units) async {
    final values = units.toList(growable: false);
    if (values.isEmpty) return;
    await _db.transaction(() async {
      for (final unit in values) {
        _validateUnitTarget(unit);
        await _codecForKind(unit.libraryEntryRef.kind)
            .upsertToStorage(_db, unit);
      }
    });
  }

  Future<void> markDeleted(TrackingUnitSummary unit, DateTime deletedAt) {
    return _codecForKind(unit.libraryEntryRef.kind)
        .markDeletedInStorage(_db, unit, deletedAt);
  }

  TrackingUnitStorageCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
        'No tracking-unit codec is registered for kind "${kind.apiValue}".',
      );
    }
    return codec;
  }

  void _validateUnitTarget(TrackingUnitSummary unit) {
    final entryRef = unit.libraryEntryRef;
    requireKnownLibraryEntryRef(entryRef, 'trackingUnit.libraryEntryRef');
  }

  int _compareForDisplay(TrackingUnitSummary a, TrackingUnitSummary b) {
    final itemCompare = a.libraryEntryRef.id.value
        .compareTo(b.libraryEntryRef.id.value);
    if (itemCompare != 0) return itemCompare;
    final coordinatesCompare =
        _codecs[a.libraryEntryRef.kind]?.compareCoordinates(a, b) ?? 0;
    if (coordinatesCompare != 0) return coordinatesCompare;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}
