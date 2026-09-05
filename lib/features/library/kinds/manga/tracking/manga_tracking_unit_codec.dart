import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit.dart';
import 'package:drift/drift.dart';

final class MangaTrackingUnitCodec implements TrackingUnitCodec {
  const MangaTrackingUnitCodec();

  @override
  String get kind => 'manga';

  @override
  Future<void> clearCoordinates(LocalDatabase db, String id) async {
    await (db.delete(db.mangaTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  @override
  Future<void> writeCoordinates(LocalDatabase db, TrackingUnit unit) async {
    if (unit case final MangaTrackingUnit reading) {
      await db.into(db.mangaTrackingUnitRows).insertOnConflictUpdate(
            MangaTrackingUnitRowsCompanion.insert(
              id: unit.id,
              volumeNumber: Value(reading.volumeNumber),
              chapterNumber: Value(reading.chapterNumber),
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
        ? await db.select(db.mangaTrackingUnitRows).get()
        : await (db.select(db.mangaTrackingUnitRows)
              ..where((row) => row.id.isIn(selectedIds)))
            .get();
    return {
      for (final row in rows)
        row.id: _MangaCoordinates(
          volumeNumber: row.volumeNumber,
          chapterNumber: row.chapterNumber,
        ),
    };
  }

  @override
  TrackingUnit fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  ) {
    final typedCoordinates = coordinates is _MangaCoordinates
        ? coordinates
        : const _MangaCoordinates();
    return MangaTrackingUnit(
      id: row.id,
      targetRef: row.targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      volumeNumber: typedCoordinates.volumeNumber,
      chapterNumber: typedCoordinates.chapterNumber,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  @override
  int compareCoordinates(TrackingUnit left, TrackingUnit right) {
    if (left is! MangaTrackingUnit || right is! MangaTrackingUnit) {
      return 0;
    }
    final volume = _compareNullableInt(left.volumeNumber, right.volumeNumber);
    if (volume != 0) return volume;
    return _compareNullableInt(left.chapterNumber, right.chapterNumber);
  }
}

final class _MangaCoordinates {
  const _MangaCoordinates({this.volumeNumber, this.chapterNumber});

  final int? volumeNumber;
  final int? chapterNumber;
}

int _compareNullableInt(int? left, int? right) {
  return (left ?? 0).compareTo(right ?? 0);
}
