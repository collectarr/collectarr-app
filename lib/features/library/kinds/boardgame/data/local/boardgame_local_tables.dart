import 'package:drift/drift.dart';

/// Complete BoardGame-owned copy state. Play sessions are tracking data and
/// remain in their dedicated table rather than being embedded in a copy.
class BoardGameOwnedItemsRows extends Table {
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

class BoardGameTrackingRows extends Table {
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
