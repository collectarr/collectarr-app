import 'package:drift/drift.dart';

/// Complete BoardGame-collection item state. Play sessions are tracking data and
/// remain in their dedicated table rather than being embedded in a copy.


class BoardGamePlaySessionsRows extends Table {
  TextColumn get id => text()();
  TextColumn get boardGameId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get playersJson => text().withDefault(const Constant('[]'))();
  TextColumn get winner => text().nullable()();
  TextColumn get scoresJson => text().withDefault(const Constant('[]'))();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BoardGameTrackingRows extends Table {
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
