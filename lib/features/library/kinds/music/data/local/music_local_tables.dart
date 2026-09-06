import 'package:drift/drift.dart';

class MusicReleaseRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get barcode => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  DateTimeColumn get recordingDate => dateTime().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get releaseType => text().nullable()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get studio => text().nullable()();
  TextColumn get countryCode => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isLive => boolean().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MusicMediaRows extends Table {
  TextColumn get releaseId => text()();
  TextColumn get id => text()();
  IntColumn get mediaNumber => integer()();
  TextColumn get mediaCondition => text().nullable()();
  TextColumn get mediaType => text().nullable()();
  TextColumn get packaging => text().nullable()();
  IntColumn get rpm => integer().nullable()();
  TextColumn get soundType => text().nullable()();
  TextColumn get spars => text().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get trackCount => integer().nullable()();
  TextColumn get vinylColor => text().nullable()();
  TextColumn get vinylWeight => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {releaseId, id};
}

class MusicTrackRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get position => text()();
  TextColumn get title => text()();
  TextColumn get composition => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get instrument => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

class MusicOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get storageDevice => text().nullable()();
  TextColumn get storageSlot => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  DateTimeColumn get lastCleanedDate => dateTime().nullable()();
  TextColumn get matrixRunoutsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

/// Complete Music-owned copy state. The common ownership cache remains only
/// as a migration/read compatibility surface while callers are moved here.
class MusicOwnedItemsRows extends Table {
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
  TextColumn get storageDevice => text().nullable()();
  TextColumn get storageSlot => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  DateTimeColumn get lastCleanedDate => dateTime().nullable()();
  TextColumn get matrixRunoutsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}
