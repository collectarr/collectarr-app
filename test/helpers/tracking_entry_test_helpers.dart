import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';

TrackingEntryRepository trackingEntryTestRepository(LocalDatabase db) {
  return TrackingEntryRepository(
    db,
    codecs: collectarrTrackingEntryCodecs,
  );
}

Future<List<TrackingEntry>> readTrackingEntries(LocalDatabase db) {
  return trackingEntryTestRepository(db).listActive();
}

Future<List<TrackingEntry>> readAllTrackingEntries(LocalDatabase db) {
  return trackingEntryTestRepository(db).listAll();
}

Future<TrackingEntry> readSingleTrackingEntry(LocalDatabase db) async {
  final entries = await readTrackingEntries(db);
  if (entries.length != 1) {
    throw StateError('Expected one active tracking entry, got ${entries.length}.');
  }
  return entries.single;
}

Future<void> writeTrackingEntry(LocalDatabase db, TrackingEntry entry) {
  return trackingEntryTestRepository(db).upsert(entry);
}
