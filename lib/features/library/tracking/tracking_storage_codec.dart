import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';

/// The serialized, kind-neutral portion of a lifecycle row.
///
/// Hierarchy coordinates deliberately do not cross this boundary. The owning
/// kind receives the row and its opaque coordinate projection through
/// [TrackingStorageCodec.fromStorageRow].
final class TrackingStorageRow {
  const TrackingStorageRow({
    required this.id,
    required this.libraryEntryRef,
    required this.sourceType,
    required this.status,
    required this.rating,
    required this.startedAt,
    required this.finishedAt,
    required this.progress,
    required this.notes,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final LibraryEntryRef libraryEntryRef;
  final String? sourceType;
  final String? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final TrackingProgressSnapshot progress;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

final class TrackingStorageRead {
  const TrackingStorageRead(this.row, this.coordinates);

  final TrackingStorageRow row;
  final Object? coordinates;
}

/// Opaque sync input accepted at the persistence boundary.
///
/// Generic sync orchestration may carry this transport value, but it never
/// reconstructs or inspects a kind-entry tracking aggregate.
final class TrackingStorageSyncInput {
  const TrackingStorageSyncInput({
    required this.ref,
    required this.payload,
    required this.updatedAt,
    this.deletedAt,
  });

  final TrackingStateRef ref;
  final JsonMap payload;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

/// Serialized tracking state returned to generic sync/mutation orchestration.
final class TrackingStorageSyncRecord {
  const TrackingStorageSyncRecord({
    required this.ref,
    required this.payload,
    required this.isDeleted,
  });

  final TrackingStateRef ref;
  final JsonMap payload;
  final bool isDeleted;
}

/// Kind-entry lifecycle storage and reconstruction behavior.
///
/// The generic repository owns transaction and query mechanics only. A codec
/// semantic columns and their interpretation live in the kind adapter.
abstract interface class TrackingStorageCodec {
  const TrackingStorageCodec();

  CatalogMediaKind get kind;

  void validateTrackingEntryKind(LibraryEntryRef ref) {
    if (ref.kind != kind) {
      throw ArgumentError.value(
        ref.kind,
        'libraryEntryRef.kind',
        'Expected ${kind.apiValue} tracking entry',
      );
    }
  }

  Future<List<TrackingStorageRead>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  });

  /// Reads complete lifecycle rows from the owning kind table.
  Future<List<TrackingStorageRecord>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  });

  Future<TrackingStorageRecord?> findFromStorage(
    LocalDatabase db,
    TrackingStateRef ref,
  );

  Future<void> upsertToStorage(LocalDatabase db, TrackingStorageRecord entry);

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingStorageRecord entry,
    DateTime deletedAt,
  );

  /// Applies a kind-entry patch after the common lifecycle fields have been
  /// resolved. This is the only place where an opaque patch becomes typed.
  TrackingStorageRecord applyKindPatch(
    TrackingStorageRecord entry,
    TrackingKindPatch patch,
  );

  TrackingStorageRecord create({
    required String id,
    required LibraryEntryRef libraryEntryRef,
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
  });

  Future<Map<String, Object?>> loadCoordinates(
    LocalDatabase db,
    Iterable<String>? ids,
  );

  JsonMap toSyncPayload(TrackingStorageRecord entry);

  /// Reconstructs a tracking entry received from the personal Sync boundary.
  ///
  /// Kind-specific coordinates are parsed by the owning codec rather than by
  /// the shared model's transport factory.
  TrackingStorageRecord fromSyncPayload({
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });

  TrackingStorageRecord fromStorageRow(
    TrackingStorageRow row,
    Object? coordinates,
  );

  TrackingSummary summaryFromStorageRow(TrackingStorageRow row);
}

