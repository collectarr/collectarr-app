import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_storage_codecs.dart';
import 'tracking_storage_repository.dart';

/// Read-only structural tracking projection for mixed/global features.
///
/// This boundary intentionally does not expose a kind-owned lifecycle
/// aggregate. Typed tracking records remain inside the persistence repository
/// and the owning kind's tracking integration.
final class TrackingSummaryRepository {
  const TrackingSummaryRepository(this._db);

  final LocalDatabase _db;

  Future<List<TrackingSummary>> listActive() {
    return TrackingStorageRepository(
      _db,
      codecs: collectarrTrackingStorageCodecs,
    ).listActiveSummaries();
  }
}
