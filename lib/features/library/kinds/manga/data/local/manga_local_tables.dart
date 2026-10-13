import 'package:drift/drift.dart';

/// Complete Manga-collection item state.

class MangaTrackingUnitRows extends Table {
  TextColumn get id => text()();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get libraryEntryRefKey => text()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get chapterNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MangaTrackingRows extends Table {
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
