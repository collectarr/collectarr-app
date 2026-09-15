import 'package:drift/drift.dart';

/// MusicBrainz release-group storage.
class MusicReleaseGroupRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get synopsis => text().nullable()();
  DateTimeColumn get originalReleaseDate => dateTime().nullable()();
  DateTimeColumn get recordingDate => dateTime().nullable()();
  TextColumn get studio => text().nullable()();
  BoolColumn get isLive => boolean().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get externalLinksJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Concrete release/pressing belonging to a release group.
class MusicReleaseRows extends Table {
  TextColumn get id => text()();
  TextColumn get releaseGroupId => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get releaseType => text().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get countryCode => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get upc => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get packaging => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Physical or digital medium belonging to a concrete release.
class MusicMediumRows extends Table {
  TextColumn get id => text()();
  TextColumn get releaseId => text()();
  IntColumn get mediumNumber => integer()();
  TextColumn get mediumType => text().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get trackCount => integer().nullable()();
  IntColumn get expectedTrackCount => integer().nullable()();
  IntColumn get missingTrackCount => integer().nullable()();
  TextColumn get missingTrackPositionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get toc => text().nullable()();
  TextColumn get cddbId => text().nullable()();
  IntColumn get leadoutOffset => integer().nullable()();
  TextColumn get bpDiscId => text().nullable()();
  TextColumn get mediaCondition => text().nullable()();
  TextColumn get soundType => text().nullable()();
  TextColumn get vinylColor => text().nullable()();
  TextColumn get vinylWeight => text().nullable()();
  IntColumn get rpm => integer().nullable()();
  TextColumn get spars => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MusicTrackRows extends Table {
  TextColumn get id => text()();
  TextColumn get mediumId => text()();
  TextColumn get position => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get offsetMs => integer().nullable()();
  IntColumn get bitrateKbps => integer().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get trackHash => text().nullable()();
  TextColumn get instrument => text().nullable()();
  BoolColumn get isHeader => boolean().withDefault(const Constant(false))();
  IntColumn get indentLevel => integer().withDefault(const Constant(0))();
  TextColumn get parentHeaderId => text().nullable()();
  TextColumn get composition => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Release contribution relation matching Core's music_release_contributions
/// table.
class MusicReleaseContributionsRows extends Table {
  TextColumn get id => text()();
  TextColumn get releaseId => text()();
  TextColumn get personId => text()();
  TextColumn get role => text()();
  TextColumn get roleId => text().nullable()();
  IntColumn get sequence => integer().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Release identifier relation matching Core's music_release_identifiers
/// table.
class MusicReleaseIdentifiersRows extends Table {
  TextColumn get id => text()();
  TextColumn get releaseId => text()();
  TextColumn get identifierType => text()();
  TextColumn get value => text()();
  TextColumn get normalizedValue => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  TextColumn get sourceProvider => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Complete Music-owned copy state.
class MusicOwnedItemsRows extends Table {
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
  TextColumn get storageDevice => text().nullable()();
  TextColumn get storageSlot => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  DateTimeColumn get lastCleanedDate => dateTime().nullable()();
  TextColumn get matrixRunoutsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get discStorageJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MusicTrackingRows extends Table {
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

  @override
  Set<Column> get primaryKey => {id};
}

/// Music-specific listening history. A lifecycle tracking row cannot retain
/// repeated listens, so events are stored separately in the Music vertical.
class MusicListenEventsRows extends Table {
  TextColumn get id => text()();
  TextColumn get targetRefJson => text()();
  TextColumn get releaseGroupId => text()();
  TextColumn get releaseId => text().nullable()();
  TextColumn get ownedRefJson => text().nullable()();
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
