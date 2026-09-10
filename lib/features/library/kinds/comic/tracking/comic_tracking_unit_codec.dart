import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit.dart';
import 'package:drift/drift.dart';

final class ComicTrackingUnitCodec implements TrackingUnitCodec {
  const ComicTrackingUnitCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Future<List<TrackingUnit>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  }) async {
    final query = db.select(db.comicTrackingUnitRows);
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
  Future<TrackingUnit?> findFromStorage(
    LocalDatabase db,
    TrackingUnitRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final row = await (db.select(db.comicTrackingUnitRows)
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
  Future<void> upsertToStorage(LocalDatabase db, TrackingUnit unit) {
    if (unit case final ComicTrackingUnit comic) {
      return db.into(db.comicTrackingUnitRows).insertOnConflictUpdate(
            ComicTrackingUnitRowsCompanion.insert(
              id: unit.id,
              targetRefJson: jsonEncode(unit.targetRef.toJson()),
              trackingEntryId: Value(unit.trackingEntryId),
              ownedItemId: Value(unit.ownedRef?.key),
              unitType: unit.unitType,
              completedAt: unit.completedAt,
              updatedAt: unit.updatedAt,
              deletedAt: Value(unit.deletedAt),
              issueNumber: Value(comic.issueNumber),
            ),
          );
    }
    return Future.value();
  }

  @override
  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingUnit unit,
    DateTime deletedAt,
  ) async {
    await (db.update(db.comicTrackingUnitRows)
          ..where((row) => row.id.equals(unit.id)))
        .write(
      ComicTrackingUnitRowsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
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
      ownedRef: row.ownedRef,
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
