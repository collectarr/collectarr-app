import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

/// Structural tracking lifecycle data for mixed/global activity projections.
///
/// Progress coordinates, hierarchy identity, and provider-specific state stay
/// on the owning kind's tracking record. Activity only needs universal
/// lifecycle timestamps and rating data.
final class TrackingActivitySummary {
  const TrackingActivitySummary({
    required this.catalogRef,
    required this.status,
    required this.updatedAt,
    this.rating,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.deletedAt,
  });

  factory TrackingActivitySummary.fromEntry(TrackingEntry entry) {
    return TrackingActivitySummary(
      catalogRef: entry.catalogRef,
      status: entry.status ?? MediaTrackingStatus.none,
      rating: entry.rating,
      startedAt: entry.startedAt,
      completedAt: entry.finishedAt,
      notes: entry.notes,
      updatedAt: entry.updatedAt,
      deletedAt: entry.deletedAt,
    );
  }

  final CatalogEntityRef catalogRef;
  final MediaTrackingStatus status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
}
