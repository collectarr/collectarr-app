import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

TrackingStorageRepository trackingRecordTestRepository(LocalDatabase db) {
  return TrackingStorageRepository(
    db,
    codecs: collectarrTrackingStorageCodecs,
  );
}

Future<List<TrackingStorageRecord>> readTrackingStates(LocalDatabase db) {
  return trackingRecordTestRepository(db).listActiveStorageRecords();
}

Future<List<TrackingStorageRecord>> readAllTrackingStates(LocalDatabase db) {
  return trackingRecordTestRepository(db).listAllStorageRecords();
}

Future<TrackingStorageRecord> readSingleTrackingState(LocalDatabase db) async {
  final entries = await readTrackingStates(db);
  if (entries.length != 1) {
    throw StateError(
        'Expected one active tracking entry, got ${entries.length}.');
  }
  return entries.single;
}

Future<void> writeTrackingState(LocalDatabase db, TrackingStorageRecord entry) {
  return trackingRecordTestRepository(db).upsertStorageRecord(entry);
}
