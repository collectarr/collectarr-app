import 'package:drift/drift.dart';

/// Complete Comic-collection item state. Generic owned storage is retained only
/// as the kind-owned local persistence surface.
class ComicCollectionItemsRows extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isDigital => boolean().nullable()();
  TextColumn get condition => text().nullable()();
  TextColumn get grade => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get pricePaidCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get personalNotes => text().nullable()();
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
  TextColumn get collectionItemRefKey => text()();
  IntColumn get rating => integer().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {collectionItemRefKey};
}

class ComicTrackingUnitRows extends Table {
  TextColumn get id => text()();
  TextColumn get targetRefJson => text()();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get collectionItemRefKey => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get issueNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ComicTrackingRows extends Table {
  TextColumn get id => text()();
  TextColumn get catalogRefJson => text()();
  TextColumn get collectionItemRefKey => text().nullable()();
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
