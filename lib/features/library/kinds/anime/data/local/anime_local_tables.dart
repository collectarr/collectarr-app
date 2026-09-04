import 'package:drift/drift.dart';

class AnimeMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get animeType => text().nullable()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  DateTimeColumn get originalAirDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get characterAppearancesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimeEpisodeRows extends Table {
  TextColumn get seriesId => text()();
  TextColumn get id => text()();
  RealColumn get episodeNumber => real().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimeReleaseRows extends Table {
  TextColumn get seriesId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get regionCode => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get mediaCount => integer().nullable()();
  TextColumn get audioTracksJson => text().withDefault(const Constant('[]'))();
  TextColumn get subtitlesJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {seriesId, id};
}

class AnimeOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get features => text().nullable()();
  TextColumn get hdrFormatsJson => text().withDefault(const Constant('[]'))();
  TextColumn get boxSetId => text().nullable()();
  TextColumn get boxSetName => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get packaging => text().nullable()();
  TextColumn get distributor => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

class AnimeTrackingRows extends Table {
  TextColumn get id => text()();
  TextColumn get mediaId => text()();
  TextColumn get episodeId => text().nullable()();
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
