import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';

/// Book-owned tracking lifecycle entry.
final class BookTrackingLifecycle extends TrackingLifecycle {
  BookTrackingLifecycle({
    required super.id,
    required super.catalogRef,
    super.ownedRef,
    super.sourceType,
    super.status,
    super.rating,
    super.startedAt,
    super.finishedAt,
    super.progressCurrent,
    super.progressTotal,
    super.timesCompleted,
    super.notes,
    DateTime? updatedAt,
    super.deletedAt,
  }) : super(updatedAt: updatedAt ?? DateTime.now().toUtc());

  @override
  BookTrackingLifecycle copyWith({
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
    return BookTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedRef: identical(ownedRef, trackingLifecycleUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingLifecycleUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingLifecycleUnset) ? this.status : status,
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
