import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

TrackingSummary trackingSummaryFromRecord(TrackingStorageRecord record) {
  return TrackingSummary(
    id: record.id,
    libraryEntryRef: record.libraryEntryRef,
    sourceType: record.sourceType,
    status: record.status ?? MediaTrackingStatus.none,
    rating: record.rating,
    startedAt: record.startedAt,
    completedAt: record.finishedAt,
    notes: record.notes,
    updatedAt: record.updatedAt,
    deletedAt: record.deletedAt,
    progress: record.progress,
  );
}
