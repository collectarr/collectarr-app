import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:drift/drift.dart';

final class TvTrackingUnitCodec implements TrackingUnitCodec {
  const TvTrackingUnitCodec();

  @override
  String get kind => 'tv';

  @override
  Future<void> clearCoordinates(LocalDatabase db, String id) async {
    await (db.delete(db.tvTrackingUnitRows)..where((row) => row.id.equals(id)))
        .go();
  }

  @override
  Future<void> writeCoordinates(LocalDatabase db, TrackingUnit unit) async {
    if (unit case final VideoTrackingUnit video) {
      await db.into(db.tvTrackingUnitRows).insertOnConflictUpdate(
            TvTrackingUnitRowsCompanion.insert(
              id: unit.id,
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
  TrackingUnit fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  ) {
    final typedCoordinates =
        coordinates is _TvCoordinates ? coordinates : const _TvCoordinates();
    return VideoTrackingUnit(
      id: row.id,
      targetRef: row.targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      unitType: row.unitType,
      seasonNumber: typedCoordinates.seasonNumber,
      episodeNumber: typedCoordinates.episodeNumber,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  @override
  int compareCoordinates(TrackingUnit left, TrackingUnit right) {
    if (left is! VideoTrackingUnit || right is! VideoTrackingUnit) {
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
