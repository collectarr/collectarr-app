import 'package:drift/drift.dart';

class MangaMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get firstPublicationDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  DateTimeColumn get originalPublicationDate => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get chaptersJson => text().withDefault(const Constant('[]'))();
  TextColumn get characterAppearancesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get seriesJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MangaOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get rawOrSlabbed => text().nullable()();
  TextColumn get gradingCompany => text().nullable()();
  TextColumn get graderNotes => text().nullable()();
  TextColumn get labelType => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  TextColumn get pageQuality => text().nullable()();
  TextColumn get certificationNumber => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  BoolColumn get obiStripPresent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get slipcoverPresent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get dustJacketPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dustJacketCondition => text().nullable()();
  TextColumn get boxSetOuterCondition => text().nullable()();
  BoolColumn get insertsPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get printing => text().nullable()();
  TextColumn get localizedEdition => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

/// Complete Manga-owned copy state. The common ownership cache remains only
/// as a migration/read compatibility surface while callers are moved here.
class MangaOwnedItemsRows extends Table {
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
  BoolColumn get obiStripPresent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get slipcoverPresent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get dustJacketPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dustJacketCondition => text().nullable()();
  TextColumn get boxSetOuterCondition => text().nullable()();
  BoolColumn get insertsPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get printing => text().nullable()();
  TextColumn get localizedEdition => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MangaTrackingUnitRows extends Table {
  TextColumn get id => text()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get chapterNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
