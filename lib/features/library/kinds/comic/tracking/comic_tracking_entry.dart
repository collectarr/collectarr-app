import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';

/// Comic-owned tracking lifecycle entry.
///
/// Comics currently have no additional hierarchy coordinates, but the
/// lifecycle aggregate still belongs to Comic rather than to a universal
/// catalog model.
final class ComicTrackingEntry extends TrackingEntry {
  ComicTrackingEntry({
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
  ComicTrackingEntry copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingEntryUnset,
    Object? sourceType = trackingEntryUnset,
    Object? status = trackingEntryUnset,
    Object? rating = trackingEntryUnset,
    Object? startedAt = trackingEntryUnset,
    Object? finishedAt = trackingEntryUnset,
    Object? progressCurrent = trackingEntryUnset,
    Object? progressTotal = trackingEntryUnset,
    Object? timesCompleted = trackingEntryUnset,
    Object? notes = trackingEntryUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingEntryUnset,
  }) {
    return ComicTrackingEntry(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedRef: identical(ownedRef, trackingEntryUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingEntryUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingEntryUnset) ? this.status : status,
      rating:
          identical(rating, trackingEntryUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, trackingEntryUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingEntryUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingEntryUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingEntryUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingEntryUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes:
          identical(notes, trackingEntryUnset) ? this.notes : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingEntryUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

}
