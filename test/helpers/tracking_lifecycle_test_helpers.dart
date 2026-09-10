import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_lifecycle_codecs.dart';

TrackingLifecycleRepository trackingLifecycleTestRepository(LocalDatabase db) {
  return TrackingLifecycleRepository(
    db,
    codecs: collectarrTrackingLifecycleCodecs,
  );
}

Future<List<TrackingLifecycle>> readTrackingLifecycles(LocalDatabase db) {
  return trackingLifecycleTestRepository(db).listActive();
}

Future<List<TrackingLifecycle>> readAllTrackingLifecycles(LocalDatabase db) {
  return trackingLifecycleTestRepository(db).listAll();
}

Future<TrackingLifecycle> readSingleTrackingLifecycle(LocalDatabase db) async {
  final entries = await readTrackingLifecycles(db);
  if (entries.length != 1) {
    throw StateError(
        'Expected one active tracking entry, got ${entries.length}.');
  }
  return entries.single;
}

Future<void> writeTrackingLifecycle(LocalDatabase db, TrackingLifecycle entry) {
  return trackingLifecycleTestRepository(db).upsert(entry);
}
