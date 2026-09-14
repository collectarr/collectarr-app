import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';

/// Book-owned tracking lifecycle entry.
final class BookTrackingLifecycle extends PersonalTrackingBase
    with TrackingLifecycleBehavior {
  BookTrackingLifecycle({
    required this.id,
    required this.catalogRef,
    this.ownedRef,
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
        super(completedAt: finishedAt);

  @override
  final String id;
  @override
  final CatalogEntityRef catalogRef;
  @override
  final OwnedItemRef? ownedRef;
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
  BookTrackingLifecycle copyWithProgress(TrackingProgressSnapshot progress) {
    return copyWith(
      progressCurrent: progress.current,
      progressTotal: progress.total,
      timesCompleted: progress.timesCompleted,
    );
  }

  @override
  BookTrackingLifecycle copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingRecordUnset,
    Object? sourceType = trackingRecordUnset,
    Object? status = trackingRecordUnset,
    Object? rating = trackingRecordUnset,
    Object? startedAt = trackingRecordUnset,
    Object? finishedAt = trackingRecordUnset,
    Object? progressCurrent = trackingRecordUnset,
    Object? progressTotal = trackingRecordUnset,
    Object? timesCompleted = trackingRecordUnset,
    Object? notes = trackingRecordUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingRecordUnset,
  }) {
    return BookTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedRef: identical(ownedRef, trackingRecordUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingRecordUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingRecordUnset) ? this.status : status,
      rating:
          identical(rating, trackingRecordUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, trackingRecordUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingRecordUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingRecordUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingRecordUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingRecordUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes:
          identical(notes, trackingRecordUnset) ? this.notes : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingRecordUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
