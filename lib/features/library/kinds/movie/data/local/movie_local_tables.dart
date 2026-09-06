import 'package:drift/drift.dart';

class MovieMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get ageRating => text().nullable()();
  TextColumn get audienceRating => text().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get characterAppearancesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get externalLinksJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get trailerUrlsJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MovieReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get workId => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get distributor => text().nullable()();
  TextColumn get externalLinksJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get format => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get mediaJson => text().withDefault(const Constant('[]'))();
  TextColumn get region => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get trailerUrlsJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

class MovieOwnedDetailsRows extends Table {
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

/// Complete Movie-owned copy state.
class MovieOwnedItemsRows extends Table {
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
