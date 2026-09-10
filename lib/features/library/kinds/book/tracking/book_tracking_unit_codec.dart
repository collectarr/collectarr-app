import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_unit.dart';
import 'package:drift/drift.dart';

final class BookTrackingUnitCodec implements TrackingUnitCodec {
  const BookTrackingUnitCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Future<List<TrackingUnitSummary>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  }) async {
    final query = db.select(db.bookTrackingUnitRows);
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
    final row = await (db.select(db.bookTrackingUnitRows)
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
    await (db.update(db.bookTrackingUnitRows)
          ..where((row) => row.id.equals(unit.id)))
        .write(
      BookTrackingUnitRowsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  Future<void> _writeCoordinates(
      LocalDatabase db, TrackingUnitSummary unit) async {
    if (unit case final BookTrackingUnit reading) {
      await db.into(db.bookTrackingUnitRows).insertOnConflictUpdate(
            BookTrackingUnitRowsCompanion.insert(
              id: unit.id,
              targetRefJson: jsonEncode(unit.targetRef.toJson()),
              trackingEntryId: Value(unit.trackingEntryId),
              ownedItemId: Value(unit.ownedRef?.key),
              unitType: unit.unitType,
              completedAt: unit.completedAt,
              updatedAt: unit.updatedAt,
              deletedAt: Value(unit.deletedAt),
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
        ? await db.select(db.bookTrackingUnitRows).get()
        : await (db.select(db.bookTrackingUnitRows)
              ..where((row) => row.id.isIn(selectedIds)))
            .get();
    return {
      for (final row in rows)
        row.id: _BookCoordinates(
          volumeNumber: row.volumeNumber,
          chapterNumber: row.chapterNumber,
        ),
    };
  }

  @override
  TrackingUnitSummary fromStorageRow(
    TrackingUnitStorageRow row,
    Object? coordinates,
  ) {
    final typedCoordinates = coordinates is _BookCoordinates
        ? coordinates
        : const _BookCoordinates();
    return BookTrackingUnit(
      id: row.id,
      targetRef: row.targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedRef: row.ownedRef,
      volumeNumber: typedCoordinates.volumeNumber,
      chapterNumber: typedCoordinates.chapterNumber,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  @override
  int compareCoordinates(TrackingUnitSummary left, TrackingUnitSummary right) {
    if (left is! BookTrackingUnit || right is! BookTrackingUnit) {
      return 0;
    }
    final volume = _compareNullableInt(left.volumeNumber, right.volumeNumber);
    if (volume != 0) return volume;
    return _compareNullableInt(left.chapterNumber, right.chapterNumber);
  }
}

final class _BookCoordinates {
  const _BookCoordinates({this.volumeNumber, this.chapterNumber});

  final int? volumeNumber;
  final int? chapterNumber;
}

int _compareNullableInt(int? left, int? right) {
  return (left ?? 0).compareTo(right ?? 0);
}
