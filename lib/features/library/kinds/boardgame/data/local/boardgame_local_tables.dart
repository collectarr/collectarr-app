import 'package:drift/drift.dart';

class BoardGameMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get platformsJson => text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get contributorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get mechanicsJson => text().withDefault(const Constant('[]'))();
  TextColumn get categoriesJson => text().withDefault(const Constant('[]'))();
  TextColumn get familiesJson => text().withDefault(const Constant('[]'))();
  TextColumn get expansionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get rankingsJson => text().withDefault(const Constant('[]'))();
  TextColumn get searchAliasesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class BoardGameEditionRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get titleValue => text().nullable()();
  TextColumn get workId => text().nullable()();
  TextColumn get editionTitle => text().nullable()();
  TextColumn get ageRating => text().nullable()();
  TextColumn get audienceRating => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get language => text().nullable()();
  IntColumn get maxPlayers => integer().nullable()();
  IntColumn get minAge => integer().nullable()();
  IntColumn get minPlayers => integer().nullable()();
  IntColumn get playingTimeMinutes => integer().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

/// Complete BoardGame-owned copy state. Play sessions are tracking data and
/// remain in their dedicated table rather than being embedded in a copy.
class BoardGameOwnedItemsRows extends Table {
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
  TextColumn get editionLanguage => text().nullable()();
  TextColumn get editionRegion => text().nullable()();
  TextColumn get componentCondition => text().nullable()();
  TextColumn get componentCompleteness => text().nullable()();
  TextColumn get missingPiecesNotes => text().nullable()();
  BoolColumn get isSleeved => boolean().withDefault(const Constant(false))();
  BoolColumn get hasCustomInsert =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hasPaintedMiniatures =>
      boolean().withDefault(const Constant(false))();
  TextColumn get storageNotes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

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
