import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

/// Structural lifecycle projection for mixed/global hosts.
///
/// Kind-owned hierarchy coordinates and provider-specific state stay in the
/// concrete kind tracking aggregate. This projection is sufficient for
/// global joins, status badges, activity, and queue displays.
final class TrackingSummary {
  const TrackingSummary({
    required this.id,
    required this.catalogRef,
    required this.status,
    required this.updatedAt,
    this.ownedRef,
    this.sourceType,
    this.rating,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final MediaTrackingStatus status;
  final OwnedItemRef? ownedRef;
  final TrackingSourceType? sourceType;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TrackingLifecycleRef get ref => TrackingLifecycleRef(
        kind: catalogRef.mediaKind,
        id: id,
      );

  bool get isDeleted => deletedAt != null;
  String? get statusStorageValue => mediaTrackingStatusToStorageValue(status);
  String get statusLabel => status.label;
}
