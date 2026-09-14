import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_lifecycle_codecs.dart';

TrackingStorageRepository trackingLifecycleTestRepository(LocalDatabase db) {
  return TrackingStorageRepository(
    db,
    codecs: collectarrTrackingLifecycleCodecs,
  );
}

Future<List<TrackingStorageRecord>> readTrackingLifecycles(LocalDatabase db) {
  return trackingLifecycleTestRepository(db).listActiveStorageRecords();
}

Future<List<TrackingStorageRecord>> readAllTrackingLifecycles(
    LocalDatabase db) {
  return trackingLifecycleTestRepository(db).listAllStorageRecords();
}

Future<TrackingStorageRecord> readSingleTrackingLifecycle(
    LocalDatabase db) async {
  final entries = await readTrackingLifecycles(db);
  if (entries.length != 1) {
    throw StateError(
        'Expected one active tracking entry, got ${entries.length}.');
  }
  return entries.single;
}

Future<void> writeTrackingLifecycle(
    LocalDatabase db, TrackingStorageRecord entry) {
  return trackingLifecycleTestRepository(db).upsertStorageRecord(entry);
}
