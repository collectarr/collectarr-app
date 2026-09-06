import 'package:drift/drift.dart';

class ComicMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get seriesTitle => text().nullable()();
  TextColumn get issueNumber => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get imprint => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  DateTimeColumn get coverDate => dateTime().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get country => text().withDefault(const Constant('US'))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get ageRating => text().nullable()();
  TextColumn get crossover => text().nullable()();
  TextColumn get synopsis => text().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get searchAliasesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get writersJson => text().withDefault(const Constant('[]'))();
  TextColumn get artistsJson => text().withDefault(const Constant('[]'))();
  TextColumn get inkersJson => text().withDefault(const Constant('[]'))();
  TextColumn get coloristsJson => text().withDefault(const Constant('[]'))();
  TextColumn get letterersJson => text().withDefault(const Constant('[]'))();
  TextColumn get editorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get coverArtistsJson => text().withDefault(const Constant('[]'))();
  TextColumn get creatorCreditsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get charactersJson => text().withDefault(const Constant('[]'))();
  TextColumn get characterDetailsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get creatorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get storyArcsJson => text().withDefault(const Constant('[]'))();
  TextColumn get keyEventsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isKeyComic => boolean().withDefault(const Constant(false))();
  TextColumn get keyReason => text().nullable()();
  TextColumn get variant => text().nullable()();
  TextColumn get variantDescription => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get seriesJson => text().nullable()();
  TextColumn get publishingJson => text().nullable()();
  TextColumn get editionTitle => text().nullable()();
  TextColumn get titleExtension => text().nullable()();
  TextColumn get physicalFormat => text().nullable()();
  TextColumn get physicalFormatLabel => text().nullable()();
  TextColumn get linksJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ComicReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get publisher => text().nullable()();
  TextColumn get imprint => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get upc => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get variantsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

/// Complete Comic-owned copy state. Generic owned storage is retained only
/// as the kind-owned local persistence surface.
class ComicOwnedItemsRows extends Table {
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
  TextColumn get rawOrSlabbed => text().nullable()();
  TextColumn get gradingCompany => text().nullable()();
  TextColumn get graderNotes => text().nullable()();
  TextColumn get labelType => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  TextColumn get pageQuality => text().nullable()();
  TextColumn get certificationNumber => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  BoolColumn get keyComic => boolean().withDefault(const Constant(false))();
  TextColumn get keyReason => text().nullable()();
  TextColumn get keyCategory => text().nullable()();
  TextColumn get keySeverity => text().nullable()();
  IntColumn get coverPriceCents => integer().nullable()();
  DateTimeColumn get lastBagBoardDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ComicReadingRows extends Table {
  TextColumn get ownedItemId => text()();
  IntColumn get rating => integer().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

class ComicOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get rawOrSlabbed => text().nullable()();
  TextColumn get gradingCompany => text().nullable()();
  TextColumn get graderNotes => text().nullable()();
  TextColumn get labelType => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  TextColumn get pageQuality => text().nullable()();
  TextColumn get certificationNumber => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  BoolColumn get keyComic => boolean().withDefault(const Constant(false))();
  TextColumn get keyReason => text().nullable()();
  TextColumn get keyCategory => text().nullable()();
  TextColumn get keySeverity => text().nullable()();
  IntColumn get coverPriceCents => integer().nullable()();
  DateTimeColumn get lastBagBoardDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

class ComicTrackingUnitRows extends Table {
  TextColumn get id => text()();
  TextColumn get issueNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
