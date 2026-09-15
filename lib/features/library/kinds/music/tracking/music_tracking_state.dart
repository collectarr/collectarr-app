import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';

/// Music-owned tracking lifecycle entry.
final class MusicTrackingState extends PersonalTrackingBase
    with TrackingStorageRecordBehavior {
  MusicTrackingState({
    required this.id,
    required this.catalogRef,
    required this.releaseId,
    Object? sourceType,
    super.status,
    super.rating,
    super.startedAt,
    DateTime? finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    super.notes,
    DateTime? updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        updatedAt = updatedAt ?? DateTime.now().toUtc(),
        super(completedAt: finishedAt) {
    requireMusicReleaseRef(
      catalogRef,
      label: 'Music tracking catalogRef',
    );
    if (releaseId.trim().isEmpty || catalogRef.id != releaseId.trim()) {
      throw ArgumentError.value(
        releaseId,
        'releaseId',
        'Music tracking releaseId must match catalogRef.id',
      );
    }
  }

  @override
  final String id;
  @override
  final CatalogEntityRef catalogRef;
  @override
  OwnedItemRef? get ownedRef => null;
  final String releaseId;
  @override
  final TrackingSourceType? sourceType;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;

  @override
  TrackingProgressSnapshot get progress => TrackingProgressSnapshot(
        current: progressCurrent,
        total: progressTotal,
        timesCompleted: timesCompleted,
      );

  @override
  MusicTrackingState copyWithProgress(TrackingProgressSnapshot progress) {
    return copyWith(
      progressCurrent: progress.current,
      progressTotal: progress.total,
      timesCompleted: progress.timesCompleted,
    );
  }

  @override
  MusicTrackingState copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingStorageUnset,
    Object? sourceType = trackingStorageUnset,
    Object? status = trackingStorageUnset,
    Object? rating = trackingStorageUnset,
    Object? startedAt = trackingStorageUnset,
    Object? finishedAt = trackingStorageUnset,
    Object? progressCurrent = trackingStorageUnset,
    Object? progressTotal = trackingStorageUnset,
    Object? timesCompleted = trackingStorageUnset,
    Object? notes = trackingStorageUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingStorageUnset,
  }) {
    final nextCatalogRef = catalogRef ?? this.catalogRef;
    final nextOwnedRef = identical(ownedRef, trackingStorageUnset)
        ? this.ownedRef
        : ownedRef as OwnedItemRef?;
    if (nextOwnedRef != null) {
      throw StateError('Music tracking cannot be attached to an owned copy.');
    }
    return MusicTrackingState(
      id: id ?? this.id,
      catalogRef: nextCatalogRef,
      releaseId: nextCatalogRef.id,
      sourceType: identical(sourceType, trackingStorageUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingStorageUnset) ? this.status : status,
      rating: identical(rating, trackingStorageUnset)
          ? this.rating
          : rating as int?,
      startedAt: identical(startedAt, trackingStorageUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingStorageUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingStorageUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingStorageUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingStorageUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes: identical(notes, trackingStorageUnset)
          ? this.notes
          : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingStorageUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
