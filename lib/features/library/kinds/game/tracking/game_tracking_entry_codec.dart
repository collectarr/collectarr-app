import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';

/// Game-owned lifecycle tracking mapping. Platform/release semantics stay in
/// the Game vertical; this codec only maps the universal lifecycle contract.
final class GameTrackingEntryCodec implements TrackingEntryCodec {
  const GameTrackingEntryCodec();

  @override
  String get kind => 'game';

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
    return TrackingEntry(
      id: id,
      catalogRef: catalogRef,
      ownedItemId: payload['owned_item_id'] as String?,
      editionId: payload['edition_id'] as String?,
      variantId: payload['variant_id'] as String?,
      bundleReleaseId: payload['bundle_release_id'] as String?,
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
    return TrackingEntry(
      id: row.id,
      catalogRef: row.catalogRef,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
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
      throw const FormatException('Game tracking entry is missing catalog_ref');
    }
    return CatalogEntityRef.fromJson(Map<String, dynamic>.from(raw));
  }

  void _validateKind(CatalogEntityRef ref) {
    if (ref.kind != kind) {
      throw ArgumentError.value(
        ref.kind,
        'catalogRef.kind',
        'Expected Game tracking entry',
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
