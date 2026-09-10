import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

/// Sentinel used by typed tracking-entry subclasses when they need to
/// distinguish an omitted nullable patch from an explicit `null`.
///
/// The sentinel lets kind-owned tracking entries preserve omitted nullable
/// patches through common lifecycle updates without adding semantic fields to
/// the shared model.
const Object trackingLifecycleUnset = Object();

class TrackingLifecycle extends PersonalTrackingBase {
  TrackingLifecycle({
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
    required this.updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        super(
          completedAt: finishedAt,
        );

  final String id;
  final CatalogEntityRef catalogRef;
  final OwnedItemRef? ownedRef;
  final TrackingSourceType? sourceType;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DateTime? get finishedAt => completedAt;

  TrackingSourceType? get trackingSource => sourceType;

  String? get sourceTypeApiValue => sourceType?.apiValue;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      'owned_ref': ownedRef?.toJson(),
      'source_type': sourceTypeApiValue,
      'status': statusStorageValue,
      'rating': rating,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'finished_at': finishedAt?.toUtc().toIso8601String(),
      'progress_current': progressCurrent,
      'progress_total': progressTotal,
      'times_completed': timesCompleted,
      'notes': notes,
    };
  }

  TrackingLifecycle copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingLifecycleUnset,
    Object? sourceType = trackingLifecycleUnset,
    Object? status = trackingLifecycleUnset,
    Object? rating = trackingLifecycleUnset,
    Object? startedAt = trackingLifecycleUnset,
    Object? finishedAt = trackingLifecycleUnset,
    Object? progressCurrent = trackingLifecycleUnset,
    Object? progressTotal = trackingLifecycleUnset,
    Object? timesCompleted = trackingLifecycleUnset,
    Object? notes = trackingLifecycleUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingLifecycleUnset,
  }) {
    return TrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedRef: identical(ownedRef, trackingLifecycleUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingLifecycleUnset)
          ? this.sourceType
          : trackingSourceTypeFromValue(sourceType),
      status: identical(status, trackingLifecycleUnset)
          ? this.status
          : mediaTrackingStatusFromValue(status),
      rating:
          identical(rating, trackingLifecycleUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, trackingLifecycleUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingLifecycleUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingLifecycleUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingLifecycleUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingLifecycleUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes:
          identical(notes, trackingLifecycleUnset) ? this.notes : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingLifecycleUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}
