import 'package:drift/drift.dart';

/// Complete Anime-collection item state.


class AnimeTrackingRows extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
  TextColumn get status => text().withDefault(const Constant(''))();
  TextColumn get sourceType => text().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get progressCurrent => integer().nullable()();
  IntColumn get progressTotal => integer().nullable()();
  IntColumn get timesCompleted => integer().withDefault(const Constant(0))();
  IntColumn get seasonNumber => integer().nullable()();
  RealColumn get episodeNumber => real().nullable()();
  TextColumn get episodeRatingsJson =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimeTrackingUnitRows extends Table {
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

class AnimeWatchSessionRows extends Table {
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

class AnimeCustomEpisodeRows extends Table {
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
