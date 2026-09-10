import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit.dart';
import 'package:drift/drift.dart';

final class TvTrackingUnitCodec implements TrackingUnitCodec {
  const TvTrackingUnitCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<List<TrackingUnitSummary>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  }) async {
    final query = db.select(db.tvTrackingUnitRows);
    if (activeOnly) query.where((row) => row.deletedAt.isNull());
    final rows = await query.get();
    final coordinates = await loadCoordinates(db, rows.map((row) => row.id));
    return [
      for (final row in rows)
        fromStorageRow(
          trackingUnitStorageRowFromColumns(
            id: row.id,
            targetRefJson: row.targetRefJson,
            trackingEntryId: row.trackingEntryId,
            ownedItemId: row.ownedItemId,
            unitType: row.unitType,
            completedAt: row.completedAt,
            updatedAt: row.updatedAt,
            deletedAt: row.deletedAt,
          ),
          coordinates[row.id],
        ),
    ];
  }

  @override
  Future<TrackingUnitSummary?> findFromStorage(
    LocalDatabase db,
    TrackingUnitRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final row = await (db.select(db.tvTrackingUnitRows)
          ..where((item) => item.id.equals(ref.id)))
        .getSingleOrNull();
    if (row == null) return null;
    final coordinates = await loadCoordinates(db, [row.id]);
    return fromStorageRow(
      trackingUnitStorageRowFromColumns(
        id: row.id,
        targetRefJson: row.targetRefJson,
        trackingEntryId: row.trackingEntryId,
        ownedItemId: row.ownedItemId,
        unitType: row.unitType,
        completedAt: row.completedAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      ),
      coordinates[row.id],
    );
  }

  @override
  Future<void> upsertToStorage(LocalDatabase db, TrackingUnitSummary unit) {
    return _writeCoordinates(db, unit);
  }

  @override
  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingUnitSummary unit,
    DateTime deletedAt,
  ) async {
    await (db.update(db.tvTrackingUnitRows)
          ..where((row) => row.id.equals(unit.id)))
        .write(
      TvTrackingUnitRowsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  Future<void> _writeCoordinates(
      LocalDatabase db, TrackingUnitSummary unit) async {
    if (unit case final TvTrackingUnit video) {
      await db.into(db.tvTrackingUnitRows).insertOnConflictUpdate(
            TvTrackingUnitRowsCompanion.insert(
              id: unit.id,
              targetRefJson: jsonEncode(unit.targetRef.toJson()),
              trackingEntryId: Value(unit.trackingEntryId),
              ownedItemId: Value(unit.ownedRef?.key),
              unitType: unit.unitType,
              completedAt: unit.completedAt,
              updatedAt: unit.updatedAt,
              deletedAt: Value(unit.deletedAt),
              seasonNumber: Value(video.seasonNumber),
              episodeNumber: Value(video.episodeNumber),
            ),
          );
    }
  }

  @override
  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  ) async {
    final selectedIds = ids?.toSet().toList(growable: false);
    if (selectedIds != null && selectedIds.isEmpty) {
      return const {};
    }
    final rows = selectedIds == null
        ? await db.select(db.tvTrackingUnitRows).get()
        : await (db.select(db.tvTrackingUnitRows)
              ..where((row) => row.id.isIn(selectedIds)))
            .get();
    return {
      for (final row in rows)
        row.id: _TvCoordinates(
          seasonNumber: row.seasonNumber,
          episodeNumber: row.episodeNumber,
        ),
    };
  }

  @override
  TrackingUnitSummary fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  ) {
    final typedCoordinates =
        coordinates is _TvCoordinates ? coordinates : const _TvCoordinates();
    return TvTrackingUnit(
      id: row.id,
      targetRef: row.targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedRef: row.ownedRef,
      seasonNumber: typedCoordinates.seasonNumber,
      episodeNumber: typedCoordinates.episodeNumber,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  @override
  int compareCoordinates(TrackingUnitSummary left, TrackingUnitSummary right) {
    if (left is! TvTrackingUnit || right is! TvTrackingUnit) {
      return 0;
    }
    final season = _compareNullableInt(left.seasonNumber, right.seasonNumber);
    if (season != 0) return season;
    return _compareNullableInt(left.episodeNumber, right.episodeNumber);
  }
}

final class _TvCoordinates {
  const _TvCoordinates({this.seasonNumber, this.episodeNumber});

  final int? seasonNumber;
  final int? episodeNumber;
}

int _compareNullableInt(int? left, int? right) {
  return (left ?? 0).compareTo(right ?? 0);
}
