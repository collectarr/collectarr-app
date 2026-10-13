import 'package:drift/drift.dart';

/// Complete TV-collection item state.

class TvWatchSessionRows extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryId => text()();
  TextColumn get libraryEntryRefKey => text()();
  TextColumn get episodeId => text().nullable()();
  TextColumn get trackingEntryId => text().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get seenWhere => text().nullable()();
  DateTimeColumn get watchedAt => dateTime()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TvCustomEpisodeRows extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryId => text()();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get stillImageUrl => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get thumbnailImageUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// TV-entry tracking-entry coordinates.
///
/// Lifecycle and structural references remain in the generic tracking index;
/// episode coordinates and ratings belong to TV and are stored here.
class TvTrackingRows extends Table {
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
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  TextColumn get episodeRatingsJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class TvTrackingUnitRows extends Table {
  TextColumn get id => text()();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get libraryEntryRefKey => text()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
