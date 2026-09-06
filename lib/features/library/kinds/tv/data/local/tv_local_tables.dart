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

/// Complete TV-owned copy state.
class TvOwnedItemsRows extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isDigital => boolean().nullable()();
  TextColumn get anchorType => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get condition => text().nullable()();
  TextColumn get grade => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get pricePaidCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get personalNotes => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get indexNumber => integer().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get soldAt => dateTime().nullable()();
  IntColumn get sellPriceCents => integer().nullable()();
  TextColumn get soldTo => text().nullable()();
  TextColumn get ownerUserId => text().nullable()();
  TextColumn get ownerLabel => text().nullable()();
  TextColumn get locationId => text().nullable()();
  TextColumn get purchaseStore => text().nullable()();
  TextColumn get collectionStatus => text().nullable()();
  IntColumn get marketValueCents => integer().nullable()();
  TextColumn get features => text().nullable()();
  TextColumn get hdrFormatsJson => text().withDefault(const Constant('[]'))();
  TextColumn get boxSetId => text().nullable()();
  TextColumn get boxSetName => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get packaging => text().nullable()();
  TextColumn get distributor => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TvWatchSessionRows extends Table {
  TextColumn get id => text()();
  TextColumn get seriesId => text()();
  TextColumn get episodeId => text().nullable()();
  TextColumn get targetRefJson => text().nullable()();
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

class TvEpisodeProgressRows extends Table {
  TextColumn get seriesId => text()();
  TextColumn get seasonId => text()();
  TextColumn get episodeId => text()();
  IntColumn get seasonNumber => integer().nullable()();
  RealColumn get episodeNumber => real().nullable()();
  IntColumn get watchedCount => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastWatchedAt => dateTime().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {seriesId, seasonId, episodeId};
}

class TvCustomEpisodeRows extends Table {
  TextColumn get id => text()();
  TextColumn get seriesId => text()();
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

class TvTrackingUnitRows extends Table {
  TextColumn get id => text()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
