import 'package:drift/drift.dart';

class GameMediaRows extends Table {
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
  TextColumn get companyRolesJson => text().withDefault(const Constant('[]'))();
  TextColumn get ageRatingsJson => text().withDefault(const Constant('[]'))();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get searchAliasesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class GameReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get workId => text().nullable()();
  TextColumn get platform => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get regionCode => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

/// Complete Game-owned copy state.
class GameOwnedItemsRows extends Table {
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
  TextColumn get completeness => text().nullable()();
  BoolColumn get hasBox => boolean().nullable()();
  BoolColumn get hasManual => boolean().nullable()();
  TextColumn get priceChartingId => text().nullable()();
  TextColumn get coreRegion => text().nullable()();
  BoolColumn get valueIsLocked => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
