import 'package:collectarr_app/core/models/tracking_status.dart';

/// The personal tracking state shared by every media kind.
///
/// Hierarchy coordinates, ownership references, and provider/source details do
/// not belong here. Those remain on the kind-specific tracking record until
/// the tracking storage split is completed.
class PersonalTrackingBase {
  PersonalTrackingBase({
    Object? status,
    this.rating,
    this.startedAt,
    this.completedAt,
    this.notes,
  }) : status = mediaTrackingStatusFromValue(status);

  final MediaTrackingStatus? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;

  String? get statusStorageValue => mediaTrackingStatusToStorageValue(status);
}
