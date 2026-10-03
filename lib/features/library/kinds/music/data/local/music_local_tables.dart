import 'package:drift/drift.dart';

import 'package:collectarr_app/core/models/library_entry_ref.dart';

class MusicTrackingRows extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get rating => integer().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get progressCurrent => integer().nullable()();
  IntColumn get progressTotal => integer().nullable()();
  IntColumn get timesCompleted => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Music-specific listening history. A lifecycle tracking row cannot retain
/// repeated listens, so events are stored separately in the Music vertical.
class MusicListenEventsRows extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
  DateTimeColumn get listenedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
