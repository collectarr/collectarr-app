import 'package:drift/drift.dart';

/// Complete Game-collection item state.
class GameCollectionItemsRows extends Table {
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
  TextColumn get completeness => text().nullable()();
  BoolColumn get hasBox => boolean().nullable()();
  BoolColumn get hasManual => boolean().nullable()();
  TextColumn get priceChartingId => text().nullable()();
  TextColumn get coreRegion => text().nullable()();
  BoolColumn get valueIsLocked => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class GameTrackingRows extends Table {
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
