import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';

import 'comic_tracking_entry.dart';

/// Comic-owned lifecycle tracking mapping.
///
/// Comics do not have episodic tracking coordinates. The codec still owns the
/// wire/storage mapping so sync never falls back to a generic kind parser.
final class ComicTrackingEntryCodec implements TrackingEntryCodec {
  const ComicTrackingEntryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  ComicTrackingEntry create({
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
    _validateKind(catalogRef);
    return ComicTrackingEntry(
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

  @override
  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  ) async =>
      const {};

  @override
  Future<void> clearCoordinates(LocalDatabase db, String id) async {}

  @override
  Future<void> writeCoordinates(LocalDatabase db, TrackingEntry entry) async {
    _validateKind(entry.catalogRef);
  }

  @override
  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
    _validateKind(entry.catalogRef);
    return entry.toSyncPayload();
  }

  @override
  TrackingEntry fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final catalogRef = _catalogRefFromPayload(payload);
    _validateKind(catalogRef);
    return ComicTrackingEntry(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedItemRefFromSerialized(payload['owned_ref']),
      sourceType: payload['source_type'] as String?,
      status: payload['status'] as String?,
      rating: _int(payload['rating']),
      startedAt: _date(payload['started_at']),
      finishedAt: _date(payload['finished_at']),
      progressCurrent: _int(payload['progress_current']),
      progressTotal: _int(payload['progress_total']),
      timesCompleted: _int(payload['times_completed']),
      notes: payload['notes'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  TrackingEntry fromStorageRow(
    TrackingEntryStorageRow row,
    Object? coordinates,
  ) {
    _validateKind(row.catalogRef);
    return ComicTrackingEntry(
      id: row.id,
      catalogRef: row.catalogRef,
      ownedRef: row.ownedRef,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  CatalogEntityRef _catalogRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['catalog_ref'];
    if (raw is! Map) {
      throw const FormatException(
          'Comic tracking entry is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }

  void _validateKind(CatalogEntityRef ref) {
    if (ref.mediaKind != kind) {
      throw ArgumentError.value(
        ref.mediaKind,
        'catalogRef.kind',
        'Expected Comic tracking entry',
      );
    }
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
