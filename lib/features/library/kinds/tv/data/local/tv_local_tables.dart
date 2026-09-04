import 'package:drift/drift.dart';

class TvSeriesRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  TextColumn get network => text().nullable()();
  DateTimeColumn get originalAirDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  IntColumn get seasonCount => integer().nullable()();
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

class TvSeasonRows extends Table {
  TextColumn get seriesId => text()();
  TextColumn get id => text()();
  IntColumn get seasonNumber => integer().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {seriesId, id};
}

class TvEpisodeRows extends Table {
  TextColumn get seriesId => text()();
  TextColumn get seasonId => text()();
  TextColumn get id => text()();
  IntColumn get seasonNumber => integer().nullable()();
  RealColumn get episodeNumber => real().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class TvReleaseRows extends Table {
  TextColumn get seriesId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get mediaCount => integer().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get regionCode => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get caseType => text().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  IntColumn get seasonCount => integer().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get languageAudioJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get languageSubtitlesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get contentRating => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {seriesId, id};
}

class TvReleaseMediaRows extends Table {
  TextColumn get releaseId => text()();
  TextColumn get id => text()();
  IntColumn get mediaNumber => integer().nullable()();
  TextColumn get mediaType => text().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get episodeCount => integer().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get regionCode => text().nullable()();
  TextColumn get encoding => text().nullable()();
  TextColumn get aspectRatio => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get audioTracks => text().nullable()();
  TextColumn get subtitles => text().nullable()();
  TextColumn get layers => text().nullable()();
  TextColumn get frameRate => text().nullable()();
  TextColumn get bitDepth => text().nullable()();
  TextColumn get resolution => text().nullable()();
  TextColumn get hdrFormat => text().nullable()();
  TextColumn get episodesJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {releaseId, id};
}

class TvReleaseEpisodeMapRows extends Table {
  TextColumn get releaseId => text()();
  TextColumn get id => text()();
  TextColumn get mediaId => text()();
  TextColumn get episodeId => text()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get sequenceNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {releaseId, id};
}

class TvOwnedDetailsRows extends Table {
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
