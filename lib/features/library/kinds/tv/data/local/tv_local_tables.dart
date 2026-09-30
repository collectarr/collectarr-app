import 'package:drift/drift.dart';

/// Complete TV-owned copy state.
class TvOwnedItemsRows extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isDigital => boolean().nullable()();
  TextColumn get targetRefJson => text().nullable()();
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

/// TV-owned tracking-entry coordinates.
///
/// Lifecycle and structural references remain in the generic tracking index;
/// episode coordinates and ratings belong to TV and are stored here.
class TvTrackingRows extends Table {
  TextColumn get id => text()();
  TextColumn get catalogRefJson => text()();
  TextColumn get ownedRefKey => text().nullable()();
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
  TextColumn get targetRefJson => text()();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get ownedRefKey => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
