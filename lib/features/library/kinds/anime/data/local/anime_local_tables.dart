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

/// Complete Anime-owned copy state. The common ownership cache remains only
/// as a migration/read compatibility surface while callers are moved here.
class AnimeOwnedItemsRows extends Table {
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

class AnimeTrackingUnitRows extends Table {
  TextColumn get id => text()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AnimeWatchSessionRows extends Table {
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

class AnimeCustomEpisodeRows extends Table {
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