/// Shared persistence mechanics for kind-entry lifecycle codecs.
///
/// The mixin owns only filtering/reconstruction mechanics. Each kind supplies
/// its row query and its own Drift companion, so no semantic table definition
/// or field interpretation crosses the kind boundary.
mixin TrackingStorageCodecSupport {
  CatalogMediaKind get kind;

  void validateTrackingEntryKind(LibraryEntryRef ref) {
    if (ref.kind != kind) {
      throw ArgumentError.value(
        ref.kind,
        'libraryEntryRef.kind',
        'Expected ${kind.apiValue} tracking entry',
      );
    }
  }

  TrackingStorageRecord fromStorageRow(
    TrackingStorageRow row,
    Object? coordinates,
  );

  TrackingStorageRecord applyKindPatch(
    TrackingStorageRecord entry,
    TrackingKindPatch patch,
  ) {
    if (patch.kind != kind) {
      throw ArgumentError.value(
        patch.kind,
        'patch.kind',
        'Expected ${kind.apiValue} tracking patch',
      );
    }
    throw UnsupportedError(
      'Tracking kind ${kind.apiValue} does not define kind-entry patches.',
    );
  }

  TrackingSummary summaryFromStorageRow(TrackingStorageRow row) {
    return TrackingSummary(
      id: row.id,
      status:
          mediaTrackingStatusFromValue(row.status) ?? MediaTrackingStatus.none,
      libraryEntryRef: row.libraryEntryRef,
      sourceType: trackingSourceTypeFromValue(row.sourceType),
      rating: row.rating,
      startedAt: row.startedAt,
      completedAt: row.finishedAt,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      progress: row.progress,
    );
  }

  Future<List<TrackingStorageRead>> readStorageRecords(
    LocalDatabase db, {
    required bool activeOnly,
  });

  Future<void> writeStorageRecord(
      LocalDatabase db, TrackingStorageRecord entry);

  Future<void> deleteStorageRecord(
    LocalDatabase db,
    TrackingStorageRecord entry,
    DateTime deletedAt,
  );

  Future<List<TrackingStorageRecord>> listFromStorage(
    LocalDatabase db, {
    bool activeOnly = true,
  }) async {
    return [
      for (final record in await readStorageRecords(
        db,
        activeOnly: activeOnly,
      ))
        fromStorageRow(record.row, record.coordinates),
    ];
  }

  Future<TrackingStorageRecord?> findFromStorage(
    LocalDatabase db,
    TrackingStateRef ref,
  ) async {
    if (ref.kind != kind) return null;
    for (final record in await readStorageRecords(
      db,
      activeOnly: false,
    )) {
      if (record.row.id == ref.id) {
        return fromStorageRow(record.row, record.coordinates);
      }
    }
    return null;
  }

  Future<void> upsertToStorage(LocalDatabase db, TrackingStorageRecord entry) {
    return writeStorageRecord(db, entry);
  }

  Future<void> markDeletedInStorage(
    LocalDatabase db,
    TrackingStorageRecord entry,
    DateTime deletedAt,
  ) {
    return deleteStorageRecord(db, entry, deletedAt);
  }
}

TrackingStorageRow trackingStorageRowFromColumns({
  required String id,
  required String libraryEntryRefKey,
  required String? sourceType,
  required String? status,
  required int? rating,
  required DateTime? startedAt,
  required DateTime? finishedAt,
  required TrackingProgressSnapshot progress,
  required String? notes,
  required DateTime updatedAt,
  required DateTime? deletedAt,
}) {
  final libraryEntryRef = LibraryEntryRef.fromKey(libraryEntryRefKey);
  return TrackingStorageRow(
    id: id,
    libraryEntryRef: libraryEntryRef,
    sourceType: sourceType,
    status: status,
    rating: rating,
    startedAt: startedAt,
    finishedAt: finishedAt,
    progress: progress,
    notes: notes,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

LibraryEntryRef trackingLibraryEntryRefFromPayload(
  JsonMap payload,
  CatalogMediaKind expectedKind,
) {
  final ref = libraryEntryRefFromSerialized(payload['library_entry_ref']);
  if (ref == null || ref.kind != expectedKind) {
    throw FormatException(
      'Tracking payload requires a ${expectedKind.apiValue} library_entry_ref.',
    );
  }
  return ref;
}
