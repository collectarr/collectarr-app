import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit.dart';
import 'package:drift/drift.dart';

final class ComicTrackingUnitCodec implements TrackingUnitCodec {
  const ComicTrackingUnitCodec();

  @override
  String get kind => 'comic';

  @override
  Future<void> clearCoordinates(LocalDatabase db, String id) async {
    await (db.delete(db.comicTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  @override
  Future<void> writeCoordinates(LocalDatabase db, TrackingUnit unit) async {
    if (unit case final ComicTrackingUnit comic) {
      await db.into(db.comicTrackingUnitRows).insertOnConflictUpdate(
            ComicTrackingUnitRowsCompanion.insert(
              id: unit.id,
              issueNumber: Value(comic.issueNumber),
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
        ? await db.select(db.comicTrackingUnitRows).get()
        : await (db.select(db.comicTrackingUnitRows)
              ..where((row) => row.id.isIn(selectedIds)))
            .get();
    return {
      for (final row in rows) row.id: _ComicCoordinates(row.issueNumber),
    };
  }

  @override
  TrackingUnit fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  ) {
    final typedCoordinates = coordinates is _ComicCoordinates
        ? coordinates
        : const _ComicCoordinates(null);
    return ComicTrackingUnit(
      id: row.id,
      targetRef: row.targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      issueNumber: typedCoordinates.issueNumber,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  @override
  int compareCoordinates(TrackingUnit left, TrackingUnit right) {
    if (left is! ComicTrackingUnit || right is! ComicTrackingUnit) {
      return 0;
    }
    return (left.issueNumber ?? '').compareTo(right.issueNumber ?? '');
  }
}

final class _ComicCoordinates {
  const _ComicCoordinates(this.issueNumber);

  final String? issueNumber;
}
